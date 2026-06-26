import { defineField, defineType } from "sanity";

export default defineType({
  name: "testimonial",
  title: "Testimonial",
  type: "document",
  fields: [
    defineField({ name: "quote", title: "Quote", type: "text", rows: 3, validation: (r) => r.required() }),
    defineField({ name: "name", title: "Name", type: "string", validation: (r) => r.required() }),
    defineField({ name: "meta", title: "Meta", type: "string", description: "e.g. Member · 8 months" }),
    defineField({ name: "order", title: "Order", type: "number" }),
  ],
});
