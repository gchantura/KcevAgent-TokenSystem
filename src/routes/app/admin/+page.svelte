<script lang="ts">
	import type { PageData } from './$types';
	import { enhance } from '$app/forms';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data }: { data: PageData } = $props();
	const profiles = $derived(data.profiles);
	const organizations = $derived(data.organizations);
	const auditLogs = $derived(data.auditLogs);

	let activeTab = $state<'users' | 'orgs' | 'audit'>('users');

	function formatDate(d: string) {
		return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
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

	function getInitials(name: string | null) {
		if (!name) return '?';
		return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
	}
</script>

<div class="p-6 lg:p-8 max-w-7xl mx-auto">
	<!-- Header -->
	<div class="mb-6">
		<div class="flex items-center gap-2 text-xs text-[#9aa5b4] mb-1">
			<span>Admin</span>
		</div>
		<h1 class="text-2xl font-bold text-[#1a1a1a]">Platform Admin</h1>
		<p class="text-sm text-[#4a5568] mt-1">Manage users, organizations, and platform settings</p>
	</div>

	<!-- Stats -->
	<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Total users</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{profiles.length}</p>
		</div>
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Organizations</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{organizations.length}</p>
		</div>
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Active users</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{profiles.filter(p => p.status === 'active').length}</p>
		</div>
		<div class="bg-white rounded-xl border border-[#d9e4ff] p-4">
			<p class="text-xs font-bold text-[#9aa5b4] uppercase tracking-wider mb-1">Platform admins</p>
			<p class="text-2xl font-bold text-[#1a1a1a]">{profiles.filter(p => p.is_platform_admin).length}</p>
		</div>
	</div>

	<!-- Tabs -->
	<div class="flex gap-0 border-b border-[#d9e4ff] mb-6">
		{#each [['users', 'Users'], ['orgs', 'Organizations'], ['audit', 'Audit Log']] as [id, label]}
			<button
				onclick={() => activeTab = id as typeof activeTab}
				class="px-4 py-2 text-sm font-medium border-b-2 transition-colors
					{activeTab === id
						? 'border-[#004aff] text-[#004aff]'
						: 'border-transparent text-[#4a5568] hover:text-[#1a1a1a]'}"
			>
				{label}
			</button>
		{/each}
	</div>

	<!-- Users tab -->
	{#if activeTab === 'users'}
		<div class="bg-white rounded-xl border border-[#d9e4ff] overflow-hidden">
			<table class="w-full text-sm">
				<thead>
					<tr class="border-b border-[#d9e4ff] bg-[#f8fafd]">
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider">User</th>
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider hidden sm:table-cell">Status</th>
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider hidden md:table-cell">Admin</th>
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider hidden lg:table-cell">Joined</th>
					</tr>
				</thead>
				<tbody class="divide-y divide-[#f0f4fd]">
					{#each profiles as profile}
						<tr class="hover:bg-[#f8fafd] transition-colors">
							<td class="px-4 py-3">
								<div class="flex items-center gap-3">
									<div class="w-8 h-8 rounded-full bg-[#eef2ff] flex items-center justify-center text-xs font-bold text-[#004aff] flex-shrink-0">
										{getInitials(profile.display_name)}
									</div>
									<div>
										<p class="text-xs font-bold text-[#1a1a1a]">{profile.display_name ?? 'Unknown'}</p>
										<p class="text-[10px] text-[#9aa5b4] font-mono">{profile.id.slice(0, 8)}…</p>
									</div>
								</div>
							</td>
							<td class="px-4 py-3 hidden sm:table-cell">
								<StatusBadge status={profile.status} size="xs" />
							</td>
							<td class="px-4 py-3 hidden md:table-cell">
								{#if profile.is_platform_admin}
									<span class="text-xs font-bold text-[#004aff]">● Admin</span>
								{:else}
									<span class="text-xs text-[#9aa5b4]">—</span>
								{/if}
							</td>
							<td class="px-4 py-3 hidden lg:table-cell">
								<span class="text-xs text-[#9aa5b4]">{formatDate(profile.created_at)}</span>
							</td>
						</tr>
					{/each}
					{#if profiles.length === 0}
						<tr>
							<td colspan="4" class="px-4 py-8 text-center text-xs text-[#9aa5b4]">No users found</td>
						</tr>
					{/if}
				</tbody>
			</table>
		</div>
	{/if}

	<!-- Organizations tab -->
	{#if activeTab === 'orgs'}
		<div class="bg-white rounded-xl border border-[#d9e4ff] overflow-hidden">
			<table class="w-full text-sm">
				<thead>
					<tr class="border-b border-[#d9e4ff] bg-[#f8fafd]">
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider">Organization</th>
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider hidden sm:table-cell">Status</th>
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider hidden md:table-cell">Members</th>
						<th class="text-left px-4 py-3 text-xs font-bold text-[#9aa5b4] uppercase tracking-wider hidden lg:table-cell">Created</th>
					</tr>
				</thead>
				<tbody class="divide-y divide-[#f0f4fd]">
					{#each organizations as org}
						<tr class="hover:bg-[#f8fafd] transition-colors">
							<td class="px-4 py-3">
								<div class="flex items-center gap-3">
									<div class="w-8 h-8 rounded-lg bg-[#d9e4ff] flex items-center justify-center text-xs font-bold text-[#004aff] flex-shrink-0">
										{org.name[0].toUpperCase()}
									</div>
									<div>
										<a href="/app/org/{org.slug}" class="text-xs font-bold text-[#004aff] hover:underline">{org.name}</a>
										<p class="text-[10px] text-[#9aa5b4]">/{org.slug}</p>
									</div>
								</div>
							</td>
							<td class="px-4 py-3 hidden sm:table-cell">
								<StatusBadge status={org.status} size="xs" />
							</td>
							<td class="px-4 py-3 hidden md:table-cell">
								<span class="text-xs text-[#4a5568]">{(org.organization_members as { count: number }[])?.[0]?.count ?? 0}</span>
							</td>
							<td class="px-4 py-3 hidden lg:table-cell">
								<span class="text-xs text-[#9aa5b4]">{formatDate(org.created_at)}</span>
							</td>
						</tr>
					{/each}
					{#if organizations.length === 0}
						<tr>
							<td colspan="4" class="px-4 py-8 text-center text-xs text-[#9aa5b4]">No organizations found</td>
						</tr>
					{/if}
				</tbody>
			</table>
		</div>
	{/if}

	<!-- Audit Log tab -->
	{#if activeTab === 'audit'}
		<div class="bg-white rounded-xl border border-[#d9e4ff] divide-y divide-[#d9e4ff]">
			{#if auditLogs.length === 0}
				<div class="p-8 text-center">
					<p class="text-xs text-[#9aa5b4]">No audit events recorded yet</p>
				</div>
			{:else}
				{#each auditLogs as log}
					<div class="px-4 py-3 flex items-start gap-3 hover:bg-[#f8fafd] transition-colors">
						<div class="w-7 h-7 rounded-full bg-[#eef2ff] flex items-center justify-center text-[10px] font-bold text-[#004aff] flex-shrink-0 mt-0.5">
							{getInitials((log.profiles as { display_name: string | null } | null)?.display_name ?? null)}
						</div>
						<div class="flex-1 min-w-0">
							<div class="flex items-start justify-between gap-2">
								<p class="text-xs text-[#1a1a1a]">
									<span class="font-bold">{(log.profiles as { display_name: string | null } | null)?.display_name ?? 'System'}</span>
									{' '}<span class="text-[#004aff]">{log.action}</span>
									{' on '}<span class="font-medium">{log.resource_type}</span>
								</p>
								<span class="text-[10px] text-[#9aa5b4] flex-shrink-0">{formatRelative(log.created_at)}</span>
							</div>
							{#if log.resource_id}
								<p class="text-[10px] text-[#9aa5b4] font-mono mt-0.5">{log.resource_id}</p>
							{/if}
						</div>
					</div>
				{/each}
			{/if}
		</div>
	{/if}
</div>
