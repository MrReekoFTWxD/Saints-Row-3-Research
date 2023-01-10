Main_menu_load_doc = -1

-- Initializes main menu loading...
--
function main_menu_load_init()
	--This doc is included as a dependency of main_menu_top, so the only thing we want to do is store a global reference to it...
	Main_menu_load_doc = vint_document_find("main_menu_load")
	
end

function main_menu_load_cleanup()
end

-- Starts the main menu load.
function main_menu_load_start()
	--Play animations...
	local intro_loading_anim_h = vint_object_find("intro_loading_anim", 0, Main_menu_load_doc)		--Fade in percent...
	local loading_pulse_anim_h = vint_object_find("loading_pulse_anim", 0, Main_menu_load_doc)		--
	lua_play_anim(intro_loading_anim_h, 0, Main_menu_load_doc)
	lua_play_anim(loading_pulse_anim_h, 0, Main_menu_load_doc)
end

-- if percent < 1 then update the loading progress indicator
-- otherwise transition to "press start..."

-- Update from game the percentage of the loading...
-- when it is done loading it should called
function main_menu_load_complete(percent)
	if percent >= 1 then
		--Main menu loaded....
		main_menu_load_finished()
		percent = 1
	end
	
	--Insert Percent into loading text
	local values = {[0] = "GAME_LOADING", [1] = floor(percent*100)}
	local str = vint_insert_values_in_string("{0} {1}%%%", values)
	vint_set_property(vint_object_find("mm_percent_complete", 0, Main_menu_load_doc), "text_tag", str)
end

function main_menu_load_finished()
	-- Show press start... call to main_menu_top.lua
	main_menu_top_press_start_show()
	
	--Show Logo...
	main_menu_logo_show()
	
	-- Force pause intro loading anim...
	local intro_loading_anim_h = vint_object_find("intro_loading_anim", 0, Main_menu_load_doc)		--Fade in percent...
	vint_set_property(intro_loading_anim_h, "is_paused", true)
	
	-- Hide loading stuff...
	local intro_loading_fadeout_anim_h = vint_object_find("intro_loading_fadeout_anim", 0, Main_menu_load_doc)
	lua_play_anim(intro_loading_fadeout_anim_h, 0, Main_menu_load_doc)
end

function main_menu_load_skip()
	local screen_black_out_h = vint_object_find("screen_black_out", 0, Main_menu_load_doc)
	vint_set_property(screen_black_out_h, "alpha", 0)
	
	local loading_grp_h = vint_object_find("loading_grp", 0, Main_menu_load_doc)
	vint_set_property(loading_grp_h, "alpha", 0)
end