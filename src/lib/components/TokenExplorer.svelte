<script lang="ts">
	import StatusBadge from './StatusBadge.svelte';
	import type { TokenCollection, DesignToken, TokenValue, DesignSystemMode } from '$lib/supabase/types';

	type TokenWithValues = DesignToken & { token_values: TokenValue[] };
	type CollectionWithTokens = TokenCollection & { design_tokens: TokenWithValues[] };

	const {
		collections,
		modes,
		dsId,
		orgSlug,
		projectSlug
	}: {
		collections: CollectionWithTokens[];
		modes: DesignSystemMode[];
		dsId: string;
		orgSlug: string;
		projectSlug: string;
	} = $props();

	let searchQuery = $state('');
	let selectedType = $state('all');
	let selectedStatus = $state('all');
	let selectedTier = $state('all');
	let selectedToken = $state<TokenWithValues | null>(null);
	let expandedCollections = $state<Set<string>>(new Set<string>());
	$effect(() => { expandedCollections = new Set(collections.map(c => c.id)); });

	const tokenTypes = ['all', 'color', 'typography', 'spacing', 'sizing', 'border', 'shadow', 'opacity', 'duration', 'other'];
	const statuses = ['all', 'draft', 'active', 'deprecated', 'archived'];
	const tiers = ['all', 'primitive', 'semantic', 'component', 'custom'];

	const tierColors = {
		primitive: 'bg-[#eef2ff] text-[#004aff]',
		semantic: 'bg-[#ffecc2] text-[#7d5e00]',
		component: 'bg-[#d3eedf] text-[#0e6b2c]',
		custom: 'bg-[#f5f7fa] text-[#4a5568]'
	};

	function matchesFilter(token: TokenWithValues) {
		if (selectedType !== 'all' && token.token_type !== selectedType) return false;
		if (selectedStatus !== 'all' && token.status !== selectedStatus) return false;
		if (searchQuery && !token.name.toLowerCase().includes(searchQuery.toLowerCase()) && !token.path.toLowerCase().includes(searchQuery.toLowerCase())) return false;
		return true;
	}

	function getFilteredTokens(collection: CollectionWithTokens) {
		if (selectedTier !== 'all' && collection.tier !== selectedTier) return [];
		return (collection.design_tokens ?? []).filter(matchesFilter);
	}

	const totalVisible = $derived(collections.reduce((sum, c) => sum + getFilteredTokens(c).length, 0));

	function toggleCollection(id: string) {
		const next = new Set(expandedCollections);
		if (next.has(id)) next.delete(id);
		else next.add(id);
		expandedCollections = next;
	}

	function getDefaultValue(token: TokenWithValues) {
		const defaultMode = modes.find(m => m.is_default);
		const val = token.token_values?.find(v => v.mode_id === (defaultMode?.id ?? null)) ?? token.token_values?.[0];
		return val?.raw_value ?? '—';
	}

	function isColor(token: TokenWithValues) {
		return token.token_type === 'color';
	}

	function looksLikeColor(value: string) {
		return /^#[0-9a-f]{3,8}$/i.test(value) || /^rgb/.test(value) || /^hsl/.test(value);
	}
</script>

<div class="flex flex-col h-full lg:flex-row">
	<!-- Left: Token list -->
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
						placeholder="Search tokens..."
						class="w-full pl-8 pr-3 py-1.5 text-xs border border-[#d9e4ff] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent bg-white"
					/>
				</div>
				<a
					href="/app/org/{orgSlug}/tokens/new?ds={dsId}"
					class="px-3 py-1.5 text-xs font-bold bg-[#004aff] text-white rounded-lg hover:bg-[#0040dd] transition-colors whitespace-nowrap"
				>
					+ Token
				</a>
			</div>
			<div class="flex gap-2 flex-wrap">
				<select
					bind:value={selectedTier}
					class="text-xs border border-[#d9e4ff] rounded-lg px-2 py-1 bg-white focus:outline-none focus:ring-2 focus:ring-[#004aff]"
				>
					{#each tiers as t}
						<option value={t}>{t === 'all' ? 'All tiers' : t.charAt(0).toUpperCase() + t.slice(1)}</option>
					{/each}
				</select>
				<select
					bind:value={selectedType}
					class="text-xs border border-[#d9e4ff] rounded-lg px-2 py-1 bg-white focus:outline-none focus:ring-2 focus:ring-[#004aff]"
				>
					{#each tokenTypes as t}
						<option value={t}>{t === 'all' ? 'All types' : t.charAt(0).toUpperCase() + t.slice(1)}</option>
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
			<p class="text-[10px] text-[#9aa5b4]">{totalVisible} token{totalVisible !== 1 ? 's' : ''} shown</p>
		</div>

		<!-- Collections and tokens -->
		<div class="flex-1 overflow-auto">
			{#if collections.length === 0}
				<div class="p-8 text-center">
					<div class="w-12 h-12 rounded-xl bg-[#f5f7fa] flex items-center justify-center mx-auto mb-3">
						<svg class="w-6 h-6 text-[#9aa5b4]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z"/>
						</svg>
					</div>
					<p class="text-sm font-bold text-[#1a1a1a] mb-1">No token collections</p>
					<p class="text-xs text-[#4a5568] mb-4">Create your first token collection to start organizing your design tokens</p>
					<a
						href="/app/org/{orgSlug}/tokens/new?ds={dsId}"
						class="inline-flex items-center gap-1.5 px-4 py-2 bg-[#004aff] text-white text-xs font-bold rounded-lg hover:bg-[#0040dd] transition-colors"
					>
						Add token
					</a>
				</div>
			{:else}
				{#each collections as collection}
					{@const filteredTokens = getFilteredTokens(collection)}
					{#if selectedTier === 'all' || collection.tier === selectedTier}
						<div class="border-b border-[#d9e4ff]">
							<!-- Collection header -->
							<button
								onclick={() => toggleCollection(collection.id)}
								class="w-full flex items-center gap-2 px-4 py-2.5 bg-[#f8fafd] hover:bg-[#f0f4fd] transition-colors text-left"
							>
								<svg
									class="w-3.5 h-3.5 text-[#9aa5b4] transition-transform {expandedCollections.has(collection.id) ? '' : '-rotate-90'}"
									fill="none" stroke="currentColor" viewBox="0 0 24 24"
								>
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
								</svg>
								<span class="text-xs font-bold text-[#1a1a1a]">{collection.name}</span>
								<span class="text-[10px] px-1.5 py-0.5 rounded-full font-bold {tierColors[collection.tier as keyof typeof tierColors]}">
									{collection.tier}
								</span>
								<span class="ml-auto text-[10px] text-[#9aa5b4]">{filteredTokens.length} tokens</span>
							</button>

							<!-- Tokens -->
							{#if expandedCollections.has(collection.id)}
								{#if filteredTokens.length === 0}
									<div class="px-4 py-3 text-xs text-[#9aa5b4] italic">No tokens match the current filters</div>
								{:else}
									{#each filteredTokens as token}
										<button
											onclick={() => selectedToken = selectedToken?.id === token.id ? null : token}
											class="w-full flex items-center gap-3 px-4 py-2.5 hover:bg-[#f5f7fa] transition-colors text-left border-t border-[#f0f4fd]
												{selectedToken?.id === token.id ? 'bg-[#eef2ff] border-l-2 border-l-[#004aff]' : ''}"
										>
											<!-- Color swatch or type icon -->
											<div class="w-6 h-6 rounded flex-shrink-0 flex items-center justify-center">
												{#if isColor(token) && looksLikeColor(getDefaultValue(token))}
													<div
														class="w-5 h-5 rounded border border-[#c7d2e1]"
														style="background-color: {getDefaultValue(token)}"
													></div>
												{:else}
													<span class="text-[10px] font-bold text-[#9aa5b4] uppercase">{token.token_type.slice(0, 2)}</span>
												{/if}
											</div>

											<div class="flex-1 min-w-0">
												<p class="text-xs font-bold text-[#1a1a1a] truncate">{token.name}</p>
												<p class="text-[10px] text-[#9aa5b4] truncate font-mono">{token.path}</p>
											</div>

											<div class="flex items-center gap-2 flex-shrink-0">
												<span class="text-xs text-[#4a5568] font-mono">{getDefaultValue(token)}</span>
												<StatusBadge status={token.status} size="xs" />
											</div>
										</button>
									{/each}
								{/if}
							{/if}
						</div>
					{/if}
				{/each}
			{/if}
		</div>
	</div>

	<!-- Right: Token detail panel -->
	{#if selectedToken}
		<div class="w-full lg:w-80 bg-white border-t lg:border-t-0 lg:border-l border-[#d9e4ff] flex flex-col overflow-hidden">
			<div class="flex items-center justify-between px-4 py-3 border-b border-[#d9e4ff]">
				<h3 class="text-sm font-bold text-[#1a1a1a]">Token detail</h3>
				<button
					onclick={() => selectedToken = null}
					class="text-[#9aa5b4] hover:text-[#1a1a1a]"
					aria-label="Close"
				>
					<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
					</svg>
				</button>
			</div>

			<div class="flex-1 overflow-auto p-4 space-y-4">
				<!-- Preview -->
				{#if isColor(selectedToken) && looksLikeColor(getDefaultValue(selectedToken))}
					<div
						class="w-full h-24 rounded-xl border border-[#c7d2e1]"
						style="background-color: {getDefaultValue(selectedToken)}"
					></div>
				{/if}

				<!-- Name & path -->
				<div>
					<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Token</p>
					<p class="text-base font-bold text-[#1a1a1a]">{selectedToken.name}</p>
					<p class="text-xs font-mono text-[#004aff] mt-0.5">{selectedToken.path}</p>
				</div>

				<!-- Status & type -->
				<div class="flex gap-2">
					<StatusBadge status={selectedToken.status} size="sm" />
					<span class="text-xs px-2 py-0.5 rounded-full bg-[#f5f7fa] text-[#4a5568] font-bold">{selectedToken.token_type}</span>
					{#if selectedToken.is_alias}
						<span class="text-xs px-2 py-0.5 rounded-full bg-[#ffecc2] text-[#7d5e00] font-bold">alias</span>
					{/if}
				</div>

				<!-- Values per mode -->
				{#if selectedToken.token_values && selectedToken.token_values.length > 0}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-2">Values</p>
						<div class="space-y-1.5">
							{#each selectedToken.token_values as val}
								{@const modeName = modes.find(m => m.id === val.mode_id)?.name ?? 'Default'}
								<div class="flex items-center justify-between p-2 rounded-lg bg-[#f8fafd] border border-[#d9e4ff]">
									<span class="text-xs text-[#4a5568]">{modeName}</span>
									<div class="flex items-center gap-2">
										{#if isColor(selectedToken) && looksLikeColor(val.raw_value)}
											<div class="w-4 h-4 rounded border border-[#c7d2e1]" style="background-color: {val.raw_value}"></div>
										{/if}
										<span class="text-xs font-mono text-[#1a1a1a] font-bold">{val.raw_value}</span>
									</div>
								</div>
							{/each}
						</div>
					</div>
				{/if}

				<!-- Description -->
				{#if selectedToken.description}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Description</p>
						<p class="text-xs text-[#4a5568]">{selectedToken.description}</p>
					</div>
				{/if}

				<!-- Usage guidance -->
				{#if selectedToken.usage_guidance}
					<div>
						<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Usage</p>
						<div class="p-2 rounded-lg bg-[#d3eedf] border border-[#86efac]">
							<p class="text-xs text-[#0e6b2c]">{selectedToken.usage_guidance}</p>
						</div>
					</div>
				{/if}

				<!-- Timestamps -->
				<div class="border-t border-[#d9e4ff] pt-3">
					<p class="text-[10px] text-[#9aa5b4]">
						Created {new Date(selectedToken.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
					</p>
					{#if selectedToken.updated_at !== selectedToken.created_at}
						<p class="text-[10px] text-[#9aa5b4]">
							Updated {new Date(selectedToken.updated_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
						</p>
					{/if}
				</div>

				<!-- Edit button -->
				<a
					href="/app/org/{orgSlug}/tokens/{selectedToken.id}/edit"
					class="block w-full text-center py-2 px-4 border border-[#d9e4ff] rounded-lg text-xs font-bold text-[#004aff] hover:bg-[#eef2ff] transition-colors"
				>
					Edit token
				</a>
			</div>
		</div>
	{/if}
</div>
