<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageData, ActionData } from './$types';

	const { data, form }: { data: PageData; form: ActionData } = $props();
	let loading = $state(false);
</script>

<div class="p-6 lg:p-8 max-w-xl mx-auto">
	<nav class="flex items-center gap-1 text-xs text-[#9aa5b4] mb-4">
		<a href="/app/org/{data.org?.slug}" class="hover:text-[#004aff]">{data.org?.name}</a>
		<span>/</span>
		<span class="text-[#1a1a1a]">New project</span>
	</nav>

	<h1 class="text-2xl font-bold text-[#1a1a1a] mb-6">Create project</h1>

	{#if form?.error}
		<div class="mb-4 p-3 rounded-lg bg-[#f9d3d8] border border-[#f9a8b4] text-[#600006] text-sm">
			{form.error}
		</div>
	{/if}

	<div class="bg-white rounded-xl border border-[#d9e4ff] p-6">
		<form
			method="POST"
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
				<label for="name" class="block text-xs font-bold text-[#1a1a1a] mb-1">Project name</label>
				<input
					id="name"
					name="name"
					type="text"
					required
					placeholder="Web App"
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
					rows={3}
					placeholder="What does this project cover?"
					class="w-full px-3 py-2 text-sm border border-[#c7d2e1] rounded-lg bg-white text-[#1a1a1a] placeholder-[#9aa5b4] focus:outline-none focus:ring-2 focus:ring-[#004aff] focus:border-transparent transition-all resize-none"
				></textarea>
			</div>

			<div class="flex gap-3 pt-2">
				<a
					href="/app/org/{data.org?.slug}"
					class="flex-1 py-2 px-4 border border-[#d9e4ff] rounded-lg text-sm font-bold text-[#4a5568] hover:bg-[#f5f7fa] transition-colors text-center"
				>
					Cancel
				</a>
				<button
					type="submit"
					disabled={loading}
					class="flex-1 py-2 px-4 bg-[#004aff] text-white text-sm font-bold rounded-lg hover:bg-[#0040dd] disabled:bg-[#9ab3ff] transition-colors"
				>
					{loading ? 'Creating...' : 'Create project'}
				</button>
			</div>
		</form>
	</div>
</div>
