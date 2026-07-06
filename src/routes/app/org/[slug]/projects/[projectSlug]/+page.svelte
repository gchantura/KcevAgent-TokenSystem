<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageData, ActionData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data, form }: { data: PageData; form: ActionData } = $props();
	const org = $derived(data.org);
	const project = $derived(data.project);
	const designSystems = $derived(data.designSystems);

	let showCreateDs = $state(false);
	let loading = $state(false);

	const maturityColors = {
		draft: 'border-[#d9e4ff]',
		review: 'border-[#ffd47c]',
		approved: 'border-[#86efac]',
		deprecated: 'border-[#fca5a5]'
	};
</script>

<div class="p-6 lg:p-8 max-w-5xl mx-auto">
	<!-- Breadcrumb + header -->
	<div class="mb-6">
		<nav class="flex items-center gap-1 text-xs text-[#9aa5b4] mb-1">
			<a href="/app/org/{org.slug}" class="hover:text-[#004aff]">{org.name}</a>
			<span>/</span>
			<span class="text-[#1a1a1a]">{project.name}</span>
		</nav>
		<div class="flex items-center justify-between gap-4">
			<div>
				<h1 class="text-2xl font-bold text-[#1a1a1a]">{project.name}</h1>
				{#if project.description}
					<p class="text-sm text-[#4a5568] mt-1">{project.description}</p>
				{/if}
			</div>
			<button
				onclick={() => showCreateDs = true}
				class="px-4 py-2 bg-[#004aff] text-white text-xs font-bold rounded-lg hover:bg-[#0040dd] transition-colors whitespace-nowrap"
			>
				+ Design system
			</button>
		</div>
	</div>

	{#if form?.error}
		<div class="mb-4 p-3 rounded-lg bg-[#f9d3d8] border border-[#f9a8b4] text-[#600006] text-sm">
			{form.error}
		</div>
	{/if}

	<!-- Design systems -->
	{#if designSystems.length === 0 && !showCreateDs}
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-12 text-center">
			<div class="w-12 h-12 rounded-xl bg-[#f5f7fa] flex items-center justify-center mx-auto mb-3">
				<svg class="w-6 h-6 text-[#9aa5b4]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"/>
				</svg>
			</div>
			<p class="text-sm font-bold text-[#1a1a1a] mb-1">No design systems yet</p>
			<p class="text-xs text-[#4a5568] mb-4">Create your first design system to start managing tokens and components</p>
			<button
				onclick={() => showCreateDs = true}
				class="inline-flex items-center gap-1.5 px-4 py-2 bg-[#004aff] text-white text-xs font-bold rounded-lg hover:bg-[#0040dd] transition-colors"
			>
				Create design system
			</button>
		</div>
	{:else}
		<div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
			{#each designSystems as ds}
				<a
					href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}"
					class="block bg-white rounded-xl border-2 transition-all hover:shadow-md {maturityColors[ds.maturity as keyof typeof maturityColors] ?? 'border-[#d9e4ff]'} p-5 group"
				>
					<div class="flex items-start justify-between gap-2 mb-3">
						<div class="w-10 h-10 rounded-xl bg-[#eef2ff] flex items-center justify-center">
							<svg class="w-5 h-5 text-[#004aff]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"/>
							</svg>
						</div>
						<StatusBadge status={ds.maturity} size="xs" />
					</div>
					<h3 class="text-sm font-bold text-[#1a1a1a] group-hover:text-[#004aff] transition-colors mb-0.5">{ds.name}</h3>
					<p class="text-[10px] text-[#9aa5b4]">v{ds.version}</p>
					{#if ds.description}
						<p class="text-xs text-[#4a5568] mt-2 line-clamp-2">{ds.description}</p>
					{/if}
					<div class="mt-3 pt-3 border-t border-[#d9e4ff] flex items-center justify-between">
						<span class="text-[10px] text-[#9aa5b4]">
							Updated {new Date(ds.updated_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
						</span>
						<span class="text-xs text-[#004aff] font-bold opacity-0 group-hover:opacity-100 transition-opacity">Open →</span>
					</div>
				</a>
			{/each}
		</div>
	{/if}

	<!-- Create DS modal -->
	{#if showCreateDs}
		<div class="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
			<div class="bg-white rounded-2xl border border-[#d9e4ff] shadow-xl w-full max-w-md p-6">
				<div class="flex items-center justify-between mb-4">
					<h2 class="text-base font-bold text-[#1a1a1a]">Create design system</h2>
					<button
						onclick={() => showCreateDs = false}
						class="text-[#9aa5b4] hover:text-[#1a1a1a]"
						aria-label="Close dialog"
					>
						<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
						</svg>
					</button>
				</div>

				<form
					method="POST"
					action="?/createDs"
					use:enhance={() => {
						loading = true;
						return async ({ update }) => {
							await update();
							loading = false;
							showCreateDs = false;
						};
					}}
					class="space-y-4"
				>
					<div>
						<label for="ds-name" class="block text-xs font-bold text-[#1a1a1a] mb-1">Name</label>
						<input
							id="ds-name"
							name="name"
							type="text"
							required
							placeholder="My Design System"
							class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all"
						/>
					</div>

					<div class="flex gap-3">
						<button
							type="button"
							onclick={() => showCreateDs = false}
							class="flex-1 py-2 px-4 border border-[#d9e4ff] rounded-lg text-sm font-bold text-[#4a5568] hover:bg-[#f5f7fa] transition-colors"
						>
							Cancel
						</button>
						<button
							type="submit"
							disabled={loading}
							class="flex-1 py-2 px-4 bg-[#004aff] text-white text-sm font-bold rounded-lg hover:bg-[#0040dd] disabled:bg-[#9ab3ff] transition-colors"
						>
							{loading ? 'Creating...' : 'Create'}
						</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
</div>
