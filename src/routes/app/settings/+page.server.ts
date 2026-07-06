import { fail, redirect } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
	updateProfile: async ({ request, locals: { safeGetSession, supabase } }) => {
		const { user } = await safeGetSession();
		if (!user) redirect(303, '/auth/sign-in');

		const formData = await request.formData();
		const display_name = String(formData.get('display_name') ?? '').trim();
		const bio = String(formData.get('bio') ?? '').trim();

		if (!display_name) return fail(400, { error: 'Display name is required.' });

		const { error } = await supabase
			.from('profiles')
			.update({ display_name, bio: bio || null })
			.eq('id', user.id);

		if (error) return fail(500, { error: error.message });

		return { success: true };
	}
};
