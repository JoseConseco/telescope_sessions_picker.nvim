local has_telescope, telescope = pcall(require, 'telescope')
-- local session = require('telescope._extensions.sessions_picker.sessions')
local sessions = require('telescope._extensions.sessions_picker.sessions')

if not has_telescope then
	  error('This plugins requires nvim-telescope/telescope.nvim')
end

-- utils.init_files()

-- return telescope.register_extension{
-- 	-- setup = main.setup,
--   exports = { session = session.project }
-- }
return telescope.register_extension {exports = {sessions = sessions.run_sessions_picker}}

