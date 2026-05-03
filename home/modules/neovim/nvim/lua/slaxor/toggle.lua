local M = {}

-- Define toggle pairs
local toggles = {
  ["true"]		=	"false",
  ["yes"]			=	"no",
  ["on"]			=	"off",
  ["1"]				=	"0",
  ["+"]				=	"-",
  ["ifdef"]		=	"ifndef",
  ["if"]			=	"if !",
  ["always"]	=	"never",
  ["all"]			=	"none",
  ["left"]		=	"right",
  ["north"]		=	"south",
  ["east"]		=	"west",
  ["ja"]	    =	"nein",
  ["an"]	    =	"aus",
  ["immer"]	  =	"nie",
  ["alles"]		=	"nichts",
  ["links"]		=	"rechts",
  ["nord"]		=	"süd",
  ["ost"]			=	"west",
}

for k, v in pairs(vim.deepcopy(toggles)) do
  toggles[v] = k
end

local function match_case(from, to)
  if from:match("^[A-Z]+$") then
    return to:upper()
  elseif from:match("^[A-Z]") then
    return to:sub(1,1):upper() .. to:sub(2)
  else
    return to:lower()
  end
end

local function toggle_word()
  local word = vim.fn.expand("<cword>")
  local lower = word:lower()
  local repl = toggles[lower]
  if repl then
    vim.cmd("normal! ciw" .. match_case(word, repl))
  else
    vim.notify("No toggle mapping for: " .. word, vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command("ToggleWord", toggle_word, {})
vim.keymap.set("n", "=", toggle_word, { desc = "Toggle word under cursor" })

return M

