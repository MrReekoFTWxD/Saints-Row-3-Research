-------------------------------------------------------------------------------
--GSI Combo Component
-------------------------------------------------------------------------------
-- Inherited from Vdo_base_object
Vdo_gsi_combo = Vdo_base_object:new_base()

-- Standard Init Function
function vdo_gsi_combo_init()
end

-- Standard Cleanup Function
function vdo_gsi_combo_cleanup()
end

--CONSTANTS
local METER_LABEL_PADDING = 9 * 3

function Vdo_gsi_combo:init()
	--retaget flashing anim
	self.meter_pulse_anim_h = vint_object_find("meter_pulse", self.handle)
	vint_set_property(self.meter_pulse_anim_h, "target_handle", self.handle)
end

-------------------------------------------------------------------------------
-- Creates and initializes the Combo Meter. Still requires an update call
-- afterwards, but this helps with seperating the two processes of initializing 
-- and update.
-------------------------------------------------------------------------------
function Vdo_gsi_combo:create(skin)
	--Setup skin
	local skin = GSI_SKIN[skin]
	if skin == nil then
		--No skin use default
		skin = GSI_SKIN["Default"] 
	end
	
	--Set Tint on Meters
	local fill_obj = Vdo_base_object:new("fill", self.handle)
	local fill_2_obj = Vdo_base_object:new("fill_2", self.handle)
	
	local tint = skin.tint
	fill_obj:set_color(tint[1], tint[2], tint[3])
	fill_2_obj:set_color(tint[1], tint[2], tint[3])
		
	--Set width of meter by referencing
	local fill_size_full	= fill_obj:get_property("scale", self.handle)
	local fill_size_empty = 0	
	
	--Store off max size of meter...
	local meter_bg_obj = Vdo_base_object:new("bg", self.handle)
	self.meter_width, self.meter_height = meter_bg_obj:get_actual_size() 
	
	--Store size of combo text width...
	local combo_txt_obj = Vdo_base_object:new("combo_txt", self.handle)
	self.combo_num_width = combo_txt_obj:get_actual_size()
	
	--Initialize Standard Indicator Values
	self.visible = -1						--Is the indicator displaying? 
	self.is_dirty = true					--Is the indicator dirty? we set this to true if we want the GSI to re-align everything.
	self.skin = skin
	self.width = 190 * 3
	self.height = 10 * 3
	
	
	--Initialize Custom Values 
	self.meter_percent = 1
	self.fill_size_full = fill_size_full
	self.fill_size_empty = fill_size_empty
	self.is_flashing = false
	self.label = 0
end

-------------------------------------------------------------------------------
--Updates the meter
-------------------------------------------------------------------------------
function Vdo_gsi_combo:update(visible, skin, label_crc, combo_value, meter_percent, is_flashing)
	--Set visible
	self:set_visible(visible)
	
	--Get objects for modification
	local label_txt_obj = Vdo_base_object:new("label_txt", self.handle)
	local combo_txt_obj = Vdo_base_object:new("combo_txt", self.handle)
	local meter_obj = Vdo_base_object:new("meter_grp", self.handle)
	
	local fill_bg_obj = Vdo_base_object:new("bg", self.handle)
	local fill_obj = Vdo_base_object:new("fill", self.handle)
	local fill_2_obj = Vdo_base_object:new("fill_2", self.handle)
	
	--Set label with crc
	if label_crc ~= self.label_crc then
		if label_crc == 0 or label_crc == nil then
			--No crc or Invalid crc
			label_txt_obj:set_text("")
		else
			label_txt_obj:set_text_crc(label_crc)
		end
		self.is_dirty = true
	end
	
	--Set label with crc
	combo_txt_obj:set_text(combo_value)

	--Setup properties for fills
	--Set Meter Fill based on percent input
	local fill_width, fill_height = fill_obj:get_property("scale")
	fill_width = self.fill_size_full * meter_percent -- overwrite fill width multiplied by percentage
	fill_obj:set_property("scale", fill_width, fill_height)
	fill_2_obj:set_property("scale", fill_width, fill_height)
	
	--If meter is using mayhem skin update its color every time its updated, 
	--because it changes based on the color of the bonus cash.
	if skin == "Mayhem" then	
		fill_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		fill_2_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		
		if combo_value ~= "0" then
			combo_txt_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		else
			--reset color
			combo_txt_obj:set_color(GSI_SKIN["Mayhem"].tint[1], GSI_SKIN["Mayhem"].tint[2], GSI_SKIN["Mayhem"].tint[3])
		end
	end
	
	if skin == "TankMayhem" then	
		fill_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		fill_2_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		
		if combo_value ~= "1.00" then
			combo_txt_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		else
			--reset color
			combo_txt_obj:set_color(GSI_SKIN["TankMayhem"].tint[1], GSI_SKIN["TankMayhem"].tint[2], GSI_SKIN["TankMayhem"].tint[3])
		end
	end

	--Only re-align if this is the first time the element has been updated
	if self.is_dirty == true then
		--Repostion Elements and Calculate width/height
		local label_width, label_height = label_txt_obj:get_actual_size()
		local label_x, label_y = label_txt_obj:get_anchor()
		
		--Set Padding of label
		local combo_x = 0
		if label_width ~= 0 then
			--If the label doesn't exist then we don't need any padding
			combo_x = METER_LABEL_PADDING + label_width
		end

		--Position Combo bonus
		combo_txt_obj:set_anchor(combo_x, label_y)
		
		
		--Set position of meters...
		local meter_x, meter_y = vint_get_property(meter_obj.handle, "anchor")
		meter_x = combo_x + self.combo_num_width + METER_LABEL_PADDING
		vint_set_property(meter_obj.handle, "anchor",  meter_x, meter_y)
		
		--Get Height of object...
		local height = self.meter_height
		if label_height > height then
			height = label_height
		end

		--Store width/height to awesome.
		self.width = meter_x + self.meter_width + (20 * 3)
		self.height = height
	end
	
	
	if self.is_flashing ~= is_flashing then
		local pulse_anim_obj = Vdo_anim_object:new("pulse_anim", self.handle)
		if is_flashing == true then
			--Play and show flashing object
			lua_play_anim(self.meter_pulse_anim_h)
			fill_2_obj:set_visible(true)
		elseif is_flashing == false then
			--Pause and hide flashing object
			vint_set_property(self.meter_pulse_anim_h, "is_paused", true)
			fill_2_obj:set_visible(false)
		end
	end
	
	--Store Values
	self.label_crc = label_crc
	self.meter_percent = meter_percent
	self.is_flashing = is_flashing
end

function Vdo_gsi_combo:get_size()
	return self.width, self.height
end


--Standard Indicator Functions
function Vdo_gsi_combo:set_visible(visible)
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
end