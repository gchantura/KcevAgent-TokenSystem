import { fail } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
	resetPassword: async ({ request, locals: { supabase }, url }) => {
		const formData = await request.formData();
		const email = String(formData.get('email'));
		const redirectTo = `${url.origin}/auth/update-password`;

		const { error } = await supabase.auth.resetPasswordForEmail(email, { redirectTo });

		if (error) {
			return fail(400, { error: error.message });
		}

		return { success: true };
	}
};
