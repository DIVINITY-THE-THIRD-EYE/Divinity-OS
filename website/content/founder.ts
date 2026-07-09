// Founder identity — real facts only (PROJECT_RULES #3: never invent).

export type Founder = {
  name: string;
  title: string;
  image: string;
  bio: string;
  credentials: string[];
};

// TODO(PH-002): real certifications/credentials pending — see PLACEHOLDERS.md
export const founder: Founder = {
  name: "Sachin Rajvanshi",
  title: "Founder & Guide",
  image: "/founder.webp",
  bio: "Sachin Rajvanshi founded Divinity to bring breath-led yoga, fitness and therapeutic practice together under one roof in Lucknow — meeting each student where they are and guiding them, patiently, toward where they wish to be.",
  credentials: [
    "[PLACEHOLDER: founder credentials/certifications — see PLACEHOLDERS.md PH-002]",
  ],
};
