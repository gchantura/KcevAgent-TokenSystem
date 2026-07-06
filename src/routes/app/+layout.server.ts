import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals: { safeGetSession, supabase } }) => {
	const { session, user } = await safeGetSession();

	if (!session || !user) {
		redirect(303, '/auth/sign-in');
	}

	// Load user's organizations
	const { data: memberships } = await supabase
		.from('organization_members')
		.select(`
			id,
			role_id,
			status,
			organizations (
				id,
				name,
				slug,
				logo_url,
				status
			),
			roles (
				id,
				name,
				slug
			)
		`)
		.eq('user_id', user.id)
		.eq('status', 'active')
		.order('joined_at', { ascending: true });

	// Load user profile
	const { data: profile } = await supabase
		.from('profiles')
		.select('*')
		.eq('id', user.id)
		.maybeSingle();

	return {
		session,
		user,
		profile,
		memberships: memberships ?? []
	};
};
