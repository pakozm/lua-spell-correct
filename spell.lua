-- Spelling Corrector.
--
-- Copyright 2014 Francisco Zamora-Martinez
-- Adaptation of Peter Norvig python Spelling Corrector:
-- http://norvig.com/spell-correct.html
-- Open source code under MIT license: http://www.opensource.org/licenses/mit-license.php

local pairs,ipairs = pairs,ipairs
local coroutine_yield,coroutine_wrap = coroutine.yield,coroutine.wrap
local alphabet_str,alphabet,model = 'abcdefghijklmnopqrstuvwxyz',{},{}
for a in alphabet_str:gmatch(".") do alphabet[#alphabet+1] = a end

local function list(w) return pairs{[w]=true} end

local function max(...)
  local model = model
  local f = function(w) return model[w] or 1 end
  local max,hyp=0,nil
  for _,it in ipairs{...} do
    for w in it[1],it[2] do
      local p = f(w) if p>max or ( p==max and hyp<w ) then hyp,max=w,f(w) end
    end
    if hyp then return hyp end
  end
  return false,"Unable to find sugestions"
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
  local model = model
  for w_it in words do for w in w_it do model[w] = (model[w] or 1) + 1 end end
end

local function init(filename) train_model(words(filename)) end

local make_yield = function()
  local set = {}
  return function(w) if not set[w] then set[w] = true coroutine_yield(w) end end
end

local function edits1(word_str)
  local yield = make_yield()
  return coroutine_wrap(function()
      local set, splits, word = {}, {}, {}
      for i=1,#word_str do
        word[i],splits[i] = word_str:sub(i,i),{word_str:sub(1,i),word_str:sub(i)}
      end
      -- sentinels
      splits[0], splits[#word_str+1] = { "", word_str }, { word_str, ""}
      -- deletes
      for i=1,#word_str do yield( splits[i-1][1]..splits[i+1][2] ) end
      -- transposes
      for i=1,#word_str-1 do
        yield( splits[i-1][1]..word[i+1]..word[i]..splits[i+2][2] )
      end
      -- replaces
      for i=1,#word_str do for j=1,#alphabet do
          yield( splits[i-1][1]..alphabet[j]..splits[i+1][2] )
      end end
      -- inserts
      for i=0,#word_str do for j=1,#alphabet do
          yield( splits[i][1]..alphabet[j]..splits[i+1][2] )
      end end
  end)
end

local function known_edits2(w, set)
  local yield = make_yield()
  return coroutine_wrap(function()
      for e1 in edits1(w) do for e2 in edits1(e1) do
          if model[e2] then yield( e2 ) end
      end end
  end)
end

local function known(list,aux)
  return coroutine_wrap(function()
      for w in list,aux do if model[w] then coroutine_yield(w) end end
  end)
end

local function correct(w)
  local w = w:lower()
  return max({known(list(w))}, {known(edits1(w))}, {known_edits2(w)}, {list(w)})
end

return { init=init, correct=correct, model=model }
