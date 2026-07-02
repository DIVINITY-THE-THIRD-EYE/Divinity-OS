import { describe, it, expect } from "vitest";
import { translate, locales } from "./translations";
import { navItems, legalItems, footerGroups } from "@/lib/nav";

describe("translate", () => {
  it("returns the original text unchanged for 'en'", () => {
    expect(translate("en", "About")).toBe("About");
    expect(translate("en", "Some untranslated string")).toBe("Some untranslated string");
  });

  it("translates known nav labels to Hindi", () => {
    expect(translate("hi", "About")).toBe("परिचय");
    expect(translate("hi", "Services")).toBe("सेवाएं");
    expect(translate("hi", "Contact")).toBe("संपर्क करें");
  });

  it("falls back to the English text for an untranslated key", () => {
    expect(translate("hi", "Some brand-new label nobody translated yet")).toBe(
      "Some brand-new label nobody translated yet"
    );
  });

  it("supports exactly en and hi", () => {
    expect(locales).toEqual(["en", "hi"]);
  });

  it("has a Hindi translation for every nav/footer label used on the site", () => {
    const allLabels = new Set<string>();
    for (const item of navItems) allLabels.add(item.label);
    for (const item of legalItems) allLabels.add(item.label);
    for (const group of footerGroups) {
      allLabels.add(group.title);
      for (const item of group.items) allLabels.add(item.label);
    }

    for (const label of allLabels) {
      expect(translate("hi", label), `missing Hindi translation for "${label}"`).not.toBe(label);
    }
  });
});
