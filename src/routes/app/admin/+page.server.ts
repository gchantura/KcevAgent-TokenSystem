import type { PageServerLoad } from './$types';
import { error, redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	// Check if user is platform admin
	const { data: profile } = await supabase
		.from('profiles')
		.select('is_platform_admin')
		.eq('id', user.id)
		.maybeSingle();

	if (!profile?.is_platform_admin) {
		error(403, 'Platform admin access required');
	}

	// Load all users/profiles
	const { data: profiles } = await supabase
		.from('profiles')
		.select('*')
		.order('created_at', { ascending: false });

	// Load all organizations
	const { data: organizations } = await supabase
		.from('organizations')
		.select(`
			*,
			organization_members(count)
		`)
		.order('created_at', { ascending: false });

	// Load recent audit logs
	const { data: auditLogs } = await supabase
		.from('audit_logs')
		.select('*, profiles:actor_id(display_name)')
		.order('created_at', { ascending: false })
		.limit(20);

	return {
		profiles: profiles ?? [],
		organizations: organizations ?? [],
		auditLogs: auditLogs ?? []
	};
};
