function vdo_city_control_init()
end

-- Inherited from Vdo_base_object
Vdo_city_control = Vdo_base_object:new_base()

--Local Constants...
local CONTROL_START_ANGLE 	= 2.5
local CONTROL_END_ANGLE 	= 2.49		-- This is really negative, but entering as positive to make equation work
local RESPECT_START_ANGLE 	= 2.7547
local RESPECT_END_ANGLE 	= 2.77315

--Standard Init...
function Vdo_city_control:init()

	--Retarget animations...
	local control_text_anim = Vdo_anim_object:new("control_text_anim", self.handle, self.doc_handle, self.doc_handle)
	local control_up_anim	= Vdo_anim_object:new("control_up_anim", self.handle, self.doc_handle, self.doc_handle)
	local respect_text_anim = Vdo_anim_object:new("respect_text_anim", self.handle, self.doc_handle, self.doc_handle)
	control_text_anim:set_target_handle(self.handle)
	control_up_anim:set_target_handle(self.handle)
	respect_text_anim:set_target_handle(self.handle)
	
	self.start_angle 	= CONTROL_START_ANGLE
	self.end_angle 	= CONTROL_END_ANGLE
	
	--Initalize Values
	self.pct = 0
	self:update(0, false)
end


-- Update/animate the respect meter
--
-- @param	total_respect		current total amount of respect player has
-- @param	respect_pct		 	% the player is towards their next rank level
-- @param	level: player		rank level

--------------------------------------------------------------------------- 
-- Fills up the meter and plays added respect animation.
-- After animation is complete it does a callback which checks if we've
-- Increased a level and calls that animation...
--
-- @param	total_respect		current total amount of respect player has
-- @param	old_respect_pct 	% previous player is towards their next rank level
-- @param	respect_pct		 	% the player is towards their next rank level
-- @param	level_old			rank level previous 
-- @param	level_new			rank level new
---------------------------------------------------------------------------
function Vdo_city_control:update_respect(total_respect, respect_pct, level, do_animation)

	-- min/max for a percentage
	respect_pct = limit(respect_pct, 0, 1)
	
	local start_angle = self.start_angle - ((self.start_angle + self.end_angle) * self.pct)
	local end_angle = self.start_angle - ((self.start_angle + self.end_angle) * respect_pct)
	
	--Find objects for 
	local level_txt = Vdo_base_object:new("percent_text", self.handle, self.doc_handle)
	local control_pct_new = Vdo_base_object:new("new_percent_text", self.handle, self.doc_handle)
	
	--level and respect...
	level_txt:set_text(level)
	control_pct_new:set_text("+" .. total_respect)
	
	if do_animation == true then
		-- Animate Meter
		local control_up_anim = Vdo_anim_object:new("control_up_anim", self.handle, self.doc_handle)
		local meter_tween = Vdo_tween_object:new("meter_tween",self.handle, self.doc_handle)
		local meter_bg_tween = Vdo_tween_object:new("meter_bg_tween",self.handle, self.doc_handle)
		
		-- Animate from previous to new		
		meter_tween:set_property("start_value", start_angle)
		meter_tween:set_property("end_value", end_angle)
		meter_bg_tween:set_property("start_value", start_angle - .06)
		meter_bg_tween:set_property("end_value", end_angle - .06)
		control_up_anim:play(0)
		
		--Play text animation...
		local control_text_anim = Vdo_anim_object:new("control_text_anim", self.handle, self.doc_handle)
		local respect_text_anim = Vdo_anim_object:new("respect_text_anim", self.handle, self.doc_handle)
		control_text_anim:play(0)
		respect_text_anim:play(0)
	else
		--Set Meter Manually.
		local meter = Vdo_base_object:new("meter", self.handle, self.doc_handle)
		local meter_bg = Vdo_base_object:new("meter_bg", self.handle, self.doc_handle)
		meter:set_property("end_angle", end_angle, self.doc_handle)
		meter_bg:set_property("end_angle", end_angle - .06)
	end
	
	self.pct = respect_pct
	self.level = level
end

-- Update/animate the control meter
--
-- @param	pct					% of control of district...
-- @param	do_animation		if set to true we animate from the last value set...
function Vdo_city_control:update(control_pct, do_animation)

	-- min/max for a percentage
	control_pct = limit(control_pct, 0, 1)
	
	local start_angle = self.start_angle - ((self.start_angle + self.end_angle) * self.pct)
	local end_angle = self.start_angle - ((self.start_angle + self.end_angle) * control_pct)
	
	--Find objects for 
	local control_pct_old = Vdo_base_object:new("percent_text", self.handle, self.doc_handle)
	local control_pct_new = Vdo_base_object:new("new_percent_text", self.handle, self.doc_handle)
	
	if do_animation == true then
		--Set Text Percentages %%%
		control_pct_old:set_text(floor(self.pct * 100 + 0.5) .. "%%")
		control_pct_new:set_text(floor(control_pct * 100 + 0.5) .. "%%")

		-- Animate Meter
		local control_up_anim = Vdo_anim_object:new("control_up_anim", self.handle, self.doc_handle)
		local meter_tween = Vdo_tween_object:new("meter_tween",self.handle, self.doc_handle)
		local meter_bg_tween = Vdo_tween_object:new("meter_bg_tween",self.handle, self.doc_handle)
		
		-- Animate from previous to new		
		meter_tween:set_property("start_value", start_angle)
		meter_tween:set_property("end_value", end_angle)
		meter_bg_tween:set_property("start_value", start_angle - .06)
		meter_bg_tween:set_property("end_value", end_angle - .06)
		control_up_anim:play(0)		

		--Play text animation...
		local control_text_anim = Vdo_anim_object:new("control_text_anim", self.handle, self.doc_handle)
		control_text_anim:play(0)		
	else
		--Control Percentages...
		control_pct_old:set_text(floor(control_pct * 100 + 0.5) .. "%%")
		control_pct_new:set_text(floor(control_pct * 100 + 0.5) .. "%%")
		
		--Set Meter Manually.
		local meter = Vdo_base_object:new("meter", self.handle, self.doc_handle)
		local meter_bg = Vdo_base_object:new("meter_bg", self.handle, self.doc_handle)
		meter:set_property("end_angle", end_angle)
		meter_bg:set_property("end_angle", end_angle - .06)
	end
	self.pct = control_pct
end

-- Shows or hides the pulse of the icon when control is added...
function Vdo_city_control:pulse_icon(pulse_bool)
	local pulse = Vdo_base_object:new("fist_pulse", self.handle, self.doc_handle)
	pulse:set_visible(pulse_bool)
end

function Vdo_city_control:set_icon(icon_bmp_name)

end


-------------------------------------------------------------------------------
-- Augments the meter and turns it into a respect type...
-------------------------------------------------------------------------------
function Vdo_city_control:change_to_respect()
	--Change Icon
	local icon = Vdo_base_object:new("icon", self.handle, self.doc_handle)
	icon:set_image("uhd_ui_hud_respect_fleur")

	--Change color...
	local meter = Vdo_base_object:new("meter", self.handle, self.doc_handle)
	local meter_bg = Vdo_base_object:new("meter_bg", self.handle, self.doc_handle)
	local meter_tint_tween = Vdo_tween_object:new("control_meter_tint", self.handle, self.doc_handle)
	meter:set_color(COLOR_RESPECT_METER.R, COLOR_RESPECT_METER.G, COLOR_RESPECT_METER.B)
	meter_tint_tween:set_property("start_value", COLOR_RESPECT_METER.R, COLOR_RESPECT_METER.G, COLOR_RESPECT_METER.B)
	meter_tint_tween:set_property("end_value", COLOR_RESPECT_METER_HIGHLIGHT.R, COLOR_RESPECT_METER_HIGHLIGHT.G, COLOR_RESPECT_METER_HIGHLIGHT.B)
	
	self.start_angle 	= RESPECT_START_ANGLE 	
	self.end_angle 	= RESPECT_END_ANGLE

	meter:set_property("start_angle", self.start_angle)
	meter_bg:set_property("start_angle", self.start_angle - .06)
	
	self.pct = 0
	self:update(0, false)
	--Sets rotation on text...
	local new_respect_text = Vdo_base_object:new("new_percent_text", self.handle, self.doc_handle)
	new_respect_text:set_rotation(-8 * DEG_TO_RAD)
end