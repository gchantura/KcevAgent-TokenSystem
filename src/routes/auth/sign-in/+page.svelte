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

	<h1 class="auth-title">Sign in</h1>
	<p class="auth-subtitle">Sign in to your design system workspace</p>

	{#if form?.error}
		<div class="alert alert-error" style="margin-bottom:16px;">
			<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" style="flex-shrink:0;margin-top:1px;">
				<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
			</svg>
			{form.error}
		</div>
	{/if}

	<form
		method="POST"
		action="?/signIn"
		use:enhance={() => {
			loading = true;
			return async ({ update }) => { await update(); loading = false; };
		}}
		style="display:flex;flex-direction:column;gap:14px;"
	>
		<div class="form-group">
			<label class="form-label" for="email">Email address</label>
			<input
				id="email" name="email" type="email" required
				autocomplete="email" placeholder="you@company.com"
				class="form-input"
			/>
		</div>

		<div class="form-group">
			<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:5px;">
				<label class="form-label" for="password" style="margin-bottom:0;">Password</label>
				<a href="/auth/reset-password" style="font-size:11px;color:var(--accent);text-decoration:none;">Forgot?</a>
			</div>
			<input
				id="password" name="password" type="password" required
				autocomplete="current-password" placeholder="••••••••"
				class="form-input"
			/>
		</div>

		<button type="submit" class="btn btn-primary btn-lg" disabled={loading} style="width:100%;margin-top:4px;">
			{#if loading}
				<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" style="animation:spin 0.8s linear infinite;">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>
				</svg>
				Signing in…
			{:else}
				Sign in
			{/if}
		</button>
	</form>

	<p class="auth-footer-link">
		Don't have an account? <a href="/auth/sign-up">Create one</a>
	</p>
</div>
