package.path = string.format("?.lua;%s",package.path)
local spell = require "spell"

spell.init("big.txt")

while true do
  io.write("Enter a word (ctrl+d exits): ")
  io.stdout:flush()
  local w = io.read()
  if not w then break end
  print("Sugestion:", assert( spell.correct(w) ))
end
print()
