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

	const tabs = [
		{ id: 'tokens' as const, label: 'Tokens', count: collections.flatMap(c => c.design_tokens ?? []).length },
		{ id: 'components' as const, label: 'Components', count: components.length },
		{ id: 'releases' as const, label: 'Releases', count: releases.length }
	];
</script>

<div class="flex flex-col h-full">
	<!-- Header -->
	<div class="bg-white border-b border-[#d9e4ff] px-6 py-4">
		<div class="flex items-start justify-between gap-4">
			<div>
				<nav class="flex items-center gap-1 text-xs text-[#9aa5b4] mb-1">
					<a href="/app/org/{org.slug}" class="hover:text-[#004aff]">{org.name}</a>
					<span>/</span>
					<a href="/app/org/{org.slug}/projects/{project.slug}" class="hover:text-[#004aff]">{project.name}</a>
					<span>/</span>
					<span class="text-[#1a1a1a]">{ds.name}</span>
				</nav>
				<div class="flex items-center gap-3">
					<h1 class="text-xl font-bold text-[#1a1a1a]">{ds.name}</h1>
					<StatusBadge status={ds.maturity} size="sm" />
					<span class="text-xs text-[#9aa5b4]">v{ds.version}</span>
				</div>
				{#if ds.description}
					<p class="text-sm text-[#4a5568] mt-1">{ds.description}</p>
				{/if}
			</div>
			<div class="flex items-center gap-2 flex-shrink-0">
				<a
					href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}/settings"
					class="px-3 py-1.5 text-xs font-bold border border-[#d9e4ff] rounded-lg text-[#4a5568] hover:border-[#004aff] hover:text-[#004aff] transition-colors"
				>
					Settings
				</a>
			</div>
		</div>

		<!-- Tabs -->
		<div class="flex gap-0 mt-4 -mb-4 border-b border-transparent">
			{#each tabs as tab}
				<button
					onclick={() => activeTab = tab.id}
					class="flex items-center gap-1.5 px-4 py-2 text-sm font-medium border-b-2 transition-colors
						{activeTab === tab.id
							? 'border-[#004aff] text-[#004aff]'
							: 'border-transparent text-[#4a5568] hover:text-[#1a1a1a]'}"
				>
					{tab.label}
					{#if tab.count > 0}
						<span class="text-[10px] font-bold px-1.5 py-0.5 rounded-full
							{activeTab === tab.id ? 'bg-[#eef2ff] text-[#004aff]' : 'bg-[#f5f7fa] text-[#9aa5b4]'}">
							{tab.count}
						</span>
					{/if}
				</button>
			{/each}
		</div>
	</div>

	<!-- Tab content -->
	<div class="flex-1 overflow-auto">
		{#if activeTab === 'tokens'}
			<TokenExplorer {collections} {modes} dsId={ds.id} orgSlug={org.slug} projectSlug={project.slug} />
		{:else if activeTab === 'components'}
			<ComponentLibrary {components} dsId={ds.id} orgSlug={org.slug} projectSlug={project.slug} />
		{:else if activeTab === 'releases'}
			<div class="p-6 max-w-3xl mx-auto">
				<div class="flex items-center justify-between mb-4">
					<h2 class="text-base font-bold text-[#1a1a1a]">Releases</h2>
					<a
						href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}/releases/new"
						class="px-3 py-1.5 text-xs font-bold bg-[#004aff] text-white rounded-lg hover:bg-[#0040dd] transition-colors"
					>
						+ New release
					</a>
				</div>

				{#if releases.length === 0}
					<div class="bg-white rounded-xl border border-[#d9e4ff] p-8 text-center">
						<p class="text-sm text-[#9aa5b4]">No releases yet</p>
					</div>
				{:else}
					<div class="space-y-3">
						{#each releases as release}
							<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
								<div class="flex items-start justify-between gap-3">
									<div>
										<div class="flex items-center gap-2 mb-1">
											<span class="text-sm font-bold text-[#1a1a1a]">v{release.version}</span>
											{#if release.name}
												<span class="text-sm text-[#4a5568]">— {release.name}</span>
											{/if}
											<StatusBadge status={release.status} size="xs" />
										</div>
										{#if release.description}
											<p class="text-xs text-[#4a5568]">{release.description}</p>
										{/if}
										<p class="text-[10px] text-[#9aa5b4] mt-1">
											{new Date(release.created_at).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
										</p>
									</div>
								</div>
							</div>
						{/each}
					</div>
				{/if}
			</div>
		{/if}
	</div>
</div>
