import { defineField, defineType } from "sanity";

export default defineType({
  name: "classSlot",
  title: "Class slot",
  type: "document",
  fields: [
    defineField({
      name: "day",
      title: "Day",
      type: "string",
      options: { list: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], layout: "radio" },
      validation: (r) => r.required(),
    }),
    defineField({ name: "time", title: "Time", type: "string", description: "24h, e.g. 6:00" }),
    defineField({
      name: "batch",
      title: "Batch",
      type: "string",
      options: { list: ["Dawn", "Midday", "Dusk"] },
    }),
    defineField({ name: "name", title: "Class name", type: "string" }),
    defineField({ name: "detail", title: "Detail", type: "string" }),
    defineField({ name: "level", title: "Level", type: "string" }),
    defineField({ name: "order", title: "Order", type: "number" }),
  ],
});
