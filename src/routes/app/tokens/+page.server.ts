import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	// Redirect to first org's design systems
	const { data: memberships } = await supabase
		.from('organization_members')
		.select('organizations(id, slug)')
		.eq('user_id', user.id)
		.eq('status', 'active')
		.limit(1);

	const firstOrg = memberships?.[0]?.organizations as { id: string; slug: string } | null;
	if (firstOrg?.slug) {
		redirect(303, `/app/org/${firstOrg.slug}`);
	}
	redirect(303, '/app/onboarding');
};
