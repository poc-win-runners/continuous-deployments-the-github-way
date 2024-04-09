import { nodeResolve } from "@rollup/plugin-node-resolve";

export default {
    input: "main.mjs",
    output: {
        file: "bundle.js",
        format: "iife",
    },
    plugins: [nodeResolve()],
};
