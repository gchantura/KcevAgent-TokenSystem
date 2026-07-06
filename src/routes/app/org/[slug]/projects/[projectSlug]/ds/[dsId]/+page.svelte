<script lang="ts">
	import type { PageData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';
	import TokenExplorer from '$lib/components/TokenExplorer.svelte';
	import ComponentLibrary from '$lib/components/ComponentLibrary.svelte';

	const { data }: { data: PageData } = $props();
	const org = $derived(data.org);
	const project = $derived(data.project);
	const ds = $derived(data.ds);
	const collections = $derived(data.collections);
	const components = $derived(data.components);
	const modes = $derived(data.modes);
	const releases = $derived(data.releases);

	let activeTab = $state<'tokens' | 'components' | 'releases'>('tokens');

	const tabs = $derived([
		{ id: 'tokens' as const, label: 'Tokens', count: collections.flatMap(c => c.design_tokens ?? []).length },
		{ id: 'components' as const, label: 'Components', count: components.length },
		{ id: 'releases' as const, label: 'Releases', count: releases.length }
	]);
</script>

<!-- Header -->
<div class="page-header">
	<div class="page-header-breadcrumb">
		<a href="/app/org/{org.slug}">{org.name}</a>
		<span class="sep">/</span>
		<a href="/app/org/{org.slug}/projects/{project.slug}">{project.name}</a>
		<span class="sep">/</span>
		<span style="color:var(--text-primary);font-weight:600;">{ds.name}</span>
	</div>
	<div style="display:flex;align-items:center;gap:8px;margin:0 auto 0 12px;">
		<StatusBadge status={ds.maturity} size="xs" />
		<span class="mono" style="font-size:11px;color:var(--text-muted);">v{ds.version}</span>
	</div>
	<div class="page-header-actions">
		<button class="btn btn-secondary btn-sm">
			<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
			</svg>
			Settings
		</button>
	</div>
</div>

<!-- Tabs -->
<div class="tabs">
	{#each tabs as tab}
		<button
			class="tab {activeTab === tab.id ? 'active' : ''}"
			onclick={() => activeTab = tab.id}
		>
			{tab.label}
			{#if tab.count > 0}
				<span class="tab-count">{tab.count}</span>
			{/if}
		</button>
	{/each}
</div>

<!-- Tab content -->
<div style="flex:1;overflow:hidden;display:flex;flex-direction:column;">
	{#if activeTab === 'tokens'}
		<TokenExplorer
			{collections} {modes}
			dsId={ds.id}
			orgSlug={org.slug}
			projectSlug={project.slug}
		/>
	{:else if activeTab === 'components'}
		<ComponentLibrary
			{components}
			dsId={ds.id}
			orgSlug={org.slug}
			projectSlug={project.slug}
		/>
	{:else if activeTab === 'releases'}
		<div class="page-body">
			<div class="page-body-inner" style="max-width:720px;">
				<div class="section-heading">
					<span class="section-title">Releases</span>
					<button class="btn btn-primary btn-sm">
						<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/>
						</svg>
						New release
					</button>
				</div>

				{#if releases.length === 0}
					<div class="card">
						<div class="empty-state">
							<div class="empty-icon">
								<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z"/>
								</svg>
							</div>
							<p class="empty-title">No releases yet</p>
							<p class="empty-desc">Create your first release to track design system versions.</p>
						</div>
					</div>
				{:else}
					<div class="card">
						<table class="data-table">
							<thead>
								<tr>
									<th>Version</th>
									<th>Name</th>
									<th>Status</th>
									<th>Released</th>
								</tr>
							</thead>
							<tbody>
								{#each releases as r}
									<tr>
										<td><span class="mono" style="font-weight:600;">v{r.version}</span></td>
										<td style="color:var(--text-secondary);">{r.name ?? '—'}</td>
										<td><StatusBadge status={r.status} size="xs" /></td>
										<td style="color:var(--text-muted);font-size:11px;">
											{r.published_at ? new Date(r.published_at).toLocaleDateString('en-US',{month:'short',day:'numeric',year:'numeric'}) : 'Not published'}
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				{/if}
			</div>
		</div>
	{/if}
</div>
