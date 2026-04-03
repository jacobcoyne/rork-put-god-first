import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

app.use("*", cors());

app.get("/", (c) => {
  return c.json({ status: "ok", message: "API is running" });
});

app.post("/chat", async (c) => {
  const apiKey = process.env.EXPO_PUBLIC_ANTHROPIC_API_KEY;
  if (!apiKey) {
    return c.json({ error: "API key not configured" }, 500);
  }

  const body = await c.req.json();
  const { messages, system } = body;

  if (!messages || !Array.isArray(messages)) {
    return c.json({ error: "Messages array is required" }, 400);
  }

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      system: system || "",
      messages,
    }),
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    return c.json(
      { error: (errorData as any)?.error?.message || `Claude API error: ${response.status}` },
      response.status as any
    );
  }

  const data = await response.json();
  const content = (data as any)?.content;
  if (!content || !Array.isArray(content) || content.length === 0) {
    return c.json({ error: "Empty response from Claude" }, 502);
  }

  const text = content[0]?.text || "";
  return c.json({ text });
});

export default app;
