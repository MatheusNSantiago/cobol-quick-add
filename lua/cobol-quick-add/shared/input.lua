local NuiInput = require('nui.input')
local Class = require("cobol-quick-add.shared.class")

---@class Input
local Input = Class('Input')

---@class InputOptions
---@field on_submit fun(value: string)
---@field on_close? fun(value: string)
---@field title? string
---@field default_value? string
---@field auto_mount? boolean
---@field size? {width: number, height: number}

---@param opts InputOptions
function Input:initialize(opts)
  local popup_options = {
    enter = true,
    relative = 'editor',
    position = '50%',
    size = opts.size or { width = 25, height = 1 },
    border = {
      highlight = 'FloatBorder',
      style = 'single',
      text = { top = opts.title, top_align = 'center' },
      padding = { left = 1 },
    },
  }

  self.input = NuiInput(popup_options, {
    on_submit = opts.on_submit,
    on_close = opts.on_close,
  })

  self.input:on('BufLeave', function() self.input:unmount() end)
  self.input:map('n', 'q', function() self.input:unmount() end)
  self.input:map('i', '<C-c>', function() self.input:unmount() end)

  if opts.auto_mount then self:mount() end
end

function Input:mount() self.input:mount() end
function Input:unmount() self.input:unmount() end

--  ╾───────────────────────────────────────────────────────────────────────────────────╼
---@alias Input.constructor fun(opts: InputOptions): Input
---@type Input|Input.constructor
local _Input = Input
return _Input
