<script lang="ts">
	type Status = string;
	const { status, size = 'sm' }: { status: Status; size?: 'xs' | 'sm' } = $props();

	const configs: Record<string, { bg: string; text: string; label: string }> = {
		draft:        { bg: 'bg-[#f5f7fa]',  text: 'text-[#4a5568]',  label: 'Draft' },
		review:       { bg: 'bg-[#ffecc2]',  text: 'text-[#7d5e00]',  label: 'In Review' },
		approved:     { bg: 'bg-[#d3eedf]',  text: 'text-[#0e6b2c]',  label: 'Approved' },
		deprecated:   { bg: 'bg-[#f9d3d8]',  text: 'text-[#600006]',  label: 'Deprecated' },
		active:       { bg: 'bg-[#d3eedf]',  text: 'text-[#0e6b2c]',  label: 'Active' },
		archived:     { bg: 'bg-[#f5f7fa]',  text: 'text-[#4a5568]',  label: 'Archived' },
		'needs-update': { bg: 'bg-[#ffecc2]', text: 'text-[#7d5e00]', label: 'Needs Update' },
		published:    { bg: 'bg-[#d3eedf]',  text: 'text-[#0e6b2c]',  label: 'Published' },
		pending:      { bg: 'bg-[#ffecc2]',  text: 'text-[#7d5e00]',  label: 'Pending' },
	};

	const cfg = $derived(configs[status] ?? { bg: 'bg-[#f5f7fa]', text: 'text-[#4a5568]', label: status });
	const sizeClass = $derived(size === 'xs' ? 'text-[10px] px-1.5 py-0.5' : 'text-xs px-2 py-0.5');
</script>

<span class="inline-flex items-center font-bold rounded-full {cfg.bg} {cfg.text} {sizeClass}">
	{cfg.label}
</span>
