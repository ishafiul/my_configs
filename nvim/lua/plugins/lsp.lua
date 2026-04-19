local function ensure_items(list, items)
  list = list or {}
  local seen = {}
  for _, v in ipairs(list) do
    seen[v] = true
  end
  for _, v in ipairs(items) do
    if not seen[v] then
      table.insert(list, v)
      seen[v] = true
    end
  end
  return list
end

return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = ensure_items(opts.ensure_installed, {
        "vtsls",
        "eslint",
        "biome",
        "tailwindcss",
        "jsonls",
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = ensure_items(opts.ensure_installed, {
        "typescript-language-server",
        "vtsls",
        "eslint-lsp",
        "biome",
        "tailwindcss-language-server",
        "json-lsp",
        "prettierd",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover Documentation" })
        end,
      })
    end,
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      local asdf_dart = vim.fn.expand("~/.asdf/shims/dart")
      local dart_bin = (vim.fn.executable(asdf_dart) == 1) and asdf_dart or "dart"

      opts.servers.dartls = vim.tbl_deep_extend("force", opts.servers.dartls or {}, {
        cmd = { dart_bin, "language-server", "--protocol=lsp" },
      })

      opts.servers.biome = vim.tbl_deep_extend("force", opts.servers.biome or {}, {})
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      local biome_fts = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
      }

      for _, ft in ipairs(biome_fts) do
        opts.formatters_by_ft[ft] = { "biome" }
      end
    end,
  },
}
