<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	const { form }: { form: ActionData } = $props();
	let loading = $state(false);
</script>

<div class="flex-1 flex items-center justify-center p-8">
	<div class="w-full max-w-md bg-white rounded-2xl border border-[#d9e4ff] shadow-sm p-8">
		<div class="text-center mb-6">
			<div class="w-12 h-12 rounded-xl bg-[#004aff] flex items-center justify-center mx-auto mb-3">
				<svg width="24" height="24" viewBox="0 0 16 16" fill="none">
					<rect x="2" y="2" width="5" height="5" rx="1" fill="white"/>
					<rect x="9" y="2" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
					<rect x="2" y="9" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
					<rect x="9" y="9" width="5" height="5" rx="1" fill="white"/>
				</svg>
			</div>
			<h1 class="text-2xl font-bold text-[#1a1a1a]">Create your workspace</h1>
			<p class="text-sm text-[#4a5568] mt-1">Set up your organization to start building your design system</p>
		</div>

		{#if form?.error}
			<div class="mb-4 p-3 rounded-lg bg-[#f9d3d8] border border-[#f9a8b4] text-[#600006] text-sm">
				{form.error}
			</div>
		{/if}

		<form
			method="POST"
			action="?/createOrg"
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
				<label for="name" class="block text-xs font-bold text-[#1a1a1a] mb-1">Organization name</label>
				<input
					id="name"
					name="name"
					type="text"
					required
					placeholder="Acme Corp"
					class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] placeholder-[#9aa5b4] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all"
				/>
			</div>

			<div>
				<label for="description" class="block text-xs font-bold text-[#1a1a1a] mb-1">
					Description <span class="text-[#9aa5b4] font-normal">(optional)</span>
				</label>
				<textarea
					id="description"
					name="description"
					rows={2}
					placeholder="What does your organization build?"
					class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] placeholder-[#9aa5b4] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all resize-none"
				></textarea>
			</div>

			<button
				type="submit"
				disabled={loading}
				class="w-full py-2.5 px-4 bg-[#004aff] hover:bg-[#0040dd] disabled:bg-[#9ab3ff] text-white text-sm font-bold rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:ring-offset-2"
			>
				{loading ? 'Creating workspace...' : 'Create workspace'}
			</button>
		</form>
	</div>
</div>
