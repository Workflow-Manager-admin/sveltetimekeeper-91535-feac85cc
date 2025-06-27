<script lang="ts">
	/**
	 * Digital Clock, Stopwatch, Countdown Timer (Svelte)
	 * Modern, minimal, light theme (uses provided palette)
	 */
	import { onMount, onDestroy } from "svelte";

	// Color palette (propagates to CSS vars as needed)
	const primary = "#2563eb";
	const accent = "#eab308";
	const secondary = "#64748b";

	// State for clock
	let now: Date = new Date();
	let interval: ReturnType<typeof setInterval> | null = null;

	// Stopwatch state
	let stopwatchElapsed = 0; // in ms
	let stopwatchRunning = false;
	let stopwatchInterval: ReturnType<typeof setInterval> | null = null;

	// Countdown timer state
	let countdownInput = "00:01:00"; // default: 1 minute
	let countdownTotal = 60; // seconds
	let countdownLeft = 60; // seconds
	let countdownRunning = false;
	let countdownInterval: ReturnType<typeof setInterval> | null = null;

	// Utility: pad numbers to two digits
	function pad(n: number) {
		return n.toString().padStart(2, "0");
	}

	function format(h: number, m: number, s: number, showH = true) {
		return (showH ? `${pad(h)}:` : "") + `${pad(m)}:${pad(s)}`;
	}

	// PUBLIC_INTERFACE
	/** Get digital time as string (HH:MM:SS) */
	$: currentTime = format(now.getHours(), now.getMinutes(), now.getSeconds());

	// Stopwatch formatted time
	$: swH = Math.floor(stopwatchElapsed / 3600000);
	$: swM = Math.floor((stopwatchElapsed % 3600000) / 60000);
	$: swS = Math.floor((stopwatchElapsed % 60000) / 1000);
	$: swMS = Math.floor((stopwatchElapsed % 1000) / 10);
	$: stopwatchTime = format(swH, swM, swS, swH > 0) + `.${pad(swMS)}`;

	// Countdown formatted time
	$: cdH = Math.floor(countdownLeft / 3600);
	$: cdM = Math.floor((countdownLeft % 3600) / 60);
	$: cdS = countdownLeft % 60;
	$: countdownTime = format(cdH, cdM, cdS, cdH > 0);

	// Init clock updater
	onMount(() => {
		interval = setInterval(() => now = new Date(), 1000);
		return () => { if (interval) clearInterval(interval); };
	});
	onDestroy(() => {
		if (interval) clearInterval(interval);
		if (stopwatchInterval) clearInterval(stopwatchInterval);
		if (countdownInterval) clearInterval(countdownInterval);
	});

	// Stopwatch logic
	function toggleStopwatch() {
		stopwatchRunning = !stopwatchRunning;
		if (stopwatchRunning) {
			const start = Date.now() - stopwatchElapsed;
			stopwatchInterval = setInterval(() => {
				stopwatchElapsed = Date.now() - start;
			}, 25);
		} else {
			if (stopwatchInterval) clearInterval(stopwatchInterval);
		}
	}
	function resetStopwatch() {
		stopwatchElapsed = 0;
		if (stopwatchRunning && stopwatchInterval) {
			clearInterval(stopwatchInterval);
			const start = Date.now();
			stopwatchInterval = setInterval(() => {
				stopwatchElapsed = Date.now() - start;
			}, 25);
		}
	}

	// Countdown logic
	function updateCountdownFromInput() {
		const [h = "0", m = "0", s = "0"] = countdownInput.split(":");
		const total =
			parseInt(h) * 3600 + parseInt(m) * 60 + parseInt(s);
		countdownTotal = isNaN(total) ? 0 : total;
		countdownLeft = countdownTotal;
	}
	function toggleCountdown() {
		if (countdownRunning) {
			countdownRunning = false;
			if (countdownInterval) clearInterval(countdownInterval);
			return;
		}
		// When starting, reset based on input if not counting down
		if (countdownLeft <= 0 || countdownLeft > countdownTotal) {
			updateCountdownFromInput();
		}
		countdownRunning = true;
		countdownInterval = setInterval(() => {
			if (countdownLeft > 0) {
				countdownLeft--;
			}
			if (countdownLeft <= 0) {
				countdownRunning = false;
				if (countdownInterval) clearInterval(countdownInterval);
			}
		}, 1000);
	}
	function resetCountdown() {
		if (countdownInterval) clearInterval(countdownInterval);
		countdownLeft = countdownTotal;
		countdownRunning = false;
	}
</script>

<div class="timekeeper-container" style="--primary: {primary}; --accent: {accent}; --secondary: {secondary};">
	<div class="clock-display" aria-label="Digital clock (current time)">
		{currentTime}
	</div>

	<div class="extras">
		<!-- Stopwatch -->
		<div class="sw-cd-block">
			<label class="label" for="stopwatch" style="color: var(--primary)">Stopwatch</label>
			<div class="stopwatch" id="stopwatch">
				<span class="digits">{stopwatchTime}</span>
				<button class="btn btn-primary" on:click={toggleStopwatch} aria-label={stopwatchRunning ? "Pause stopwatch" : "Start stopwatch"}>
					{stopwatchRunning ? "Pause" : "Start"}
				</button>
				<button class="btn btn-secondary" on:click={resetStopwatch} aria-label="Reset stopwatch" disabled={stopwatchRunning && stopwatchElapsed === 0}>
					Reset
				</button>
			</div>
		</div>

		<!-- Countdown Timer -->
		<div class="sw-cd-block">
			<label class="label" for="countdown" style="color: var(--accent)">Countdown</label>
			<div class="countdown" id="countdown">
				<input
					type="text"
					pattern="^\\d{1,2}:\\d{2}:\\d{2}$"
					class="cd-input"
					maxlength={8}
					title="HH:MM:SS"
					bind:value={countdownInput}
					on:change={updateCountdownFromInput}
					aria-label="Set countdown (HH:MM:SS)"
					disabled={countdownRunning}
					style="color: var(--accent)"
				/>
				<span class="digits">{countdownTime}</span>
				<button class="btn btn-accent" on:click={toggleCountdown} aria-label={countdownRunning ? "Pause countdown" : "Start countdown"}>
					{countdownRunning ? "Pause" : "Start"}
				</button>
				<button class="btn btn-secondary" on:click={resetCountdown} aria-label="Reset countdown" disabled={countdownRunning}>
					Reset
				</button>
			</div>
		</div>
	</div>
</div>

<style>
	:global(body) {
		font-family: var(--font-body, Arial, sans-serif);
	}
	.timekeeper-container {
		min-height: 60vh;
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: 3.5rem;
		background: none;
	}
	.clock-display {
		font-size: clamp(3rem, 8vw, 6rem);
		font-weight: 500;
		letter-spacing: 0.08em;
		color: var(--primary);
		background: transparent;
		padding: 0.2em 1.2em;
		border-radius: 1.2em;
		box-shadow: 0 6px 32px 0 rgba(37,99,235,0.09);
		user-select: none;
		text-align: center;
	}
	.extras {
		width: 100%;
		max-width: 33rem;
		display: flex;
		flex-direction: row;
		flex-wrap: wrap;
		justify-content: center;
		align-items: stretch;
		gap: 2rem;
	}
	.sw-cd-block {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.6rem;
		flex: 1 1 210px;
		min-width: 190px;
		background: rgba(246,248,252,0.7);
		border-radius: 1.2rem;
		box-shadow: 0 2px 11px 0 rgba(100,116,139,0.10);
		padding: 1.3rem 1.1rem 1.1rem 1.1rem;
	}
	.label {
		font-size: 1rem;
		font-weight: 400;
		letter-spacing: 0.08em;
		margin-bottom: 0.3em;
	}
	.stopwatch, .countdown {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.5rem;
		width: 100%;
	}
	.digits {
		font-size: clamp(1.4rem, 3vw, 2.1rem);
		font-family: var(--font-mono, monospace);
		letter-spacing: 0.14em;
		margin-bottom: 0.13em;
		color: var(--secondary);
	}
	.stopwatch .digits {
		color: var(--primary);
	}
	.countdown .digits {
		color: var(--accent);
	}

	.cd-input {
		font-size: 1rem;
		width: 6em;
		text-align: center;
		border-radius: 0.6em;
		border: 1.5px solid var(--accent);
		padding: 0.3em 0.7em;
		margin-bottom: 0.23em;
		background: #fffbe6;
		caret-color: var(--accent);
		box-shadow: none;
		font-family: var(--font-mono, monospace);
	}
	.cd-input:disabled {
		background: #fafafa;
		color: #c1ac4b;
		opacity: 0.9;
	}

	.btn {
		font-size: 0.97rem;
		padding: 0.34em 1em;
		border-radius: 0.6em;
		border: none;
		cursor: pointer;
		font-weight: 500;
		margin-right: 0.2em;
		transition: background 0.14s, color 0.14s, border 0.18s;
		box-shadow: 0 1px 5px 0 rgba(100,116,139,0.09);
	}
	.btn-primary {
		background: var(--primary);
		color: #fff;
	}
	.btn-primary:active, .btn-primary:hover, .btn-primary:focus {
		background: #194CA3;
	}
	.btn-accent {
		background: var(--accent);
		color: #38340b;
	}
	.btn-accent:active, .btn-accent:hover, .btn-accent:focus {
		background: #b79307;
		color: #fff;
	}
	.btn-secondary {
		background: #f3f5f6;
		color: var(--secondary);
		border: 1.1px solid var(--secondary);
	}
	.btn-secondary:active, .btn-secondary:focus, .btn-secondary:hover {
		background: var(--secondary);
		color: #fff;
	}

	.btn[disabled] {
		opacity: 0.5;
		cursor: not-allowed;
	}
	@media (max-width: 870px) {
		.extras {
			flex-direction: column;
			gap: 1.4rem;
			align-items: stretch;
		}
	}
	@media (max-width: 620px) {
		.timekeeper-container {
			gap: 2rem;
		}
		.sw-cd-block {
			min-width: unset;
			padding: 1rem 0.6rem 0.8rem 0.6rem;
		}
		.clock-display {
			font-size: clamp(2.2rem, 11vw, 4.1rem);
		}
	}
</style>
