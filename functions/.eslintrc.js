module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    "jest.config.js", // Ignore Jest config
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "object-curly-spacing": "off",
    "max-len": ["error", { "code": 120 }],
    "indent": ["error", 2],
    "require-jsdoc": "off",
    "@typescript-eslint/no-explicit-any": "warn",
    "no-trailing-spaces": "warn",
    "padded-blocks": "off",
    "arrow-parens": ["error", "as-needed"],
    "operator-linebreak": "off",
    "no-case-declarations": "warn",
  },
};
