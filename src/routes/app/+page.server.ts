import type { PageServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	// Check if user has any organizations
	const { data: memberships } = await supabase
		.from('organization_members')
		.select('organizations(id, slug)')
		.eq('user_id', user.id)
		.eq('status', 'active')
		.limit(1);

	if (!memberships || memberships.length === 0) {
		redirect(303, '/app/onboarding');
	}

	// Redirect to first org
	const firstOrg = (memberships[0]?.organizations as { id: string; slug: string } | null);
	if (firstOrg?.slug) {
		redirect(303, `/app/org/${firstOrg.slug}`);
	}

	redirect(303, '/app/onboarding');
};
