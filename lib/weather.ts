export interface WeatherData {
  temp: number;
  conditionCode: number;
  conditionText: string;
  aqi: number;
  humidity: number;
  windSpeed: number;
  uvIndex: number;
  sunrise: string;
  sunset: string;
  lastUpdated: string;
  recommendation: string;
}

export function getRecommendation(temp: number, aqi: number): string {
  if (aqi > 100) {
    return "Better to practice indoors today.";
  }
  if (temp > 38) {
    return "Consider restorative sessions due to heat.";
  }
  if (temp > 35) {
    return "Stay hydrated during afternoon classes.";
  }
  if (aqi <= 50 && temp >= 18 && temp <= 30) {
    return "Excellent day for outdoor yoga.";
  }
  if (temp < 15) {
    return "Warm up dynamically indoors today.";
  }
  return "Good conditions for pranayama.";
}

export function mapWmoCode(code: number): { text: string; icon: string } {
  switch (code) {
    case 0:
      return { text: "Clear Sky", icon: "☀️" };
    case 1:
    case 2:
    case 3:
      return { text: "Partly Cloudy", icon: "🌤️" };
    case 45:
    case 48:
      return { text: "Foggy", icon: "🌫️" };
    case 51:
    case 53:
    case 55:
      return { text: "Drizzle", icon: "🌦️" };
    case 61:
    case 63:
    case 65:
      return { text: "Rainy", icon: "🌧️" };
    case 71:
    case 73:
    case 75:
      return { text: "Snowy", icon: "❄️" };
    case 80:
    case 81:
    case 82:
      return { text: "Showers", icon: "🌦️" };
    case 95:
    case 96:
    case 99:
      return { text: "Thunderstorm", icon: "⛈️" };
    default:
      return { text: "Cloudy", icon: "☁️" };
  }
}

export function formatTime(isoString: string): string {
  try {
    const date = new Date(isoString);
    if (isNaN(date.getTime())) return "--:--";
    return date.toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
  } catch {
    return "--:--";
  }
}
