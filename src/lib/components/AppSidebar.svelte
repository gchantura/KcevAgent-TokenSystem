<script lang="ts">
	import type { Profile } from '$lib/supabase/types';

	type Membership = {
		id: string;
		role_id: string;
		status: string;
		organizations: { id: string; name: string; slug: string; logo_url: string | null; status: string } | null;
		roles: { id: string; name: string; slug: string } | null;
	};

	const {
		profile,
		memberships,
		currentPath,
		signOut
	}: {
		profile: Profile | null;
		memberships: Membership[];
		currentPath: string;
		signOut: () => void;
	} = $props();

	let mobileOpen = $state(false);

	const orgs = $derived(memberships.map(m => m.organizations).filter(Boolean));

	function isActive(href: string) {
		if (href === '/app') return currentPath === '/app';
		return currentPath.startsWith(href);
	}

	function initials(name: string | null) {
		if (!name) return '?';
		return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
	}

	const mainNav = [
		{ href: '/app', label: 'Dashboard', icon: 'grid' },
		{ href: '/app/tokens', label: 'Tokens', icon: 'tokens' },
		{ href: '/app/components', label: 'Components', icon: 'components' },
		{ href: '/app/releases', label: 'Releases', icon: 'releases' },
		{ href: '/app/docs', label: 'Docs', icon: 'docs' },
	];

	const adminNav = [
		{ href: '/app/admin', label: 'Admin', icon: 'admin' },
		{ href: '/app/settings', label: 'Settings', icon: 'settings' },
	];
</script>

<!-- Mobile overlay -->
{#if mobileOpen}
	<button
		class="sidebar-overlay"
		style="position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:39;"
		onclick={() => mobileOpen = false}
		aria-label="Close sidebar"
	></button>
{/if}

<!-- Mobile toggle -->
<button
	class="btn btn-secondary btn-sm"
	style="position:fixed;top:10px;left:10px;z-index:50;display:none;"
	class:mobile-toggle-visible={true}
	onclick={() => mobileOpen = !mobileOpen}
	aria-label="Toggle sidebar"
>
	<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor">
		<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
	</svg>
</button>

<aside class="sidebar" class:open={mobileOpen}>
	<!-- Brand -->
	<div class="sidebar-brand">
		<div class="sidebar-brand-icon">
			<svg width="14" height="14" viewBox="0 0 16 16" fill="none">
				<rect x="2" y="2" width="5" height="5" rx="1" fill="white"/>
				<rect x="9" y="2" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
				<rect x="2" y="9" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
				<rect x="9" y="9" width="5" height="5" rx="1" fill="white"/>
			</svg>
		</div>
		<span class="sidebar-brand-name">Atomic DSB</span>
	</div>

	<!-- Org section -->
	{#if orgs.length > 0}
		<div style="padding: 8px 8px 0;">
			<p class="sidebar-section-label">Workspace</p>
			{#each orgs as org}
				{#if org}
					<a
						href="/app/org/{org.slug}"
						class="nav-item {currentPath.includes('/org/' + org.slug) ? 'active' : ''}"
					>
						<span style="width:16px;height:16px;border-radius:3px;background:var(--accent-muted);color:var(--accent);font-size:9px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
							{org.name[0].toUpperCase()}
						</span>
						<span class="truncate">{org.name}</span>
					</a>
				{/if}
			{/each}
		</div>
		<div class="divider" style="margin: 6px 8px;"></div>
	{/if}

	<!-- Main nav -->
	<nav class="sidebar-nav">
		{#each mainNav as item}
			<a href={item.href} class="nav-item {isActive(item.href) ? 'active' : ''}">
				<NavIcon name={item.icon} />
				{item.label}
			</a>
		{/each}

		<div class="divider" style="margin: 6px 0;"></div>
		<p class="sidebar-section-label">Admin</p>

		{#each adminNav as item}
			<a href={item.href} class="nav-item {isActive(item.href) ? 'active' : ''}">
				<NavIcon name={item.icon} />
				{item.label}
			</a>
		{/each}
	</nav>

	<!-- Org create link -->
	<div style="padding: 4px 8px 4px;">
		<a href="/app/onboarding" class="nav-item" style="color:var(--accent);">
			<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
			</svg>
			New organization
		</a>
	</div>

	<!-- User footer -->
	<div class="sidebar-footer">
		<div class="user-row">
			<div class="avatar">
				{initials(profile?.display_name ?? null)}
			</div>
			<span class="user-name">{profile?.display_name ?? 'User'}</span>
			{#if profile?.is_platform_admin}
				<span style="font-size:9px;font-weight:700;color:var(--accent);background:var(--accent-muted);border-radius:4px;padding:2px 4px;flex-shrink:0;">Admin</span>
			{/if}
			<button
				onclick={signOut}
				class="btn btn-ghost btn-sm"
				style="padding:2px 4px;margin-left:4px;flex-shrink:0;"
				title="Sign out"
				aria-label="Sign out"
			>
				<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
				</svg>
			</button>
		</div>
	</div>
</aside>

<!-- Inline NavIcon snippets -->
{#snippet NavIcon({ name }: { name: string })}
	{#if name === 'grid'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
		</svg>
	{:else if name === 'tokens'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z"/>
		</svg>
	{:else if name === 'components'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
		</svg>
	{:else if name === 'releases'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z"/>
		</svg>
	{:else if name === 'docs'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
		</svg>
	{:else if name === 'admin'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
		</svg>
	{:else if name === 'settings'}
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
		</svg>
	{/if}
{/snippet}

<style>
@media (max-width: 768px) {
	.mobile-toggle-visible { display: flex !important; }
}
</style>
