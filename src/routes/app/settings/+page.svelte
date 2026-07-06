<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageData, ActionData } from './$types';

	const { data, form }: { data: PageData; form: ActionData } = $props();
	let loading = $state(false);
	let displayName = $state('');
	let bio = $state('');

	$effect(() => {
		displayName = data.profile?.display_name ?? '';
		bio = data.profile?.bio ?? '';
	});
</script>

<!-- Header -->
<div class="page-header">
	<div class="page-header-breadcrumb">
		<span style="color:var(--text-primary);font-weight:600;">Settings</span>
	</div>
</div>

<div class="page-body">
	<div class="page-body-inner" style="max-width:560px;">

		{#if form?.error}
			<div class="alert alert-error" style="margin-bottom:16px;">{form.error}</div>
		{/if}
		{#if form?.success}
			<div class="alert alert-success" style="margin-bottom:16px;">Profile updated successfully.</div>
		{/if}

		<!-- Profile -->
		<div class="section-heading">
			<span class="section-title">Profile</span>
		</div>
		<div class="card" style="margin-bottom:20px;">
			<div class="card-body">
				<form
					method="POST"
					action="?/updateProfile"
					use:enhance={() => {
						loading = true;
						return async ({ update }) => { await update(); loading = false; };
					}}
					style="display:flex;flex-direction:column;gap:14px;"
				>
					<div class="form-group">
						<label class="form-label" for="display_name">Display name</label>
						<input
							id="display_name" name="display_name" type="text" required
							bind:value={displayName}
							class="form-input"
						/>
					</div>
					<div class="form-group">
						<label class="form-label" for="bio">Bio <span class="form-label-opt">(optional)</span></label>
						<textarea
							id="bio" name="bio"
							bind:value={bio}
							placeholder="Tell your team about yourself…"
							class="form-textarea"
						></textarea>
					</div>
					<div>
						<button type="submit" class="btn btn-primary" disabled={loading}>
							{loading ? 'Saving…' : 'Save changes'}
						</button>
					</div>
				</form>
			</div>
		</div>

		<!-- Account info -->
		<div class="section-heading">
			<span class="section-title">Account</span>
		</div>
		<div class="card">
			<div class="card-body" style="display:flex;flex-direction:column;gap:10px;">
				<div style="display:flex;flex-direction:column;gap:2px;">
					<p style="font-size:11px;font-weight:600;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.05em;">Email</p>
					<p style="font-size:13px;color:var(--text-primary);">{data.user?.email}</p>
				</div>
				<div style="display:flex;flex-direction:column;gap:2px;">
					<p style="font-size:11px;font-weight:600;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.05em;">User ID</p>
					<p class="mono" style="font-size:11px;color:var(--text-secondary);">{data.user?.id}</p>
				</div>
				{#if data.profile?.is_platform_admin}
					<div style="padding:8px 12px;border-radius:var(--radius-md);background:var(--accent-muted);display:inline-flex;align-items:center;gap:6px;width:fit-content;">
						<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" style="color:var(--accent);">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
						</svg>
						<span style="font-size:12px;font-weight:600;color:var(--accent);">Platform Administrator</span>
					</div>
				{/if}
			</div>
		</div>
	</div>
</div>
