"use client";

import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { Locale, locales, translate } from "./translations";

const STORAGE_KEY = "divinity_locale";

type LocaleContextValue = {
  locale: Locale;
  setLocale: (l: Locale) => void;
  t: (text: string) => string;
};

const LocaleContext = createContext<LocaleContextValue>({
  locale: "en",
  setLocale: () => {},
  t: (text: string) => text,
});

export function LocaleProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>("en");

  useEffect(() => {
    const saved = window.localStorage.getItem(STORAGE_KEY);
    if (saved && locales.includes(saved as Locale)) {
      setLocaleState(saved as Locale);
    }
  }, []);

  const setLocale = (l: Locale) => {
    setLocaleState(l);
    window.localStorage.setItem(STORAGE_KEY, l);
  };

  const value = useMemo(
    () => ({ locale, setLocale, t: (text: string) => translate(locale, text) }),
    [locale]
  );

  return <LocaleContext.Provider value={value}>{children}</LocaleContext.Provider>;
}

export function useLocale() {
  return useContext(LocaleContext);
}
