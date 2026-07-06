<script lang="ts">
	import './layout.css';
	import { invalidate } from '$app/navigation';
	import { onMount } from 'svelte';
	import { createClient } from '$lib/supabase/client';

	const { children, data } = $props();
	const supabase = createClient();

	onMount(() => {
		const { data: { subscription } } = supabase.auth.onAuthStateChange((event, _session) => {
			(async () => {
				if (event === 'SIGNED_IN' || event === 'SIGNED_OUT' || event === 'TOKEN_REFRESHED') {
					await invalidate('supabase:auth');
				}
			})();
		});
		return () => subscription.unsubscribe();
	});
</script>

{@render children()}
