-- Spelling Corrector.
--
-- Copyright 2014 Francisco Zamora-Martinez
-- Adaptation of Peter Norvig python Spelling Corrector:
-- http://norvig.com/spell-correct.html
-- Open source code under MIT license: http://www.opensource.org/licenses/mit-license.php

local alphabet,model = 'abcdefghijklmnopqrstuvwxyz',{}

local function nz(t) return (next(t) and t) or nil end

local function max(t,f)
  local max,hyp=0,nil
  for w in pairs(t) do
    local p = f(w) if p>max or ( p==max and hyp<w ) then hyp,max=w,f(w) end
  end
  return hyp
end

local function words(filename)
  local f = io.open(filename)
  return function()
    local line = f:read("*l")
    if not line then return nil end
    return line:lower():gmatch("[a-z]+")
  end
end

local function train_model(words)
  for w_it in words do for w in w_it do model[w] = (model[w] or 1) + 1 end end
end

local function init(filename) train_model(words(filename)) end

local function edits1(w)
  local set = {}
  for i=1,#w do set[ w:sub(1,i-1) .. w:sub(i+1) ] = true end -- deletes
  for i=1,#w-1 do -- transposes
    set[ w:sub(1,i-1) .. w:sub(i+1,i+1) .. w:sub(i,i) .. w:sub(i+2) ] = true
  end
  for i=1,#w do for j=1,#alphabet do -- replaces
      set[ w:sub(1,i-1) .. alphabet:sub(j,j) .. w:sub(i+1) ] = true
  end end
  for i=0,#w do for j=1,#alphabet do -- inserts
      set[ w:sub(1,i) .. alphabet:sub(j,j) .. w:sub(i+1) ] = true
  end end
  return set
end

local function known_edits2(w)
  local set = {}
  for e1 in pairs(edits1(w)) do for e2 in pairs(edits1(e1)) do
      if model[e2] then set[e2] = true end
  end end
  return set
end

local function known(t)
  local ret = {}
  for w in pairs(t) do if model[w] then ret[w] = true end end
  return ret
end

local function correct(w)
  local w = w:lower()
  local candidates = nz(known{[w]=true}) or nz(known(edits1(w))) or nz(known_edits2(w)) or {[w]=true}
  return max(candidates, function(w) return model[w] or 1 end)
end

return { init=init, correct=correct, model=model }
