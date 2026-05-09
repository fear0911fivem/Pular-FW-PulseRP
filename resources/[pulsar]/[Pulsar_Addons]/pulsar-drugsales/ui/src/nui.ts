const resourceName = (): string =>
  typeof (window as unknown as { GetParentResourceName?: () => string }).GetParentResourceName === "function"
    ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
    : "pulsar-drugsales";

export async function postNui<T = unknown>(event: string, data?: unknown): Promise<T | void> {
  const res = await fetch(`https://${resourceName()}/${event}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data ?? {}),
  });
  const text = await res.text();
  if (!text) return undefined;
  try {
    return JSON.parse(text) as T;
  } catch {
    return text as unknown as T;
  }
}
