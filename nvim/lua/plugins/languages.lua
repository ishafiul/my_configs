return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },

  {
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
    opts = function()
      local asdf_flutter = vim.fn.expand("~/.asdf/shims/flutter")
      local flutter_bin = (vim.fn.executable(asdf_flutter) == 1) and asdf_flutter or "flutter"
      local asdf_dart = vim.fn.expand("~/.asdf/shims/dart")
      local dart_bin = (vim.fn.executable(asdf_dart) == 1) and asdf_dart or "dart"

      return {
        flutter_path = flutter_bin,
        lsp = {
          cmd = { dart_bin, "language-server", "--protocol=lsp" },
          color = {
            enabled = true,
            background = false,
          },
        },
      }
    end,
  },
}
