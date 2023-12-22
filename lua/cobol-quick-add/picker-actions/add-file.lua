local Menu = require('cobol-quick-add.shared.menu')
local Input = require('cobol-quick-add.shared.input')

local U = require('cobol-quick-add.utils')
local lsp = require('cobol-quick-add.lsp')
local M = {}

function M.add_file()
  M.buf = vim.api.nvim_get_current_buf()

  local menu = Menu({
    title = 'Tipo de arquivo',
    items = { 'Entrada', 'Saída' },
    size = { width = 20, height = 2 },
    on_submit = function(item)
      local filename

      M.input_sequence({
        title = 'Nome do arquivo',
        on_submit = function(value)
          local es = item.text == 'Entrada' and 'E' or 'S'
          filename = value:upper() .. es
          M.insert_file_control_entry(filename)
        end,
      }, {
        title = 'Tamanho do arquivo',
        on_submit = function(value) M.insert_file_description(filename, value) end,
      })
    end,
  })
  menu:mount()
end

function M.insert_file_control_entry(filename)
  local entry = ('%sSELECT %s ASSIGN TO UT-S-%s.'):format(U.spaces(11), filename, filename)

  lsp.tree_provider(function(tree)
    local input_output_sec = lsp.search_node('INPUT-OUTPUT SECTION', tree)
    if not input_output_sec then return end

    local file_assignments = input_output_sec.children

    local is_first_assignment = #file_assignments == 0
    if is_first_assignment then
      local first_entry_line = input_output_sec.range.start + 5

      local comment = U.spaces(6) .. '*'
      M.insert_lines(first_entry_line, { entry, comment })
      return
    end

    local last_assignment = file_assignments[#file_assignments]
    local last_assignment_line = last_assignment.range.finish + 1

    M.insert_lines(last_assignment_line + 1, { entry })
  end)
end

function M.insert_file_description(filename, filesize)
  local description = {
    U.spaces(7) .. 'FD  ' .. filename,
    U.spaces(11) .. 'BLOCK  0',
    U.spaces(11) .. 'RECORD ' .. filesize,
    U.spaces(11) .. 'RECORDING F.',
    U.spaces(6) .. '*',
    U.spaces(7) .. ('01  REGISTRO-%s%sPIC X(%s).'):format(filename, U.spaces(20 - #filename), filesize),
  }
  lsp.tree_provider(function(tree)
    local file_sec = lsp.search_node('FILE SECTION', tree)
    if not file_sec then return end

    local file_descriptions = file_sec.children

    local is_first_description = #file_descriptions == 0
    if is_first_description then
      local first_description_line = file_sec.range.start + 1
      M.insert_lines(first_description_line + 4, description)

      return
    end
    local last_description = file_descriptions[#file_descriptions]
    local last_description_line = last_description.range.finish + 1

    table.insert(description, 1, U.spaces(6) .. '*')
    M.insert_lines(last_description_line + 6, description)
  end)
end

---@param ... { title : string, on_submit : fun(value: string) }
function M.input_sequence(...)
  local inputs = { ... }
  if #inputs == 0 then return end
  local opts = table.remove(inputs, 1)

  local input
  input = Input({
    title = opts.title,
    on_submit = function(value)
      opts.on_submit(value)
      input:unmount()

      M.input_sequence(unpack(inputs))
    end,
  })
  input:mount()
end

function M.insert_lines(line_idx, lines)
  vim.api.nvim_buf_set_lines(M.buf or 0, line_idx - 1, line_idx - 1, false, lines) --
end

return M.add_file
