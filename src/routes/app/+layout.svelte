<script lang="ts">
	import { page } from '$app/state';
	import { goto } from '$app/navigation';
	import { createClient } from '$lib/supabase/client';
	import AppSidebar from '$lib/components/AppSidebar.svelte';
	import type { LayoutData } from './$types';

	const { children, data }: { children: import('svelte').Snippet; data: LayoutData } = $props();

	const supabase = createClient();

	async function signOut() {
		await supabase.auth.signOut();
		goto('/auth/sign-in');
	}
</script>

<div class="flex h-screen bg-[#d6dde6] overflow-hidden">
	<AppSidebar
		profile={data.profile}
		memberships={data.memberships}
		currentPath={page.url.pathname}
		{signOut}
	/>

	<main class="flex-1 overflow-auto">
		{@render children()}
	</main>
</div>
