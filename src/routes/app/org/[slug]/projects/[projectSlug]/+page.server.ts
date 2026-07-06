import type { PageServerLoad, Actions } from './$types';
import { error, fail, redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params, locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	const { data: org } = await supabase
		.from('organizations')
		.select('id, name, slug')
		.eq('slug', params.slug)
		.maybeSingle();
	if (!org) error(404, 'Organization not found');

	const isMember = await supabase.rpc('is_org_member', { org_id: org.id });
	if (!isMember.data) error(403, 'Not a member');

	const { data: project } = await supabase
		.from('projects')
		.select('*')
		.eq('organization_id', org.id)
		.eq('slug', params.projectSlug)
		.maybeSingle();
	if (!project) error(404, 'Project not found');

	const { data: designSystems } = await supabase
		.from('design_systems')
		.select('*')
		.eq('project_id', project.id)
		.order('created_at');

	return { org, project, designSystems: designSystems ?? [] };
};

export const actions: Actions = {
	createDs: async ({ request, params, locals: { safeGetSession, supabase } }) => {
		const { user } = await safeGetSession();
		if (!user) redirect(303, '/auth/sign-in');

		const formData = await request.formData();
		const name = String(formData.get('name') ?? '').trim();

		if (!name) return fail(400, { error: 'Design system name is required.' });

		const { data: org } = await supabase
			.from('organizations')
			.select('id')
			.eq('slug', params.slug)
			.maybeSingle();
		if (!org) return fail(404, { error: 'Org not found' });

		const canCreate = await supabase.rpc('has_org_permission', {
			org_id: org.id,
			perm_key: 'design_systems:create'
		});
		if (!canCreate.data) return fail(403, { error: 'You do not have permission to create design systems.' });

		const { data: project } = await supabase
			.from('projects')
			.select('id')
			.eq('organization_id', org.id)
			.eq('slug', params.projectSlug)
			.maybeSingle();
		if (!project) return fail(404, { error: 'Project not found' });

		const { data: ds, error: dsError } = await supabase
			.from('design_systems')
			.insert({ project_id: project.id, name, created_by: user.id })
			.select()
			.single();

		if (dsError) return fail(400, { error: dsError.message });

		// Create default modes
		await supabase.from('design_system_modes').insert([
			{ design_system_id: ds.id, name: 'Light', slug: 'light', is_default: true },
			{ design_system_id: ds.id, name: 'Dark', slug: 'dark', is_default: false }
		]);

		// Create default token collections
		await supabase.from('token_collections').insert([
			{ design_system_id: ds.id, name: 'Color', slug: 'color', tier: 'primitive', sort_order: 0 },
			{ design_system_id: ds.id, name: 'Typography', slug: 'typography', tier: 'primitive', sort_order: 1 },
			{ design_system_id: ds.id, name: 'Spacing', slug: 'spacing', tier: 'primitive', sort_order: 2 },
			{ design_system_id: ds.id, name: 'Brand Colors', slug: 'brand-colors', tier: 'semantic', sort_order: 3 },
			{ design_system_id: ds.id, name: 'UI Tokens', slug: 'ui-tokens', tier: 'semantic', sort_order: 4 }
		]);

		// Log audit event
		await supabase.from('audit_logs').insert({
			organization_id: org.id,
			actor_id: user.id,
			action: 'created_design_system',
			resource_type: 'design_system',
			resource_id: ds.id,
			metadata: { name }
		});

		redirect(303, `/app/org/${params.slug}/projects/${params.projectSlug}/ds/${ds.id}`);
	}
};
