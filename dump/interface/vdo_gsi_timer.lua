-------------------------------------------------------------------------------
--GSI Timer Component
-------------------------------------------------------------------------------
-- Inherited from Vdo_base_object
Vdo_gsi_timer = Vdo_base_object:new_base()

--Timer colors...
TIMER_COLOR_NORMAL_ID 	= 0
TIMER_COLOR_ALARM_ID 	= 1

local Timer_colors = {
	[TIMER_COLOR_NORMAL_ID] = {R=226/255,G=191/255,B=11/255},		--YELLOW
	[TIMER_COLOR_ALARM_ID] = {R=255/255,G=0/255,B=0/255}				--RED
}

local GSI_TIMER_HEIGHT = 40 * 3

-- Standard Init Function
function vdo_gsi_timer_init()
end

-- Standard Cleanup Function
function vdo_gsi_timer_cleanup()
end

function Vdo_gsi_timer:init()
end

function Vdo_gsi_timer:create(skin)
	--set skin default
	if skin ~= "positive" and skin ~= "negative" then
		skin = "negative"
	end
	
	if skin == "running_man" then
		skin = "negative"
		self.running_man_mode = true
	end
	
	--Set default time...
	local timer_txt_h = vint_object_find("timer_txt", self.handle)
	local seconds_txt_h = vint_object_find("seconds_txt", self.handle)
	local colon_txt_h = vint_object_find("colon_txt", self.handle)
	
	vint_set_property(seconds_txt_h, "visible", false)
	vint_set_property(colon_txt_h, "visible", false)

	local default_time = "00:00"
	
	--Retarget Animations...
	local seconds_flash_anim_h = vint_object_find("seconds_flash_anim", self.handle)
	vint_set_property(seconds_flash_anim_h, "target_handle", self.handle)
	
	local color_shift_anim_h = vint_object_find("color_shift_anim", self.handle)
	local color_shift_twn_h = vint_object_find("color_shift_twn", color_shift_anim_h)
	vint_set_property(color_shift_twn_h, "target_handle", self.handle)	-- Retarget tween to base object... this changes the color...

	local timer_slam_anim_h = vint_object_find("timer_slam_anim", self.handle)
	vint_set_property(timer_slam_anim_h, "target_handle", self.handle)
		
	--Get width/height of fullsize
	vint_set_property(timer_txt_h, "text_tag", default_time)
	local width, height = element_get_actual_size(timer_txt_h)
	
	--Initialize Standard Indicator Values
	self.timer_txt_h = timer_txt_h
	self.seconds_txt_h = seconds_txt_h
	self.colon_txt_h = colon_txt_h
	self.seconds_flash_anim_h = seconds_flash_anim_h
	self.color_shift_anim_h = color_shift_anim_h
	self.color_shift_twn_h = color_shift_twn_h
	self.timer_slam_anim_h = timer_slam_anim_h
	self.visible = -1						--Is the indicator displaying? 
	self.is_dirty = true					--Is the indicator dirty? we set this to true if we want the GSI to re-align everything.
	self.skin = skin
	self.width = width
	self.height = GSI_TIMER_HEIGHT
	
	--force color of timer to normal
	self:color_shift(TIMER_COLOR_NORMAL_ID, true)
	
	--Initialize Custom Values 
	self.timer_value = 0
	self.label_crc = 0
end

function Vdo_gsi_timer:update(visible, skin, label_crc, timer_value, is_countdown)
	--[[
	debug_print("vint", 	"visible" .. var_to_string(visible) .. "\n")
	debug_print("vint", 	"skin" .. var_to_string(skin) .. "\n")
	debug_print("vint", 	"label_crc" .. var_to_string(label_crc) .. "\n")
	debug_print("vint", 	"timer_value" .. var_to_string(timer_value) .. "\n")
	debug_print("vint", 	"is_positive" .. var_to_string(is_positive) .. "\n")
	debug_print("vint", 	"is_flashing" .. var_to_string(is_flashing) .. "\n\n")
	]]
	local force_color = false		--Determines if we are going to force the color to the current timer value...
	
	--label_crc is no longer supported by this...
	--Set visible
	self:set_visible(visible)
	
	--Reference objects
	local timer_txt_h 	= self.timer_txt_h
	local seconds_txt_h	= self.seconds_txt_h
	local colon_txt_h 	= self.colon_txt_h
	
	--Error Check for timer value
	if timer_value == nil then
		timer_value = 0
	end
	
	---Split up the timer value(seconds) into...
	local minutes = floor(timer_value / 60)
	local seconds = abs(timer_value % 60)
	
	--Pad the seconds for the timer
	if seconds < 10 then
		seconds = "0" .. seconds
	end
	
	--Timer has reset...
	if timer_value >= self.timer_value then
		--Pause any animations that modify timer visuals...
		vint_set_property(self.seconds_flash_anim_h, "is_paused", true)
		vint_set_property(self.timer_slam_anim_h, "is_paused", true)
		
		--we've reset the timer, reset scales and alpha which could be modified by animations...
		vint_set_property(seconds_txt_h, "scale", 1.0, 1.0)
		vint_set_property(timer_txt_h, "scale", 1.0, 1.0)
		
		vint_set_property(seconds_txt_h, "alpha", 1)
		vint_set_property(timer_txt_h, "alpha", 1)
		
		force_color = true	--immediatly change colors...
	end
	
	local width = 0 
	
	if timer_value < 60 then
		--Show only colon and seconds...
		vint_set_property(timer_txt_h, "visible", false)
		vint_set_property(seconds_txt_h, "visible", true)
		vint_set_property(colon_txt_h, "visible", true)
		vint_set_property(seconds_txt_h, "text_tag", seconds)		
		
		--calculate width of timer...
		local timer_x, timer_y = vint_get_property(seconds_txt_h, "anchor")
		-- set scale so we get accurate size...
		vint_set_property(seconds_txt_h, "scale", 1.0, 1.0)
		local timer_width, timer_height = element_get_actual_size(seconds_txt_h)
		width = floor(timer_x + (timer_width * 0.5) + GSI_TEXT_SPACING)
	else
		--Show only standard timer...
		vint_set_property(timer_txt_h, "visible", true)
		vint_set_property(seconds_txt_h, "visible", false)
		vint_set_property(colon_txt_h, "visible", false)
		
		local time_formatted = minutes .. ":" .. seconds
		vint_set_property(timer_txt_h, "text_tag", time_formatted)
		
		--calculate width of timer...
		local timer_x, timer_y = vint_get_property(timer_txt_h, "anchor")
		local timer_width, timer_height = element_get_actual_size(timer_txt_h)
		local timer_half_width = (timer_width * 0.5)
		timer_x = (31 * 3) + timer_half_width
		vint_set_property(timer_txt_h, "anchor", timer_x, timer_y)
		width = floor(timer_x + timer_half_width + GSI_TEXT_SPACING)
	end
	
	if is_countdown == true then
		--If we are under 10 seconds... then we should shift to red.
		if timer_value <= 10 then
			--Shift Color to red...
			self:color_shift(TIMER_COLOR_ALARM_ID, force_color)
		else
			--Modify Color to default state...
			self:color_shift(TIMER_COLOR_NORMAL_ID, force_color)
		end
		
		--do flashes if we are under 5 seconds...
		if timer_value <= 5 then
			--Flash if we at 5 or under seconds
			lua_play_anim(self.seconds_flash_anim_h)
		end
		
		--Slam if we are at 30, 20 or <= 10 seconds...
		if timer_value == 30 or timer_value == 20 or timer_value <= 10 then
			if self.running_man_mode == true and timer_value <= 10 then
			--This is a special case fix to change running man, so we don't slam at 10 or under... 
			-- if we wanted it to work normally, we would just take out the if statement and just play the anim... (JMH 6/23/2011)
			else
				lua_play_anim(self.timer_slam_anim_h)
			end
		end
	end
	if self.width ~= width then
		self.is_dirty = true
	end

	--Store new width and height of indicator
	self.width = width 
	self.height = GSI_TIMER_HEIGHT 
	self.timer_value = timer_value
end

function Vdo_gsi_timer:get_size()
	return self.width, self.height
end

-------------------------------------------------------------------------------
-- Changes color to the specified timer state
-- @param	color_id		state of timer... ( TIMER_COLOR_NORMAL_ID, TIMER_COLOR_ALARM_ID,...)
-- @param	force_color	if we don't want a transition...
-------------------------------------------------------------------------------
function Vdo_gsi_timer:color_shift(color_id, force_color)

	if color_id == self.color_id then
		--don't change color...
		return
	end
	local twn_h = self.color_shift_twn_h
	
		--If we force the color set our start time in the past....
	local start_color = {}
	start_color.R, start_color.G, start_color.B = vint_get_property(twn_h, "end_value")
	
	-- Advance time of animation if we are going to foce the color...
	local start_time = 0
	if force_color then
		start_color = Timer_colors[color_id]
		start_time = -2
	end
	
	local end_color = Timer_colors[color_id]
	
	if start_color == nil or end_color == nil then
		debug_print("vint", "invalid color id sent to Vdo_gsi_timer:color_shift()\n")
		return
	end
	
	-- Override colors
	vint_set_property(twn_h, "start_value", start_color.R, start_color.G, start_color.B)
	vint_set_property(twn_h, "end_value", end_color.R, end_color.G, end_color.B)
	lua_play_anim(self.color_shift_anim_h, start_time)
	
	self.color_id = color_id

end

--Standard Indicator Functions
function Vdo_gsi_timer:set_visible(visible)
	--Hide the indicator if it is not visible
	if visible ~= self.visible then
		if visible == true then
			self:set_property("visible", true)
			self.visible = visible
		else
			self:set_property("visible", false)
			self.visible = visible
		end
		
		--Format of the indicators changed, so lets make sure we set the flag to dirty.
		--The vdo_gsi will take care of everything when we set this dirty flag to true...
		self.is_dirty = true
	end
end'0