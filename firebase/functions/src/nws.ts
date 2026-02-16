export interface NwsAlert {
  id: string;
  event: string;
  severity: string;
  headline: string;
  description: string;
  instruction: string;
  effective: string;
  expires: string;
  senderName: string;
  areaDesc: string;
}

const NWS_BASE = "https://api.weather.gov/alerts/active";

/**
 * Fetch active NWS alerts for a given lat/lon point.
 * Returns an empty array on any failure (alerts should never block).
 */
export async function fetchAlerts(
  latitude: number,
  longitude: number
): Promise<NwsAlert[]> {
  try {
    const url = `${NWS_BASE}?point=${latitude},${longitude}`;
    const response = await fetch(url, {
      headers: {
        "User-Agent": "(Heather Weather App Cloud Functions)",
        "Accept": "application/geo+json",
      },
    });

    if (!response.ok) return [];

    const data = (await response.json()) as {
      features?: Array<{ properties: Record<string, unknown> }>;
    };
    const features = data.features ?? [];
    const now = new Date();

    return features
      .map((feature) => {
        const props = feature.properties;
        const expires = props.expires
          ? new Date(props.expires as string)
          : null;

        // Skip expired alerts
        if (expires && expires < now) return null;

        return {
          id: (props.id as string) ?? "",
          event: (props.event as string) ?? "Weather Alert",
          severity: (props.severity as string) ?? "Unknown",
          headline: (props.headline as string) ?? "",
          description: (props.description as string) ?? "",
          instruction: (props.instruction as string) ?? "",
          effective: (props.effective as string) ?? "",
          expires: (props.expires as string) ?? "",
          senderName: (props.senderName as string) ?? "",
          areaDesc: (props.areaDesc as string) ?? "",
        } as NwsAlert;
      })
      .filter((alert): alert is NwsAlert => alert !== null);
  } catch {
    return [];
  }
}
