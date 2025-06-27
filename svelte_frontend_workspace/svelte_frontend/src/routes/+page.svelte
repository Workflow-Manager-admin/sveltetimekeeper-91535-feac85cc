<script lang="ts">
	import Timekeeper from './Timekeeper.svelte';
</script>

<svelte:head>
	<title>Timekeeper</title>
	<meta name="description" content="A modern Svelte digital clock, stopwatch, and countdown timer" />
</svelte:head>

<Timekeeper />

<style>
	:global(.timekeeper-container) {
		margin-top: 2.5rem;
	}
</style>
