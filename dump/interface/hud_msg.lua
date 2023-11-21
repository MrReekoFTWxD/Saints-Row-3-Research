Hud_msg_doc = 0

-- Has to match the enum in hud_message.h
HUD_REGION_DEBUG = 0
HUD_REGION_HELP = 1
HUD_REGION_DIVERSION = 2
HUD_REGION_SUBTITLES = 3
HUD_REGION_CUTSCENE_HELP = 4
HUD_REGION_USE_MSGS = 5
HUD_REGION_NEW_GAMEPLAY = 6
HUD_REGION_CRITICAL_TIMER = 7
HUD_NUM_REGIONS = 8

HUD_MSG_DIR_UP = 0
HUD_MSG_DIR_DOWN = 1
HUD_MSG_DIR_CENTER = 2

Hud_msg_std_text = {scale = 0.6, wrap_width = 0, leading = 0}
Hud_msg_help_text = {scale = 0.7, wrap_width = 390 * 3, leading = 0}
Hud_msg_subtitle_text = {scale = 0.7, wrap_width = 0, leading = 0} -- Needs to match subtitles.cpp

-- HUD Message Icon Enum... action_message_icon in
--
-- d:\projects\sr3\main\sr3\src\game\control\control_gameplay.h
HUD_MSG_ICON_NONE = 0
HUD_MSG_ICON_Y = 1
HUD_MSG_ICON_X = 2
HUD_MSG_ICON_A = 3
HUD_MSG_ICON_BACK = 4
HUD_MSG_ICON_DPAD_LEFT = 5
HUD_MSG_ICON_DPAD_RIGHT = 6
HUD_MSG_ICON_DPAD_DOWN = 7
HUD_MSG_ICON_DPAD_UP = 8
HUD_MSG_ICON_SHOP = 9
HUD_MSG_ICON_MISSION = 10
HUD_MSG_ICON_HUMANSHIELD = 11
HUD_MSG_ICON_MECHANIC = 12
HUD_MSG_ICON_GARAGE = 13
HUD_MSG_ICON_CRIB = 14

Hud_msg_icons = {
	[HUD_MSG_ICON_NONE] = {
		bmp = "ui_blank"
	},
	[HUD_MSG_ICON_SHOP] = {
		bmp = "uhd_ui_hud_use_shopping",
		color = {R = 201 / 255, G = 186 / 255, B = 44 / 255},
		x = -34 * 3,
		y = -39 * 3
	},
	[HUD_MSG_ICON_Y] = {
		bmp = CTRL_BUTTON_Y
	},
	[HUD_MSG_ICON_X] = {
		bmp = CTRL_BUTTON_X
	},
	[HUD_MSG_ICON_A] = {
		bmp = CTRL_MENU_BUTTON_A
	},
	[HUD_MSG_ICON_DPAD_LEFT] = {
		bmp = CTRL_BUTTON_DPAD_LEFT
	},
	[HUD_MSG_ICON_DPAD_RIGHT] = {
		bmp = CTRL_BUTTON_DPAD_RIGHT
	},
	[HUD_MSG_ICON_DPAD_DOWN] = {
		bmp = CTRL_BUTTON_DPAD_DOWN
	},
	[HUD_MSG_ICON_DPAD_UP] = {
		bmp = CTRL_BUTTON_DPAD_UP
	},
	[HUD_MSG_ICON_BACK] = {
		bmp = CTRL_MENU_BUTTON_BACK
	},
	[HUD_MSG_ICON_MISSION] = {
		bmp = "uhd_ui_hud_icon_new_mission"
	},
	[HUD_MSG_ICON_HUMANSHIELD] = {
		bmp = "uhd_ui_hud_use_human_shield",
		color = {R = 201 / 255, G = 186 / 255, B = 44 / 255},
		x = -30 * 3,
		y = -55 * 3
	},
	[HUD_MSG_ICON_MECHANIC] = {
		bmp = "uhd_ui_hud_use_wrench",
		color = {R = 201 / 255, G = 186 / 255, B = 44 / 255},
		x = -34 * 3,
		y = -39 * 3
	},
	[HUD_MSG_ICON_GARAGE] = {
		bmp = "uhd_ui_hud_use_garage",
		color = {R = 201 / 255, G = 186 / 255, B = 44 / 255},
		x = -34 * 3,
		y = -39 * 3
	},
	[HUD_MSG_ICON_CRIB] = {
		bmp = "uhd_ui_hud_use_crib",
		color = {R = 201 / 255, G = 186 / 255, B = 44 / 255},
		x = -34 * 3,
		y = -39 * 3
	}
}

local Hud_msg_use_msg_h
local Hud_msg_use_btn
local Hud_msg_use_start_x = 0
local Hud_msg_use_start_y = 0
local Hud_msg_use_text_start_x = 0
local Hud_msg_use_text_start_y = 0

local Hud_msg_new_gameplay_h
local Hud_msg_gameplay_btn
local Hud_msg_gameplay_start_x = 0
local Hud_msg_gameplay_start_y = 0

local Hud_msg_critical = {}

local Hud_msg_current_use_msg_id = 0
local Hud_msg_current_critical_msg_id = 0
local Hud_msg_current_critical_msg_visible = false

Hud_msg_regions = {
	[HUD_REGION_DEBUG] = {
		text_fmt = Hud_msg_std_text,
		direction = HUD_MSG_DIR_CENTER,
		max_msgs = 10,
		anchor = "msg_debug_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_HELP] = {
		text_fmt = Hud_msg_help_text,
		direction = HUD_MSG_DIR_DOWN,
		max_msgs = 3,
		anchor = "msg_help_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_DIVERSION] = {
		text_fmt = Hud_msg_std_text,
		direction = HUD_MSG_DIR_UP,
		max_msgs = 7,
		anchor = "msg_diversion_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_SUBTITLES] = {
		text_fmt = Hud_msg_subtitle_text,
		direction = HUD_MSG_DIR_CENTER,
		max_msgs = 3,
		anchor = "msg_subtitle_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_CUTSCENE_HELP] = {
		text_fmt = Hud_msg_help_text,
		direction = HUD_MSG_DIR_CENTER,
		max_msgs = 2,
		anchor = "cs_help_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_USE_MSGS] = {
		text_fmt = Hud_msg_help_text,
		direction = HUD_MSG_DIR_DOWN,
		max_msgs = 1,
		anchor = "msg_help_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_NEW_GAMEPLAY] = {
		text_fmt = Hud_msg_help_text,
		direction = HUD_MSG_DIR_DOWN,
		max_msgs = 1,
		anchor = "msg_help_anchor",
		msgs = {num_msgs = 0}
	},
	[HUD_REGION_CRITICAL_TIMER] = {
		text_fmt = Hud_msg_help_text,
		direction = HUD_MSG_DIR_DOWN,
		max_msgs = 1,
		anchor = "msg_help_anchor",
		msgs = {num_msgs = 0}
	}
}

-- all messages are stored here with the data item handle as index
Hud_msgs = {}

function hud_msg_init()
	Hud_msg_doc = vint_document_find("hud_msg")

	-- resolve the anchors out to handles
	for i, v in pairs(Hud_msg_regions) do
		v.anchor = vint_object_find(v.anchor)
	end

	--Resize help region if we are in hd
	if vint_is_std_res() == false then
		--HD mode
		Hud_msg_help_text.wrap_width = 635 * 3
	end

	if game_get_language() == "JP" then
		Hud_msg_subtitle_text.leading = -3
	elseif game_get_language() == "SK" then
		Hud_msg_subtitle_text.scale = 0.9
		Hud_msg_subtitle_text.leading = -3
	end

	--Store center for centering later...
	Hud_msg_use_msg_h = vint_object_find("use_msg")
	Hud_msg_use_start_x, Hud_msg_use_start_y = vint_get_property(Hud_msg_use_msg_h, "anchor")
	local use_text_h = vint_object_find("use_text", Hud_msg_use_msg_h)
	Hud_msg_use_text_start_x, Hud_msg_use_text_start_y = vint_get_property(use_text_h, "anchor")

	--Store off the buttons for later use
	Hud_msg_use_btn = Vdo_hint_button:new("use_btn")
	Hud_msg_gameplay_btn = Vdo_hint_button:new("new_gameplay_btn")

	--Hide Use Message...
	vint_set_property(Hud_msg_use_msg_h, "alpha", 0)

	--Store center for centering later...
	Hud_msg_new_gameplay_h = vint_object_find("new_gameplay_msg")
	Hud_msg_gameplay_start_x, Hud_msg_gameplay_start_y = vint_get_property(Hud_msg_new_gameplay_h, "anchor")

	--Hide New Gameplay Message...
	vint_set_property(Hud_msg_new_gameplay_h, "alpha", 0)

	--Critical Timer
	Hud_msg_critical.grp_h = vint_object_find("critical_timer")
	Hud_msg_critical.timer_grp_h = vint_object_find("timer_grp", Hud_msg_critical.grp_h)
	Hud_msg_critical.timer_txt_h = vint_object_find("critical_time_txt", Hud_msg_critical.grp_h)
	Hud_msg_critical.timer_bmp_h = vint_object_find("timer_bmp", Hud_msg_critical.grp_h)
	Hud_msg_critical.timer_desc_txt_h = vint_object_find("critical_timer_desc_txt", Hud_msg_critical.grp_h)
	Hud_msg_critical.critical_bg_h = vint_object_find("critical_bg", Hud_msg_critical.grp_h)
	Hud_msg_critical.fade_in_anim_h = vint_object_find("critical_timer_fade_in")
	Hud_msg_critical.fade_out_anim_h = vint_object_find("critical_timer_fade_out")

	--Store centering information for the timer.
	Hud_msg_critical.timer_grp_x, Hud_msg_critical.timer_grp_y = vint_get_property(Hud_msg_critical.timer_grp_h, "anchor")

	--Hide Critical Timer...
	vint_set_property(Hud_msg_critical.grp_h, "alpha", 0)

	--Subscribe to data...
	vint_datagroup_add_subscription("hud_messages", "insert", "hud_msg_new_message")
	vint_datagroup_add_subscription("hud_messages", "update", "hud_msg_update_message")
	vint_datagroup_add_subscription("hud_messages", "remove", "hud_msg_remove_message")
end

function hud_msg_process()
	for i, region in pairs(Hud_msg_regions) do
		if region.is_dirty == true then
			hud_msg_update_region(region, i)
			region.is_dirty = false
		end
	end
end

function hud_msg_update_region(region, region_index)
	local pos_x, pos_y = 0, 0
	local msgs_displayed = 0

	if region_index == HUD_REGION_USE_MSGS then
		--Use messages...
		for msg_i = 0, region.msgs.num_msgs - 1 do
			if msgs_displayed >= region.max_msgs then
			else
				local msg = region.msgs[msg_i]
				local msg_id = msg.di_h
				hud_msg_update_use(msg)
				if Hud_msg_current_use_msg_id ~= msg.di_h then
					--New message we should always fade in...
					local h = vint_object_find("use_msg_fade_out", 0, Hud_msg_doc)
					vint_set_property(h, "is_paused", true)
					h = vint_object_find("use_msg_fade_in", 0, Hud_msg_doc)
					lua_play_anim(h, 0, Hud_msg_doc)
				end
				if Hud_msg_current_use_msg_id == msg.di_h then
					if msg.fade_time ~= 0 then
						--old message with a fade time, lets fade out...
						local h = vint_object_find("use_msg_fade_in", 0, Hud_msg_doc)
						vint_set_property(h, "is_paused", true)
						h = vint_object_find("use_msg_fade_out", 0, Hud_msg_doc)
						lua_play_anim(h, 0, Hud_msg_doc)
						msg_id = -1
					end
				end
				Hud_msg_current_use_msg_id = msg_id
			end
			msgs_displayed = msgs_displayed + 1
		end
		if region.msgs.num_msgs == 0 and Hud_msg_current_use_msg_id ~= -1 then
			--Fade out if there are no more messages left in the queue..
			local h = vint_object_find("use_msg_fade_in", 0, Hud_msg_doc)
			vint_set_property(h, "is_paused", true)
			h = vint_object_find("use_msg_fade_out", 0, Hud_msg_doc)
			lua_play_anim(h, 0, Hud_msg_doc)
			Hud_msg_current_use_msg_id = -1
		end
	elseif region_index == HUD_REGION_CRITICAL_TIMER then
		--Critical Timer messages...
		for msg_i = 0, region.msgs.num_msgs - 1 do
			if msgs_displayed < region.max_msgs then
				local msg = region.msgs[msg_i]
				local msg_id = msg.di_h
				hud_msg_update_critical(msg)
				if Hud_msg_current_critical_msg_id ~= msg.di_h and msg.di_h ~= -1 then
					if Hud_msg_current_critical_msg_visible == false then
						--New message we should always fade in...
						vint_set_property(Hud_msg_critical.fade_out_anim_h, "is_paused", true)
						lua_play_anim(Hud_msg_critical.fade_in_anim_h, 0, Hud_msg_doc)
						Hud_msg_current_critical_msg_visible = true
					end
				end
				if Hud_msg_current_critical_msg_id == msg.di_h then
					if Hud_msg_current_critical_msg_visible == true then
						if msg.fade_time ~= 0 then
							--old message with a fade time, lets fade out...
							vint_set_property(Hud_msg_critical.fade_in_anim_h, "is_paused", true)
							lua_play_anim(Hud_msg_critical.fade_out_anim_h, 0, Hud_msg_doc)
							Hud_msg_current_critical_msg_visible = false
						end
					end
				end
				Hud_msg_current_critical_msg_id = msg_id
			end
			msgs_displayed = msgs_displayed + 1
		end

		if region.msgs.num_msgs == 0 and Hud_msg_current_critical_msg_id ~= -1 then
			if Hud_msg_current_critical_msg_visible == true then
				--Fade out if there are no more messages left in the queue..
				vint_set_property(Hud_msg_critical.fade_in_anim_h, "is_paused", true)
				lua_play_anim(Hud_msg_critical.fade_out_anim_h, 0, Hud_msg_doc)
				Hud_msg_current_critical_msg_id = -1
				Hud_msg_current_critical_msg_visible = false
			end
		end
	else
		--Standard Help message...
		for msg_i = 0, region.msgs.num_msgs - 1 do
			local msg = region.msgs[msg_i]
			local o = msg.text_obj_h

			if msgs_displayed >= region.max_msgs then
				if o ~= 0 then
					vint_object_destroy(o)
				end
				msg.text_obj_h = 0
			else
				-- create a text item if needed
				if o == 0 then
					o = vint_object_create("hud_msg", "text", region.anchor)
					if o == 0 then
						debug_print("vint", "Problem: hud_msg cannot be created!\n")
						return
					end
					vint_set_property(o, "text_tag", msg.text)
					vint_set_property(o, "font", "thin_overlay")
					vint_set_property(o, "text_scale", region.text_fmt.scale, region.text_fmt.scale)
					vint_set_property(o, "tint", 0.862, 0.862, 0.862) --(220,220,220)
					vint_set_property(o, "leading", region.text_fmt.leading)

					local auto_offset, halign
					if region.direction == HUD_MSG_DIR_CENTER then
						auto_offset = "n"
						halign = "center"
					elseif region.direction == HUD_MSG_DIR_UP then
						auto_offset = "sw"
						halign = "left"
					else -- HUD_MSG_DIR_DOWN
						auto_offset = "nw"
						halign = "left"
					end

					if region.text_fmt.wrap_width > 0 then
						vint_set_property(o, "word_wrap", true)
						vint_set_property(o, "wrap_width", region.text_fmt.wrap_width)
					end

					vint_set_property(o, "auto_offset", auto_offset)
					vint_set_property(o, "horz_align", halign)
					vint_set_property(o, "shadow_enabled", true)
					vint_set_property(o, "shadow_offset", 2, 2)
					vint_set_property(o, "shadow_alpha", .6)
					vint_set_property(o, "shadow_tint", 0, 0, 0)

					if msg.audio_id ~= -1 then
						game_audio_play(msg.audio_id, msg.audio_type)
					end

					msg.text_obj_h = o
				end

				-- place the text
				vint_set_property(o, "anchor", pos_x, pos_y)

				local w, h = vint_get_property(o, "unscaled_size")

				if h ~= nil then
					-- figure position of next element
					if region.direction == HUD_MSG_DIR_UP then
						pos_y = pos_y - h
					else -- HUD_MSG_DIR_DOWN or HUD_MSG_DIR_CENTER
						pos_y = pos_y + h
					end
				else
					debug_print("vint", "Problem: hud_msg region has no height!\n")
				end
			end

			msgs_displayed = msgs_displayed + 1
		end
	end
end

function hud_msg_new_message(di_h)
	local region_index, priority, text, modifier, fade_time, audio_type, audio_id, icon1, icon2, pc_key, timer_value =
		vint_dataitem_get(di_h)

	local region = Hud_msg_regions[region_index]

	if region == nil then
		debug_print(
			"vint",
			"Message placed in invalid region, discarding. Region Index: " .. var_to_string(region_index) .. "\n"
		)
		return
	end

	-- initialize message
	local msg = {
		di_h = di_h,
		fade_time = fade_time,
		region_index = region_index,
		priority = priority,
		text = text,
		modifier = modifier,
		audio_type = audio_type,
		icon1 = icon1,
		icon2 = icon2,
		pc_key = pc_key,
		audio_id = audio_id,
		text_obj_h = 0,
		timer_value = timer_value
	}

	--Process special cases for special regions first...
	if region_index == HUD_REGION_NEW_GAMEPLAY then
		hud_msg_update_gameplay_msg(di_h)
	else
		--Standard region...

		-- insert in region list in priority order
		local insert_index = region.msgs.num_msgs
		for i = 0, region.msgs.num_msgs - 1 do
			local m = region.msgs[i]
			if m.priority < priority then
				insert_index = i
				break
			end
		end

		-- shift the list down
		for i = region.msgs.num_msgs, insert_index + 1, -1 do
			region.msgs[i] = region.msgs[i - 1]
		end

		-- insert new msg
		region.msgs[insert_index] = msg
		region.msgs.num_msgs = region.msgs.num_msgs + 1
		Hud_msgs[di_h] = msg
		region.is_dirty = true

		--process fades differently for use messages...
		if msg.region_index ~= HUD_REGION_USE_MSGS and msg.region_index ~= HUD_REGION_CRITICAL_TIMER then
			hud_msg_fade_process(msg, fade_time)
		end
	end
end

function hud_msg_update_message(di_h)
	local region_index, priority, text, modifier, fade_time, audio_type, audio_id, icon1, icon2, pc_key, timer_value =
		vint_dataitem_get(di_h)
	local msg = Hud_msgs[di_h]

	if msg == nil then
		-- we have no record of this data item
		hud_msg_new_message(di_h)
		return
	end

	if region_index == HUD_REGION_NEW_GAMEPLAY then
		hud_msg_update_gameplay_msg(di_h)
	else
		--Standard Msg Region...
		local region = Hud_msg_regions[msg.region_index]

		-- update the text item if it's changed
		if msg.text ~= text or msg.timer_value ~= timer_value then
			msg.text = text
			if msg.text_obj_h ~= 0 then
				vint_set_property(msg.text_obj_h, "text_tag", text)
			elseif msg.region_index == HUD_REGION_USE_MSGS or msg.region_index == HUD_REGION_CRITICAL_TIMER then
				-- the whole message has to be updated
				-- find msg in region
				local region = Hud_msg_regions[msg.region_index]
				local msg_index = -1
				for i = 0, region.msgs.num_msgs - 1 do
					if di_h == region.msgs[i].di_h then
						msg_index = i
						break
					end
				end

				-- remove it
				if msg_index > -1 then
					for i = msg_index + 1, region.msgs.num_msgs - 1 do
						region.msgs[i - 1] = region.msgs[i]
					end

					region.msgs.num_msgs = region.msgs.num_msgs - 1
					region.is_dirty = true
				end
				Hud_msgs[di_h] = nil
				hud_msg_new_message(di_h)
			end
		end

		--Update fade time...
		msg.fade_time = fade_time

		-- Use messages fade differently
		if msg.region_index ~= HUD_REGION_USE_MSGS and msg.region_index ~= HUD_REGION_CRITICAL_TIMER then
			hud_msg_fade_process(msg, fade_time)
		end

		region.is_dirty = true
	end
end

function hud_msg_remove_message(di_h)
	local region_index,
		priority,
		text,
		modifier,
		fade_time,
		audio_type,
		audio_id,
		icon1,
		icon2,
		pc_key,
		unused_timer,
		silent_kill = vint_dataitem_get(di_h)

	if region_index == HUD_REGION_NEW_GAMEPLAY then
		local h = vint_object_find("gameplay_msg_fade_out")
		vint_set_property(h, "is_paused", true)
		h = vint_object_find("gameplay_msg_fade_in")
		vint_set_property(h, "is_paused", true)
		vint_set_property(Hud_msg_new_gameplay_h, "alpha", 0)
	else
		local msg = Hud_msgs[di_h]
		if msg ~= nil then
			-- clean up any existing fade tween
			if msg.fade_tween_h ~= nil then
				vint_object_destroy(msg.fade_tween_h)
			end

			-- destroy text object
			if msg.text_obj_h ~= 0 then
				vint_object_destroy(msg.text_obj_h)
			end

			-- find msg in region
			local region = Hud_msg_regions[msg.region_index]
			local msg_index = -1
			for i = 0, region.msgs.num_msgs - 1 do
				if di_h == region.msgs[i].di_h then
					msg_index = i
					break
				end
			end

			-- remove it
			if msg_index > -1 then
				for i = msg_index + 1, region.msgs.num_msgs - 1 do
					region.msgs[i - 1] = region.msgs[i]
				end

				region.msgs.num_msgs = region.msgs.num_msgs - 1
				region.is_dirty = true
			end
		end

		Hud_msgs[di_h] = nil
	end
end

function hud_msg_fade_process(msg, new_fade)
	local is_fading = (msg.fade_time ~= nil and msg.fade_time ~= 0)
	local should_be_fading = (new_fade > 0)

	if is_fading ~= should_be_fading then
		-- clean up any existing tween
		if msg.fade_tween_h ~= nil then
			vint_object_destroy(msg.fade_tween_h)
		end

		if should_be_fading == true then
			-- start fading
			local o = vint_object_create("msg_fade", "tween", vint_object_find("root_animation"))
			vint_set_property(o, "target_handle", msg.text_obj_h)
			vint_set_property(o, "target_property", "alpha")
			vint_set_property(o, "duration", new_fade)
			vint_set_property(o, "start_value", 1)
			vint_set_property(o, "end_value", 0)
			vint_set_property(o, "start_time", vint_get_time_index())
			msg.fade_tween_h = o
		else
			-- stop fading
			vint_set_property(msg.text_obj_h, "alpha", 1)
		end
	end

	msg.fade_time = new_fade
end

function hud_msg_hide_region(region, hide)
	local region = Hud_msg_regions[region]

	if region ~= nil then
		vint_set_property(region.anchor, "visible", hide == false)
	end
end

function hud_msg_update_use(msg)
	--get data out of table...
	local text = msg.text
	local modifier = msg.modifier
	local icon1 = msg.icon1
	local icon2 = msg.icon2
	local pc_key = msg.pc_key

	--pop in message
	vint_set_property(Hud_msg_use_msg_h, "visible", true)
	vint_set_property(Hud_msg_use_msg_h, "alpha", 1)

	local bg_h = vint_object_find("use_bg", Hud_msg_use_msg_h)
	local use_icon_h = vint_object_find("use_icon", Hud_msg_use_msg_h)
	local use_txt_h = vint_object_find("use_text", Hud_msg_use_msg_h)
	local use_mod_txt_h = vint_object_find("use_modifier_text", Hud_msg_use_msg_h)
	local use_mod_txt_bg_h = vint_object_find("use_modifier_bg", Hud_msg_use_msg_h)

	--Set text for use message...
	vint_set_property(use_txt_h, "text_tag", text)

	--Add modifier button if needed... (HOLD) + message...
	local mod_width = 0
	if modifier ~= "" then
		vint_set_property(use_mod_txt_h, "text_tag", modifier)
		vint_set_property(use_mod_txt_h, "visible", true)
		vint_set_property(use_mod_txt_bg_h, "visible", true)

		--set backgorund size of left button...
		local w, h = element_get_actual_size(use_mod_txt_h)
		local bg_width, bg_height = element_get_actual_size(use_mod_txt_bg_h)
		mod_width = w + (14 * 3)
		element_set_actual_size(use_mod_txt_bg_h, mod_width, bg_height)
	else
		--Hide modifier action...
		vint_set_property(use_mod_txt_h, "visible", false)
		vint_set_property(use_mod_txt_bg_h, "visible", false)
	end

	--Icon1 is the button image... so set it..
	local button_width = 0
	if icon1 ~= HUD_MSG_ICON_NONE then
		local icon_bmp = Hud_msg_icons[icon1].bmp
		Hud_msg_use_btn:set_button(icon_bmp, pc_key)
		Hud_msg_use_btn:set_visible(true)
		local h_w, h_h = Hud_msg_use_btn:get_size()
		button_width = h_w
		local button_x = (button_width * 0.5) + (5 * 3)
		Hud_msg_use_btn:set_anchor(button_x, 0)
		local h_x, h_y = Hud_msg_use_btn:get_anchor()
		vint_set_property(use_txt_h, "anchor", h_x + button_x, Hud_msg_use_text_start_y)
	 --Hud_msg_use_text_start_x, Hud_msg_use_text_start_y)
	else
		Hud_msg_use_btn:set_visible(false)
		--offset text from left...
		vint_set_property(use_txt_h, "anchor", (8 * 3), Hud_msg_use_text_start_y)
	end

	--Target positions for centers...
	local target_x = Hud_msg_use_start_x
	local target_y = Hud_msg_use_start_y

	--Icon2 is the action image...
	if icon2 ~= HUD_MSG_ICON_NONE then
		local icon_bmp = Hud_msg_icons[icon2].bmp
		local color = Hud_msg_icons[icon2].color

		--Set color if it is defined...
		if color then
			vint_set_property(use_icon_h, "tint", color.R, color.G, color.B)
		else
			--No specified color...
			vint_set_property(use_icon_h, "tint", 1, 1, 1)
		end

		vint_set_property(use_icon_h, "image", Hud_msg_icons[icon2].bmp)
		vint_set_property(use_icon_h, "visible", true)
		vint_set_property(bg_h, "visible", false)
		vint_set_property(use_txt_h, "visible", false)

		local w, h = element_get_actual_size(use_icon_h)
		target_x = Hud_msg_use_start_x - w / 2 - (10 * 3)
	else
		vint_set_property(use_icon_h, "visible", false)
		vint_set_property(use_txt_h, "visible", true)
		vint_set_property(bg_h, "visible", true)

		--Update background size and center to screen...
		local h_w, h_h = element_get_actual_size(use_txt_h)
		local w = button_width + h_w + (17 * 3)

		--set background size of button...
		local bg_width, bg_height = element_get_actual_size(bg_h)
		element_set_actual_size(bg_h, w, bg_height)

		--Center object to screen...
		local scale_x, scale_y = vint_get_property(Hud_msg_use_msg_h, "scale") -- get scale of the box so we can center it appropriatly..
		target_x = (Hud_msg_use_start_x - ((w - mod_width) / 2) * scale_x)
	end

	--Set Position...
	vint_set_property(Hud_msg_use_msg_h, "anchor", target_x, target_y)
end

function hud_msg_update_critical(msg)
	--get data out of table...
	local text = msg.text
	local modifier = msg.modifier
	local timer_value = msg.timer_value

	local timer_grp_h = Hud_msg_critical.timer_grp_h
	local timer_txt_h = Hud_msg_critical.timer_txt_h
	local timer_bmp_h = Hud_msg_critical.timer_bmp_h
	local timer_desc_txt = Hud_msg_critical.timer_desc_txt_h
	local critical_bg_h = Hud_msg_critical.critical_bg_h

	---Format the time
	local minutes = floor(timer_value / 60)
	local seconds = timer_value % 60
	--Pad the seconds for the timer
	if seconds < 1 then
		-- Fixing a case where we had negative 0
		seconds = "00"
	elseif seconds < 10 then
		seconds = "0" .. seconds
	end

	local time_formatted
	if minutes < 1 then
		time_formatted = ":" .. seconds
	else
		time_formatted = minutes .. ":" .. seconds
	end

	--Set Text values...
	vint_set_property(timer_txt_h, "text_tag", time_formatted)
	vint_set_property(timer_desc_txt, "text_tag", text)

	--center timer with text
	local timer_width, timer_height = element_get_actual_size(timer_txt_h)
	local timer_bmp_width, timer_bmp_height = element_get_actual_size(timer_bmp_h)
	timer_width = timer_width + timer_bmp_width
	local x = -timer_width / 2
	vint_set_property(timer_grp_h, "anchor", x, Hud_msg_critical.timer_grp_y)

	--Update background size and center to screen...
	local timer_desc_width, timer_desc_height = element_get_actual_size(timer_desc_txt)
	local width = timer_desc_width + (20 * 3)
	width = max(width, timer_width)
	local critical_bg_width, critical_bg_height = element_get_actual_size(critical_bg_h)
	element_set_actual_size(critical_bg_h, width, critical_bg_height)
end

function hud_msg_update_gameplay_msg(di_h)
	local region_index, priority, text, modifier, fade_time, audio_type, audio_id, icon1, icon2, pc_key =
		vint_dataitem_get(di_h)

	if fade_time == 0 then
		local h = vint_object_find("gameplay_msg_fade_out")
		vint_set_property(h, "is_paused", true)
		lua_play_anim(vint_object_find("gameplay_msg_fade_in"))
	else
		lua_play_anim(vint_object_find("gameplay_msg_fade_out"))
	end

	local use_txt_h = vint_object_find("new_gameplay_txt", Hud_msg_new_gameplay_h)
	local use_bmp_h = vint_object_find("gameplay_icon", Hud_msg_new_gameplay_h)

	--Icon1 is the button image... so set it..
	if icon1 ~= HUD_MSG_ICON_NONE then
		local icon_bmp = Hud_msg_icons[icon1].bmp
		Hud_msg_gameplay_btn:set_button(icon_bmp, pc_key)
	end

	if icon2 == HUD_MSG_ICON_NONE then
		vint_set_property(use_bmp_h, "visible", false)
	else
		local icon_data = Hud_msg_icons[icon2]
		vint_set_property(use_bmp_h, "image", icon_data.bmp)
		vint_set_property(use_bmp_h, "visible", true)
	end

	vint_set_property(use_txt_h, "text_tag", text)
	vint_set_property(use_txt_h, "visible", true)

	local button_x = 0
	local h_w, h_h = Hud_msg_gameplay_btn:get_size()
	local new_button_x = button_x + (h_w * 0.5) + (5 * 3)

	--Update background size and center to screen...
	local w = 0
	local img_w, img_h = element_get_actual_size(use_bmp_h)
	w = w + h_w

	Hud_msg_gameplay_btn:set_anchor(new_button_x, 0)
	vint_set_property(use_bmp_h, "anchor", new_button_x + (h_w * 0.5) + (img_w * 0.5) + (3 * 3), 0)
	vint_set_property(use_txt_h, "anchor", new_button_x + (h_w * 0.5) + img_w + (5 * 3), 0)

	h_w, h_h = element_get_actual_size(use_txt_h)
	w = w + h_w + img_w + (20 * 3)

	--set backgorund size of button...
	local bg_h = vint_object_find("new_gameplay_bg")
	local bg_width, bg_height = element_get_actual_size(bg_h)
	element_set_actual_size(bg_h, w, bg_height)

	--Center object to screen...
	local scale_x, scale_y = vint_get_property(Hud_msg_new_gameplay_h, "scale") -- get scale of the box so we can center it appropriatly..
	vint_set_property(
		Hud_msg_new_gameplay_h,
		"anchor",
		Hud_msg_gameplay_start_x - ((w / 2) * scale_x),
		Hud_msg_gameplay_start_y
	)
end

-------------------------------------------------------------------------------
-- Moves subtitle messages to top of screen
--
function hud_msg_subtitle_top()
	local anchor_x, anchor_y = vint_get_property(Hud_msg_regions[HUD_REGION_SUBTITLES].anchor, "anchor")
	local scale_x, scale_y = vint_get_property(Hud_msg_regions[HUD_REGION_SUBTITLES].anchor, "scale")
	anchor_y = (94 * 3) * scale_x
	vint_set_property(Hud_msg_regions[HUD_REGION_SUBTITLES].anchor, "anchor", anchor_x, anchor_y)
end

-------------------------------------------------------------------------------
-- Moves subtitle messages to bottom of screen
--
function hud_msg_subtitle_bottom()
	local anchor_x, anchor_y = vint_get_property(Hud_msg_regions[HUD_REGION_SUBTITLES].anchor, "anchor")
	local scale_x, scale_y = vint_get_property(Hud_msg_regions[HUD_REGION_SUBTITLES].anchor, "scale")
	anchor_y = (561 * 3) * scale_x
	vint_set_property(Hud_msg_regions[HUD_REGION_SUBTITLES].anchor, "anchor", anchor_x, anchor_y)
end
et_'0