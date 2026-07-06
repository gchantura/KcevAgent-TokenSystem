import type { PageServerLoad } from './$types';
import { error, redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params, locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	// Get org by slug
	const { data: org } = await supabase
		.from('organizations')
		.select('*')
		.eq('slug', params.slug)
		.maybeSingle();

	if (!org) error(404, 'Organization not found');

	// Check membership
	const { data: membership } = await supabase
		.from('organization_members')
		.select('*, roles(*)')
		.eq('organization_id', org.id)
		.eq('user_id', user.id)
		.eq('status', 'active')
		.maybeSingle();

	if (!membership) error(403, 'You are not a member of this organization');

	// Load projects with design system counts
	const { data: projects } = await supabase
		.from('projects')
		.select(`
			*,
			design_systems(
				id, name, maturity, version,
				design_tokens(count),
				components(count)
			)
		`)
		.eq('organization_id', org.id)
		.eq('status', 'active')
		.order('created_at', { ascending: true });

	// Load recent audit logs
	const { data: auditLogs } = await supabase
		.from('audit_logs')
		.select('*, profiles:actor_id(display_name, avatar_url)')
		.eq('organization_id', org.id)
		.order('created_at', { ascending: false })
		.limit(10);

	// Stats
	const allDs = (projects ?? []).flatMap(p => (p.design_systems as unknown[]) ?? []) as {
		id: string; maturity: string;
		design_tokens: { count: number }[];
		components: { count: number }[];
	}[];

	const stats = {
		projectCount: (projects ?? []).length,
		designSystemCount: allDs.length,
		tokenCount: allDs.reduce((sum, ds) => sum + (ds.design_tokens?.[0]?.count ?? 0), 0),
		componentCount: allDs.reduce((sum, ds) => sum + (ds.components?.[0]?.count ?? 0), 0),
		maturityBreakdown: {
			draft: allDs.filter(ds => ds.maturity === 'draft').length,
			review: allDs.filter(ds => ds.maturity === 'review').length,
			approved: allDs.filter(ds => ds.maturity === 'approved').length,
			deprecated: allDs.filter(ds => ds.maturity === 'deprecated').length
		}
	};

	return { org, membership, projects: projects ?? [], auditLogs: auditLogs ?? [], stats };
};
