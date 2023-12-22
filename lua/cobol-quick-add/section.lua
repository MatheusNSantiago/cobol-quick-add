local Input = require('cobol-quick-add.input')
local defaults = require('cobol-quick-add.utils').defaults
local M = {}

---@class  AddSectionInputOpts
---@field title? string
---@field default_value? string
---@field position? { row: number, col: number }
---@field size? { width: number, height: number }
---@field after? function

---@class AddSectionOpts
---@field line_number number
---@field bufnr number
---@field win number
---@field input? AddSectionInputOpts

---@param opts? AddSectionOpts
function M.add_section(opts)
  opts = opts or { input = {} }
  local line_number = opts.line_number or vim.fn.line('.')
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local win = opts.win or vim.api.nvim_get_current_win()

  Input({
    auto_mount = true,
    title = defaults(opts.input.title, 'Nova seção'),
    default_value = opts.input.default_value,
    position = opts.input.position,
    size = opts.input.size,
    on_close = opts.input.after,
    on_submit = function(header)
      header = header:upper()

      local header_number = header:match('^(%d+)-') or ''
      local header_number_99 = header_number:gsub('%d%d$', '99')

      local template = {
        '*',
        '*---------------------------------------*',
        header,
        '*---------------------------------------*',
        '*',
        ' ',
        '*',
        ' ' .. header_number_99 .. '-SAI.',
        '     EXIT.',
        '*',
      }

      local full_len = template[2]:len()

      M.add_left_pad(template)

      local section = 'SECTION.'
      local middle_pad = full_len - #header - #section
      template[3] = ' ' .. template[3] .. string.rep(' ', middle_pad - 1) .. section

      vim.api.nvim_buf_set_lines(bufnr, line_number - 1, line_number, false, template)

      -- coloca o cursor no meio da seção
      vim.api.nvim_set_current_win(win)
      vim.api.nvim_win_set_cursor(win, { line_number + 5, 8 })

      if opts.input.after then opts.input.after() end
    end,
  })
end

--- adiconar padding até a seção A
function M.add_left_pad(lines)
  for i, text in ipairs(lines) do
    lines[i] = string.rep(' ', 6) .. text
  end
end

return M
