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
	const currentOrgSlug = $derived(() => {
		const match = currentPath.match(/\/app\/org\/([^/]+)/);
		return match ? match[1] : null;
	});

	const navItems = [
		{ href: '/app', label: 'Dashboard', icon: 'grid' },
		{ href: '/app/tokens', label: 'Tokens', icon: 'palette' },
		{ href: '/app/components', label: 'Components', icon: 'layers' },
		{ href: '/app/releases', label: 'Releases', icon: 'tag' },
		{ href: '/app/docs', label: 'Documentation', icon: 'book-open' },
	];

	const adminItems = [
		{ href: '/app/admin', label: 'Admin', icon: 'shield' },
		{ href: '/app/settings', label: 'Settings', icon: 'settings' },
	];

	function isActive(href: string) {
		if (href === '/app') return currentPath === '/app';
		return currentPath.startsWith(href);
	}

	function getInitials(name: string | null) {
		if (!name) return '?';
		return name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
	}
</script>

<!-- Mobile menu toggle -->
<button
	class="lg:hidden fixed top-4 left-4 z-50 p-2 bg-white rounded-lg border border-[#d9e4ff] shadow-sm"
	onclick={() => mobileOpen = !mobileOpen}
	aria-label="Toggle menu"
>
	<svg class="w-5 h-5 text-[#1a1a1a]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
		{#if mobileOpen}
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
		{:else}
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
		{/if}
	</svg>
</button>

<!-- Overlay -->
{#if mobileOpen}
	<button
		class="lg:hidden fixed inset-0 bg-black/30 z-30"
		onclick={() => mobileOpen = false}
		aria-label="Close menu"
	></button>
{/if}

<!-- Sidebar -->
<aside
	class="
		fixed lg:static inset-y-0 left-0 z-40
		w-[220px] flex-shrink-0 bg-white border-r border-[#d9e4ff]
		flex flex-col transition-transform duration-200
		{mobileOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
	"
>
	<!-- Brand -->
	<div class="flex items-center gap-2 px-4 py-4 border-b border-[#d9e4ff]">
		<div class="w-7 h-7 rounded-lg bg-[#004aff] flex items-center justify-center flex-shrink-0">
			<svg width="14" height="14" viewBox="0 0 16 16" fill="none">
				<rect x="2" y="2" width="5" height="5" rx="1" fill="white"/>
				<rect x="9" y="2" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
				<rect x="2" y="9" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
				<rect x="9" y="9" width="5" height="5" rx="1" fill="white"/>
			</svg>
		</div>
		<span class="text-sm font-bold text-[#1a1a1a]">Atomic DSB</span>
	</div>

	<!-- Org selector -->
	{#if orgs.length > 0}
		<div class="px-3 pt-3 pb-1">
			<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider px-1 mb-1">Organization</p>
			{#each orgs as org}
				{#if org}
					<a
						href="/app/org/{org.slug}"
						class="flex items-center gap-2 px-2 py-1.5 rounded-lg text-xs font-medium transition-colors
							{currentPath.includes(org.slug) ? 'bg-[#eef2ff] text-[#004aff]' : 'text-[#4a5568] hover:bg-[#f5f7fa]'}"
					>
						<div class="w-5 h-5 rounded bg-[#d9e4ff] flex items-center justify-center text-[10px] font-bold text-[#004aff] flex-shrink-0">
							{org.name[0].toUpperCase()}
						</div>
						<span class="truncate">{org.name}</span>
					</a>
				{/if}
			{/each}
			<a
				href="/app/onboarding"
				class="flex items-center gap-2 px-2 py-1.5 rounded-lg text-xs text-[#004aff] hover:bg-[#eef2ff] transition-colors mt-1"
			>
				<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
				</svg>
				<span>New organization</span>
			</a>
		</div>
		<div class="mx-3 my-2 border-t border-[#d9e4ff]"></div>
	{/if}

	<!-- Main nav -->
	<nav class="flex-1 px-3 space-y-0.5 overflow-y-auto">
		{#each navItems as item}
			<a
				href={item.href}
				class="flex items-center gap-2.5 px-2 py-2 rounded-lg text-xs font-medium transition-colors
					{isActive(item.href) ? 'bg-[#eef2ff] text-[#004aff] font-bold' : 'text-[#4a5568] hover:bg-[#f5f7fa]'}"
			>
				<NavIcon name={item.icon} active={isActive(item.href)} />
				<span>{item.label}</span>
			</a>
		{/each}

		<div class="border-t border-[#d9e4ff] my-2 pt-2">
			<p class="text-[10px] font-bold text-[#9aa5b4] uppercase tracking-wider px-1 mb-1">Admin</p>
			{#each adminItems as item}
				<a
					href={item.href}
					class="flex items-center gap-2.5 px-2 py-2 rounded-lg text-xs font-medium transition-colors
						{isActive(item.href) ? 'bg-[#eef2ff] text-[#004aff] font-bold' : 'text-[#4a5568] hover:bg-[#f5f7fa]'}"
				>
					<NavIcon name={item.icon} active={isActive(item.href)} />
					<span>{item.label}</span>
				</a>
			{/each}
		</div>
	</nav>

	<!-- User section -->
	<div class="border-t border-[#d9e4ff] p-3">
		<div class="flex items-center gap-2">
			<div class="w-7 h-7 rounded-full bg-[#004aff26] flex items-center justify-center text-xs font-bold text-[#004aff] flex-shrink-0">
				{getInitials(profile?.display_name ?? null)}
			</div>
			<div class="flex-1 min-w-0">
				<p class="text-xs font-bold text-[#1a1a1a] truncate">{profile?.display_name ?? 'User'}</p>
				{#if profile?.is_platform_admin}
					<span class="text-[10px] text-[#004aff] font-medium">Platform Admin</span>
				{/if}
			</div>
			<button
				onclick={signOut}
				class="text-[#9aa5b4] hover:text-[#1a1a1a] transition-colors"
				title="Sign out"
			>
				<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
				</svg>
			</button>
		</div>
	</div>
</aside>

<!-- NavIcon helper component (inline) -->
{#snippet NavIcon({ name, active }: { name: string; active: boolean })}
	{#if name === 'grid'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
		</svg>
	{:else if name === 'palette'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"/>
		</svg>
	{:else if name === 'layers'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
		</svg>
	{:else if name === 'tag'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z"/>
		</svg>
	{:else if name === 'book-open'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
		</svg>
	{:else if name === 'shield'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
		</svg>
	{:else if name === 'settings'}
		<svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
		</svg>
	{/if}
{/snippet}
