<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageData, ActionData } from './$types';

	const { data, form }: { data: PageData; form: ActionData } = $props();
	let loading = $state(false);
</script>

<!-- Header -->
<div class="page-header">
	<div class="page-header-breadcrumb">
		<a href="/app/org/{data.org?.slug}">{data.org?.name}</a>
		<span class="sep">/</span>
		<span style="color:var(--text-primary);font-weight:600;">New project</span>
	</div>
</div>

<div class="page-body">
	<div class="page-body-inner" style="max-width:480px;">
		<h1 style="font-size:16px;font-weight:700;color:var(--text-primary);margin-bottom:20px;">Create project</h1>

		{#if form?.error}
			<div class="alert alert-error" style="margin-bottom:16px;">{form.error}</div>
		{/if}

		<div class="card">
			<div class="card-body">
				<form
					method="POST"
					use:enhance={() => {
						loading = true;
						return async ({ update }) => { await update(); loading = false; };
					}}
					style="display:flex;flex-direction:column;gap:14px;"
				>
					<div class="form-group">
						<label class="form-label" for="name">Project name</label>
						<input id="name" name="name" type="text" required placeholder="Web Application" class="form-input" />
					</div>
					<div class="form-group">
						<label class="form-label" for="description">Description <span class="form-label-opt">(optional)</span></label>
						<textarea id="description" name="description" placeholder="What does this project cover?" class="form-textarea"></textarea>
					</div>
					<div style="display:flex;gap:8px;">
						<a href="/app/org/{data.org?.slug}" class="btn btn-secondary" style="flex:1;justify-content:center;">Cancel</a>
						<button type="submit" class="btn btn-primary" disabled={loading} style="flex:1;">
							{loading ? 'Creating…' : 'Create project'}
						</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>
