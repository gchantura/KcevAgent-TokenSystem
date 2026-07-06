import type { PageServerLoad } from './$types';
import { error, redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params, locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	// Get org
	const { data: org } = await supabase
		.from('organizations')
		.select('id, name, slug')
		.eq('slug', params.slug)
		.maybeSingle();
	if (!org) error(404, 'Organization not found');

	// Check membership
	const isMember = await supabase.rpc('is_org_member', { org_id: org.id });
	if (!isMember.data) error(403, 'Not a member');

	// Get project
	const { data: project } = await supabase
		.from('projects')
		.select('id, name, slug, organization_id')
		.eq('organization_id', org.id)
		.eq('slug', params.projectSlug)
		.maybeSingle();
	if (!project) error(404, 'Project not found');

	// Get design system
	const { data: ds } = await supabase
		.from('design_systems')
		.select('*')
		.eq('id', params.dsId)
		.eq('project_id', project.id)
		.maybeSingle();
	if (!ds) error(404, 'Design system not found');

	// Get token collections with tokens
	const { data: collections } = await supabase
		.from('token_collections')
		.select(`
			*,
			design_tokens(
				*,
				token_values(*)
			)
		`)
		.eq('design_system_id', ds.id)
		.order('sort_order');

	// Get components
	const { data: components } = await supabase
		.from('components')
		.select('*')
		.eq('design_system_id', ds.id)
		.order('name');

	// Get modes
	const { data: modes } = await supabase
		.from('design_system_modes')
		.select('*')
		.eq('design_system_id', ds.id);

	// Get releases
	const { data: releases } = await supabase
		.from('releases')
		.select('*')
		.eq('design_system_id', ds.id)
		.order('created_at', { ascending: false })
		.limit(5);

	return {
		org,
		project,
		ds,
		collections: collections ?? [],
		components: components ?? [],
		modes: modes ?? [],
		releases: releases ?? []
	};
};
