"use client";

import { useEffect, useState, useCallback, useRef } from "react";
import { locationConfig } from "@/lib/content";
import {
  getRecommendation,
  mapWmoCode,
  formatTime,
  type WeatherData,
} from "@/lib/weather";

const CACHE_KEY = "divinity_weather_cache";
const CACHE_TTL_MS = 15 * 60 * 1000; // 15 minutes

interface CachedState {
  data: WeatherData;
  timestamp: number;
}

export default function WeatherWidget() {
  const [data, setData] = useState<WeatherData | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const abortRef = useRef<AbortController | null>(null);

  const fetchWeather = useCallback(async (force = false) => {
    // Prevent overlapping parallel fetches
    if (abortRef.current) abortRef.current.abort();
    const controller = new AbortController();
    abortRef.current = controller;

    setLoading(true);
    setError(null);

    // Try reading cache if not forced refresh
    if (!force) {
      try {
        const cached = localStorage.getItem(CACHE_KEY);
        if (cached) {
          const parsed: CachedState = JSON.parse(cached);
          const age = Date.now() - parsed.timestamp;
          if (age < CACHE_TTL_MS) {
            setData(parsed.data);
            setLoading(false);
            return;
          }
        }
      } catch (e) {
        console.warn("Weather cache read error:", e);
      }
    }

    const { latitude, longitude, timezone } = locationConfig;
    const weatherUrl = `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,uv_index&daily=sunrise,sunset&timezone=${encodeURIComponent(timezone)}&forecast_days=1`;
    const aqiUrl = `https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${latitude}&longitude=${longitude}&current=us_aqi&timezone=${encodeURIComponent(timezone)}`;

    try {
      // Run both fetch calls in parallel with a timeout signal
      const timeoutSignal = AbortSignal.any([
        controller.signal,
        AbortSignal.timeout(8000),
      ]);

      const [weatherRes, aqiRes] = await Promise.all([
        fetch(weatherUrl, { signal: timeoutSignal }),
        fetch(aqiUrl, { signal: timeoutSignal }),
      ]);

      if (!weatherRes.ok || !aqiRes.ok) {
        throw new Error("Weather service returned an error status.");
      }

      const weatherJson = await weatherRes.json();
      const aqiJson = await aqiRes.json();

      // Validate JSON structure
      if (
        !weatherJson.current ||
        !weatherJson.daily ||
        !aqiJson.current ||
        typeof weatherJson.current.temperature_2m !== "number" ||
        typeof aqiJson.current.us_aqi !== "number"
      ) {
        throw new Error("Received invalid data structure from API.");
      }

      const temp = weatherJson.current.temperature_2m;
      const aqi = aqiJson.current.us_aqi;
      const wmoCode = weatherJson.current.weather_code;
      const { text: conditionText } = mapWmoCode(wmoCode);

      const parsedData: WeatherData = {
        temp,
        conditionCode: wmoCode,
        conditionText,
        aqi,
        humidity: weatherJson.current.relative_humidity_2m,
        windSpeed: weatherJson.current.wind_speed_10m,
        uvIndex: weatherJson.current.uv_index || 0,
        sunrise: weatherJson.daily.sunrise?.[0]
          ? formatTime(weatherJson.daily.sunrise[0])
          : "--:--",
        sunset: weatherJson.daily.sunset?.[0]
          ? formatTime(weatherJson.daily.sunset[0])
          : "--:--",
        lastUpdated: new Date().toLocaleTimeString("en-US", {
          hour: "numeric",
          minute: "2-digit",
          hour12: true,
        }),
        recommendation: getRecommendation(temp, aqi),
      };

      // Save cache
      try {
        const cachePayload: CachedState = {
          data: parsedData,
          timestamp: Date.now(),
        };
        localStorage.setItem(CACHE_KEY, JSON.stringify(cachePayload));
      } catch (cacheErr) {
        console.warn("Failed to write weather cache:", cacheErr);
      }

      setData(parsedData);
      setError(null);
    } catch (err: any) {
      if (err.name === "AbortError" || err.name === "TimeoutError") {
        console.warn("Weather fetch aborted or timed out.");
      }
      
      // Attempt cached fallback on error
      try {
        const cached = localStorage.getItem(CACHE_KEY);
        if (cached) {
          const parsed: CachedState = JSON.parse(cached);
          setData(parsed.data);
          setError("Failed to fetch fresh weather. Showing cached data.");
          setLoading(false);
          return;
        }
      } catch (e) {}

      setError(
        err.message || "Failed to load weather data. Please check your connection."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchWeather();
    return () => {
      if (abortRef.current) abortRef.current.abort();
    };
  }, [fetchWeather]);

  if (loading) {
    return (
      <div className="border border-[var(--line-dark)] bg-void p-6 animate-pulse" aria-label="Loading weather information">
        <div className="h-4 w-1/3 bg-mist/20 rounded mb-4" />
        <div className="grid grid-cols-2 gap-4">
          <div className="h-10 bg-mist/20 rounded" />
          <div className="h-10 bg-mist/20 rounded" />
        </div>
        <div className="h-8 bg-mist/20 rounded mt-4" />
      </div>
    );
  }

  if (error && !data) {
    return (
      <div className="border border-clay/30 bg-void/50 p-6 text-center" role="alert">
        <p className="font-mono text-[11px] text-clay uppercase tracking-wide">
          Weather service offline
        </p>
        <p className="mt-2 font-body text-sm text-mist">{error}</p>
        <button
          onClick={() => fetchWeather(true)}
          className="mt-4 border border-[var(--line-dark)] px-4 py-2 font-mono text-[10px] uppercase tracking-wider text-bone hover:border-ember hover:text-ember transition-colors"
        >
          Retry
        </button>
      </div>
    );
  }

  if (!data) return null;

  const aqiColor =
    data.aqi <= 50
      ? "text-emerald-400 border-emerald-400/20 bg-emerald-950/20"
      : data.aqi <= 100
      ? "text-amber-400 border-amber-400/20 bg-amber-950/20"
      : "text-rose-400 border-rose-400/20 bg-rose-950/20";

  return (
    <div className="border border-[var(--line-dark)] bg-void p-6 relative overflow-hidden flex flex-col justify-between">
      {/* Background radial highlight */}
      <span
        aria-hidden
        className="pointer-events-none absolute -right-12 -top-12 h-36 w-36 rounded-full"
        style={{
          background:
            "radial-gradient(circle, rgba(208,138,62,0.06), transparent 70%)",
        }}
      />

      <div className="relative">
        <div className="flex items-center justify-between mb-4">
          <p className="eyebrow text-mist">Studio Environment</p>
          <span className="font-mono text-[9px] text-mist/50">
            {error ? "Offline Mode" : `Updated ${data.lastUpdated}`}
          </span>
        </div>

        <div className="flex items-baseline gap-2">
          <span className="font-display text-4xl text-bone">
            {Math.round(data.temp)}°C
          </span>
          <span className="font-body text-sm text-mist">{data.conditionText}</span>
        </div>

        {/* Dynamic wellness recommendation */}
        <div className="mt-4 border-l border-ember pl-3 py-1 bg-ember/[0.02]">
          <p className="font-body text-[13px] italic leading-relaxed text-bone">
            &ldquo;{data.recommendation}&rdquo;
          </p>
        </div>

        <div className="grid grid-cols-2 gap-x-4 gap-y-3 mt-6 border-t border-[var(--line-dark)] pt-4 text-[12px] font-body text-mist">
          <div className="flex justify-between border-b border-[var(--line-dark)]/40 pb-1.5">
            <span>Air Quality (AQI)</span>
            <span className={`px-1.5 py-0.5 rounded border text-[10px] font-mono ${aqiColor}`}>
              {data.aqi}
            </span>
          </div>
          <div className="flex justify-between border-b border-[var(--line-dark)]/40 pb-1.5">
            <span>Humidity</span>
            <span className="text-bone font-mono">{data.humidity}%</span>
          </div>
          <div className="flex justify-between border-b border-[var(--line-dark)]/40 pb-1.5">
            <span>Wind Speed</span>
            <span className="text-bone font-mono">{Math.round(data.windSpeed)} km/h</span>
          </div>
          <div className="flex justify-between border-b border-[var(--line-dark)]/40 pb-1.5">
            <span>UV Index</span>
            <span className="text-bone font-mono">{data.uvIndex}</span>
          </div>
          <div className="flex justify-between pb-0">
            <span>Sunrise</span>
            <span className="text-bone font-mono">{data.sunrise}</span>
          </div>
          <div className="flex justify-between pb-0">
            <span>Sunset</span>
            <span className="text-bone font-mono">{data.sunset}</span>
          </div>
        </div>
      </div>

      {error && (
        <div className="mt-4 p-2 bg-clay/5 border border-clay/10 text-center">
          <p className="font-mono text-[9px] text-clay">{error}</p>
          <button
            onClick={() => fetchWeather(true)}
            className="mt-1 font-mono text-[9px] underline text-bone hover:text-ember transition-colors"
          >
            Retry Refresh
          </button>
        </div>
      )}
    </div>
  );
}
