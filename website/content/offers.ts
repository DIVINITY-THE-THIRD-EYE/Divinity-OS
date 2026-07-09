// Intro offer + promo bar copy. Not yet wired into any component (that lands
// with the homepage rebuild); this module exists so the data has one home.

export type IntroOffer = {
  price: string;
  duration: string;
  terms: string;
};

// TODO(PH-005): price/duration are live on the site today; exact terms &
// conditions are unconfirmed.
export const introOffer: IntroOffer = {
  price: "₹99",
  duration: "first week",
  terms: "[PLACEHOLDER: exact terms & conditions for the ₹99 first-week offer — see PLACEHOLDERS.md PH-005]",
};

export const promoBar =
  "[PLACEHOLDER: promo bar text — see PLACEHOLDERS.md PH-005]";
