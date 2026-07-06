<script lang="ts">
	import type { PageData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data }: { data: PageData } = $props();

	const org = $derived(data.org);
	const projects = $derived(data.projects);
	const auditLogs = $derived(data.auditLogs);
	const stats = $derived(data.stats);

	function formatDate(dateStr: string) {
		return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
	}

	function formatRelative(dateStr: string) {
		const diff = Date.now() - new Date(dateStr).getTime();
		const mins = Math.floor(diff / 60000);
		if (mins < 1) return 'just now';
		if (mins < 60) return `${mins}m ago`;
		const hrs = Math.floor(mins / 60);
		if (hrs < 24) return `${hrs}h ago`;
		return `${Math.floor(hrs / 24)}d ago`;
	}

	const maturityColors = {
		draft: { bg: 'bg-[#f5f7fa]', text: 'text-[#4a5568]', label: 'Draft' },
		review: { bg: 'bg-[#ffecc2]', text: 'text-[#7d5e00]', label: 'In Review' },
		approved: { bg: 'bg-[#d3eedf]', text: 'text-[#0e6b2c]', label: 'Approved' },
		deprecated: { bg: 'bg-[#f9d3d8]', text: 'text-[#600006]', label: 'Deprecated' }
	};
</script>

<div class="p-6 lg:p-8 max-w-7xl mx-auto">
	<!-- Header -->
	<div class="mb-8">
		<div class="flex items-center gap-2 text-xs text-[#9aa5b4] mb-1">
			<span>Dashboard</span>
		</div>
		<h1 class="text-2xl font-bold text-[#1a1a1a]">{org.name}</h1>
		{#if org.description}
			<p class="text-sm text-[#4a5568] mt-1">{org.description}</p>
		{/if}
	</div>

	<!-- Stats grid -->
	<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Projects</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{stats.projectCount}</p>
		</div>
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Design Systems</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{stats.designSystemCount}</p>
		</div>
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Tokens</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{stats.tokenCount}</p>
		</div>
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Components</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{stats.componentCount}</p>
		</div>
	</div>

	<div class="grid lg:grid-cols-3 gap-6">
		<!-- Projects + Design Systems -->
		<div class="lg:col-span-2 space-y-4">
			<div class="flex items-center justify-between">
				<h2 class="text-base font-bold text-[#1a1a1a]">Projects</h2>
				<a
					href="/app/org/{org.slug}/projects/new"
					class="text-xs text-[#004aff] hover:underline font-medium"
				>+ New project</a>
			</div>

			{#if projects.length === 0}
				<div class="bg-white rounded-xl border border-[#d9e4ff] p-8 text-center">
					<div class="w-12 h-12 rounded-xl bg-[#f5f7fa] flex items-center justify-center mx-auto mb-3">
						<svg class="w-6 h-6 text-[#9aa5b4]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
						</svg>
					</div>
					<p class="text-sm font-bold text-[#1a1a1a] mb-1">No projects yet</p>
					<p class="text-xs text-[#4a5568] mb-4">Create your first project to get started</p>
					<a
						href="/app/org/{org.slug}/projects/new"
						class="inline-flex items-center gap-1.5 px-4 py-2 bg-[#004aff] text-white text-xs font-bold rounded-lg hover:bg-[#0040dd] transition-colors"
					>
						Create project
					</a>
				</div>
			{:else}
				{#each projects as project}
					<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
						<div class="flex items-start justify-between gap-3 mb-3">
							<div>
								<h3 class="text-sm font-bold text-[#1a1a1a]">{project.name}</h3>
								{#if project.description}
									<p class="text-xs text-[#4a5568] mt-0.5">{project.description}</p>
								{/if}
							</div>
							<a
								href="/app/org/{org.slug}/projects/{project.slug}"
								class="text-xs text-[#004aff] hover:underline font-medium flex-shrink-0"
							>Open →</a>
						</div>

						{#if project.design_systems && (project.design_systems as unknown[]).length > 0}
							<div class="space-y-2">
								{#each (project.design_systems as { id: string; name: string; maturity: string; version: string }[]) as ds}
									<a
										href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}"
										class="flex items-center justify-between p-2 rounded-lg border border-[#d9e4ff] hover:border-[#004aff] transition-colors group"
									>
										<div class="flex items-center gap-2">
											<div class="w-6 h-6 rounded-md bg-[#eef2ff] flex items-center justify-center">
												<svg class="w-3.5 h-3.5 text-[#004aff]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"/>
												</svg>
											</div>
											<div>
												<p class="text-xs font-bold text-[#1a1a1a] group-hover:text-[#004aff] transition-colors">{ds.name}</p>
												<p class="text-[10px] text-[#9aa5b4]">v{ds.version}</p>
											</div>
										</div>
										<span class="text-[10px] font-bold px-2 py-0.5 rounded-full {maturityColors[ds.maturity as keyof typeof maturityColors]?.bg} {maturityColors[ds.maturity as keyof typeof maturityColors]?.text}">
											{maturityColors[ds.maturity as keyof typeof maturityColors]?.label ?? ds.maturity}
										</span>
									</a>
								{/each}
							</div>
						{:else}
							<p class="text-xs text-[#9aa5b4] italic">No design systems yet</p>
						{/if}
					</div>
				{/each}
			{/if}

			<!-- Maturity summary -->
			{#if stats.designSystemCount > 0}
				<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
					<h3 class="text-sm font-bold text-[#1a1a1a] mb-3">Maturity overview</h3>
					<div class="flex gap-2 flex-wrap">
						{#each Object.entries(stats.maturityBreakdown) as [status, count]}
							{#if count > 0}
								<div class="flex items-center gap-1.5 px-2 py-1 rounded-lg {maturityColors[status as keyof typeof maturityColors]?.bg ?? 'bg-gray-100'}">
									<span class="text-xs font-bold {maturityColors[status as keyof typeof maturityColors]?.text ?? 'text-gray-700'}">{count}</span>
									<span class="text-xs {maturityColors[status as keyof typeof maturityColors]?.text ?? 'text-gray-700'}">{maturityColors[status as keyof typeof maturityColors]?.label ?? status}</span>
								</div>
							{/if}
						{/each}
					</div>
				</div>
			{/if}
		</div>

		<!-- Recent activity -->
		<div>
			<h2 class="text-base font-bold text-[#1a1a1a] mb-4">Recent activity</h2>
			<div class="bg-white rounded-xl border border-[#d9e4ff] divide-y divide-[#d9e4ff]">
				{#if auditLogs.length === 0}
					<div class="p-6 text-center">
						<p class="text-xs text-[#9aa5b4]">No activity yet</p>
					</div>
				{:else}
					{#each auditLogs as log}
						<div class="p-3">
							<div class="flex items-start gap-2">
								<div class="w-6 h-6 rounded-full bg-[#eef2ff] flex items-center justify-center text-[10px] font-bold text-[#004aff] flex-shrink-0 mt-0.5">
									{((log.profiles as { display_name: string | null } | null)?.display_name ?? '?')[0]?.toUpperCase() ?? '?'}
								</div>
								<div class="flex-1 min-w-0">
									<p class="text-xs text-[#1a1a1a]">
										<span class="font-bold">{(log.profiles as { display_name: string | null } | null)?.display_name ?? 'Unknown'}</span>
										{' '}{log.action.replace(/_/g, ' ')}
									</p>
									<p class="text-[10px] text-[#9aa5b4] mt-0.5">{formatRelative(log.created_at)}</p>
								</div>
							</div>
						</div>
					{/each}
				{/if}
			</div>
		</div>
	</div>
</div>
