-- Keymaps are loaded automatically on the VeryLazy event
-- Default keymaps: https://www.lazyvim.org/configuration/keymaps

vim.keymap.set("n", "<leader>ac", function()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  local tabs = {}

  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= "" then
        table.insert(tabs, name)
      end
    end
  end

  local msg = "Context:\n"
    .. "- Active file: "
    .. file
    .. "\n"
    .. "- Cursor: line "
    .. line
    .. ", col "
    .. col
    .. "\n"
    .. "- Open tabs:\n  - "
    .. table.concat(tabs, "\n  - ")

  vim.fn.setreg("+", msg)
  print("Copied IDE context to clipboard")
end, { desc = "Copy IDE context for AI" })
