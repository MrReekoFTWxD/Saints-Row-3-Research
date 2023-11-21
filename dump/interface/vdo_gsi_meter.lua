-------------------------------------------------------------------------------
--GSI Meter Component
-------------------------------------------------------------------------------
-- Inherited from Vdo_base_object
Vdo_gsi_meter = Vdo_base_object:new_base()

-- Standard Init Function
function vdo_gsi_meter_init()
end

-- Standard Cleanup Function
function vdo_gsi_meter_cleanup()
end

--CONSTANTS
local METER_LABEL_PADDING = 9 * 3

function Vdo_gsi_meter:init()
	--retaget anim
	self.meter_pulse_anim_h = vint_object_find("meter_pulse_anim", self.handle)
	vint_set_property(self.meter_pulse_anim_h, "target_handle", self.handle)
	
	self.meter_highlight_grp_h = vint_object_find("meter_highlight_grp", self.handle)
	vint_set_property(self.meter_highlight_grp_h, "visible", false)
end

-------------------------------------------------------------------------------
-- Creates and initializes the meter. Still requires an update call afterwards, 
-- but this helps with seperating the two processes of initializing and update.
-------------------------------------------------------------------------------
function Vdo_gsi_meter:create(skin)
	--Setup skin
	local skin = GSI_SKIN[skin]
	if skin == nil then
		--No skin use default
		skin = GSI_SKIN["Default"] 
	end
	
	--Set Tint on Meters
	local fill_h = vint_object_find("fill", self.handle)
	local highlight_fill_h = vint_object_find("highlight_fill", self.handle)
	
	local tint = skin.tint
	vint_set_property(fill_h, "tint", tint[1], tint[2], tint[3])
	vint_set_property(highlight_fill_h, "tint", tint[1], tint[2], tint[3])
		
	--Set width of meter by referencing
	local fill_size_full	= vint_get_property(fill_h, "scale")
	local fill_size_empty = 0
	
	--Initialize Standard Indicator Values
	self.visible = -1						--Is the indicator displaying? 
	self.is_dirty = true					--Is the indicator dirty? we set this to true if we want the GSI to re-align everything.
	self.skin = skin
	
	--Store off max size of meter...
	local meter_bg_h = vint_object_find("bg", self.handle)
	self.meter_width, self.meter_height = element_get_actual_size(meter_bg_h) 
	
	self.label_width = 0
	self.width = 100 * 3
	self.height = 10 * 3
	
	--Get objects for modification in our update...
	local text_h = vint_object_find("label_txt", self.handle)
	local meter_grp_h = vint_object_find("meter_grp", self.handle)
	local meter_highlight_grp_h = vint_object_find("meter_highlight_grp", self.handle)
	local highlight_mask_h = vint_object_find("highlight_mask", self.handle)

	--Store handles to objects...
	self.text_h = text_h
	self.meter_grp_h = meter_grp_h
	self.meter_highlight_grp_h = meter_highlight_grp_h
	self.meter_bg_h = meter_bg_h
	self.fill_h = fill_h
	self.highlight_fill_h = highlight_fill_h
	self.highlight_mask_h = highlight_mask_h
	
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
function Vdo_gsi_meter:update(visible, skin, label_crc, meter_percent, is_flashing)
	--Set visible
	self:set_visible(visible)
	
	local text_h = self.text_h
	local fill_h = self.fill_h
	local highlight_fill_h = self.highlight_fill_h
	local meter_highlight_grp_h = self.meter_highlight_grp_h
	local highlight_mask_h = self.highlight_mask_h
	local meter_grp_h = self.meter_grp_h


	--Set label with crc
	if label_crc ~= self.label_crc then
	
		if label_crc == 0 or label_crc == nil then
			--No crc or Invalid crc
			vint_set_property(text_h, "text_tag", "")
		else
			vint_set_property(text_h, "text_tag_crc", label_crc)
		end
		self.is_dirty = true
	end
	
	--Setup properties for fills
	--Set Meter Fill based on percent input
	local fill_width, fill_height = vint_get_property(fill_h, "scale")
	fill_width = self.fill_size_full * meter_percent -- overwrite fill width multiplied by percentage
	vint_set_property(fill_h, "scale", fill_width, fill_height)
	vint_set_property(highlight_mask_h, "scale", fill_width, 1.1 * 3)
	
	--If meter is using mayhem skin update its color every time its updated, 
	--because it changes based on the color of the bonus cash.
	if skin == "Mayhem" then	
		vint_set_property(fill_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		vint_set_property(highlight_fill_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
	end
	
	--Only re-align if this is the first time the element has been updated
	if self.is_dirty == true then
		--Get Label size...
		
		local label_width, label_height = element_get_actual_size(text_h)
		self:set_meter_position(label_width)
		self.label_width = label_width
		self.height = label_height
	end
	
	if self.is_flashing ~= is_flashing then
		if is_flashing == true then
			--Play and show flashing object
			lua_play_anim(self.meter_pulse_anim_h)
			vint_set_property(meter_highlight_grp_h, "visible", true)
		elseif is_flashing == false then
			--Pause and hide flashing object
			vint_set_property(self.meter_pulse_anim_h, "is_paused", true)
			vint_set_property(meter_highlight_grp_h, "visible", false)
		end
	end

	--Store Values
	self.label_crc = label_crc
	self.meter_percent = meter_percent
	self.is_flashing = is_flashing
end

function Vdo_gsi_meter:get_size()
	return self.width, self.height
end

-------------------------------------------------------------------------------
-- returns the label width of the meter...
-------------------------------------------------------------------------------
function Vdo_gsi_meter:get_label_width()
	return self.label_width 
end

-------------------------------------------------------------------------------
-- Sets the meter position of the gsi meter, this is done in vdo_gsi to
-- get the meters aligned if there is two of them...
-- @param label_width
--
function Vdo_gsi_meter:set_meter_position(label_width)
	local meter_x, meter_y = vint_get_property(self.meter_grp_h, "anchor")
	
	--Set Padding of label
	local label_padding = METER_LABEL_PADDING	
	if label_width == 0 then
		--If the label doesn't exist then we don't need any padding
		label_padding = 0 
	end
	
	meter_x = label_padding + label_width + label_padding
	vint_set_property(self.meter_grp_h, "anchor",  meter_x, meter_y)
	vint_set_property(self.meter_highlight_grp_h, "anchor",  meter_x, meter_y)
	
	self.width 	= meter_x + self.meter_width + (20 * 3)
end

--Standard Indicator Functions
function Vdo_gsi_meter:set_visible(visible)
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

function Vdo_gsi_meter:debug(debug_enabled)
	self.debug_enabled = debug_enabled
end