import type { PageServerLoad, Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ locals: { safeGetSession, supabase } }) => {
	const { user } = await safeGetSession();
	if (!user) redirect(303, '/auth/sign-in');
	return {};
};

export const actions: Actions = {
	createOrg: async ({ request, locals: { safeGetSession, supabase } }) => {
		const { user } = await safeGetSession();
		if (!user) redirect(303, '/auth/sign-in');

		const formData = await request.formData();
		const name = String(formData.get('name') ?? '').trim();
		const description = String(formData.get('description') ?? '').trim();

		if (!name) return fail(400, { error: 'Organization name is required.' });

		const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

		// Create organization
		const { data: org, error: orgError } = await supabase
			.from('organizations')
			.insert({ name, slug, description: description || null, created_by: user.id })
			.select()
			.single();

		if (orgError) {
			const msg = orgError.code === '23505' ? 'An organization with that name already exists.' : orgError.message;
			return fail(400, { error: msg });
		}

		// Create default roles for this org
		const defaultRoles = [
			{ name: 'Owner', slug: 'owner', description: 'Full access to everything' },
			{ name: 'Admin', slug: 'admin', description: 'Manage members and settings' },
			{ name: 'Editor', slug: 'editor', description: 'Create and edit design system content' },
			{ name: 'Contributor', slug: 'contributor', description: 'Contribute changes for review' },
			{ name: 'Viewer', slug: 'viewer', description: 'View-only access' }
		];

		const { data: roles } = await supabase
			.from('roles')
			.insert(defaultRoles.map(r => ({ ...r, organization_id: org.id })))
			.select();

		const ownerRole = roles?.find(r => r.slug === 'owner');
		if (!ownerRole) return fail(500, { error: 'Failed to create roles.' });

		// Add creator as owner
		const { error: memberError } = await supabase
			.from('organization_members')
			.insert({ organization_id: org.id, user_id: user.id, role_id: ownerRole.id });

		if (memberError) return fail(500, { error: memberError.message });

		// Assign all permissions to owner role
		const { data: permissions } = await supabase.from('permissions').select('id');
		if (permissions && permissions.length > 0) {
			await supabase.from('role_permissions').insert(
				permissions.map(p => ({ role_id: ownerRole.id, permission_id: p.id, granted_by: user.id }))
			);
		}

		// Assign limited permissions to admin role
		const adminRole = roles?.find(r => r.slug === 'admin');
		if (adminRole) {
			const { data: adminPerms } = await supabase
				.from('permissions')
				.select('id')
				.in('key', ['members:manage', 'projects:create', 'projects:edit', 'design_systems:create', 'design_systems:edit', 'tokens:manage', 'components:manage', 'docs:manage', 'releases:create', 'audit:view']);
			if (adminPerms) {
				await supabase.from('role_permissions').insert(
					adminPerms.map(p => ({ role_id: adminRole.id, permission_id: p.id, granted_by: user.id }))
				);
			}
		}

		// Create default project
		const { data: project } = await supabase
			.from('projects')
			.insert({ organization_id: org.id, name: 'Main Project', slug: 'main', created_by: user.id })
			.select()
			.single();

		// Create default design system
		if (project) {
			await supabase
				.from('design_systems')
				.insert({ project_id: project.id, name: `${name} Design System`, created_by: user.id });
		}

		redirect(303, `/app/org/${slug}`);
	}
};
