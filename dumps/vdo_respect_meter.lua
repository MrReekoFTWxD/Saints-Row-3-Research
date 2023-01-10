function vdo_respect_meter_init()
	
	
end

-- Inherited from Vdo_base_object
Vdo_respect_meter = Vdo_base_object:new_base()

--Local Constants...

--Used to keep track of the the state of the meter.
local RESPECT_STATE_REST 						= 0		-- If we are ready to update...
local RESPECT_STATE_RESPECT 					= 1		-- If we are getting respect...
local RESPECT_STATE_RANKUP 					= 2		-- If we are going to rank up...
local RESPECT_STATE_UPGRADE 					= 3		-- If we are in upgrade state...
local RESPECT_STATE_RETURNING 				= 4		-- If we are returning back to be ready for update...


--Queue IDs, used for queuing up the rankup/upgrade stuff.
local RESPECT_QUEUE_NOTHING = 0 			
local RESPECT_QUEUE_RANKUP = 1 
local RESPECT_QUEUE_RANKUP_UPGRADE = 2 

local RESPECT_START_ANGLE = 2.65
local RESPECT_END_ANGLE = 2.6 	-- This is really negative, but entering as positive to make equation work


--Standard Init...
function Vdo_respect_meter:init()
	--Replace button images
	self.back_button_img = get_back_image()
	self.back_button_key = game_get_key_name_for_action( "CBA_GAC_MAP_MENU" )
	self.button_h = Vdo_hint_button:new( "button_icon" )
	self.button_pulse_h = Vdo_hint_button:new( "button_icon_pulse" )
	
	self.respect_level = Vdo_base_object:new("respect_level_text", self.handle, self.doc_handle)
	self.respect_meter = Vdo_base_object:new("respect_meter", self.handle, self.doc_handle)
	
	-- Override color with global
	local circle_pulse_00 = Vdo_base_object:new("circles_pulse_00", self.handle, self.doc_handle)
	local circles_pulse_01 = Vdo_base_object:new("circles_pulse_01", self.handle, self.doc_handle)
	local circles_pulse_01 = Vdo_base_object:new("circles_pulse_01", self.handle, self.doc_handle)
	
	self.respect_meter:set_color(COLOR_RESPECT_METER.R, COLOR_RESPECT_METER.G, COLOR_RESPECT_METER.B)
	circle_pulse_00:set_color(COLOR_RESPECT_METER.R, COLOR_RESPECT_METER.G, COLOR_RESPECT_METER.B)
	circles_pulse_01:set_color(COLOR_RESPECT_METER_HIGHLIGHT.R, COLOR_RESPECT_METER_HIGHLIGHT.G, COLOR_RESPECT_METER_HIGHLIGHT.B)
	
	local pulse_tweens = {"respect_meter_tint", "tint_tween_1", "tint_tween_2", "tint_tween_3"}
	for idx, val in pairs(pulse_tweens) do
		local h = Vdo_tween_object:new(val, self.handle, self.doc_handle)
		h:set_property("start_value", COLOR_RESPECT_METER.R, COLOR_RESPECT_METER.G, COLOR_RESPECT_METER.B)
		h:set_property("end_value", COLOR_RESPECT_METER_HIGHLIGHT.R, COLOR_RESPECT_METER_HIGHLIGHT.G, COLOR_RESPECT_METER_HIGHLIGHT.B)
	end
	
	-- Clone fleur outline animation and object. Then Retarget and store handles for later...
	local fleur_outline = Vdo_anim_object:new("fleur_outline", self.handle, self.doc_handle)
	local fleur_outline_anim = Vdo_anim_object:new("fleur_outline_zoom_anim", self.handle, self.doc_handle)
	self.fluer_outline_anims = {}
	self.fluer_outlines = {}
	for index = 1, 7 do
		local fleur_outline_clone = Vdo_base_object:clone(fleur_outline.handle)
		local anim = Vdo_anim_object:clone(fleur_outline_anim.handle)
		anim:set_target_handle(fleur_outline_clone.handle)
		anim:stop()
		self.fluer_outline_anims[index] = anim 
		self.fluer_outlines[index] = fleur_outline_clone.handle
	end
	
	--Initalize Values
	self.is_first_update = true
	self.respect = -1
	self.respect_pct = 0
	self.level = -1
	self.queue_rank_up = RESPECT_QUEUE_NOTHING	-- When this is set to true and the respect meter goes up...
	self.is_ranking_up = false							-- Set to true when we are ranking up...
	self.should_go_back_to_normal = false			-- Flag used to determine if we should go back to normal state while the upgrade button is displayed.
	self.state = -1										-- Used to keep track of what state the respect meter is in, so we don't overlap shit...
	self.is_in_store = false
	
	-- Respect Up animation
	local respect_up_anim = Vdo_anim_object:new("respect_up_anim", self.handle, self.doc_handle)
	local respect_up_end_tween = Vdo_tween_object:new("respect_up_end", respect_up_anim.handle, respect_up_anim.doc_handle)
	local respect_up_callback_string = self:package_tween_callback("respect_up_cb")
	respect_up_end_tween:set_end_event(respect_up_callback_string)		
	
	-- Rank Up Animation...
	local rank_up_anim = Vdo_anim_object:new("rank_anim", self.handle, self.doc_handle)
	local rank_up_end_tween = Vdo_tween_object:new("rank_up_end", rank_up_anim.handle, rank_up_anim.doc_handle)
	local rank_up_callback_string = self:package_tween_callback("rank_up_cb")
	rank_up_end_tween:set_end_event(rank_up_callback_string)	
	
	-- Rank Up and Upgrade animation...
	local rank_up_and_upgrade_anim = Vdo_anim_object:new("rank_and_upgrade_anim", self.handle, self.doc_handle)
	local rank_up_and_upgrade_end_tween = Vdo_tween_object:new("rank_up_and_upgrade_end", rank_up_and_upgrade_anim.handle, rank_up_and_upgrade_anim.doc_handle)
	local rank_up_and_upgrade_callback_string = self:package_tween_callback("rank_upgrade_cb")
	rank_up_and_upgrade_end_tween:set_end_event(rank_up_and_upgrade_callback_string)	
	
	--Callbacks for return state...
	local return_callback_string = self:package_tween_callback("return_complete_cb")	
	local rank_and_upgrade_return_anim = Vdo_tween_object:new("rank_and_upgrade_return_anim", self.handle, self.doc_handle)
	local rank_and_upgrade_return_twn = Vdo_tween_object:new("rank_and_upgrade_return_twn", rank_and_upgrade_return_anim.handle, rank_and_upgrade_return_anim.doc_handle)
	rank_and_upgrade_return_twn:set_end_event(return_callback_string)
	
	local rank_return_anim = Vdo_tween_object:new("rank_return_anim", self.handle, self.doc_handle)
	local rank_return_twn = Vdo_tween_object:new("rank_return_twn", rank_return_anim.handle, rank_return_anim.doc_handle)
	rank_return_twn:set_end_event(return_callback_string)
	
	local respect_up_return_anim = Vdo_tween_object:new("respect_up_return_anim", self.handle, self.doc_handle)
	local respect_up_return_twn = Vdo_tween_object:new("respect_up_return_twn", respect_up_return_anim.handle, respect_up_return_anim.doc_handle)
	respect_up_return_twn:set_end_event(return_callback_string)
end

-- Update/animate the respect meter
--
-- @param	total_respect		current total amount of respect player has
-- @param	respect_pct		 	% the player is towards their next rank level
-- @param	level: player		rank level
function Vdo_respect_meter:update_respect(total_respect, respect_pct, level, show_upgrade_anim)
	
	--level starts at 0 but needs to be displayed as starting from 1
	level = level + 1


	--Always make sure the standard return animation is stopped...
	local stop_return_anim = false

	if self.is_first_update then
		
		--First Update, this means we will set everything up manually without any special animations...
		self:fill_meter(total_respect, self.respect_pct, respect_pct, false)
		
		-- Set Level
		self.respect_level:set_text(level)
		
		self.is_first_update = false
		self:set_state(RESPECT_STATE_RESPECT)
		stop_return_anim = true
	else
		-- The Real Update...
		
		-- We are currently returning from another state... so we have to handle this someway.
		-- This might break if we are trying to level up a second time while returning...
		if self.state == RESPECT_STATE_RETURNING then
			--Force fill the meter...
			self:fill_meter(total_respect, self.respect_pct, respect_pct, false)
			
			--Force Set Level...
			self.respect_level:set_text(level)
		elseif self.state ~= RESPECT_STATE_RANKUP and self.state ~= RESPECT_STATE_UPGRADE then
			-- Ok to do the upgrade animation...
			if level > self.level then
				if level ~= 0 then
					--Only do the fantastic upgrade animation if we are past level 0...
					
					--Add Respect Up
					self:fill_meter(total_respect, self.respect_pct, 1, true)
					
					if show_upgrade_anim == true then
						--Queue Up Level Up animation
						self.queue_rank_up = RESPECT_QUEUE_RANKUP_UPGRADE
					else 
						--Just Queue Rank up...
						self.queue_rank_up = RESPECT_QUEUE_RANKUP
					end
				else
					-- Set Level to 0
					self.respect_level:set_text(level)
					
					--Just some added respect...
					self:fill_meter(total_respect, self.respect_pct, 1, true)
				end
				self:set_state(RESPECT_STATE_RANKUP)
				stop_return_anim = true
			else
				if total_respect <= self.respect then
					--negative respect... just fill the meter and reset our state...
					self:fill_meter(total_respect, self.respect_pct, respect_pct, false)
		
					-- Set Level
					self.respect_level:set_text(level)
					--Don't change state just keep whatever state we were in and let everything else flow.
					--self:set_state(RESPECT_STATE_RESPECT)
				else
					--Just some added respect...
					self:fill_meter(total_respect, self.respect_pct, respect_pct, true)
					self:set_state(RESPECT_STATE_RESPECT)
					stop_return_anim = true
				end	
			end	
			
		else 
			-- Do not update the thing if we are in upgrade state or returning from an upgrade state... 
		end
	end
	
	if stop_return_anim then
		local anim = Vdo_anim_object:new("respect_up_return_anim", self.handle, self.doc_handle)
		anim:stop()
	end
	
	--Store values off for later access...
	self.level = level
	self.respect_pct = respect_pct
	self.respect = total_respect
end


--------------------------------------------------------------------------- 
-- Fills up the meter and plays added respect animation.
-- After animation is complete it does a callback which checks if we've
-- Increased a level and calls that animation...
--
-- @param new_text_string	Text string for header
---------------------------------------------------------------------------
function Vdo_respect_meter:fill_meter(total_respect, old_respect_pct, respect_pct, do_animation)
		
	-- calculate respect gained since last update
	local new_respect = total_respect - self.respect
	
	-- min/max for a percentage
	respect_pct = limit(respect_pct, 0, 1)
	
	local start_respect_angle = RESPECT_START_ANGLE - ((RESPECT_START_ANGLE + RESPECT_END_ANGLE) * old_respect_pct)
	local end_respect_angle = RESPECT_START_ANGLE - ((RESPECT_START_ANGLE + RESPECT_END_ANGLE) * respect_pct)
	
	local respect_amount_obj = Vdo_base_object:new("respect_amount_text", self.handle, self.doc_handle)
	local respect_up_anim = Vdo_anim_object:new("respect_up_anim", self.handle, self.doc_handle)


	-- Animate Meter
	local respect_up_anim = Vdo_anim_object:new("respect_up_anim", self.handle, self.doc_handle)
	local meter_tween = Vdo_tween_object:new("meter_tween",self.handle, self.doc_handle)
	local meter_bg_tween = Vdo_tween_object:new("meter_bg_tween",self.handle, self.doc_handle)
	
	-- Animate from previous to new		
	meter_tween:set_property("start_value", start_respect_angle)
	meter_tween:set_property("end_value", end_respect_angle)
	meter_bg_tween:set_property("start_value", start_respect_angle - .03)
	meter_bg_tween:set_property("end_value", end_respect_angle - .03)
	
	if do_animation == true then
		respect_up_anim:play(0)			
	else
		--force meter in position
		local respect_meter = Vdo_base_object:new("respect_meter", self.handle, self.doc_handle)
		local respect_meter_bg = Vdo_base_object:new("respect_meter_bg", self.handle, self.doc_handle)
		respect_meter:set_property("end_angle", end_respect_angle)
		respect_meter_bg:set_property("end_angle", end_respect_angle - .03)		
	end
	
	if new_respect > 0 then
		--Show amount of respect earned....
		respect_amount_obj:set_visible(true)
		respect_amount_obj:set_text("+" .. new_respect)
	else
		--Set text to empty if total_respect is empty...
		respect_amount_obj:set_visible(false)
	end
end


-- Set the meter in rank up state and play eccentric rank up animation
-- Then stay in Upgrade State...
function Vdo_respect_meter:rank_up_and_upgrade()
	self.back_button_key = game_get_key_name_for_action( "CBA_GAC_MAP_MENU" )
	self.button_h:set_button( self.back_button_img, self.back_button_key, false, false)
	self.button_pulse_h:set_button( self.back_button_img, self.back_button_key, false, false)
	
	--Play Circles animatino
	local circles_anim = Vdo_anim_object:new("circles", self.handle, self.doc_handle)

	--Play Outline Zoom Animation...
	local fleur_outline = Vdo_base_object:new("fleur_outline", self.handle, self.doc_handle)
	local fleur_outline_anim = Vdo_anim_object:new("fleur_outline_zoom_anim", self.handle, self.doc_handle)
	local rank_up_anim = Vdo_anim_object:new("rank_and_upgrade_anim", self.handle, self.doc_handle)
	
	fleur_outline_anim:play()
	circles_anim:play()
	rank_up_anim:play(.2)
	
	--Play Fleur outline animation...
	for index = 1, 7 do
		self.fluer_outline_anims[index]:play(index * .125)
	end
	
	--self.button_h:set_button( self.back_button_img, self.back_button_key, false, false)
	--self.button_pulse_h:set_button( self.back_button_img, self.back_button_key, false, false)
	
	-- Play Respect Up Sound
	-- but only if we are in the hud or in a store.
	if Hud_has_focus == true or self.is_in_store == true then
		game_UI_audio_play("UI_HUD_Respect_Level_Up")
	end

	--Remove from Rank up Queue
	self.queue_rank_up = RESPECT_QUEUE_NOTHING
end

-- Set the meter in rank up state and play eccentric rank up animation.
function Vdo_respect_meter:rank_up()

	--Play Circles animatino
	local circles_anim = Vdo_anim_object:new("circles", self.handle, self.doc_handle)

	--Play Outline Zoom Animation...
	local fleur_outline = Vdo_base_object:new("fleur_outline", self.handle, self.doc_handle)
	local fleur_outline_anim = Vdo_anim_object:new("fleur_outline_zoom_anim", self.handle, self.doc_handle)
	local rank_up_anim = Vdo_anim_object:new("rank_anim", self.handle, self.doc_handle)
	
	fleur_outline_anim:play()
	circles_anim:play()
	rank_up_anim:play(.2)
	
	--Play Fleur outline animation...
	for index = 1, 7 do
		self.fluer_outline_anims[index]:play(index * .125)
	end

	-- Play Respect Up Sound
	-- But only if we are not in the hud
	if Hud_has_focus == true or self.is_in_store == true then
		game_UI_audio_play("UI_HUD_Respect_Level_Up")
	end
	
	--Remove from Rank up Queue
	self.queue_rank_up = RESPECT_QUEUE_NOTHING
end


--Animates the VDO from what ever state it is in back to the normal state...
function Vdo_respect_meter:back_to_normal()

	--Set Level...
	self.respect_level:set_text(self.level)
	
	if self.state == RESPECT_STATE_UPGRADE or self.state == RESPECT_STATE_RANKUP then
		--Fill up respect meter from 0...
		self:fill_meter(0, 0, self.respect_pct, false)
		
		if self.state == RESPECT_STATE_UPGRADE then	
			--Then animate back to respect state...
			local anim = Vdo_anim_object:new("rank_and_upgrade_return_anim", self.handle, self.doc_handle)
			anim:play()
		else
			--Then animate back to respect state..
			local anim = Vdo_anim_object:new("rank_return_anim", self.handle, self.doc_handle)
			anim:play()
		end
		self:set_state(RESPECT_STATE_RETURNING)
	elseif self.state == RESPECT_STATE_RESPECT then
		--do normal back to rest state...
		local anim = Vdo_anim_object:new("respect_up_return_anim", self.handle, self.doc_handle)
		anim:play()
	elseif self.state == RESPECT_STATE_REST then
		--just make sure the level is visible
		self.respect_level:set_alpha(1)
	end
end

--This gets called when any return animations are complete...
function Vdo_respect_meter:return_complete_cb()
	self.should_go_back_to_normal = false
	self:set_state(RESPECT_STATE_REST)
	--debug_print("vint", "Reset back to false...\n")	
end

function Vdo_respect_meter:game_is_finished_showing_upgrades()
	if self.state == RESPECT_STATE_RANKUP then
		--queue to go back to normal... 
		self.should_go_back_to_normal = true
	else
		--Not in the rank up state so we should just go back...
		self:back_to_normal() 
	end
end

-- Determines if the meter can hide or not... this is basically used by the 
-- Hud timer script to hide elements that are not needed visually...
function Vdo_respect_meter:can_hide()
	local can_hide = true
	if self.state == RESPECT_STATE_RANKUP or self.state == RESPECT_STATE_UPGRADE then
		--We cannot hide if we are upgrading...
		can_hide = false
	end
	return can_hide
end

-- Shows or hides the pulse of the icon when respect is tallied...
function Vdo_respect_meter:pulse_icon(pulse_bool)
	local pulse = Vdo_base_object:new("fleur_pulse", self.handle, self.doc_handle)
	pulse:set_visible(pulse_bool)
end

-- Simple callback setup in the init. It is called by the rank up and rankup/upgrade animations.
-- When this is fired up we determine what state to move in based on what was queued from the last update.
function Vdo_respect_meter:rank_up_cb()
	-- Transition back to normal state....
	self:back_to_normal()
end

--Call back after rank up and upgrade...
function Vdo_respect_meter:rank_upgrade_cb()
	--Set state to upgrade since we are now in the upgrade button state...
	self:set_state(RESPECT_STATE_UPGRADE)

	--Determine if we should go back to the normal state, if the game has said so.
	if self.should_go_back_to_normal then
		-- Transition back to normal state....
		self:back_to_normal()
	end
end

-- Simple callback setup in the init. It is called by the respect up animation(slamdown effect...)
-- When this is fired after we determine if we aren't trying to queue up these other things...
function Vdo_respect_meter:respect_up_cb()
	--Determine if we rank up or just bring back the level
	if self.queue_rank_up == RESPECT_QUEUE_RANKUP_UPGRADE then 
		--Do the rank up and upgrade animation
		self:rank_up_and_upgrade()
	elseif self.queue_rank_up == RESPECT_QUEUE_RANKUP then
		--Do the rank up animation but no upgrade...
		self:rank_up()
	else
		if self.state == RESPECT_STATE_REST or self.state == RESPECT_STATE_RESPECT then
			-- Transition back to normal state... only if we are aren't in Upgrade mode...
			self:back_to_normal()
		end
	end
end

-------------------------------------------------------------------------------
-- Set the state of the code...
-------------------------------------------------------------------------------
function Vdo_respect_meter:set_state(state)
	self.state = state
end

function Vdo_respect_meter:get_data()
	return self.respect, self.respect_pct, self.level
end


-------------------------------------------------------------------------------
-- Resets respect meter to be first update
-- Set this every time if you don't want to play the animation when 
-- using update_respect()
--
function Vdo_respect_meter:reset_first_update()
	self.is_first_update = true
end

function Vdo_respect_meter:set_is_in_store(is_in_store)
	self.is_in_store = is_in_store
end

function Vdo_respect_meter:set_color(color)
	local new_color = table_clone(color)
	new_color.R = new_color.R * .5
	new_color.G = new_color.G * .5
	new_color.B = new_color.B * .5
	for index = 1, #self.fluer_outlines do
		vint_set_property(self.fluer_outlines[index], "tint", new_color.R, new_color.G, new_color.B)
	end
	local epic_circles_01_h = vint_object_find("epic_circles_01", self.handle)
	local epic_circles_02_h = vint_object_find("epic_circles_02", self.handle)
	vint_set_property(epic_circles_01_h, "tint", new_color.R, new_color.G, new_color.B)
	vint_set_property(epic_circles_02_h, "tint", new_color.R, new_color.G, new_color.B)
end