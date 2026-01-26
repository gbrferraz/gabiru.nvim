vim.opt_local.errorformat = '%f(%l): %t%*[^ ] %m'

local function run_build(build_type, on_success)
  vim.cmd 'write' -- Save file
  print 'Building...'

  -- Prepare command: cmd /c build.bat [release]
  local cmd = { 'cmd', '/c', 'build.bat' }
  if build_type then
    table.insert(cmd, build_type)
  end

  -- Run asynchronously
  vim.system(cmd, { text = true }, function(obj)
    -- Schedule UI updates back to the main thread
    vim.schedule(function()
      local output = obj.stdout .. '\n' .. obj.stderr
      local lines = vim.split(output, '\n')

      -- Populate Quickfix list
      vim.fn.setqflist({}, 'r', {
        title = 'Build Output',
        lines = lines,
        efm = vim.bo.errorformat,
      })

      if obj.code ~= 0 then
        print 'Build Failed!'
        vim.cmd 'copen' -- Show errors
      else
        print 'Build Success!'
        vim.cmd 'cclose' -- Hide errors

        -- EXECUTE THE CALLBACK (Run the game)
        if on_success then
          on_success()
        end
      end
    end)
  end)
end

-- 3. Keybindings
local map = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { buffer = true, desc = 'C: ' .. desc })
end

-- [F5] QUICKEST LOOP: Build Debug -> If Success -> Run
map('<F5>', function()
  run_build(nil, function()
    -- This runs only if build code == 0
    vim.cmd '!start bin\\debug\\game.exe'
  end)
end, 'Build & Run')

-- Standard Mappings
map('<leader>b', function()
  run_build(nil)
end, 'Build Only (Debug)')
map('<leader>B', function()
  run_build 'release'
end, 'Build Only (Release)')
map('<leader>r', function()
  vim.cmd '!start bin\\debug\\game.exe'
end, 'Run Last Build')

-- Debugger
map('<leader>d', function()
  local raddbg_path = 'C:\\Tools\\raddbg\\raddbg.exe' -- Check path!
  local game_path = vim.fn.getcwd() .. '\\bin\\debug\\game.exe'
  vim.cmd('!start "" "' .. raddbg_path .. '" "' .. game_path .. '"')
end, 'Debug with RAD')
