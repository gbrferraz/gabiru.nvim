local function setup_build()
  local path_sep = package.config:sub(1, 1)
  local build_script = vim.fn.getcwd() .. path_sep .. 'build.bat'

  if vim.fn.filereadable(build_script) == 1 then
    vim.opt_local.makeprg = '"' .. build_script .. '"'
  else
    vim.opt_local.makeprg = 'odin run src'
  end
end

setup_build()

vim.opt_local.errorformat = '%f(%l:%c) %m'

vim.keymap.set('n', '<leader>b', function()
  vim.cmd 'make'
end, { buffer = true, desc = 'Run Odin make' })
