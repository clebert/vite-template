import preact from "@preact/preset-vite";
import { defineConfig } from "vite";

export default defineConfig(({ command }) => ({
  base: command === "build" ? "/vite-template/" : "/",
  plugins: [preact()],
}));
