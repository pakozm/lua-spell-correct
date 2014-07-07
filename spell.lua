-- Spelling Corrector.
--
-- Copyright 2014 Francisco Zamora-Martinez
-- Adaptation of Peter Norvig python Spelling Corrector:
-- http://norvig.com/spell-correct.html
-- Open source code under MIT license: http://www.opensource.org/licenses/mit-license.php

local pairs,ipairs = pairs,ipairs
local yield,wrap = coroutine.yield,coroutine.wrap
local alphabet_str,alphabet,model = 'abcdefghijklmnopqrstuvwxyz',{},{}
for a in alphabet_str:gmatch(".") do alphabet[#alphabet+1] = a end

local function list(w) return pairs{[w]=true} end

local function max(...)
  local arg,max,hyp = table.pack(...),0,nil
  for w in table.unpack(arg) do
    local p = model[w] or 1 if p>max or ( p==max and hyp<w ) then hyp,max=w,p end
  end
  return hyp
end

local function words(text) return text:lower():gmatch("[a-z]+") end

local function train(features)
  for f in features do model[f] = (model[f] or 1) + 1 end
end

local function init(filename) train(words(io.open(filename):read("*a"))) end

local make_yield = function()
  local set = {}
  return function(w) if not set[w] then set[w] = true yield(w) end end
end

local function edits1(word_str, yield)
  local yield = yield or make_yield()
  return wrap(function()
      local splits, word = {}, {}
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
  local yield,yield2 = make_yield(),make_yield()
  return wrap(function()
      for e1 in edits1(w) do for e2 in edits1(e1,yield2) do
          if model[e2] then yield( e2 ) end
      end end
  end)
end

local function known(list,aux)
  return wrap(function()
      for w in list,aux do if model[w] then yield(w) end end
  end)
end

local function correct(w)
  local w = w:lower()
  local result = max(known(list(w))) or max(known(edits1(w))) or max(known_edits2(w)) or max(list(w))
  if result then return result else return false,"Unable to find sugestions" end
end

return { init=init, correct=correct, model=model }
