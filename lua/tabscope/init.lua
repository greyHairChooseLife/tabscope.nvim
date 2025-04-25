local u = require("tabscope.utils")
local rep = require("tabscope.representation")

local M = {}

--- Returns current representation of plugin state.
---@return string
M.get_internal_representation = function()
  local result = ""

  local tracked_buffers =
    rep.buffers("Tracked buffers", M.tracked_buffers.get_buffers(), "")
  result = result .. tracked_buffers .. "--\n"

  local tab_local_buffers =
    rep.tabs("Tab local buffers", M.tab_buffers.get_tab_buffers())
  result = result .. tab_local_buffers .. "--\n"

  result = result .. rep.visible_tabs() .. "--\n"
  result = result .. rep.listed_buffers() .. "--"
  return result
end

--- Launches the plugin
M.setup = function(_)
  M.tracked_buffers = require("tabscope.buffer-managers.tracked").new()
  M.tab_buffers = require("tabscope.buffer-managers.tab").new(M.tracked_buffers)
  M.listed_buffers = require("tabscope.buffer-managers.listed").new(
    M.tracked_buffers,
    M.tab_buffers
  )

  local reset_plugin_state = function()
    M.tracked_buffers.remove_not_visible_buffers()
    M.tab_buffers.remove_not_visible_buffers()
    M.listed_buffers.update()
  end

  u.on_event("SessionLoadPost", reset_plugin_state)
  reset_plugin_state()

  vim.api.nvim_create_user_command("TabScopeDebug", function()
    local output = M.get_internal_representation()
    print(output)
  end, {})
end

-- M.remove_tab_buffer = function(id)
--   if M.tab_buffers == nil then
--     error("The plugin must be initialized")
--   end

--   M.tab_buffers.remove_buffer_for_current_tab(id)
-- end

--- Removes buffer from specified tab (defaults to current tab if not provided)
---@param buf_id number @ buffer to remove
---@param tab_id number|nil @ tab to remove buffer from (defaults to current tab)
M.remove_tab_buffer = function(buf_id, tab_id)
  if M.tab_buffers == nil then
    error("The plugin must be initialized")
  end

  M.tab_buffers.remove_tab_buffer_from_tab(buf_id, tab_id)
end

--- Returns the list of buffer IDs associated with the given tab (or current tab if nil).
---@param tab_id? number The tab page ID. Defaults to the current tab page.
---@return number[] A list of buffer IDs.
M.get_buffers_for_tab = function(tab_id)
  if M.tab_buffers == nil then
    error("The plugin must be initialized via setup()")
  end

  local target_tab_id = tab_id
  if target_tab_id == nil then
    target_tab_id = vim.api.nvim_get_current_tabpage()
  end

  -- Assuming get_buffers_for_tab was added to the object returned by tab.lua's new()
  return M.tab_buffers.get_buffers_for_tab(target_tab_id)
end

--- Removes buffer from specified tab (defaults to current tab if not provided)
---@param buf_id number @ buffer to remove
---@param tab_id number|nil @ tab to remove buffer from (defaults to current tab)
M.remove_tab_buffer_from_tab = function(buf_id, tab_id)
  if M.tab_buffers == nil then
    error("The plugin must be initialized via setup()")
  end

  local target_tab_id = tab_id
  if target_tab_id == nil then
    target_tab_id = vim.api.nvim_get_current_tabpage()
  end

  -- Assuming get_buffers_for_tab was added to the object returned by tab.lua's new()
  return M.tab_buffers.remove_tab_buffer_from_tab(buf_id, target_tab_id)
end

return M
