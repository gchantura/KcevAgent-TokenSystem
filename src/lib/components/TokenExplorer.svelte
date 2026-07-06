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

	function matches(token: TokenWithValues) {
		if (selectedType !== 'all' && token.token_type !== selectedType) return false;
		if (selectedStatus !== 'all' && token.status !== selectedStatus) return false;
		if (searchQuery) {
			const q = searchQuery.toLowerCase();
			return token.name.toLowerCase().includes(q) || token.path.toLowerCase().includes(q);
		}
		return true;
	}

	function getFiltered(collection: CollectionWithTokens) {
		if (selectedTier !== 'all' && collection.tier !== selectedTier) return [];
		return (collection.design_tokens ?? []).filter(matches);
	}

	const totalVisible = $derived(collections.reduce((s, c) => s + getFiltered(c).length, 0));

	function toggleCol(id: string) {
		const n = new Set(expandedCollections);
		if (n.has(id)) n.delete(id); else n.add(id);
		expandedCollections = n;
	}

	function defaultVal(token: TokenWithValues) {
		const def = modes.find(m => m.is_default);
		const v = token.token_values?.find(v => v.mode_id === (def?.id ?? null)) ?? token.token_values?.[0];
		return v?.raw_value ?? '—';
	}

	function isColor(t: TokenWithValues) { return t.token_type === 'color'; }
	function looksColor(v: string) { return /^#[0-9a-f]{3,8}$/i.test(v) || /^rgb/.test(v) || /^hsl/.test(v); }
</script>

<div class="token-explorer" style="flex:1;overflow:hidden;">

	<!-- Left panel -->
	<div class="token-list-panel">

		<!-- Filter bar -->
		<div class="filter-bar">
			<div class="search-input-wrap">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
					<circle cx="11" cy="11" r="8"/><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-4.35-4.35"/>
				</svg>
				<input
					bind:value={searchQuery}
					type="search"
					placeholder="Search tokens…"
					class="search-input"
				/>
			</div>
			<select bind:value={selectedTier} class="filter-select">
				{#each tiers as t}
					<option value={t}>{t === 'all' ? 'All tiers' : t[0].toUpperCase() + t.slice(1)}</option>
				{/each}
			</select>
			<select bind:value={selectedType} class="filter-select">
				{#each tokenTypes as t}
					<option value={t}>{t === 'all' ? 'All types' : t[0].toUpperCase() + t.slice(1)}</option>
				{/each}
			</select>
			<select bind:value={selectedStatus} class="filter-select">
				{#each statuses as s}
					<option value={s}>{s === 'all' ? 'All statuses' : s[0].toUpperCase() + s.slice(1)}</option>
				{/each}
			</select>
			<span class="filter-count">{totalVisible} token{totalVisible !== 1 ? 's' : ''}</span>
			<a href="/app/org/{orgSlug}/tokens/new?ds={dsId}" class="btn btn-primary btn-sm" style="margin-left:auto;">
				<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/>
				</svg>
				Add token
			</a>
		</div>

		<!-- Collections -->
		<div style="flex:1;overflow-y:auto;">
			{#if collections.length === 0}
				<div class="empty-state">
					<div class="empty-icon">
						<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z"/>
						</svg>
					</div>
					<p class="empty-title">No token collections</p>
					<p class="empty-desc">Add token collections to start organizing your design tokens.</p>
					<a href="/app/org/{orgSlug}/tokens/new?ds={dsId}" class="btn btn-primary btn-sm">Add first token</a>
				</div>
			{:else}
				{#each collections as collection}
					{@const filtered = getFiltered(collection)}
					{#if selectedTier === 'all' || collection.tier === selectedTier}
						<!-- Collection header -->
						<button
							class="collection-header"
							onclick={() => toggleCol(collection.id)}
						>
							<svg
								class="collection-chevron {expandedCollections.has(collection.id) ? 'open' : ''}"
								viewBox="0 0 24 24" fill="none" stroke="currentColor"
							>
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 18l6-6-6-6"/>
							</svg>
							<span class="collection-name">{collection.name}</span>
							<StatusBadge status={collection.tier} size="xs" />
							<span style="font-size:11px;color:var(--text-muted);margin-left:8px;">{filtered.length}</span>
						</button>

						<!-- Tokens in this collection -->
						{#if expandedCollections.has(collection.id)}
							{#if filtered.length === 0}
								<div style="padding:8px 16px 8px 36px;">
									<p style="font-size:11px;color:var(--text-muted);font-style:italic;">No tokens match filters</p>
								</div>
							{:else}
								{#each filtered as token}
									{@const val = defaultVal(token)}
									<button
										class="token-row {selectedToken?.id === token.id ? 'selected' : ''}"
										onclick={() => selectedToken = selectedToken?.id === token.id ? null : token}
										style="padding-left:32px;"
									>
										<!-- Swatch or type icon -->
										{#if isColor(token) && looksColor(val)}
											<div class="token-swatch" style="background:{val};"></div>
										{:else}
											<div class="token-type-icon">{token.token_type.slice(0,2)}</div>
										{/if}

										<div style="flex:1;min-width:0;">
											<div class="token-name truncate">{token.name}</div>
											<div class="token-path truncate">{token.path}</div>
										</div>

										<div style="display:flex;align-items:center;gap:6px;flex-shrink:0;">
											<span class="token-value mono">{val}</span>
											<StatusBadge status={token.status} size="xs" />
										</div>
									</button>
								{/each}
							{/if}
						{/if}
					{/if}
				{/each}
			{/if}
		</div>
	</div>

	<!-- Right: detail panel -->
	{#if selectedToken}
		<div class="token-detail-panel">
			<div class="token-detail-header">
				<span style="font-size:12px;font-weight:600;color:var(--text-primary);">Token detail</span>
				<button
					class="btn btn-ghost btn-sm"
					onclick={() => selectedToken = null}
					aria-label="Close detail panel"
					style="padding:2px 4px;"
				>
					<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
					</svg>
				</button>
			</div>

			<div class="token-detail-body">
				<!-- Color preview -->
				{#if isColor(selectedToken) && looksColor(defaultVal(selectedToken))}
					<div style="width:100%;height:80px;border-radius:var(--radius-md);border:1px solid var(--border);background:{defaultVal(selectedToken)};margin-bottom:16px;"></div>
				{/if}

				<!-- Name & path -->
				<div style="margin-bottom:14px;">
					<p style="font-size:14px;font-weight:700;color:var(--text-primary);margin-bottom:2px;">{selectedToken.name}</p>
					<p class="mono" style="font-size:11px;color:var(--accent);">{selectedToken.path}</p>
				</div>

				<!-- Tags -->
				<div style="display:flex;gap:4px;flex-wrap:wrap;margin-bottom:14px;">
					<StatusBadge status={selectedToken.status} size="xs" />
					<span class="badge badge-draft" style="font-size:10px;">{selectedToken.token_type}</span>
					{#if selectedToken.is_alias}
						<span class="badge" style="background:var(--yellow-bg);color:var(--yellow);font-size:10px;">alias</span>
					{/if}
				</div>

				<!-- Values by mode -->
				{#if selectedToken.token_values?.length > 0}
					<div style="margin-bottom:14px;">
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:8px;">Values</p>
						<div style="display:flex;flex-direction:column;gap:4px;">
							{#each selectedToken.token_values as tv}
								{@const modeName = modes.find(m => m.id === tv.mode_id)?.name ?? 'Default'}
								<div style="display:flex;align-items:center;justify-content:space-between;padding:7px 10px;border:1px solid var(--border);border-radius:var(--radius-md);background:var(--bg-subtle);">
									<span style="font-size:11px;color:var(--text-secondary);">{modeName}</span>
									<div style="display:flex;align-items:center;gap:6px;">
										{#if isColor(selectedToken) && looksColor(tv.raw_value)}
											<div class="token-swatch" style="width:14px;height:14px;background:{tv.raw_value};border-radius:3px;"></div>
										{/if}
										<span class="mono" style="font-size:11px;font-weight:600;color:var(--text-primary);">{tv.raw_value}</span>
									</div>
								</div>
							{/each}
						</div>
					</div>
				{/if}

				<!-- Description -->
				{#if selectedToken.description}
					<div style="margin-bottom:14px;">
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Description</p>
						<p style="font-size:12px;color:var(--text-secondary);">{selectedToken.description}</p>
					</div>
				{/if}

				<!-- Usage guidance -->
				{#if selectedToken.usage_guidance}
					<div style="margin-bottom:14px;">
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Usage</p>
						<div class="alert alert-info" style="font-size:11px;">{selectedToken.usage_guidance}</div>
					</div>
				{/if}

				<!-- Meta -->
				<div style="border-top:1px solid var(--border);padding-top:12px;margin-top:8px;">
					<p style="font-size:11px;color:var(--text-muted);">
						Updated {new Date(selectedToken.updated_at).toLocaleDateString('en-US',{month:'short',day:'numeric',year:'numeric'})}
					</p>
				</div>
			</div>
		</div>
	{/if}
</div>
