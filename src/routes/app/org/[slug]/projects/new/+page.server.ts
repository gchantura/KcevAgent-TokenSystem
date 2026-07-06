import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');

	const { data: org } = await supabase
		.from('organizations')
		.select('id, name, slug')
		.eq('slug', params.slug)
		.maybeSingle();

	return { org };
};

export const actions: Actions = {
	default: async ({ request, params, locals: { safeGetSession, supabase } }) => {
		const { user } = await safeGetSession();
		if (!user) redirect(303, '/auth/sign-in');

		const formData = await request.formData();
		const name = String(formData.get('name') ?? '').trim();
		const description = String(formData.get('description') ?? '').trim();

		if (!name) return fail(400, { error: 'Project name is required.' });

		const { data: org } = await supabase
			.from('organizations')
			.select('id')
			.eq('slug', params.slug)
			.maybeSingle();
		if (!org) return fail(404, { error: 'Org not found' });

		const canCreate = await supabase.rpc('has_org_permission', {
			org_id: org.id,
			perm_key: 'projects:create'
		});
		if (!canCreate.data) return fail(403, { error: 'No permission to create projects.' });

		const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

		const { error: projectError } = await supabase
			.from('projects')
			.insert({ organization_id: org.id, name, slug, description: description || null, created_by: user.id });

		if (projectError) {
			const msg = projectError.code === '23505' ? 'A project with that name already exists.' : projectError.message;
			return fail(400, { error: msg });
		}

		redirect(303, `/app/org/${params.slug}/projects/${slug}`);
	}
};
