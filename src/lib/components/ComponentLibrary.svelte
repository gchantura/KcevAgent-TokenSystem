<script lang="ts">
	import StatusBadge from './StatusBadge.svelte';
	import type { Component } from '$lib/supabase/types';

	const {
		components,
		dsId,
		orgSlug,
		projectSlug
	}: {
		components: Component[];
		dsId: string;
		orgSlug: string;
		projectSlug: string;
	} = $props();

	let searchQuery = $state('');
	let selectedCategory = $state('all');
	let selectedStatus = $state('all');
	let selectedComponent = $state<Component | null>(null);

	const categories = $derived(['all', ...new Set(components.map(c => c.category))]);
	const statuses = ['all', 'draft', 'review', 'approved', 'deprecated', 'needs-update'];

	const filtered = $derived(components.filter(c => {
		if (selectedCategory !== 'all' && c.category !== selectedCategory) return false;
		if (selectedStatus !== 'all' && c.status !== selectedStatus) return false;
		if (searchQuery && !c.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
		return true;
	}));

	const grouped = $derived(() => {
		const map = new Map<string, Component[]>();
		for (const c of filtered) {
			const list = map.get(c.category) ?? [];
			list.push(c);
			map.set(c.category, list);
		}
		return map;
	});

	const maturityIcon = {
		draft: '○',
		review: '◐',
		approved: '●',
		deprecated: '✕'
	};
</script>

<div class="flex flex-col h-full lg:flex-row">
	<!-- Left: component list -->
	<div class="flex-1 flex flex-col overflow-hidden">
		<!-- Filters -->
		<div class="bg-white border-b border-[#d9e4ff] px-4 py-3 flex flex-col gap-2">
			<div class="flex gap-2">
				<div class="relative flex-1">
					<svg class="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-[#9aa5b4]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
					</svg>
					<input
						bind:value={searchQuery}
						type="search"
						placeholder="Search components..."
						class="w-full pl-8 pr-3 py-1.5 text-xs border border-[#d9e4ff] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent bg-white"
					/>
				</div>
				<a
					href="/app/org/{orgSlug}/components/new?ds={dsId}"
					class="px-3 py-1.5 text-xs font-bold bg-[#004aff] text-white rounded-lg hover:bg-[#0040dd] transition-colors whitespace-nowrap"
				>
					+ Component
				</a>
			</div>
			<div class="flex gap-2 flex-wrap">
				<select
					bind:value={selectedCategory}
					class="text-xs border border-[#d9e4ff] rounded-lg px-2 py-1 bg-white focus:outline-none focus:ring-2 focus:ring-[#004aff]"
				>
					{#each categories as cat}
						<option value={cat}>{cat === 'all' ? 'All categories' : cat.charAt(0).toUpperCase() + cat.slice(1)}</option>
					{/each}
				</select>
				<select
					bind:value={selectedStatus}
					class="text-xs border border-[#d9e4ff] rounded-lg px-2 py-1 bg-white focus:outline-none focus:ring-2 focus:ring-[#004aff]"
				>
					{#each statuses as s}
						<option value={s}>{s === 'all' ? 'All statuses' : s.charAt(0).toUpperCase() + s.slice(1)}</option>
					{/each}
				</select>
			</div>
			<p class="text-[10px] text-[#9aa5b4]">{filtered.length} component{filtered.length !== 1 ? 's' : ''} shown</p>
		</div>

		<!-- Component grid -->
		<div class="flex-1 overflow-auto p-4">
			{#if components.length === 0}
				<div class="flex flex-col items-center justify-center h-full text-center py-16">
					<div class="w-12 h-12 rounded-xl bg-[#f5f7fa] flex items-center justify-center mb-3">
						<svg class="w-6 h-6 text-[#9aa5b4]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
						</svg>
					</div>
					<p class="text-sm font-bold text-[#1a1a1a] mb-1">No components yet</p>
					<p class="text-xs text-[#4a5568] mb-4">Add components to document your design system</p>
					<a
						href="/app/org/{orgSlug}/components/new?ds={dsId}"
						class="inline-flex items-center gap-1.5 px-4 py-2 bg-[#004aff] text-white text-xs font-bold rounded-lg hover:bg-[#0040dd] transition-colors"
					>
						Add component
					</a>
				</div>
			{:else if filtered.length === 0}
				<div class="text-center py-12">
					<p class="text-sm text-[#9aa5b4]">No components match your filters</p>
				</div>
			{:else}
				{#each grouped() as [category, comps]}
					<div class="mb-6">
						<h3 class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-3 px-1">
							{category}
						</h3>
						<div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
							{#each comps as component}
								<button
									onclick={() => selectedComponent = selectedComponent?.id === component.id ? null : component}
									class="text-left p-3 bg-white rounded-xl border transition-all hover:shadow-sm
										{selectedComponent?.id === component.id
											? 'border-[#004aff] ring-2 ring-[#004aff26]'
											: 'border-[#d9e4ff] hover:border-[#004aff]'}"
								>
									<!-- Component preview area -->
									<div class="h-16 rounded-lg bg-[#f8fafd] border border-[#d9e4ff] flex items-center justify-center mb-3">
										<span class="text-2xl text-[#9aa5b4]" aria-hidden="true">
											{maturityIcon[component.maturity as keyof typeof maturityIcon] ?? '○'}
										</span>
									</div>
									<div>
										<p class="text-xs font-bold text-[#1a1a1a] truncate">{component.name}</p>
										<div class="flex items-center gap-1 mt-1">
											<StatusBadge status={component.status} size="xs" />
										</div>
									</div>
								</button>
							{/each}
						</div>
					</div>
				{/each}
			{/if}
		</div>
	</div>

	<!-- Right: Component detail -->
	{#if selectedComponent}
		<div class="w-full lg:w-80 bg-white border-t lg:border-t-0 lg:border-l border-[#d9e4ff] flex flex-col overflow-hidden">
			<div class="flex items-center justify-between px-4 py-3 border-b border-[#d9e4ff]">
				<h3 class="text-sm font-bold text-[#1a1a1a]">Component detail</h3>
				<button
					onclick={() => selectedComponent = null}
					class="text-[#9aa5b4] hover:text-[#1a1a1a]"
					aria-label="Close"
				>
					<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
					</svg>
				</button>
			</div>

			<div class="flex-1 overflow-auto p-4 space-y-4">
				<div>
					<p class="text-base font-bold text-[#1a1a1a]">{selectedComponent.name}</p>
					<p class="text-xs text-[#9aa5b4] font-mono mt-0.5">{selectedComponent.slug}</p>
				</div>

				<div class="flex gap-2 flex-wrap">
					<StatusBadge status={selectedComponent.status} size="sm" />
					<StatusBadge status={selectedComponent.maturity} size="sm" />
					<span class="text-xs px-2 py-0.5 rounded-full bg-[#f5f7fa] text-[#4a5568] font-bold">{selectedComponent.category}</span>
				</div>

				{#if selectedComponent.description}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Description</p>
						<p class="text-xs text-[#4a5568]">{selectedComponent.description}</p>
					</div>
				{/if}

				{#if selectedComponent.usage_guidance}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Usage</p>
						<div class="p-2 rounded-lg bg-[#d3eedf] border border-[#86efac]">
							<p class="text-xs text-[#0e6b2c]">{selectedComponent.usage_guidance}</p>
						</div>
					</div>
				{/if}

				{#if selectedComponent.accessibility_guidance}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Accessibility</p>
						<p class="text-xs text-[#4a5568]">{selectedComponent.accessibility_guidance}</p>
					</div>
				{/if}

				{#if selectedComponent.code_reference}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Code reference</p>
						<code class="text-xs font-mono bg-[#f5f7fa] px-2 py-1 rounded">{selectedComponent.code_reference}</code>
					</div>
				{/if}

				<div class="border-t border-[#d9e4ff] pt-3">
					<p class="text-[10px] text-[#9aa5b4]">
						Updated {new Date(selectedComponent.updated_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
					</p>
				</div>

				<a
					href="/app/org/{orgSlug}/components/{selectedComponent.id}/edit"
					class="block w-full text-center py-2 px-4 border border-[#d9e4ff] rounded-lg text-xs font-bold text-[#004aff] hover:bg-[#eef2ff] transition-colors"
				>
					Edit component
				</a>
			</div>
		</div>
	{/if}
</div>
