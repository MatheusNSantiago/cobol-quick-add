local U = require('cobol-quick-add.picture.utils')
local Array = require("cobol-quick-add.shared.array")
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local dropdown = require('telescope.themes').get_dropdown
local t_actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local M = {}

function M.copy_book_dropdown()
  local function entry_maker(option)
    return {
      value = option,
      name = option.name,
      ordinal = option.name,
      display = option.name,
    }
  end

  pickers
      .new(dropdown({}), {
        prompt_title = 'Adicionar Copybook',
        finder = finders.new_table({
          results = M.get_all_copybooks(),
          entry_maker = entry_maker,
        }),
        sorter = conf.generic_sorter(),
        attach_mappings = function(telescope_buf, _)
          local copybook

          t_actions.select_default:replace(function()
            local selected_entry = action_state.get_selected_entry()
            local entry = selected_entry.value

            copybook = entry.name
            t_actions.close(telescope_buf)
          end)
          t_actions.close:enhance({
            post = function(_)
              if copybook then M.add_book(copybook) end
            end,
          })
          return true
        end,
      })
      :find()
end

--  ╾───────────────────────────────────────────────────────────────────────────────────╼
--  ╾───────────────────────────────────────────────────────────────────────────────────╼

function M.get_all_copybooks()
  local copybook_folder = M.get_copybook_dir()

  local files = Array(vim.fn.readdir(copybook_folder))
  local file_paths = files:map(function(file) return copybook_folder .. '/' .. file end)

  return file_paths:map(function(path)
    local is_copybook = path:match('%.cpy$')
    if is_copybook then
      local name = vim.fn.fnamemodify(path, ':t:r')
      local entry = { name = name, path = path }
      return entry
    end
  end)
end

function M.get_copybook_dir()
  local path = vim.fn.expand('%:p')
  while path ~= '/' do
    local parent_dir_path = vim.fn.fnamemodify(path, ':h')
    local parent_dir_files = Array(vim.fn.readdir(parent_dir_path))

    if parent_dir_files:contains('copybook') then --
      return parent_dir_path .. '/copybook'
    end

    path = parent_dir_path
  end

  return path
end

---@param name string: seta o nome do book
function M.add_book(name)
  local first_empty_line_idx = U.get_last_line_for_category('BOOKS')

  local books_category_exists = first_empty_line_idx ~= nil
  if not books_category_exists then
    M.make_heading()
    return M.add_book(name) -- tentar de novo
  end
  if not first_empty_line_idx then return end

  local entry = M.make_entry(name)
  U.insert_lines(first_empty_line_idx, entry)
end

function M.make_entry(name) return { ('%sCOPY %s.'):format(U.spaces(7), name) } end

function M.make_heading()
  local constant_category_last_line = U.get_last_line_for_category('CONSTANTES')
  assert(
    constant_category_last_line,
    'Não foi possível criar BOOKS. Verifique se a categoria anterior, CONSTANTES, existe'
  )
  U.insert_lines(constant_category_last_line, {
    '      *',
    '      *-------------------------- B O O K S ---------------------------*',
    '      *',
  })
end

return M.copy_book_dropdown
