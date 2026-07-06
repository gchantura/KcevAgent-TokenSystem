<script lang="ts">
	import type { PageData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data }: { data: PageData } = $props();
	const profiles = $derived(data.profiles);
	const organizations = $derived(data.organizations);
	const auditLogs = $derived(data.auditLogs);

	let activeTab = $state<'users' | 'orgs' | 'audit'>('users');

	function fmt(d: string) {
		return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
	}

	function relative(d: string) {
		const mins = Math.floor((Date.now() - new Date(d).getTime()) / 60000);
		if (mins < 1) return 'just now';
		if (mins < 60) return `${mins}m ago`;
		const hrs = Math.floor(mins / 60);
		if (hrs < 24) return `${hrs}h ago`;
		return `${Math.floor(hrs / 24)}d ago`;
	}

	function initials(name: string | null) {
		if (!name) return '?';
		return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
	}
</script>

<!-- Header -->
<div class="page-header">
	<div class="page-header-breadcrumb">
		<span style="color:var(--text-primary);font-weight:600;">Platform Admin</span>
	</div>
</div>

<!-- Stat strip -->
<div style="background:var(--bg-surface);border-bottom:1px solid var(--border);padding:12px 20px;display:grid;grid-template-columns:repeat(4,1fr);gap:12px;">
	{#each [
		['Total users', profiles.length],
		['Organizations', organizations.length],
		['Active users', profiles.filter(p => p.status === 'active').length],
		['Platform admins', profiles.filter(p => p.is_platform_admin).length]
	] as [label, value]}
		<div>
			<p style="font-size:10px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em;">{label}</p>
			<p style="font-size:20px;font-weight:700;color:var(--text-primary);margin-top:2px;">{value}</p>
		</div>
	{/each}
</div>

<!-- Tabs -->
<div class="tabs">
	<button class="tab {activeTab === 'users' ? 'active' : ''}" onclick={() => activeTab = 'users'}>
		Users
		<span class="tab-count">{profiles.length}</span>
	</button>
	<button class="tab {activeTab === 'orgs' ? 'active' : ''}" onclick={() => activeTab = 'orgs'}>
		Organizations
		<span class="tab-count">{organizations.length}</span>
	</button>
	<button class="tab {activeTab === 'audit' ? 'active' : ''}" onclick={() => activeTab = 'audit'}>
		Audit log
		<span class="tab-count">{auditLogs.length}</span>
	</button>
</div>

<!-- Content -->
<div class="page-body">
	<div class="page-body-inner">

		{#if activeTab === 'users'}
			<div class="card">
				{#if profiles.length === 0}
					<div class="empty-state">
						<p class="empty-title">No users found</p>
					</div>
				{:else}
					<table class="data-table">
						<thead>
							<tr>
								<th>User</th>
								<th>Status</th>
								<th>Role</th>
								<th>Joined</th>
							</tr>
						</thead>
						<tbody>
							{#each profiles as p}
								<tr>
									<td>
										<div style="display:flex;align-items:center;gap:8px;">
											<div class="avatar avatar-lg">{initials(p.display_name)}</div>
											<div>
												<p style="font-size:12px;font-weight:600;color:var(--text-primary);">{p.display_name ?? '—'}</p>
												<p class="mono" style="font-size:10px;color:var(--text-muted);">{p.id.slice(0, 12)}…</p>
											</div>
										</div>
									</td>
									<td><StatusBadge status={p.status} size="xs" /></td>
									<td>
										{#if p.is_platform_admin}
											<span class="badge" style="background:var(--accent-muted);color:var(--accent);font-size:10px;">Platform admin</span>
										{:else}
											<span style="font-size:11px;color:var(--text-muted);">—</span>
										{/if}
									</td>
									<td style="font-size:11px;color:var(--text-muted);">{fmt(p.created_at)}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				{/if}
			</div>
		{/if}

		{#if activeTab === 'orgs'}
			<div class="card">
				{#if organizations.length === 0}
					<div class="empty-state">
						<p class="empty-title">No organizations</p>
					</div>
				{:else}
					<table class="data-table">
						<thead>
							<tr>
								<th>Organization</th>
								<th>Status</th>
								<th>Members</th>
								<th>Created</th>
							</tr>
						</thead>
						<tbody>
							{#each organizations as org}
								<tr>
									<td>
										<div style="display:flex;align-items:center;gap:8px;">
											<div style="width:28px;height:28px;border-radius:var(--radius-md);background:var(--accent-muted);color:var(--accent);font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
												{org.name[0].toUpperCase()}
											</div>
											<div>
												<a href="/app/org/{org.slug}" style="font-size:12px;font-weight:600;color:var(--accent);text-decoration:none;">{org.name}</a>
												<p style="font-size:10px;color:var(--text-muted);">/{org.slug}</p>
											</div>
										</div>
									</td>
									<td><StatusBadge status={org.status} size="xs" /></td>
									<td style="font-size:12px;color:var(--text-secondary);">{(org.organization_members as {count:number}[])?.[0]?.count ?? 0}</td>
									<td style="font-size:11px;color:var(--text-muted);">{fmt(org.created_at)}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				{/if}
			</div>
		{/if}

		{#if activeTab === 'audit'}
			<div class="card">
				{#if auditLogs.length === 0}
					<div class="empty-state">
						<p class="empty-title">No audit events</p>
						<p class="empty-desc">Security events will appear here as users perform actions.</p>
					</div>
				{:else}
					<table class="data-table">
						<thead>
							<tr>
								<th>Actor</th>
								<th>Action</th>
								<th>Resource</th>
								<th>When</th>
							</tr>
						</thead>
						<tbody>
							{#each auditLogs as log}
								{@const actor = (log.profiles as {display_name:string|null}|null)}
								<tr>
									<td style="font-size:12px;font-weight:500;color:var(--text-primary);">{actor?.display_name ?? 'System'}</td>
									<td style="font-size:12px;color:var(--accent);">{log.action}</td>
									<td style="font-size:11px;color:var(--text-secondary);">{log.resource_type}</td>
									<td style="font-size:11px;color:var(--text-muted);">{relative(log.created_at)}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				{/if}
			</div>
		{/if}

	</div>
</div>
