import { defineField, defineType } from "sanity";

export default defineType({
  name: "siteSettings",
  title: "Site settings",
  type: "document",
  fields: [
    defineField({ name: "name", title: "Short name", type: "string" }),
    defineField({ name: "full", title: "Full name", type: "string" }),
    defineField({ name: "city", title: "City", type: "string" }),
    defineField({ name: "entity", title: "Legal entity", type: "string" }),
    defineField({ name: "founder", title: "Founder", type: "string" }),
    defineField({ name: "founderRole", title: "Founder role", type: "string" }),
    defineField({ name: "founderImage", title: "Founder image path", type: "string" }),
    defineField({ name: "est", title: "Established year", type: "string" }),
    defineField({ name: "url", title: "Website URL", type: "url" }),
    defineField({ name: "phone", title: "Phone number", type: "string" }),
    defineField({ name: "whatsapp", title: "WhatsApp number/ID", type: "string" }),
    defineField({ name: "instagram", title: "Instagram URL", type: "url" }),
    defineField({ name: "logoMark", title: "Logo mark path", type: "string" }),
    defineField({ name: "logoFull", title: "Logo full path", type: "string" }),
  ],
});
