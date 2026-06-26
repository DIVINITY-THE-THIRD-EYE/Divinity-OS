import { defineField, defineType } from "sanity";

export default defineType({
  name: "discipline",
  title: "Discipline",
  type: "document",
  fields: [
    defineField({ name: "title", title: "Title", type: "string", validation: (r) => r.required() }),
    defineField({
      name: "intention",
      title: "Intention",
      type: "string",
      options: {
        list: [
          { title: "For the body", value: "For the body" },
          { title: "For the breath", value: "For the breath" },
          { title: "For healing", value: "For healing" },
        ],
        layout: "radio",
      },
      validation: (r) => r.required(),
    }),
    defineField({ name: "description", title: "Description", type: "text", rows: 3 }),
    defineField({ name: "tags", title: "Tags", type: "array", of: [{ type: "string" }] }),
    defineField({ name: "order", title: "Order", type: "number" }),
  ],
  orderings: [{ title: "Order", name: "order", by: [{ field: "order", direction: "asc" }] }],
});
