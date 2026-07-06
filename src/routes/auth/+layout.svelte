<script lang="ts">
	const { children } = $props();
</script>

<div class="min-h-screen bg-[#d6dde6] flex items-center justify-center p-4">
	<div class="w-full max-w-md">
		<!-- Logo / Brand -->
		<div class="text-center mb-8">
			<div class="inline-flex items-center gap-2 mb-2">
				<div class="w-8 h-8 rounded-lg bg-[#004aff] flex items-center justify-center">
					<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
						<rect x="2" y="2" width="5" height="5" rx="1" fill="white"/>
						<rect x="9" y="2" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
						<rect x="2" y="9" width="5" height="5" rx="1" fill="white" opacity="0.7"/>
						<rect x="9" y="9" width="5" height="5" rx="1" fill="white"/>
					</svg>
				</div>
				<span class="text-xl font-bold text-[#1a1a1a] font-inter">Atomic DSB</span>
			</div>
			<p class="text-sm text-[#4a5568]">Design System Builder</p>
		</div>

		<!-- Card -->
		<div class="bg-white rounded-2xl border border-[#d9e4ff] shadow-sm p-8">
			{@render children()}
		</div>
	</div>
</div>

<style>
	:global(body) {
		font-family: 'Inter', Helvetica, sans-serif;
	}
</style>
