import { fail, redirect } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
	signUp: async ({ request, locals: { supabase } }) => {
		const formData = await request.formData();
		const email = String(formData.get('email'));
		const password = String(formData.get('password'));
		const display_name = String(formData.get('display_name'));

		if (password.length < 8) {
			return fail(400, { error: 'Password must be at least 8 characters.' });
		}

		const { error } = await supabase.auth.signUp({
			email,
			password,
			options: { data: { display_name } }
		});

		if (error) {
			return fail(400, { error: error.message });
		}

		redirect(303, '/app');
	}
};
