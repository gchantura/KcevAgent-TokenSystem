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
	let selected = $state<Component | null>(null);

	const categories = $derived(['all', ...new Set(components.map(c => c.category))]);
	const statuses = ['all', 'draft', 'review', 'approved', 'deprecated', 'needs-update'];

	const filtered = $derived(components.filter(c => {
		if (selectedCategory !== 'all' && c.category !== selectedCategory) return false;
		if (selectedStatus !== 'all' && c.status !== selectedStatus) return false;
		if (searchQuery && !c.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
		return true;
	}));

	const grouped = $derived(() => {
		const m = new Map<string, Component[]>();
		for (const c of filtered) {
			const list = m.get(c.category) ?? [];
			list.push(c);
			m.set(c.category, list);
		}
		return m;
	});

	const maturitySymbol: Record<string,string> = {
		draft: '○', review: '◑', approved: '●', deprecated: '×'
	};
</script>

<div style="display:flex;flex:1;overflow:hidden;">

	<!-- Left: grid -->
	<div style="flex:1;display:flex;flex-direction:column;overflow:hidden;{selected ? 'border-right:1px solid var(--border);' : ''}">

		<!-- Filters -->
		<div class="filter-bar">
			<div class="search-input-wrap">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
					<circle cx="11" cy="11" r="8"/><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-4.35-4.35"/>
				</svg>
				<input
					bind:value={searchQuery}
					type="search" placeholder="Search components…"
					class="search-input"
				/>
			</div>
			<select bind:value={selectedCategory} class="filter-select">
				{#each categories as cat}
					<option value={cat}>{cat === 'all' ? 'All categories' : cat[0].toUpperCase() + cat.slice(1)}</option>
				{/each}
			</select>
			<select bind:value={selectedStatus} class="filter-select">
				{#each statuses as s}
					<option value={s}>{s === 'all' ? 'All statuses' : s[0].toUpperCase() + s.slice(1)}</option>
				{/each}
			</select>
			<span class="filter-count">{filtered.length} component{filtered.length !== 1 ? 's' : ''}</span>
			<a href="/app/org/{orgSlug}/components/new?ds={dsId}" class="btn btn-primary btn-sm" style="margin-left:auto;">
				<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/>
				</svg>
				Add
			</a>
		</div>

		<div style="flex:1;overflow-y:auto;padding:16px;">
			{#if components.length === 0}
				<div class="empty-state">
					<div class="empty-icon">
						<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
						</svg>
					</div>
					<p class="empty-title">No components yet</p>
					<p class="empty-desc">Document your design system's UI components here.</p>
					<a href="/app/org/{orgSlug}/components/new?ds={dsId}" class="btn btn-primary btn-sm">Add component</a>
				</div>
			{:else if filtered.length === 0}
				<div class="empty-state">
					<p class="empty-title">No results</p>
					<p class="empty-desc">Try adjusting your search or filters.</p>
				</div>
			{:else}
				{#each grouped() as [category, comps]}
					<div style="margin-bottom:24px;">
						<p style="font-size:11px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:10px;">{category}</p>
						<div class="component-grid">
							{#each comps as c}
								<button
									class="component-card {selected?.id === c.id ? 'selected' : ''}"
									onclick={() => selected = selected?.id === c.id ? null : c}
								>
									<div class="component-preview">
										<span style="font-size:24px;color:var(--text-muted);">{maturitySymbol[c.maturity] ?? '○'}</span>
									</div>
									<p class="component-name">{c.name}</p>
									<StatusBadge status={c.status} size="xs" />
								</button>
							{/each}
						</div>
					</div>
				{/each}
			{/if}
		</div>
	</div>

	<!-- Right: detail -->
	{#if selected}
		<div style="width:300px;flex-shrink:0;background:var(--bg-surface);display:flex;flex-direction:column;overflow:hidden;">
			<div style="padding:12px 16px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;">
				<span style="font-size:12px;font-weight:600;color:var(--text-primary);">Component detail</span>
				<button
					class="btn btn-ghost btn-sm"
					onclick={() => selected = null}
					aria-label="Close"
					style="padding:2px 4px;"
				>
					<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
					</svg>
				</button>
			</div>

			<div style="flex:1;overflow-y:auto;padding:16px;display:flex;flex-direction:column;gap:14px;">
				<div>
					<p style="font-size:14px;font-weight:700;color:var(--text-primary);margin-bottom:2px;">{selected.name}</p>
					<p class="mono" style="font-size:11px;color:var(--text-muted);">{selected.slug}</p>
				</div>

				<div style="display:flex;gap:4px;flex-wrap:wrap;">
					<StatusBadge status={selected.status} size="xs" />
					<StatusBadge status={selected.maturity} size="xs" />
					<span class="badge badge-draft" style="font-size:10px;">{selected.category}</span>
				</div>

				{#if selected.description}
					<div>
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Description</p>
						<p style="font-size:12px;color:var(--text-secondary);">{selected.description}</p>
					</div>
				{/if}

				{#if selected.usage_guidance}
					<div>
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Usage</p>
						<div class="alert alert-info" style="font-size:11px;">{selected.usage_guidance}</div>
					</div>
				{/if}

				{#if selected.accessibility_guidance}
					<div>
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Accessibility</p>
						<p style="font-size:12px;color:var(--text-secondary);">{selected.accessibility_guidance}</p>
					</div>
				{/if}

				{#if selected.code_reference}
					<div>
						<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Code</p>
						<code style="font-size:11px;font-family:monospace;background:var(--bg-subtle);padding:4px 8px;border-radius:var(--radius-sm);display:block;">{selected.code_reference}</code>
					</div>
				{/if}

				<div style="border-top:1px solid var(--border);padding-top:10px;margin-top:4px;">
					<p style="font-size:11px;color:var(--text-muted);">Updated {new Date(selected.updated_at).toLocaleDateString()}</p>
				</div>
			</div>
		</div>
	{/if}
</div>
