local U = require('cobol-quick-add.utils')
local add_indicator = require('cobol-quick-add.picture.indicador')
local add_guarda = require('cobol-quick-add.picture.guarda')
local add_contador = require('cobol-quick-add.picture.contador')

return function()
  local word = U.get_word_under_cursor()
  if not word then return end
  word = word:upper()

  if word:match('^GDA%-') then
    add_guarda(word)
  elseif word:match('^CNT%-') then
    add_contador(word)
  elseif word:match('^IND%-') then
    add_indicator(word)
  elseif word:match('^CND%-') then
    local indicator = word:gsub('CND%-', 'IND%-'):gsub('%-NAO', ''):gsub('%-SIM', '')
    add_indicator(indicator)
  else
    return print(word .. ' não se encaixa em nenhuma categoria')
  end

  -- centraliza a tela
  vim.cmd('normal! zz')
end
