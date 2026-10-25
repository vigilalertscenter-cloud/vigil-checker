// Runs automatically before "npm run deploy". Stops with a plain message if a setup step was skipped.
import { readFileSync } from "node:fs";
const toml = readFileSync(new URL("./wrangler.toml", import.meta.url), "utf8");
const live = toml.split("\n").filter((l) => !l.trim().startsWith("#")).join("\n");   // ignore commented-out lines
const problems = [];
if (/PASTE-DATABASE-ID-HERE/.test(live) || !/database_id\s*=\s*"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"/i.test(live))
  problems.push("database_id in wrangler.toml is not set. Run `npx wrangler d1 create vigil-db`, then paste the id it prints (Part A, step 2).");
const pub = (live.match(/^\s*VAPID_PUBLIC\s*=\s*"([^"]*)"/m) || [])[1] || "";
if (!/^[A-Za-z0-9_-]{86,88}$/.test(pub))
  problems.push("VAPID_PUBLIC in wrangler.toml is not set. Run `python make_keys.py` and paste the VAPID_PUBLIC value (Part A, steps 4 and 5).");
if (!/^\s*VAPID_SUBJECT\s*=\s*"mailto:[^"\s@]+@[^"\s@]+"/m.test(live))
  problems.push('VAPID_SUBJECT in wrangler.toml must look like "mailto:you@example.com".');
if (problems.length) {
  console.error("\nNot deployed yet. Please fix this first:\n");
  problems.forEach((p, i) => console.error(`  ${i + 1}. ${p}`));
  console.error("");
  process.exit(1);
}
console.log("wrangler.toml looks complete. Deploying...");
