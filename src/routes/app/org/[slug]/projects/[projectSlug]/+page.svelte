<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageData, ActionData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data, form }: { data: PageData; form: ActionData } = $props();
	const org = $derived(data.org);
	const project = $derived(data.project);
	const designSystems = $derived(data.designSystems);

	let showCreate = $state(false);
	let loading = $state(false);
</script>

<!-- Header -->
<div class="page-header">
	<div class="page-header-breadcrumb">
		<a href="/app/org/{org.slug}">{org.name}</a>
		<span class="sep">/</span>
		<span style="color:var(--text-primary);font-weight:600;">{project.name}</span>
	</div>
	<div class="page-header-actions">
		<button class="btn btn-primary btn-sm" onclick={() => showCreate = true}>
			<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/>
			</svg>
			New design system
		</button>
	</div>
</div>

<div class="page-body">
	<div class="page-body-inner">

		{#if form?.error}
			<div class="alert alert-error" style="margin-bottom:16px;">{form.error}</div>
		{/if}

		<div class="section-heading">
			<span class="section-title">Design systems</span>
		</div>

		{#if designSystems.length === 0}
			<div class="card">
				<div class="empty-state">
					<div class="empty-icon">
						<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"/>
						</svg>
					</div>
					<p class="empty-title">No design systems yet</p>
					<p class="empty-desc">Create your first design system to start managing tokens and components.</p>
					<button class="btn btn-primary btn-sm" onclick={() => showCreate = true}>Create design system</button>
				</div>
			</div>
		{:else}
			<div class="card">
				<table class="data-table">
					<thead>
						<tr>
							<th>Name</th>
							<th>Version</th>
							<th>Maturity</th>
							<th>Updated</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
						{#each designSystems as ds}
							<tr>
								<td>
									<a href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}" style="font-size:12px;font-weight:600;color:var(--accent);text-decoration:none;">
										{ds.name}
									</a>
									{#if ds.description}
										<p style="font-size:11px;color:var(--text-muted);margin-top:1px;">{ds.description}</p>
									{/if}
								</td>
								<td><span class="mono" style="font-size:11px;color:var(--text-muted);">v{ds.version}</span></td>
								<td><StatusBadge status={ds.maturity} size="xs" /></td>
								<td style="font-size:11px;color:var(--text-muted);">
									{new Date(ds.updated_at).toLocaleDateString('en-US',{month:'short',day:'numeric'})}
								</td>
								<td>
									<a href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}" class="btn btn-secondary btn-sm">Open</a>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>

<!-- Create modal -->
{#if showCreate}
	<div class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="create-ds-title">
		<div class="modal">
			<div class="modal-header">
				<h2 class="modal-title" id="create-ds-title">Create design system</h2>
				<button class="btn btn-ghost btn-sm" onclick={() => showCreate = false} aria-label="Close" style="padding:2px 4px;">
					<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
					</svg>
				</button>
			</div>
			<form
				method="POST"
				action="?/createDs"
				use:enhance={() => {
					loading = true;
					return async ({ update }) => { await update(); loading = false; showCreate = false; };
				}}
			>
				<div class="modal-body" style="display:flex;flex-direction:column;gap:14px;">
					<div class="form-group">
						<label class="form-label" for="ds-name">Name</label>
						<input id="ds-name" name="name" type="text" required placeholder="My Design System" class="form-input" />
					</div>
					<div class="form-group">
						<label class="form-label" for="ds-desc">Description <span class="form-label-opt">(optional)</span></label>
						<input id="ds-desc" name="description" type="text" placeholder="What is this design system for?" class="form-input" />
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" onclick={() => showCreate = false}>Cancel</button>
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{loading ? 'Creating…' : 'Create'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}
