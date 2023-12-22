---@type { name: string, handler: string|function }[]
return {
  { name = 'Adicionar File',     handler = require('cobol-quick-add.picker-actions.add-file') },
  { name = 'Adicionar Copybook', handler = require('cobol-quick-add.picker-actions.add-copybook') },
  { name = 'Limpar Arquivo',     handler = require('cobol-quick-add.picker-actions.clean-file') },
  { name = 'Exportar Arquivo',   handler = require('cobol-quick-add.picker-actions.export-file') },
}
