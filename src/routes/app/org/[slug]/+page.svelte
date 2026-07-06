<script lang="ts">
	import type { PageData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data }: { data: PageData } = $props();

	const org = $derived(data.org);
	const projects = $derived(data.projects);
	const auditLogs = $derived(data.auditLogs);
	const stats = $derived(data.stats);

	function relative(d: string) {
		const mins = Math.floor((Date.now() - new Date(d).getTime()) / 60000);
		if (mins < 1) return 'just now';
		if (mins < 60) return `${mins}m ago`;
		const hrs = Math.floor(mins / 60);
		if (hrs < 24) return `${hrs}h ago`;
		return `${Math.floor(hrs / 24)}d ago`;
	}
</script>

<!-- Page header -->
<div class="page-header">
	<div class="page-header-breadcrumb">
		<span>Dashboard</span>
		<span class="sep">/</span>
		<span style="color:var(--text-primary);font-weight:600;">{org.name}</span>
	</div>
	<div class="page-header-actions">
		<a href="/app/org/{org.slug}/projects/new" class="btn btn-primary btn-sm">
			<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/>
			</svg>
			New project
		</a>
	</div>
</div>

<!-- Body -->
<div class="page-body">
	<div class="page-body-inner">

		<!-- Stat cards -->
		<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;margin-bottom:20px;">
			<div class="stat-card">
				<div class="stat-label">Projects</div>
				<div class="stat-value">{stats.projectCount}</div>
			</div>
			<div class="stat-card">
				<div class="stat-label">Design Systems</div>
				<div class="stat-value">{stats.designSystemCount}</div>
			</div>
			<div class="stat-card">
				<div class="stat-label">Tokens</div>
				<div class="stat-value">{stats.tokenCount}</div>
			</div>
			<div class="stat-card">
				<div class="stat-label">Components</div>
				<div class="stat-value">{stats.componentCount}</div>
			</div>
		</div>

		<div style="display:grid;grid-template-columns:1fr 300px;gap:16px;align-items:start;">

			<!-- Projects list -->
			<div>
				<!-- Maturity overview -->
				{#if stats.designSystemCount > 0}
					<div class="card" style="margin-bottom:16px;">
						<div class="card-header">
							<span class="card-title">Design system maturity</span>
						</div>
						<div class="card-body" style="display:flex;gap:8px;flex-wrap:wrap;padding:12px 16px;">
							{#each [['draft','Draft'],['review','In review'],['approved','Approved'],['deprecated','Deprecated']] as [s, label]}
								{#if stats.maturityBreakdown[s as keyof typeof stats.maturityBreakdown] > 0}
									<div style="display:flex;align-items:center;gap:6px;padding:6px 10px;border:1px solid var(--border);border-radius:var(--radius-md);background:var(--bg-subtle);">
										<span style="font-size:18px;font-weight:700;color:var(--text-primary);">
											{stats.maturityBreakdown[s as keyof typeof stats.maturityBreakdown]}
										</span>
										<StatusBadge status={s} size="xs" />
									</div>
								{/if}
							{/each}
						</div>
					</div>
				{/if}

				<!-- Projects -->
				<div class="section-heading">
					<span class="section-title">Projects</span>
					<a href="/app/org/{org.slug}/projects/new" class="btn btn-secondary btn-sm">New</a>
				</div>

				{#if projects.length === 0}
					<div class="card">
						<div class="empty-state">
							<div class="empty-icon">
								<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
								</svg>
							</div>
							<p class="empty-title">No projects yet</p>
							<p class="empty-desc">Create your first project to start organizing design systems.</p>
							<a href="/app/org/{org.slug}/projects/new" class="btn btn-primary">Create project</a>
						</div>
					</div>
				{:else}
					<div style="display:flex;flex-direction:column;gap:10px;">
						{#each projects as project}
							{@const dsList = (project.design_systems as {id:string;name:string;maturity:string;version:string}[]|null) ?? []}
							<div class="card">
								<div class="card-header">
									<div>
										<a
											href="/app/org/{org.slug}/projects/{project.slug}"
											style="font-size:13px;font-weight:600;color:var(--text-primary);text-decoration:none;"
											class:hover-accent={true}
										>
											{project.name}
										</a>
										{#if project.description}
											<p style="font-size:11px;color:var(--text-muted);margin-top:2px;">{project.description}</p>
										{/if}
									</div>
									<a href="/app/org/{org.slug}/projects/{project.slug}" class="btn btn-secondary btn-sm">Open →</a>
								</div>

								{#if dsList.length > 0}
									<div style="border-top:1px solid var(--border);">
										<table class="data-table">
											<thead>
												<tr>
													<th>Design System</th>
													<th>Version</th>
													<th>Maturity</th>
												</tr>
											</thead>
											<tbody>
												{#each dsList as ds}
													<tr style="cursor:pointer;" onclick={() => { window.location.href = `/app/org/${org.slug}/projects/${project.slug}/ds/${ds.id}`; }}>
														<td>
															<a
																href="/app/org/{org.slug}/projects/{project.slug}/ds/{ds.id}"
																style="color:var(--accent);text-decoration:none;font-weight:500;"
															>
																{ds.name}
															</a>
														</td>
														<td><span class="mono" style="font-size:11px;color:var(--text-muted);">v{ds.version}</span></td>
														<td><StatusBadge status={ds.maturity} size="xs" /></td>
													</tr>
												{/each}
											</tbody>
										</table>
									</div>
								{:else}
									<div style="padding:12px 16px;">
										<p style="font-size:12px;color:var(--text-muted);font-style:italic;">No design systems yet</p>
									</div>
								{/if}
							</div>
						{/each}
					</div>
				{/if}
			</div>

			<!-- Activity feed -->
			<div>
				<div class="section-heading">
					<span class="section-title">Recent activity</span>
				</div>
				<div class="card">
					{#if auditLogs.length === 0}
						<div style="padding:24px;text-align:center;">
							<p style="font-size:12px;color:var(--text-muted);">No activity recorded yet</p>
						</div>
					{:else}
						<div style="divide-y:var(--border);">
							{#each auditLogs as log, i}
								{@const actor = (log.profiles as {display_name:string|null}|null)}
								<div style="padding:10px 14px;{i > 0 ? 'border-top:1px solid var(--bg-subtle);' : ''}display:flex;gap:8px;align-items:flex-start;">
									<div class="avatar" style="margin-top:2px;flex-shrink:0;">
										{(actor?.display_name ?? '?')[0]?.toUpperCase() ?? '?'}
									</div>
									<div style="flex:1;min-width:0;">
										<p style="font-size:12px;color:var(--text-primary);">
											<strong>{actor?.display_name ?? 'System'}</strong>
											{' '}{log.action.replace(/_/g,' ')}
										</p>
										<p style="font-size:11px;color:var(--text-muted);margin-top:2px;">{relative(log.created_at)}</p>
									</div>
								</div>
							{/each}
						</div>
					{/if}
				</div>
			</div>

		</div>
	</div>
</div>
