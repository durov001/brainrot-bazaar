// BRAINROT BAZAAR: copy the entry into the output dir and write its dossier.
import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildDossier } from "./vendor/makefun-roblox.ts";

const root = fileURLToPath(new URL(".", import.meta.url));
const target = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";
const skipDotfiles = (p: string): boolean => !basename(p).startsWith(".");

mkdirSync(target, { recursive: true });
copyFileSync(join(root, "game.rbxl"), join(target, "game.rbxl"));
copyFileSync(join(root, "PLAY.json"), join(target, "PLAY.json"));
cpSync(join(root, "src"), join(target, "src"), { recursive: true, filter: skipDotfiles });
mkdirSync(join(target, "screenshots"), { recursive: true });
if (existsSync(join(root, "screenshots"))) {
	cpSync(join(root, "screenshots"), join(target, "screenshots"), { recursive: true, filter: skipDotfiles });
}

const caps = {
	text_max_bytes: 65536,
	screenshots: { max: 4, max_bytes: 262144 },
	max_instances: 500000,
	scripts_max_source_bytes: 8388608,
	scripts_max_path_chars: 1048576,
};
const dossier = buildDossier(target, caps);
writeFileSync(join(target, "dossier.json"), dossier);
