// Membership plans + how to pay for them.

export type Plan = {
  name: string;
  price: string;
  cadence: string;
  blurb: string;
  features?: string[];
  featured?: boolean;
};

// TODO(PH-007): confirm current prices are correct before launch.
export const plans: Plan[] = [
  {
    name: "The Devotee",
    price: "₹3,900",
    cadence: "per quarter",
    blurb: "All disciplines, three months. The complete practice.",
    features: [
      "All yoga & fitness batches",
      "Personalised diet plan",
      "Therapeutic sessions included",
      "Progress & milestone tracking",
      "Priority workshop access",
    ],
    featured: true,
  },
  {
    name: "The Seeker",
    price: "₹1,500",
    cadence: "per month",
    blurb: "One discipline, monthly. The simplest way to begin.",
  },
  {
    name: "The Yogi",
    price: "₹12,000",
    cadence: "per year",
    blurb: "Full annual access, one-on-one guidance, retreats & alumni circle.",
  },
  {
    name: "Drop-in",
    price: "₹200",
    cadence: "per class",
    blurb: "A single class, to feel the space before you commit.",
  },
];

// UPI payment (see public/payment-qr.png). Replace the QR with the academy's
// own before launch — the bank/handle below should match the real account.
export const payment = {
  bank: "UCO Bank",
  qr: "/payment-qr.png",
  note: "Scan with any UPI app — GPay, PhonePe, Paytm — then share a screenshot to confirm your enrolment.",
};
