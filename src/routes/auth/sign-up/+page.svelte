<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	const { form }: { form: ActionData } = $props();
	let loading = $state(false);
</script>

<div class="auth-card">
	<div class="auth-logo">
		<div class="auth-logo-mark">
			<svg width="14" height="14" viewBox="0 0 16 16" fill="none">
				<rect x="2" y="2" width="5" height="5" rx="1" fill="white"/>
				<rect x="9" y="2" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
				<rect x="2" y="9" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
				<rect x="9" y="9" width="5" height="5" rx="1" fill="white"/>
			</svg>
		</div>
		<span style="font-size:14px;font-weight:700;color:var(--text-primary);">Atomic DSB</span>
	</div>

	<h1 class="auth-title">Create account</h1>
	<p class="auth-subtitle">Start building your design system today</p>

	{#if form?.error}
		<div class="alert alert-error" style="margin-bottom:16px;">{form.error}</div>
	{/if}
	{#if form?.success}
		<div class="alert alert-success" style="margin-bottom:16px;">Account created! You can now sign in.</div>
	{/if}

	<form
		method="POST"
		action="?/signUp"
		use:enhance={() => {
			loading = true;
			return async ({ update }) => { await update(); loading = false; };
		}}
		style="display:flex;flex-direction:column;gap:14px;"
	>
		<div class="form-group">
			<label class="form-label" for="display_name">Full name</label>
			<input
				id="display_name" name="display_name" type="text" required
				placeholder="Mara Hoffmann"
				class="form-input"
			/>
		</div>

		<div class="form-group">
			<label class="form-label" for="email">Email address</label>
			<input
				id="email" name="email" type="email" required
				autocomplete="email" placeholder="you@company.com"
				class="form-input"
			/>
		</div>

		<div class="form-group">
			<label class="form-label" for="password">Password <span class="form-label-opt">(min 8 chars)</span></label>
			<input
				id="password" name="password" type="password" required
				minlength={8} autocomplete="new-password" placeholder="Create a strong password"
				class="form-input"
			/>
		</div>

		<button type="submit" class="btn btn-primary btn-lg" disabled={loading} style="width:100%;margin-top:4px;">
			{loading ? 'Creating account…' : 'Create account'}
		</button>
	</form>

	<p class="auth-footer-link">
		Already have an account? <a href="/auth/sign-in">Sign in</a>
	</p>
</div>
