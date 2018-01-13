import resolve from "rollup-plugin-node-resolve";

export default {
    input: "fiber-demo-lit-html.js",
    output: {
        file: "../../docs/fiber-demo-lit-html.js",
        format: "iife"
    },
    plugins: [resolve()]
};
