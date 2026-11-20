// main.ts — packages BRAINROT BAZAAR for make.fun: copies the place file,
// the sources, the screenshots and PLAY.json into the output directory,
// then writes the dossier as raw bytes.
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { buildDossier } from "./vendor/makefun-roblox.ts";

const repoRoot = fileURLToPath(new URL(".", import.meta.url));
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";

function copyTree(source: string, target: string): void {
  for (const entry of fs.readdirSync(source, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) {
      continue;
    }
    const from = path.join(source, entry.name);
    const to = path.join(target, entry.name);
    if (entry.isDirectory()) {
      fs.mkdirSync(to, { recursive: true });
      copyTree(from, to);
    } else if (entry.isFile()) {
      fs.copyFileSync(from, to);
    }
  }
}

const placeFile = path.join(repoRoot, "game.rbxl");
if (!fs.existsSync(placeFile)) {
  throw new Error("main.ts: game.rbxl is missing; run rojo build first");
}
fs.mkdirSync(outDir, { recursive: true });
fs.copyFileSync(placeFile, path.join(outDir, "game.rbxl"));
fs.copyFileSync(path.join(repoRoot, "PLAY.json"), path.join(outDir, "PLAY.json"));
fs.mkdirSync(path.join(outDir, "src"), { recursive: true });
copyTree(path.join(repoRoot, "src"), path.join(outDir, "src"));
fs.mkdirSync(path.join(outDir, "screenshots"), { recursive: true });
copyTree(path.join(repoRoot, "screenshots"), path.join(outDir, "screenshots"));

const dossier = buildDossier(outDir, {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
});
if (dossier.length > 1572864) {
  throw new Error(`main.ts: dossier.json is ${dossier.length} bytes, over the 1.5 MiB cap`);
}
fs.writeFileSync(path.join(outDir, "dossier.json"), dossier);
console.log(`dossier.json: ${dossier.length} bytes`);
