Hud_healthbars_status = {	
	
	--Hostiles Info
	hostiles = { },
	
	hostile_elements = {
		grp_h = 0, fill_h = 0, border_h = 0,
	},
	
	--animations
	anims = { },
	
	anim_elements = {
		healthbar_anim_h = 0, 
	},
	
	handles = {},
}

USE_OBJECT_HANDLE_KEY = 0

COLOR_RED				= 0
COLOR_BLUE				= 1
COLOR_NEUTRAL			= 2

function hud_healthbars_init()
	--mini healthbar
	local h = -1
	Hud_healthbars_status.hostile_elements.grp_h = vint_object_find("health_mini_grp")
	vint_set_property(Hud_healthbars_status.hostile_elements.grp_h, "visible", false)
	
	h = Hud_healthbars_status.hostile_elements.grp_h
	Hud_healthbars_status.hostile_elements.fill_h = vint_object_find("health_mini_fill", h)
	Hud_healthbars_status.hostile_elements.border_h = vint_object_find("health_mini_border", h)
	Hud_healthbars_status.hostile_elements.grit_h = vint_object_find("health_mini_grit", h)
	Hud_healthbars_status.handles.mp_arrow_h = vint_object_find("mp_arrow", h)
	Hud_healthbars_status.handles.mp_name_h = vint_object_find("mp_name", h)
	Hud_healthbars_status.handles.overhead_cash_h = vint_object_find("overhead_cash", h)
	Hud_healthbars_status.handles.race_pos_h = vint_object_find("race_pos", h)
	
	--large healthbar
	Hud_healthbars_status.handles.health_large_grp = vint_object_find("health_large_grp")
	vint_set_property(Hud_healthbars_status.handles.health_large_grp, "visible", false)
	
	h = Hud_healthbars_status.handles.health_large_grp
	Hud_healthbars_status.handles.health_large_fill = vint_object_find("health_large_fill", h)
	Hud_healthbars_status.handles.health_large_border = vint_object_find("health_large_border", h)
	
	--animation
	Hud_healthbars_status.anim_elements.healthbar_anim_h = vint_object_find("health_mini_fade_out")
	--large
	Hud_healthbars_status.handles.health_large_fade_out = vint_object_find("health_large_fade_out")
	--overhead_cash fade out
	Hud_healthbars_status.handles.overhead_cash_fade_out = vint_object_find("overhead_cash_fade_out")
	
	--Pause animations
	vint_set_property(Hud_healthbars_status.anim_elements.healthbar_anim_h, "is_paused", true)
	--large
	vint_set_property(Hud_healthbars_status.handles.health_large_fade_out, "is_paused", true)
	--overhead_cash fade out
	vint_set_property(Hud_healthbars_status.handles.overhead_cash_fade_out, "is_paused", true)
		
	--Health Bar Subscription
	vint_datagroup_add_subscription("sr2_local_player_septic", "insert", "hud_healthbars_update")
	vint_datagroup_add_subscription("sr2_local_player_septic", "update", "hud_healthbars_update")
	vint_datagroup_add_subscription("sr2_local_player_septic", "remove", "hud_healthbars_update")
end

function hud_healthbars_cleanup()
end

function tint_element( handle, color )
	if color == COLOR_RED then
		vint_set_property( handle, "tint", 0.71, 0, 0 )
	elseif color == COLOR_BLUE then
		vint_set_property( handle, "tint", COLOR_SAINTS_PURPLE.R, COLOR_SAINTS_PURPLE.G, COLOR_SAINTS_PURPLE.B )
		--SR2 COOP Blue
		--vint_set_property( handle,	"tint", 0.27, 0.51, 0.84 )
	else
		vint_set_property( handle, "tint", 1, 1, 1 )
	end
end

function tint_healthbar( hostile, color )
	tint_element( hostile.fill_h, color )
	tint_element( hostile.mp_name_h, color )
	tint_element( hostile.mp_arrow_h, color )
	tint_element( hostile.cash_h, color )
	tint_element( hostile.race_pos_h, color )
end

function hud_healthbars_update(di_h, event)

	local no_object_key, object_handle, screen_x, screen_y, z_depth,
		distance, health_pct, name, overhead_cash, race_position,
		is_visible, color, is_big, health_full_alpha, mp_respawn_invulnerable,
		show_bar, show_name, show_arrow, show_cash, show_race_pos, alpha = vint_dataitem_get(di_h)
	
	local decoded_name = vint_debug_decode_wide_string( name )	
	
	local key = ( no_object_key == USE_OBJECT_HANDLE_KEY ) and object_handle or no_object_key
	
	if event == "update" then
	
		--check to see if there is a hostile indicator for the key
		if Hud_healthbars_status.hostiles[key] == nil then
			
			--Doesn't currently exist so create the hostile indicator
			local grp_h = vint_object_clone(Hud_healthbars_status.hostile_elements.grp_h)
			local fill_h = vint_object_find("health_mini_fill", grp_h)
			local border_h = vint_object_find("health_mini_border", grp_h)
			local grit_h = vint_object_find("health_mini_grit", grp_h)
			local mp_name_h = vint_object_find("mp_name", grp_h)
			local mp_arrow_h = vint_object_find("mp_arrow", grp_h)
			local overhead_cash_h = vint_object_find("overhead_cash", grp_h)
			local race_pos_h = vint_object_find("race_pos", grp_h)
			
			--Create the animation clones			
			local anim_clone_0 = vint_object_clone(Hud_healthbars_status.anim_elements.healthbar_anim_h )
			local anim_0_fade = vint_object_find("mini_alpha_twn", anim_clone_0)
			vint_set_property(anim_clone_0, "is_paused", true)
			vint_set_property(anim_0_fade, "target_handle",	grp_h)
			
			
			local invulnerable_anim_0 = 0 
			if MP_enabled == true then
				
				--Create invulnerable animation clones				
				invulnerable_anim_0 = vint_object_clone(vint_object_find("health_anim_1"))
				
				---   0 = 191; 112; 0  ->> 0 = 255; 255; 147
				local h = vint_object_find("health_flash_0_tween", invulnerable_anim_0)
				vint_set_property(h, "start_value", 0.749, 0.439, 0)
				vint_set_property(h, "end_value", 1, 1, 0.576)
				vint_set_property(h, "loop_mode", "bounce")
				vint_set_property(h, "target_handle", fill_h)
				
				--Destroy the other tween :)
				local h = vint_object_find("health_flash_1_tween", invulnerable_anim_0)
				vint_object_destroy(h)
				
				if mp_respawn_invulnerable == false then
					vint_set_property(invulnerable_anim_0, "is_paused", true)
				else
					lua_play_anim(invulnerable_anim_0, 0)
				end
			end
			
			
			--Create the animation clones			
			local cash_fade_clone = vint_object_clone(Hud_healthbars_status.handles.overhead_cash_fade_out)
			local cash_fade_1 = vint_object_find("over_cash_fade_1", cash_fade_clone)
			local cash_fade_2 = vint_object_find("over_cash_fade_2", cash_fade_clone)
			vint_set_property(cash_fade_clone, "is_paused", true)
			vint_set_property(cash_fade_1, "target_handle",	overhead_cash_h)
			vint_set_property(cash_fade_2, "target_handle",	overhead_cash_h)

			-- Assign the handles (these values shouldn't change after creation)
			Hud_healthbars_status.hostiles[key] = {
				--dont delete items from this table................
				grp_h = grp_h,
				fill_h = fill_h,
				border_h = border_h,
				grit_h = grit_h,
				health_pct = health_pct ,
				anim_clone_0 = anim_clone_0,
				anim_0_fade = anim_0_fade,
				invulnerable_anim_0 = invulnerable_anim_0,
				mp_respawn_invulnerable = mp_respawn_invulnerable,
				cash_fade_clone = cash_fade_clone,
				cash_fade_1 = cash_fade_1,
				cash_fade_2 = cash_fade_2,
				distance = distance,
				is_visible = is_visible,
				screen_x = screen_x,
				screen_y = screen_y,
				z_depth = z_depth,
				mp_arrow_h = mp_arrow_h,
				mp_name_h = mp_name_h, 
				overhead_cash_h = overhead_cash_h,
				overhead_cash = overhead_cash,
				race_pos_h = race_pos_h,
				race_position = race_position,
			}
			
			-- Convenience local var
			local hostile = Hud_healthbars_status.hostiles[key]
						
			if is_big then
				-- Different fill graphics
				vint_set_property(hostile.fill_h, "image", "uhd_ui_hud_meter_fill")
				vint_set_property(hostile.border_h, "image", "uhd_ui_hud_meter_border")
				vint_set_property(hostile.grit_h, "image", "uhd_ui_hud_meter_grit")	
			end
			
--			debug_print( "vint_healthbars", "Creating healthbar for " .. decoded_name .. " key: " .. key .. "\n" )
		end
		
		-- Convenience local var
		local hostile = Hud_healthbars_status.hostiles[key]
		
		-- This is all debug calculations, so comment this out if you don't need to see it
		do
			local current_visible = vint_get_property( hostile.grp_h, "visible" )
			local current_bar = vint_get_property( hostile.fill_h, "visible" )
			local current_name = vint_get_property( hostile.mp_name_h, "visible" )
			local current_arrow = vint_get_property( hostile.mp_arrow_h, "visible" )
			local current_cash = vint_get_property( hostile.overhead_cash_h, "visible" )
			local current_race_pos = vint_get_property( hostile.race_pos_h, "visible" )
			
			if current_visible ~= is_visible or
				current_bar ~= show_bar or
				current_name ~= show_name or
				current_arrow ~= show_arrow or
				current_cash ~= show_cash or
				current_race_pos ~= show_race_pos then
				
				--[[
				debug_print( "vint_healthbars", "Updating healthbar for " .. decoded_name ..
					" key: " .. key ..
					( is_visible and " visible " or "" ) ..
					( show_bar and " bar " or "" ) ..
					( show_name and " name " or "" ) ..
					( show_arrow and " arrow " or "" ) ..
					( show_cash and " cash " or "" ) ..
					( show_race_pos and " race_pos " or "" ) ..
					"\n" )	]]
			end
		end
		
		if is_big then
			--big bar
			local w, h = element_get_actual_size(Hud_healthbars_status.handles.health_large_fill)
			vint_set_property(hostile.fill_h, "source_se", w * health_pct, h)
			vint_set_property(hostile.border_h, "source_se", (w * health_pct) + 12 * 3, h + 12 * 3)
		else
			--regular bar
			local w, h = element_get_actual_size(Hud_healthbars_status.hostile_elements.fill_h)
			vint_set_property(hostile.fill_h, "source_se", w * health_pct, h)
			vint_set_property(hostile.border_h, "source_se", (w * health_pct) + 12 * 3, h + 12 * 3)
		end
		
		--debug_print("vint", "health_full_alpha " .. var_to_string(health_full_alpha) .. "\n")
		
		if health_pct ~= hostile.health_pct and health_pct == 0 then
			if health_full_alpha == false then
				lua_play_anim(hostile.anim_clone_0, 0)
			end
		end
		
		if health_full_alpha == true then
			vint_set_property(hostile.grp_h, "alpha", 1)
		end
		
		-- Change visibility for: whole group
		vint_set_property(hostile.grp_h, "visible", is_visible)
		
		-- ...bar
		vint_set_property(hostile.fill_h, "visible", show_bar)
		if alpha < 1.0 then
			vint_set_property(hostile.border_h, "visible", false)
			vint_set_property(hostile.grit_h, "visible", false)
		else
			vint_set_property(hostile.border_h, "visible", show_bar)
			vint_set_property(hostile.grit_h, "visible", show_bar)
		end
		
		-- ...name
		vint_set_property(hostile.mp_name_h, "visible", show_name)
		if alpha < 1.0 then
			vint_set_property(hostile.mp_name_h, "shadow_enabled", false) 
		else
			vint_set_property(hostile.mp_name_h, "shadow_enabled", true) 
		end
		
		-- ...arrow
		vint_set_property(hostile.mp_arrow_h, "visible", show_arrow)
		
		-- ...cash
		if overhead_cash ~= 0 then
			vint_set_property(hostile.overhead_cash_h, "text_tag", "+$" .. format_cash(overhead_cash))
		end
		
		if overhead_cash == 0 and hostile.overhead_cash ~= 0  then
			lua_play_anim(hostile.cash_fade_clone)
		else
			vint_set_property(hostile.overhead_cash_h, "visible", show_cash)
			vint_set_property(hostile.overhead_cash_h, "alpha", 1)
			vint_set_property(hostile.case_fade_clone, "is_paused", true)
		end
		
		hostile.overhead_cash = overhead_cash
		
		-- ...race_pos
		vint_set_property(hostile.race_pos_h, "visible", show_race_pos)
		if show_race_pos then
			vint_set_property(hostile.race_pos_h, "image", "ingame_race_position_" .. race_position) 
		end
		
		-- Set the name
		vint_set_property(hostile.mp_name_h, "text_tag", name)
		
		-- Set the color
		tint_healthbar( hostile, color )
		
		--Screen Position		
		local x = screen_x
		local y = screen_y
		vint_set_property(hostile.grp_h, "anchor", x, y)	
		
		--Scale
		local maxclamp = 0.40
		local minclamp = 0.1
		
		local maxscale = 1
		local minscale = 0.5
		
		--Clamp the distances
		if distance <= minclamp then
			distance = minclamp 
		elseif distance >= maxclamp then
			distance = maxclamp
		end

		local newdist = (distance - minclamp)
		local ratio = 1 - (newdist / (maxclamp - minclamp))
		local scale = (ratio * (maxscale-minscale)) + minscale
		
		vint_set_property(hostile.grp_h, "scale", scale, scale)
		vint_set_property(hostile.grp_h, "alpha", alpha)
			
		--Z Depth
		if z_depth ~= hostile.z_depth then
			vint_set_property(hostile.grp_h,  "depth", z_depth)
		end
		
		--Invulnerability change
		if MP_enabled == true then
			if hostile.mp_respawn_invulnerable ~= mp_respawn_invulnerable then
				if mp_respawn_invulnerable == false then
					vint_set_property(hostile.invulnerable_anim_0, "is_paused", true)
				else
					lua_play_anim(hostile.invulnerable_anim_0, 0)
				end
			end
			hostile.mp_respawn_invulnerable = mp_respawn_invulnerable
		end
		
		--dont ever delete this.........
		hostile.health_pct = health_pct
		
		-- For debugging purposes we also store the decoded name
		hostile.decoded_name = decoded_name
	end

		
	--If you got a remove event, remove the clones	
	if event == "remove" and Hud_healthbars_status.hostiles[key] ~= nil then
--		debug_print("vint_healthbars", "Remove healthbar for " .. decoded_name .. " key: " .. key .. "\n")
		local hostile = Hud_healthbars_status.hostiles[key]
		vint_object_destroy(hostile.grp_h)
		vint_object_destroy(hostile.anim_clone_0)
		vint_object_destroy(hostile.cash_fade_clone)
		vint_object_destroy(hostile.invulnerable_anim_0)
		Hud_healthbars_status.hostiles[key] = nil
	end
		
end

-- Prints out info for every entry in the current hostiles list
--
function hud_healthbars_debug_print()
--	debug_print( "vint_healthbars", "Current healthbar entries:\n" )
	
--	for key, entry in pairs(Hud_healthbars_status.hostiles) do
--		debug_print( "vint_healthbars", "\tkey: " .. key .. " name: " .. entry.decoded_name .. "\n" )
--	end
end




