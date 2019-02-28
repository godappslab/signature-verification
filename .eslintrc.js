module.exports = {
  env: {
    es6: true,
    node: true
  },
  extends: "eslint:recommended",
  parserOptions: {
    ecmaVersion: 2015,
    sourceType: "module"
  },
  rules: {
    indent: [
      "error",
      4,
      {
        SwitchCase: 1
      }
    ],
    "linebreak-style": ["error", "unix"],
    quotes: ["error", "single"],
    semi: ["error", "always"],
    "no-unused-vars": [
      "error",
      {
        args: "after-used",
        argsIgnorePattern: "^_"
      }
    ],
    "no-var": "error",
    "no-irregular-whitespace": ["error", { skipRegExps: true }]
  },
  globals: {
    __: false
  }
};
