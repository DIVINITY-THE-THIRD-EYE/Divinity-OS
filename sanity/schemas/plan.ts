import { defineField, defineType } from "sanity";

export default defineType({
  name: "plan",
  title: "Membership plan",
  type: "document",
  fields: [
    defineField({ name: "name", title: "Name", type: "string", validation: (r) => r.required() }),
    defineField({ name: "price", title: "Price", type: "string", description: "e.g. ₹3,900" }),
    defineField({ name: "cadence", title: "Cadence", type: "string", description: "e.g. per quarter" }),
    defineField({ name: "blurb", title: "Blurb", type: "text", rows: 2 }),
    defineField({ name: "features", title: "Features", type: "array", of: [{ type: "string" }] }),
    defineField({ name: "featured", title: "Featured?", type: "boolean", initialValue: false }),
    defineField({ name: "order", title: "Order", type: "number" }),
  ],
});
