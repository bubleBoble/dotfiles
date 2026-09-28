import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { Model } from "@earendil-works/pi-ai";

const STATUS_KEY = "chatgpt-usage";
const USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";
const ACCOUNT_CLAIM = "https://api.openai.com/auth";

type UsageWindow = {
	used_percent?: number;
	reset_after_seconds?: number;
	reset_at?: number;
};

type UsageResponse = {
	rate_limit?: {
		primary_window?: UsageWindow;
		secondary_window?: UsageWindow;
	};
};

function isChatGptModel(model: Model<any> | undefined): boolean {
	return model?.provider === "openai-codex";
}

function getAccountId(token: string): string | undefined {
	try {
		const payload = token.split(".")[1];
		if (!payload) return undefined;
		const decoded = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
		return decoded?.[ACCOUNT_CLAIM]?.chatgpt_account_id;
	} catch {
		return undefined;
	}
}

function formatDuration(seconds: number): string {
	const minutes = Math.max(0, Math.ceil(seconds / 60));
	if (minutes < 60) return `${minutes}m`;

	const hours = Math.floor(minutes / 60);
	const remainingMinutes = minutes % 60;
	if (hours < 24) return remainingMinutes ? `${hours}h${remainingMinutes}m` : `${hours}h`;

	const days = Math.floor(hours / 24);
	const remainingHours = hours % 24;
	return remainingHours ? `${days}d${remainingHours}h` : `${days}d`;
}

function secondsUntilReset(window: UsageWindow): number | undefined {
	if (typeof window.reset_after_seconds === "number" && Number.isFinite(window.reset_after_seconds)) {
		return window.reset_after_seconds;
	}
	if (typeof window.reset_at !== "number" || !Number.isFinite(window.reset_at)) return undefined;
	return window.reset_at - Date.now() / 1000;
}

function formatWindow(label: string, window: UsageWindow | undefined): string | undefined {
	if (!window || typeof window.used_percent !== "number" || !Number.isFinite(window.used_percent)) return undefined;

	const remaining = Math.round(Math.max(0, Math.min(100, 100 - window.used_percent)));
	const resetSeconds = secondsUntilReset(window);
	const reset = resetSeconds === undefined ? "" : ` (reload: ${formatDuration(resetSeconds)})`;
	return `${label} ${remaining}% left${reset}`;
}

function formatUsage(data: UsageResponse): string | undefined {
	const primary = formatWindow("5h", data.rate_limit?.primary_window);
	const secondary = formatWindow("week", data.rate_limit?.secondary_window);
	const windows = [primary, secondary].filter(Boolean);
	return windows.length ? `ChatGPT: ${windows.join(" · ")}` : undefined;
}

function setStatus(ctx: ExtensionContext, text: string | undefined) {
	ctx.ui.setStatus(STATUS_KEY, text === undefined ? undefined : ctx.ui.theme.fg("dim", text));
}

export default function (pi: ExtensionAPI) {
	let refreshGeneration = 0;

	async function refresh(ctx: ExtensionContext, model = ctx.model) {
		const generation = ++refreshGeneration;
		if (!isChatGptModel(model)) {
			setStatus(ctx, undefined);
			return;
		}

		setStatus(ctx, "ChatGPT usage …");

		try {
			const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model!);
			if (!auth.ok || !auth.apiKey) throw new Error("ChatGPT OAuth is unavailable");

			const accountId = getAccountId(auth.apiKey);
			if (!accountId) throw new Error("ChatGPT account is unavailable");

			const response = await fetch(USAGE_URL, {
				headers: {
					Authorization: `Bearer ${auth.apiKey}`,
					"ChatGPT-Account-Id": accountId,
				},
				signal: AbortSignal.timeout(10_000),
			});
			if (!response.ok) throw new Error(`ChatGPT usage request failed (${response.status})`);

			const status = formatUsage((await response.json()) as UsageResponse);
			if (!status) throw new Error("ChatGPT usage response was incomplete");
			if (generation === refreshGeneration) setStatus(ctx, status);
		} catch {
			if (generation === refreshGeneration) setStatus(ctx, "ChatGPT usage unavailable");
		}
	}

	pi.on("session_start", (_event, ctx) => {
		void refresh(ctx);
	});
	pi.on("model_select", (event, ctx) => {
		void refresh(ctx, event.model);
	});
	pi.on("agent_settled", (_event, ctx) => {
		void refresh(ctx);
	});
	pi.on("session_shutdown", (_event, ctx) => {
		refreshGeneration++;
		setStatus(ctx, undefined);
	});
}
