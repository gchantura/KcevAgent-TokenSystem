<script lang="ts">
	const { status, size = 'sm' }: { status: string; size?: 'xs' | 'sm' } = $props();

	const map: Record<string, string> = {
		draft: 'badge-draft',
		active: 'badge-active',
		approved: 'badge-approved',
		review: 'badge-review',
		deprecated: 'badge-deprecated',
		'needs-update': 'badge-needs-update',
		archived: 'badge-archived',
		published: 'badge-published',
		pending: 'badge-pending',
		suspended: 'badge-suspended',
		primitive: 'badge-primitive',
		semantic: 'badge-semantic',
		component: 'badge-component',
		custom: 'badge-custom',
	};

	const labels: Record<string, string> = {
		draft: 'Draft',
		active: 'Active',
		approved: 'Approved',
		review: 'In review',
		deprecated: 'Deprecated',
		'needs-update': 'Needs update',
		archived: 'Archived',
		published: 'Published',
		pending: 'Pending',
		suspended: 'Suspended',
		primitive: 'Primitive',
		semantic: 'Semantic',
		component: 'Component',
		custom: 'Custom',
	};

	const cls = $derived(map[status] ?? 'badge-draft');
	const label = $derived(labels[status] ?? status);
	const sizeStyle = $derived(size === 'xs' ? 'font-size:10px;padding:1px 5px;' : '');
</script>

<span class="badge {cls}" style={sizeStyle}>{label}</span>
