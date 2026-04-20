vim.opt.updatetime = 250

local group = vim.api.nvim_create_augroup("lazyvim_diagnostics_hover", { clear = true })

vim.api.nvim_create_autocmd("CursorHold", {
  group = group,
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "if_many",
      prefix = " ",
      scope = "cursor",
    })
  end,
})
