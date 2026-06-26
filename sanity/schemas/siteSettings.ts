import { defineField, defineType } from "sanity";

export default defineType({
  name: "siteSettings",
  title: "Site settings",
  type: "document",
  fields: [
    defineField({ name: "full", title: "Full name", type: "string" }),
    defineField({ name: "city", title: "City", type: "string" }),
    defineField({ name: "entity", title: "Legal entity", type: "string" }),
    defineField({ name: "founder", title: "Founder", type: "string" }),
    defineField({ name: "founderRole", title: "Founder role", type: "string" }),
    defineField({ name: "instagram", title: "Instagram URL", type: "url" }),
    defineField({ name: "whatsapp", title: "WhatsApp URL", type: "url" }),
  ],
});
