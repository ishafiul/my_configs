local M = {}
local controls_namespace = vim.api.nvim_create_namespace("flutter-controls")

local state = {
  controls_buf = nil,
  controls_win = nil,
  device = nil,
  job = nil,
  run_buf = nil,
  run_win = nil,
  launch_config = nil,
  workspace_root = nil,
  root = nil,
  controls_row = 1,
  controls_col = nil,
  drag = nil,
}

local controls = {
  "[▶ Run]",
  "[⌁ Device]",
  "[⚙ Config]",
  "[▣ Emulator]",
  "[↻ Reload]",
  "[⟳ Restart]",
  "[■ Stop]",
}

local function controls_line()
  return table.concat(controls, " ")
end

local function is_running()
  return state.job and vim.fn.jobwait({ state.job }, 0)[1] == -1
end

local function flutter_root()
  local root = vim.fs.root(0, { "pubspec.yaml" })
  if root then
    state.root = root
    return root
  end

  if state.root and vim.fn.isdirectory(state.root) == 1 then
    return state.root
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
      root = vim.fs.root(name, { "pubspec.yaml" })
      if root then
        state.root = root
        return root
      end
    end
  end
end

local function launch_file()
  local directory = flutter_root() or vim.uv.cwd()
  while directory do
    local candidate = directory .. "/.vscode/launch.json"
    if vim.uv.fs_stat(candidate) then
      state.workspace_root = directory
      return candidate
    end
    local parent = vim.fs.dirname(directory)
    if parent == directory then
      break
    end
    directory = parent
  end
end

local function config_cwd(config)
  local cwd = config.cwd or state.workspace_root or flutter_root()
  if not cwd then
    return nil
  end
  return cwd:gsub("${workspaceFolder}", state.workspace_root or "")
end

local function load_launch_file()
  local path = launch_file()
  if not path then
    return nil
  end

  local ok, launch = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok then
    return nil
  end
  return launch
end

local function write_controls()
  if not (
    state.controls_buf
    and vim.api.nvim_buf_is_valid(state.controls_buf)
    and state.controls_win
    and vim.api.nvim_win_is_valid(state.controls_win)
  ) then
    return
  end

  local status = is_running() and "Running" or "Stopped"
  local device = state.device and state.device.name or "No device"
  vim.bo[state.controls_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.controls_buf, 0, -1, false, { controls_line() })
  vim.bo[state.controls_buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(state.controls_buf, controls_namespace, 0, -1)
  vim.api.nvim_buf_add_highlight(state.controls_buf, controls_namespace, "FlutterControls", 0, 0, -1)
  local config = state.launch_config and state.launch_config.name or "Default"
  vim.api.nvim_win_set_config(state.controls_win, { title = string.format(" Flutter • %s • %s • %s ", status, device, config) })
end

local function move_controls(delta_row, delta_col)
  if not (state.controls_win and vim.api.nvim_win_is_valid(state.controls_win)) then
    return
  end

  local width = vim.fn.strdisplaywidth(controls_line())
  state.controls_row = math.max(0, math.min(vim.o.lines - 2, state.controls_row + delta_row))
  state.controls_col = math.max(0, math.min(vim.o.columns - width - 2, state.controls_col + delta_col))
  vim.api.nvim_win_set_config(state.controls_win, {
    relative = "editor",
    row = state.controls_row,
    col = state.controls_col,
  })
end

local function open_controls()
  flutter_root()
  M.auto_select_device()
  if state.controls_win and vim.api.nvim_win_is_valid(state.controls_win) then
    write_controls()
    return
  end

  state.controls_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.controls_buf].bufhidden = "wipe"
  vim.bo[state.controls_buf].filetype = "flutter-controls"
  local width = vim.fn.strdisplaywidth(controls_line())
  state.controls_col = state.controls_col or math.max(0, vim.o.columns - width - 4)
  state.controls_win = vim.api.nvim_open_win(state.controls_buf, false, {
    border = "rounded",
    col = state.controls_col,
    focusable = true,
    height = 1,
    relative = "editor",
    row = state.controls_row,
    style = "minimal",
    title = " Flutter ",
    width = width,
    zindex = 60,
  })
  vim.api.nvim_set_hl(0, "FlutterControls", { fg = "#c8d3f5", bg = "#1e2030", bold = true })
  vim.wo[state.controls_win].winblend = 0
  vim.wo[state.controls_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = state.controls_buf,
    once = true,
    callback = function()
      state.controls_buf = nil
      state.controls_win = nil
    end,
  })
  vim.keymap.set("n", "<LeftMouse>", function()
    local position = vim.fn.getmousepos()
    state.drag = {
      row = position.screenrow,
      col = position.screencol,
      moved = false,
    }
  end, { buffer = state.controls_buf, silent = true })
  vim.keymap.set("n", "<LeftDrag>", function()
    local drag = state.drag
    if not drag then
      return
    end
    local position = vim.fn.getmousepos()
    move_controls(position.screenrow - drag.row, position.screencol - drag.col)
    drag.row = position.screenrow
    drag.col = position.screencol
    drag.moved = true
  end, { buffer = state.controls_buf, silent = true })
  vim.keymap.set("n", "<LeftRelease>", function()
    local drag = state.drag
    state.drag = nil
    if not drag or drag.moved then
      return
    end
    local position = vim.fn.getmousepos()
    local actions = { M.run, M.select_device, M.select_config, M.launch_emulator, M.reload, M.restart, M.stop }
    local column = 1
    for index, label in ipairs(controls) do
      local width = vim.fn.strdisplaywidth(label)
      if position.wincol >= column and position.wincol < column + width then
        actions[index]()
        return
      end
      column = column + width + 1
    end
  end, { buffer = state.controls_buf, silent = true })
  write_controls()
end

local function send(command)
  if not is_running() then
    vim.notify("Flutter app is not running", vim.log.levels.WARN)
    return
  end
  vim.fn.chansend(state.job, command)
end

local function close_run_panel(delete_buffer)
  if state.run_win and vim.api.nvim_win_is_valid(state.run_win) then
    vim.api.nvim_win_close(state.run_win, true)
  end
  state.run_win = nil

  if delete_buffer and state.run_buf and vim.api.nvim_buf_is_valid(state.run_buf) then
    vim.api.nvim_buf_delete(state.run_buf, { force = true })
    state.run_buf = nil
  end
end

function M.stop()
  if is_running() then
    vim.fn.chansend(state.job, "q\n")
  end
  state.job = nil
  close_run_panel(true)
  write_controls()
end

function M.reload()
  send("r\n")
end

function M.restart()
  send("R\n")
end

local function run_on_device(device, config)
  local root = config_cwd(config or {}) or flutter_root()
  if not root then
    vim.notify("No pubspec.yaml found for this buffer", vim.log.levels.ERROR)
    return
  end
  if is_running() then
    M.stop()
  end

  state.device = device
  vim.cmd("botright 15new")
  state.run_win = vim.api.nvim_get_current_win()
  state.run_buf = vim.api.nvim_get_current_buf()
  vim.bo[state.run_buf].bufhidden = "wipe"
  vim.bo[state.run_buf].filetype = "flutter-run"
  vim.api.nvim_buf_set_name(state.run_buf, "Flutter Run")
  vim.wo[state.run_win].winfixheight = true
  local run_buffer = state.run_buf
  local command = { "flutter", "run", "-d", device.id }
  for _, argument in ipairs((config and config.args) or {}) do
    table.insert(command, argument)
  end
  local job = vim.fn.termopen(command, {
    cwd = root,
    on_exit = function()
      vim.schedule(function()
        if state.job == job then
          state.job = nil
        end
        if state.run_buf == run_buffer then
          close_run_panel(true)
        end
        write_controls()
      end)
    end,
  })
  state.job = job
  vim.cmd("startinsert")
  open_controls()
  write_controls()
end

local function list_devices(callback)
  local root = flutter_root()
  if not root then
    vim.notify("Open a Flutter project file first", vim.log.levels.ERROR)
    return
  end
  vim.system({ "flutter", "devices", "--machine" }, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(result.stderr ~= "" and result.stderr or "Could not list Flutter devices", vim.log.levels.ERROR)
        return
      end
      local ok, devices = pcall(vim.json.decode, result.stdout)
      if not ok or #devices == 0 then
        vim.notify("No Flutter devices available", vim.log.levels.WARN)
        return
      end
      callback(devices)
    end)
  end)
end

function M.auto_select_device(after_select)
  if state.device then
    if after_select then
      after_select(state.device)
    end
    return
  end

  list_devices(function(devices)
    state.device = devices[1]
    write_controls()
    if after_select then
      after_select(state.device)
    end
  end)
end

function M.select_device(after_select)
  list_devices(function(devices)
      vim.ui.select(devices, {
        format_item = function(device)
          return string.format("%s (%s)", device.name, device.id)
        end,
        prompt = "Flutter device",
      }, function(device)
        if not device then
          return
        end
        state.device = device
        write_controls()
        if after_select then
          after_select(device)
        end
      end)
  end)
end

function M.launch_emulator()
  vim.system({ "flutter", "emulators" }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(result.stderr ~= "" and result.stderr or "Could not list Flutter emulators", vim.log.levels.ERROR)
        return
      end

      local emulators = {}
      for line in result.stdout:gmatch("[^\r\n]+") do
        local id, name = vim.trim(line):match("^([^%s]+)%s+•%s+([^•]+)")
        if id and name and id ~= "Id" then
          table.insert(emulators, { id = id, name = vim.trim(name) })
        end
      end
      if #emulators == 0 then
        vim.notify("No Flutter emulators configured", vim.log.levels.WARN)
        return
      end

      vim.ui.select(emulators, {
        format_item = function(emulator)
          return string.format("%s (%s)", emulator.name, emulator.id)
        end,
        prompt = "Launch Flutter emulator",
      }, function(emulator)
        if not emulator then
          return
        end
        vim.system({ "flutter", "emulators", "--launch", emulator.id }, { text = true }, function(launch)
          vim.schedule(function()
            if launch.code == 0 then
              vim.notify("Emulator starting. Use [Device] after it finishes booting.")
            else
              vim.notify(launch.stderr ~= "" and launch.stderr or "Could not launch emulator", vim.log.levels.ERROR)
            end
          end)
        end)
      end)
    end)
  end)
end

local function run_node_config(config)
  local root = config_cwd(config)
  if not root or not config.command then
    vim.notify("Launch configuration is missing cwd or command", vim.log.levels.ERROR)
    return
  end
  vim.cmd("tabnew")
  vim.api.nvim_buf_set_name(0, "Run: " .. config.name)
  vim.fn.termopen({ "/bin/zsh", "-lc", config.command }, { cwd = root })
  vim.cmd("startinsert")
end

function M.select_config()
  local launch = load_launch_file()
  if not launch then
    vim.notify("No .vscode/launch.json found", vim.log.levels.WARN)
    return
  end
  local choices = {}
  for _, config in ipairs(launch.configurations or {}) do
    table.insert(choices, { kind = "config", value = config })
  end
  for _, compound in ipairs(launch.compounds or {}) do
    table.insert(choices, { kind = "compound", value = compound })
  end
  vim.ui.select(choices, {
    format_item = function(choice)
      local suffix = choice.kind == "compound" and "compound" or choice.value.type
      return string.format("%s (%s)", choice.value.name, suffix)
    end,
    prompt = "Launch configuration",
  }, function(choice)
    if choice then
      state.launch_config = choice.value
      state.launch_kind = choice.kind
      write_controls()
    end
  end)
end

function M.run()
  local config = state.launch_config
  if state.launch_kind == "compound" and config then
    local path = launch_file()
    local launch = path and vim.json.decode(table.concat(vim.fn.readfile(path), "\n")) or {}
    for _, name in ipairs(config.configurations or {}) do
      for _, item in ipairs(launch.configurations or {}) do
        if item.name == name and item.type == "node-terminal" then
          run_node_config(item)
        end
      end
    end
    return
  end
  if config and config.type == "node-terminal" then
    run_node_config(config)
    return
  end
  if state.device then
    run_on_device(state.device, config)
  else
    M.auto_select_device(function(device)
      run_on_device(device, config)
    end)
  end
end

vim.api.nvim_create_user_command("FlutterControls", open_controls, {})
vim.api.nvim_create_user_command("FlutterDevices", M.select_device, {})
vim.api.nvim_create_user_command("FlutterConfig", M.select_config, {})
vim.api.nvim_create_user_command("FlutterEmulators", M.launch_emulator, {})
vim.api.nvim_create_user_command("FlutterRun", M.run, {})
vim.api.nvim_create_user_command("FlutterReload", M.reload, {})
vim.api.nvim_create_user_command("FlutterRestart", M.restart, {})
vim.api.nvim_create_user_command("FlutterStop", M.stop, {})

vim.keymap.set("n", "<leader>F", open_controls, { desc = "Flutter Controls" })
vim.keymap.set("n", "<F5>", M.run, { desc = "Run Flutter" })

return M
