// verify-certificate — public, PII-safe certificate lookup.
//
// Called by the marketing website's /api/verify-certificate route (see
// divinity-third-eye/divinity/app/api/verify-certificate/route.ts), which
// expects a plain GET `?code=DIV-XXXX-XXXX` and a JSON body shaped like
// { valid: boolean, holder?: string, programme?: string, issuedOn?: string }.
//
// Deployed with --no-verify-jwt (see README below) so the public website can
// call it without a Supabase anon/service key. It only ever returns the
// student's first name + last-initial (never phone/email/full name), and
// only for certificates that exist — never any other student data.
//
// Deploy:
//   supabase functions deploy verify-certificate --no-verify-jwt
// Then set on Vercel (website project):
//   CERT_VERIFY_ENDPOINT = https://<project-ref>.supabase.co/functions/v1/verify-certificate

import { createClient } from "jsr:@supabase/supabase-js@2";

const CODE_RE = /^DIV-[A-Z0-9]{4}-[A-Z0-9]{4}$/;

function maskName(fullName: string | null): string {
  if (!fullName) return "Divinity Student";
  const parts = fullName.trim().split(/\s+/);
  const first = parts[0] ?? "Divinity Student";
  const lastInitial = parts.length > 1 ? `${parts[parts.length - 1][0]}.` : "";
  return lastInitial ? `${first} ${lastInitial}` : first;
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const code = (url.searchParams.get("code") ?? "").trim().toUpperCase();

  const cors = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { headers: cors });
  }

  if (!CODE_RE.test(code)) {
    return new Response(
      JSON.stringify({ valid: false, message: "Invalid certificate code format." }),
      { status: 200, headers: { "content-type": "application/json", ...cors } },
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return new Response(
      JSON.stringify({ valid: false, message: "Verification service misconfigured." }),
      { status: 500, headers: { "content-type": "application/json", ...cors } },
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data, error } = await supabase
    .from("certificates")
    .select("programme, issued_on, users:student_id(name)")
    .eq("code", code)
    .maybeSingle();

  if (error) {
    return new Response(
      JSON.stringify({ valid: false, message: "Verification lookup failed. Try again shortly." }),
      { status: 502, headers: { "content-type": "application/json", ...cors } },
    );
  }

  if (!data) {
    return new Response(JSON.stringify({ valid: false }), {
      status: 200,
      headers: { "content-type": "application/json", ...cors },
    });
  }

  const holderName = (data.users as { name: string | null } | null)?.name ?? null;

  return new Response(
    JSON.stringify({
      valid: true,
      holder: maskName(holderName),
      programme: data.programme,
      issuedOn: data.issued_on,
    }),
    { status: 200, headers: { "content-type": "application/json", ...cors } },
  );
});
