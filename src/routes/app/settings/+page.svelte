<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageData, ActionData } from './$types';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	const { data, form }: { data: PageData; form: ActionData } = $props();
	let loading = $state(false);
	let displayName = $state('');
	let bio = $state('');

	$effect(() => {
		displayName = data.profile?.display_name ?? '';
		bio = data.profile?.bio ?? '';
	});
</script>

<div class="p-6 lg:p-8 max-w-2xl mx-auto">
	<div class="mb-6">
		<h1 class="text-2xl font-bold text-[#1a1a1a]">Settings</h1>
		<p class="text-sm text-[#4a5568] mt-1">Manage your profile and preferences</p>
	</div>

	{#if form?.error}
		<div class="mb-4 p-3 rounded-lg bg-[#f9d3d8] border border-[#f9a8b4] text-[#600006] text-sm">
			{form.error}
		</div>
	{/if}

	{#if form?.success}
		<div class="mb-4 p-3 rounded-lg bg-[#d3eedf] border border-[#86efac] text-[#0e6b2c] text-sm">
			Profile updated successfully.
		</div>
	{/if}

	<div class="bg-white rounded-xl border border-[#d9e4ff] p-6 mb-6">
		<h2 class="text-base font-bold text-[#1a1a1a] mb-4">Profile</h2>

		<form
			method="POST"
			action="?/updateProfile"
			use:enhance={() => {
				loading = true;
				return async ({ update }) => {
					await update();
					loading = false;
				};
			}}
			class="space-y-4"
		>
			<div>
				<label for="display_name" class="block text-xs font-bold text-[#1a1a1a] mb-1">Display name</label>
				<input
					id="display_name"
					name="display_name"
					type="text"
					bind:value={displayName}
					class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all"
				/>
			</div>

			<div>
				<label for="bio" class="block text-xs font-bold text-[#1a1a1a] mb-1">Bio <span class="text-[#9aa5b4] font-normal">(optional)</span></label>
				<textarea
					id="bio"
					name="bio"
					rows={3}
					bind:value={bio}
					placeholder="Tell your teammates about yourself..."
					class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] placeholder-[#9aa5b4] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all resize-none"
				></textarea>
			</div>

			<div class="flex items-center gap-3">
				<button
					type="submit"
					disabled={loading}
					class="px-4 py-2 bg-[#004aff] text-white text-sm font-bold rounded-lg hover:bg-[#0040dd] disabled:bg-[#9ab3ff] transition-colors"
				>
					{loading ? 'Saving...' : 'Save changes'}
				</button>
			</div>
		</form>
	</div>

	<div class="bg-white rounded-xl border border-[#d9e4ff] p-6">
		<h2 class="text-base font-bold text-[#1a1a1a] mb-1">Account</h2>
		<p class="text-xs text-[#9aa5b4] mb-4">User ID: <code class="font-mono">{data.user?.id}</code></p>
		<p class="text-xs text-[#9aa5b4] mb-4">Email: <span class="text-[#1a1a1a] font-medium">{data.user?.email}</span></p>
		{#if data.profile?.is_platform_admin}
			<div class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-[#eef2ff] rounded-lg">
				<svg class="w-3.5 h-3.5 text-[#004aff]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
				</svg>
				<span class="text-xs font-bold text-[#004aff]">Platform Administrator</span>
			</div>
		{/if}
	</div>
</div>
