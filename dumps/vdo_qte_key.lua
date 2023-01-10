-- Inherited from Vdo_base_object
Vdo_qte_key = Vdo_base_object:new_base()


local HUD_QTE_ANIM_NONE = -1
local HUD_QTE_ANIM_MASH_STANDARD = 0
local HUD_QTE_ANIM_MASH_FAST = 1


HUD_QTE_KEY_ARROW_N	= 1
HUD_QTE_KEY_ARROW_E	= 4
HUD_QTE_KEY_ARROW_S	= 2
HUD_QTE_KEY_ARROW_W	= 3

local HUD_QTE_ARROW_DIRECTION_ROTATIONS = {
	[HUD_QTE_KEY_ARROW_N] = 0,
	[HUD_QTE_KEY_ARROW_E] = 90 * DEG_TO_RAD,
	[HUD_QTE_KEY_ARROW_S] = 180 * DEG_TO_RAD,
	[HUD_QTE_KEY_ARROW_W] = 270 * DEG_TO_RAD,
}

function Vdo_qte_key:init()
	self.key_off_handles = {}
	local key_off_grp_h = vint_object_find("key_off_grp", self.handle)
	local key_on_grp_h = vint_object_find("key_on_grp", self.handle)
	local key_glow_grp_h = vint_object_find("key_glow_grp", self.handle)
	
	self.key_off_grp_h 	= key_off_grp_h
	self.key_on_grp_h 	= key_on_grp_h
	self.key_glow_grp_h 	= key_glow_grp_h
	
	self.key_off_w_h = vint_object_find("key_w", key_off_grp_h)
	self.key_off_m_h = vint_object_find("key_m", key_off_grp_h)
	self.key_off_e_h = vint_object_find("key_e", key_off_grp_h)
	
	self.key_on_w_h = vint_object_find("key_w", key_on_grp_h)
	self.key_on_m_h = vint_object_find("key_m", key_on_grp_h)
	self.key_on_e_h = vint_object_find("key_e", key_on_grp_h)
	
	self.key_glow_w_h = vint_object_find("key_w", key_glow_grp_h)
	self.key_glow_m_h = vint_object_find("key_m", key_glow_grp_h)
	self.key_glow_e_h = vint_object_find("key_e", key_glow_grp_h)
	
	self.success_base_h 		= vint_object_find("success_base_grp", self.handle)
	self.success_base_w_h 	= vint_object_find("success_key_w", self.success_base_h)
	self.success_base_m_h 	= vint_object_find("success_key_m", self.success_base_h)
	self.success_base_e_h 	= vint_object_find("success_key_e", self.success_base_h)
	
	self.key_arrow_grp_h = vint_object_find("key_arrow_grp", self.handle)
	
	self.width = 0
	self.mash_fast_anim_h 		= vint_object_find("mash_fast_anim", self.handle)
	self.arrow_anim_h 			= vint_object_find("arrow_anim", self.handle)
	
	vint_set_property(self.mash_fast_anim_h, "target_handle", self.handle)
	vint_set_property(self.arrow_anim_h, "target_handle", self.handle)

	self.success_clones = {}
	self.success_anim_clones = {}
	
	self:mash(HUD_QTE_ANIM_NONE)
end

function Vdo_qte_key:cleanup()
end

function Vdo_qte_key:set_text(text_tag)
	local key_txt_h = vint_object_find("key_txt", self.handle)
	vint_set_property(key_txt_h, "text_tag", text_tag)
	vint_set_property(key_txt_h, "scale", 1.0, 1.0)
	
	local width, height = element_get_actual_size(key_txt_h)
	local width_max = 226 * 3
	local width_min = 20 * 3
	width = max(width, width_min)

	--keep a min width on everything...
	if width < 50 * 3	then
		width = 30 * 3
		vint_set_property(key_txt_h, "anchor", 40 * 3, -1 * 3)
	else
		vint_set_property(key_txt_h, "anchor", (width)*.5 + (25 * 3), -1 * 3)
	end
	
	if width > width_max then
		local scale = width_max/width
		vint_set_property(key_txt_h, "scale", scale, scale)
		width = width * scale
	end
	
	width = width + (35 * 3)
	self:resize(width)
end

function Vdo_qte_key:resize(width)
	--self.key_off_handles.key_w
	
	--Expand the center using source_se.x, source_se.y
	---self.key_off_w_h 
	--self.key_off_m_h 
	--self.key_off_e_h 
	local source_se_x, source_se_y = vint_get_property(self.key_off_m_h, "source_se")
	vint_set_property(self.key_off_m_h, "source_se", width, source_se_y)
	vint_set_property(self.key_on_m_h, "source_se", width, source_se_y)

	--Move Right Side
	local x, y = vint_get_property(self.key_off_e_h, "anchor")
	vint_set_property(self.key_off_e_h, "anchor", width - (40 * 3), y)
	vint_set_property(self.key_on_e_h, "anchor", width - (40 * 3), y)
	
	--Build Glow...
	local glow_m_width, glow_m_height = element_get_actual_size(self.key_glow_m_h)
	element_set_actual_size(self.key_glow_m_h, width - 19 * 3, glow_m_height)
	local x, y = vint_get_property(self.key_glow_e_h, "anchor")
	vint_set_property(self.key_glow_e_h, "anchor", width, y)

	--This stuff works...
	local inverse_start_scale = 1.669
	local center_width = (width * inverse_start_scale) - (50 * 3)
	local center_offset = 10 * 3

	vint_set_property(self.success_base_m_h, "scale", 1.0, 1.0)
	local success_m_width, success_m_height = element_get_actual_size(self.success_base_m_h)
	element_set_actual_size(self.success_base_m_h, center_width, success_m_height)
	
	local x, y = vint_get_property(self.success_base_w_h, "anchor")
	vint_set_property(self.success_base_w_h, "anchor", -center_width * 0.5 , y)
	
	local x, y = vint_get_property(self.success_base_e_h, "anchor")
	vint_set_property(self.success_base_e_h, "anchor", center_width * 0.5 , y)
	
	local success_center_grp_h = vint_object_find("success_center_grp", self.success_base_h)
	local x, y = vint_get_property(success_center_grp_h, "anchor")
	local x = ((width ) * 0.5)  + center_offset
	vint_set_property(success_center_grp_h, "anchor", x, y)
	vint_set_property(success_center_grp_h, "scale", 0.65, 0.65)
	vint_set_property(success_center_grp_h, "alpha", 0)
	
	--Store width with extra padding and it centers nicely.
	self.width = width + (18 * 3)
end

function Vdo_qte_key:get_width()
	return self.width 
end
	
function Vdo_qte_key:mash(mash_type)

	--Always stop any mashing...
	vint_set_property(self.key_off_grp_h, 	"alpha", 1)
	vint_set_property(self.key_on_grp_h, 	"alpha", 0)
	vint_set_property(self.key_glow_grp_h, "alpha", 0)
	self.mash_type = mash_type
	
	if mash_type == HUD_QTE_ANIM_NONE then
		vint_set_property(self.mash_fast_anim_h,"is_paused", true)
		vint_set_property(self.arrow_anim_h, "is_paused", true)
		vint_set_property(self.key_arrow_grp_h, "visible", false)
		return
	elseif mash_type == HUD_QTE_ANIM_MASH_STANDARD or  mash_type == HUD_QTE_ANIM_MASH_FAST then	
		lua_play_anim(self.mash_fast_anim_h)
		lua_play_anim(self.arrow_anim_h)
		vint_set_property(self.key_arrow_grp_h, "visible", self.arrows_are_visible)
	end
end

function Vdo_qte_key:show_arrows(is_visible)
	if self.mash_type == HUD_QTE_ANIM_NONE then
		vint_set_property(self.key_arrow_grp_h, "visible", false)
	else
		vint_set_property(self.key_arrow_grp_h, "visible", is_visible)
	end
	self.arrows_are_visible = is_visible
end

function Vdo_qte_key:set_arrow_direction(direction)

	if self.width == 0 then
		return
	end
	
	local x, y
	if direction == HUD_QTE_KEY_ARROW_N then
		x = self.width * .5
		y = -37.0 * 3
	elseif direction == HUD_QTE_KEY_ARROW_E then
		x = self.width + 5 * 3
		y = 0
	elseif direction == HUD_QTE_KEY_ARROW_S then 
		x = self.width * .5
		y = 37.0 * 3
	elseif direction == HUD_QTE_KEY_ARROW_W  then 
		x =  - 5 * 3
		y = 0
	end
	
	vint_set_property(self.key_arrow_grp_h, "anchor", x, y)
	local angle = HUD_QTE_ARROW_DIRECTION_ROTATIONS[direction] 
	vint_set_property(self.key_arrow_grp_h, "rotation", angle)
end

function Vdo_qte_key:success(is_success)
	if #self.success_clones ~= 0 then
		for i = 1, #self.success_clones do
			vint_object_destroy(self.success_clones[i])
			vint_object_destroy(self.success_anim_clones[i])
		end
		self.success_clones = {}
		self.success_anim_clones = {}
	end

	if is_success then
		--create mouse success items
		for i = 1, 4 do
			self.success_clones[i] = vint_object_clone(self.success_base_h)
			self.success_anim_clones[i] = vint_object_clone(vint_object_find("success_anim"))
			vint_set_property(self.success_anim_clones[i], "target_handle", self.success_clones[i])
			lua_play_anim(self.success_anim_clones[i], (i - 1) * .1)
		end
		vint_set_property(self.key_on_grp_h, "visible", false)
	else
		vint_set_property(self.key_on_grp_h, "visible", true)
	end
end