import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { session } }) => {
	if (session) {
		redirect(303, '/app');
	} else {
		redirect(303, '/auth/sign-in');
	}
};
