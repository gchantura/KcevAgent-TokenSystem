<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	const { form }: { form: ActionData } = $props();
	let loading = $state(false);
</script>

<h1 class="text-2xl font-bold text-[#1a1a1a] mb-1">Reset password</h1>
<p class="text-sm text-[#4a5568] mb-6">We'll send a reset link to your email</p>

{#if form?.error}
	<div class="mb-4 p-3 rounded-lg bg-[#f9d3d8] border border-[#f9a8b4] text-[#600006] text-sm">
		{form.error}
	</div>
{/if}

{#if form?.success}
	<div class="mb-4 p-3 rounded-lg bg-[#d3eedf] border border-[#86efac] text-[#0e6b2c] text-sm">
		Check your email for a password reset link.
	</div>
{/if}

<form
	method="POST"
	action="?/resetPassword"
	use:enhance={() => {
		loading = true;
		return async ({ update }) => {
			await update();
			loading = false;
		};
	}}
	class="space-y-4"
>
	<div>
		<label for="email" class="block text-xs font-bold text-[#1a1a1a] mb-1">Email</label>
		<input
			id="email"
			name="email"
			type="email"
			required
			autocomplete="email"
			placeholder="you@example.com"
			class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] placeholder-[#9aa5b4] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all"
		/>
	</div>

	<button
		type="submit"
		disabled={loading}
		class="w-full py-2.5 px-4 bg-[#004aff] hover:bg-[#0040dd] disabled:bg-[#9ab3ff] text-white text-sm font-bold rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:ring-offset-2"
	>
		{loading ? 'Sending...' : 'Send reset link'}
	</button>
</form>

<p class="mt-6 text-center text-xs text-[#4a5568]">
	<a href="/auth/sign-in" class="text-[#004aff] font-bold hover:underline">Back to sign in</a>
</p>
