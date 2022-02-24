local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local M = {}
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

-- local project_actions = require("telescope._extensions.project_actions")

local load_session = function(prompt_bufnr)
  local dir = actions_state.get_selected_entry(prompt_bufnr).value
  actions._close(prompt_bufnr, true)
  local current_sdir = vim.api.nvim_eval('v:this_session')
  if current_sdir or current_sdir ~= '' then --save current session if exist
    vim.fn.execute("mksession! "..current_sdir)
  end
  vim.fn.execute(":bufdo bwipeout!", "silent")
  vim.fn.execute(":so " .. dir, "silent")
end

require('telescope').setup {}

local sessions_picker = function(projects)
  pickers.new({}, {
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
      -- map('i', '<Del>', del_session) -- TODO
      return true
    end
  }):find()
end

local sdir = vim.fn.stdpath('data') ..'/session/' --TODO - use global var or smthign

M.run_sessions_picker = function()
  local projects = {}
  local handle = vim.loop.fs_scandir(sdir)
  if type(handle) == 'string' then
    vim.api.nvim_err_writeln(handle)
    return
  end
  while true do
  	local name, t = vim.loop.fs_scandir_next(handle) -- file_name, dir_type
   	if not name then break end
		if t == 'file' then
			table.insert( projects, {name = name, path = sdir..name})
    end
  end

  sessions_picker(projects)
end

-- return telescope.register_extension {exports = {sessions = run_sessions_picker}}
return M
