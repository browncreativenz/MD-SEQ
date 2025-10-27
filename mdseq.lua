-- MD-SEQ ///////
-- v1.3 @browncreativenz
-- Generative performance sequencer
-- for the Elektrok Machinedrum
--
-- Grid controller recommended
-- K2+K3 : Toggle between grid 
-- screen and save screen
--
-- GRID SCREEN (default)
-- --------------------
--   K2 : Randomize the current pattern
--   K3 : Reset randomness values
--   E2 : Select track (1-16)
--   E3 : Adjust randomness value 
--        for selected track (0-10) 
--
-- SAVE SCREEN
-- -----------
--   K2 : Save pattern to the 
--        selected slot
--   K3 : Play the selected slot
--   E2 : Select save slot (1-4)

engine.name = nil

local midi_out
local steps = 16
local tracks = 16
local pattern = {}
local randomness = {}
local step_pos = 1
local clk
local running = true

local md_notes = {36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51}
local selected_track = 1

local pulse = {}
local pulse_decay = 0.6

-- grid
local g = grid.connect()

-- structured save slots
local saves = {}
local save_index = 1
local active_save = 0

-- save screen
local save_screen_active = false
local save_selected_slot = 1

-- combo detection
local k2_down = false
local k3_down = false
local suppress_key_actions_until_releases = false

-- global swing (seconds delay applied to off-beats)
local swing_amount = 0.0    -- 0.0 .. 0.6 (seconds)
local swing_step = 0.05     -- increment per tap (seconds)
local swing_max = 0.6
local swing_min = 0.0

-- helpers
local function copy_pattern(src)
  local dst = {}
  for t=1,tracks do
    dst[t] = {}
    for s=1,steps do dst[t][s] = src[t][s] end
  end
  return dst
end

local function copy_randomness(src)
  local dst = {}
  for t=1,tracks do dst[t] = src[t] end
  return dst
end

function init()
  midi_out = midi.connect(1)
  for t=1,tracks do
    pattern[t] = {}
    for s=1,steps do pattern[t][s] = (math.random()<0.2) and 1 or 0 end
    randomness[t] = 0
    pulse[t] = 0
  end
  for i=1,4 do saves[i] = {pattern=nil, randomness=nil, saved=false} end
  clk = clock.run(seq)
end

-- sequencer
function seq()
  while true do
    clock.sync(1/4) -- wait for next 16th
    -- apply swing on even steps (off-beat)
    if running and (step_pos % 2 == 0) and swing_amount > 0 then
      -- small delay to push the off-beat later
      clock.sleep(swing_amount)
    end

    if running then
      for t=1,tracks do
        local base_trigger = pattern[t][step_pos] == 1
        if base_trigger then
          midi_out:note_on(md_notes[t],100,10)
          pulse[t] = 1.0
        end
        if not base_trigger and randomness[t] > 0 then
          for i=1,randomness[t] do
            if math.random(steps) == step_pos then
              midi_out:note_on(md_notes[t],100,10)
              pulse[t] = 1.0
            end
          end
        end
      end
      step_pos = (step_pos % steps) + 1
    end

    redraw()
    grid_redraw()
  end
end

-- save / recall
local function save_to_slot(slot)
  if slot <1 or slot>4 then return end
  saves[slot].pattern = copy_pattern(pattern)
  saves[slot].randomness = copy_randomness(randomness)
  saves[slot].saved = true
  -- active_save not changed
  grid_redraw()
  redraw()
end

local function save_from_grid_rotating()
  save_to_slot(save_index)
  save_index = (save_index%4)+1
end

local function recall_slot(slot)
  if slot<1 or slot>4 then return end
  if not saves[slot].saved then return end
  pattern = copy_pattern(saves[slot].pattern)
  randomness = copy_randomness(saves[slot].randomness)
  active_save = slot
  grid_redraw()
  redraw()
end

-- encoders
function enc(n,d)
  if save_screen_active then
    if n==2 then
      save_selected_slot = util.clamp(save_selected_slot+d,1,4)
      redraw()
    end
    return
  end

  if n==2 then
    selected_track = util.clamp(selected_track+d,1,tracks)
    redraw()
    grid_redraw()
  elseif n==3 then
    randomness[selected_track] = util.clamp(randomness[selected_track]+d,0,10)
    redraw()
    grid_redraw()
  end
end

-- keys
function key(n,z)
  if n==2 then k2_down = (z==1) end
  if n==3 then k3_down = (z==1) end

  if z==1 then
    if n==2 and k3_down or n==3 and k2_down then
      save_screen_active = not save_screen_active
      suppress_key_actions_until_releases = true
      save_selected_slot = util.clamp(save_selected_slot,1,4)
      redraw()
      grid_redraw()
      return
    end
  end

  if suppress_key_actions_until_releases then
    if not (k2_down or k3_down) then
      suppress_key_actions_until_releases = false
    end
    return
  end

  if z==1 then
    if save_screen_active then
      if n==2 then save_to_slot(save_selected_slot)
      elseif n==3 then recall_slot(save_selected_slot) end
    else
      if n==2 then
        randomize_pattern()
        active_save = 0
      elseif n==3 then
        reset_randomness()
      end
    end
  end
end

-- grid keys
function g.key(x,y,z)
  if z~=1 then return end

  -- Swing controls (grid): increase = row 7, x=16 ; decrease = row 8, x=16
  if x == 16 and y == 7 then
    swing_amount = util.clamp(swing_amount + swing_step, swing_min, swing_max)
    redraw()
    grid_redraw()
    return
  elseif x == 16 and y == 8 then
    swing_amount = util.clamp(swing_amount - swing_step, swing_min, swing_max)
    redraw()
    grid_redraw()
    return
  end

  if y==2 and x<=tracks then selected_track=x
  elseif y==3 and x<=tracks then randomness[x]=util.clamp(randomness[x]+1,0,10)
  elseif y==4 and x<=tracks then randomness[x]=util.clamp(randomness[x]-1,0,10)
  elseif y==5 then
    if x==1 then randomize_pattern(); active_save=0
    elseif x==2 then reset_randomness() end
  elseif y==6 then
    if x==1 then save_from_grid_rotating()
    elseif x>=3 and x<=6 then recall_slot(x-2) end
  elseif y==7 then
    if x==1 then running=true; step_pos=1
    elseif x==2 then running=false end
  end
  redraw()
  grid_redraw()
end

-- grid redraw
function grid_redraw()
  if not g then return end
  g:all(0)
  for s=1,steps do
    g:led(s,1,(s==step_pos) and 2 or 0)
  end
  for t=1,tracks do
    local level=2
    if pulse[t]>0 then level=4 end
    if t==selected_track then level=math.max(level,10) end
    g:led(t,2,level)
  end
  for t=1,tracks do
    g:led(t,3,math.floor(randomness[t]/10*15))
    g:led(t,4,math.floor(randomness[t]/10*15))
  end
  g:led(1,5,8); g:led(2,5,8)
  for slot=1,4 do
    if saves[slot].saved then
      local level=5
      if active_save==slot then
        local beat=math.floor(clock.get_beats()*4)%2
        level=(beat==0) and 10 or 3
      end
      g:led(slot+2,6,level)
    else g:led(slot+2,6,0) end
  end
  -- swing indicators on grid: map swing_amount (0..swing_max) to 0..15
  local swing_level = math.floor((swing_amount / swing_max) * 15 + 0.5)
  g:led(16,7, swing_level) -- increase-pad brightness shows amount
  g:led(16,8, swing_level) -- decrease-pad shows same amount (dims as it decreases)
  g:led(1,6,8)
  g:led(1,7,running and 15 or 5)
  g:led(2,7,not running and 15 or 5)
  g:refresh()
end

-- pattern helpers
function randomize_pattern()
  for t=1,tracks do for s=1,steps do pattern[t][s]=(math.random()<0.2) and 1 or 0 end end
end
function reset_randomness() for t=1,tracks do randomness[t]=0 end end

-- redraw
function redraw()
  screen.clear()
  if save_screen_active then
    local box_w,box_h,spacing=20,20,12
    local total_w=4*box_w+3*spacing
    local start_x=math.floor((128-total_w)/2)
    local start_y=math.floor((64-box_h)/2)
    for slot=1,4 do
      local x=start_x+(slot-1)*(box_w+spacing)
      local y=start_y
      screen.level(2)
      screen.rect(x,y,box_w,box_h)
      screen.fill()
      if saves[slot].saved then
        screen.level(6)
        screen.rect(x,y,box_w,box_h)
        screen.fill()
      end
      if active_save==slot then
        local beat=math.floor(clock.get_beats()*4)%2
        screen.level((beat==0) and 15 or 12)
        screen.rect(x,y,box_w,box_h)
        screen.fill()
      end
      if save_selected_slot==slot then
        screen.level(15)
        screen.rect(x-2,y-2,box_w+4,box_h+4)
        screen.stroke()
      end
    end
    screen.level(15)
    screen.move(64,62)
    screen.text_center("E2=select  K2=save  K3=recall")
  else
    local box_w,box_h,margin_x,margin_y=10,8,4,14
    local start_x,start_y_top=4,30
    local start_y_bottom=start_y_top+box_h+margin_y
    for t=1,tracks do
      local row=(t<=8) and 1 or 2
      local index=(row==1) and t or t-8
      local x=start_x+(index-1)*(box_w+margin_x)
      local y=(row==1) and start_y_top or start_y_bottom
      screen.level(2)
      screen.rect(x,y,box_w,box_h)
      screen.fill()
      if pulse[t]>0 then
        screen.level(15)
        screen.rect(x,y,box_w,box_h)
        screen.fill()
      end
      if t==selected_track then
        screen.level(15)
        screen.rect(x,y,box_w,box_h)
        screen.stroke()
      end
      screen.level(15)
      screen.move(x,y-6)
      screen.text_right(string.format("%2d",randomness[t]))
      pulse[t]=util.clamp(pulse[t]-pulse_decay,0,1)
    end
  end
  screen.update()
end