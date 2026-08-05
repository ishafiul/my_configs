vim.opt.updatetime = 250
vim.opt.mousemoveevent = true

local group = vim.api.nvim_create_augroup("lazyvim_diagnostics_hover", { clear = true })
local mouse_hover_timer = vim.uv.new_timer()
local mouse_close_timer = vim.uv.new_timer()
local hover_window
local hover_request = 0

local function close_hover_window()
  if hover_window and vim.api.nvim_win_is_valid(hover_window) then
    vim.api.nvim_win_close(hover_window, true)
  end
  hover_window = nil

  for _, window in ipairs(vim.api.nvim_list_wins()) do
    local has_lsp_preview = pcall(vim.api.nvim_win_get_var, window, "lsp_floating_bufnr")
    local config = vim.api.nvim_win_get_config(window)
    if has_lsp_preview or (config.relative ~= "" and config.focusable == false) then
      vim.api.nvim_win_close(window, true)
    end
  end
end

local function mouse_over_hover_window(position)
  if not (hover_window and vim.api.nvim_win_is_valid(hover_window)) then
    return false
  end

  local row, col = unpack(vim.api.nvim_win_get_position(hover_window))
  local height = vim.api.nvim_win_get_height(hover_window)
  local width = vim.api.nvim_win_get_width(hover_window)

  return position.screenrow >= row and position.screenrow <= row + height + 2
    and position.screencol >= col and position.screencol <= col + width + 2
end

local function show_lsp_hover_at_mouse(position, request)
  local winid = position.winid
  if winid == 0 or not vim.api.nvim_win_is_valid(winid) then
    return
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    return
  end

  vim.lsp.buf_request_all(bufnr, "textDocument/hover", {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    position = { line = position.line - 1, character = position.column - 1 },
  }, function(results)
    if request ~= hover_request then
      return
    end

    local current = vim.fn.getmousepos()
    if current.winid ~= position.winid or current.line ~= position.line or current.column ~= position.column then
      return
    end

    for _, result in pairs(results) do
      if result.result and result.result.contents then
        local lines = vim.lsp.util.convert_input_to_markdown_lines(result.result.contents)
        if #lines > 0 then
          close_hover_window()
          local _, window = vim.lsp.util.open_floating_preview(lines, "markdown", {
            border = "rounded",
            close_events = { "InsertEnter", "FocusLost" },
            focusable = true,
            max_height = math.max(10, math.floor(vim.o.lines * 0.55)),
            max_width = math.floor(vim.o.columns * 0.75),
            relative = "mouse",
          })
          hover_window = window
          mouse_close_timer:stop()
        end
        return
      end
    end
  end)
end

vim.keymap.set("n", "<MouseMove>", function()
  local position = vim.fn.getmousepos()
  if mouse_over_hover_window(position) then
    mouse_close_timer:stop()
    return
  end

  hover_request = hover_request + 1
  local request = hover_request
  mouse_hover_timer:stop()
  mouse_hover_timer:start(500, 0, vim.schedule_wrap(function()
    local current = vim.fn.getmousepos()
    if current.winid == position.winid and current.line == position.line and current.column == position.column then
      show_lsp_hover_at_mouse(position, request)
    end
  end))
  mouse_close_timer:stop()
  mouse_close_timer:start(750, 0, vim.schedule_wrap(function()
    local current = vim.fn.getmousepos()
    if not mouse_over_hover_window(current) then
      close_hover_window()
    end
  end))
end, { silent = true })

vim.api.nvim_create_autocmd("CursorMoved", {
  group = group,
  callback = function()
    if hover_window and vim.api.nvim_win_is_valid(hover_window) and vim.api.nvim_get_current_win() ~= hover_window then
      close_hover_window()
    end
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  group = group,
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local diagnostics = vim.diagnostic.get(0, { lnum = cursor[1] - 1 })

    if #diagnostics > 0 then
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "if_many",
        prefix = " ",
        scope = "cursor",
      })
      return
    end

  end,
})
