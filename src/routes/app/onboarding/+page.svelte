<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	const { form }: { form: ActionData } = $props();
	let loading = $state(false);
</script>

<div class="page-body" style="display:flex;align-items:center;justify-content:center;">
	<div style="width:100%;max-width:460px;padding:32px 24px;">
		<div style="text-align:center;margin-bottom:28px;">
			<div style="width:40px;height:40px;background:var(--accent);border-radius:var(--radius-lg);display:flex;align-items:center;justify-content:center;margin:0 auto 12px;">
				<svg width="20" height="20" viewBox="0 0 16 16" fill="none">
					<rect x="2" y="2" width="5" height="5" rx="1" fill="white"/>
					<rect x="9" y="2" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
					<rect x="2" y="9" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
					<rect x="9" y="9" width="5" height="5" rx="1" fill="white"/>
				</svg>
			</div>
			<h1 style="font-size:18px;font-weight:700;color:var(--text-primary);margin-bottom:4px;">Create your workspace</h1>
			<p style="font-size:12px;color:var(--text-secondary);">Set up an organization to manage your design systems</p>
		</div>

		<div class="card">
			<div class="card-body">
				{#if form?.error}
					<div class="alert alert-error" style="margin-bottom:16px;">{form.error}</div>
				{/if}

				<form
					method="POST"
					action="?/createOrg"
					use:enhance={() => {
						loading = true;
						return async ({ update }) => { await update(); loading = false; };
					}}
					style="display:flex;flex-direction:column;gap:16px;"
				>
					<div class="form-group">
						<label class="form-label" for="name">Organization name</label>
						<input
							id="name" name="name" type="text" required
							placeholder="Acme Corp"
							class="form-input"
						/>
						<p class="form-hint">Your team's workspace for design system work</p>
					</div>

					<div class="form-group">
						<label class="form-label" for="description">Description <span class="form-label-opt">(optional)</span></label>
						<input
							id="description" name="description" type="text"
							placeholder="What does your team build?"
							class="form-input"
						/>
					</div>

					<button type="submit" class="btn btn-primary" disabled={loading} style="width:100%;padding:8px 16px;font-size:13px;">
						{loading ? 'Creating workspace…' : 'Create workspace'}
					</button>
				</form>
			</div>
		</div>
	</div>
</div>
