-- LazyVim language extras (Mason installs LSP/formatters as needed)
return {
  -- Frontend
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  -- Systems / backend
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.go" },
  -- Docs
  { import = "lazyvim.plugins.extras.lang.markdown" },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
}
