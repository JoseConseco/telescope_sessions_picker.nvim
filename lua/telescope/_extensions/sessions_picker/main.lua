P = function(v)
	print(vim.inspect(v))
	return v
end

local has_telescope, telescope = pcall(require, 'telescope')
local has_minisessions, mini = pcall(require, 'mini.sessions')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local M = {}
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local sessions_dir = vim.fn.stdpath('data') ..'/session/' --TODO - use global var or smthign
-- local project_actions = require("telescope._extensions.project_actions")

local load_session = function(prompt_bufnr)
  local dir = actions_state.get_selected_entry(prompt_bufnr).value
  actions.close(prompt_bufnr, true)
  local current_sdir = vim.api.nvim_eval('v:this_session')
  if has_minisessions then
    if MiniSessions.config.autowrite then
      vim.fn.execute("mksession! "..current_sdir)
    end
  else if current_sdir or current_sdir ~= '' then --save current session if exist
    vim.fn.execute("mksession! "..current_sdir)
  end
	--  vim.fn.execute(":LspStop", "silent")
	--  vim.fn.execute(":bufdo bwipeout!", "silent")
	--  vim.fn.execute(":%bd!", "silent")
	--  vim.fn.execute(":so " .. dir, "silent")
	-- vim.fn.execute(":normal zx", "silent")
	-- vim.fn.execute(":LspStart", "silent")
  -- Stop all LSP clients first
	for _, client in pairs(vim.lsp.get_active_clients()) do
		vim.lsp.stop_client(client)
	end

  -- Scedule buffers cleanup to avoid callback issues and source the session
  vim.schedule(function()
    -- Delete all buffers first except the current one to avoid entering buffers scheduled for deletion
    local current_buffer = vim.api.nvim_get_current_buf()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buffer) and buffer ~= current_buffer then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
    vim.api.nvim_buf_delete(current_buffer, { force = true })

    vim.api.nvim_command('silent source ' .. dir)
    -- vim.api.nvim_command('doautocmd User SessionLoadPost')
  end)
end


local new_session = function(prompt_bufnr)
  -- local dir = actions_state.get_selected_entry(prompt_bufnr).value
  actions.close(prompt_bufnr, true)
  -- local current_sdir = vim.api.nvim_eval('v:this_session')
	local current_dir = vim.fn.getcwd()
	-- get last directory from current_dir path
	local last_dir_name = string.match(current_dir, "/[^/]*/?$")  -- match  /dir/ from eg /home/user/dir/
	if last_dir_name:sub(-1) == "/" then
		last_dir_name = last_dir_name:sub(2, -2) -- delete first and last slash
	else
		last_dir_name = last_dir_name:sub(2)
	end
	local picked_name = vim.fn.input('New Session Name: ', last_dir_name)
	if picked_name == '' then
		return
	end
	local session_file = sessions_dir..'/'..picked_name
	vim.fn.execute("mksession! "..session_file)
	vim.api.nvim_echo({{'Created: '..session_file,}}, true, {})
end

local del_session = function(prompt_bufnr)
  local dir = actions_state.get_selected_entry(prompt_bufnr).value
  actions.close(prompt_bufnr, true)
	local user_answer = vim.fn.confirm('Remove: '..dir, "&Yes\n&No")
	if user_answer == 1 then
		os.remove(dir)
		vim.api.nvim_echo({{'Removed: '..dir}}, true, {})
	end
end

-- require('telescope').setup {}

local sessions_picker = function(projects, opts)
  pickers.new(opts, {
    prompt_title = 'Select a session',
    results_title = 'Sessions',
    finder = finders.new_table {
      results = projects,
      entry_maker = function(entry)
        return {
          value = entry.path,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    },
    sorter = conf.file_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', load_session)
      map('i', '<C-n>', new_session) -- TODO
      map('i', '<Del>', del_session) -- TODO
      return true
    end
  }):find()
end


M.setup = function(ext_config)
		sessions_dir = ext_config.sessions_dir or vim.fn.stdpath('data') ..'/session/'
end

M.run_sessions_picker = function(opts)
	opts = opts or {}
  local handle = vim.loop.fs_scandir(sessions_dir)
	-- P(handle)
	if handle == nil then
		print('Setup correct \'sessions_dir\': "' .. sessions_dir .. '" does not seem to exist. Cancelling')
		return
	end

  if type(handle) == 'string' then
    vim.api.nvim_err_writeln(handle)
    return
  end
  local existing_projects = {}
  while true do
  	local name, t = vim.loop.fs_scandir_next(handle) -- file_name, dir_type
   	if not name then break end
		if t == 'file' then
			table.insert( existing_projects, {name = name, path = sessions_dir..name})
    end
  end
  sessions_picker(existing_projects, opts)
end

-- return telescope.register_extension {exports = {sessions = run_sessions_picker}}
return M
