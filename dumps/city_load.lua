local IMAGE_DELAY = 5

City_load_data = { 
		handles = { },
}

City_load_images = {	
	"ui_mainmenu_load_01",
	"ui_mainmenu_load_02",
	"ui_mainmenu_load_03",
	"ui_mainmenu_load_04",
	"ui_mainmenu_load_05",
	"ui_mainmenu_load_06",
	"ui_mainmenu_load_07",
	"ui_mainmenu_load_08",
	"ui_mainmenu_load_09",
	"ui_mainmenu_load_10",
	"ui_mainmenu_load_11",
}

City_load_current_images = {}
local City_load_doc_handle = -1

function city_load_init()
	City_load_doc_handle = vint_document_find("city_load")
	local h = -1
	City_load_data.handles.loading_grp_h = vint_object_find("loading_grp",0,City_load_doc_handle)
	h = City_load_data.handles.loading_grp_h
	City_load_data.handles.images_h = vint_object_find("images",0,City_load_doc_handle)
	h = City_load_data.handles.images_h
	City_load_data.handles.bmp1_h = vint_object_find("bmp1", h)
	City_load_data.handles.bmp2_h = vint_object_find("bmp2", h)
	City_load_data.handles.bmp3_h = vint_object_find("bmp3", h)
	
	--looping animation stuff
	City_load_data.handles.transition2_h = vint_object_find("transition2",0,City_load_doc_handle)
	h = City_load_data.handles.transition2_h
	City_load_data.handles.load3_bmp1_out = vint_object_find("load3_bmp1_in", h)
	local twn_h = City_load_data.handles.load3_bmp1_out
	
	vint_set_property(twn_h, "end_event", "city_load_transition")
	
	local loading_anim_h = vint_object_find("loading_anim",0,City_load_doc_handle)
	local loading_twn_h = vint_object_find("loading_twn",loading_anim_h)
	vint_set_property(loading_twn_h, "end_event", "vint_anim_loop_callback")
	lua_play_anim(loading_anim_h,0,City_load_doc_handle)
	
	
	--play animations...
	local loading_pulse_anim_h = vint_object_find("loading_pulse_anim",0,City_load_doc_handle)
	lua_play_anim(loading_pulse_anim_h,0,City_load_doc_handle)
	
	local loading_in_anim_h = vint_object_find("loading_in_anim",0,City_load_doc_handle)
	lua_play_anim(loading_in_anim_h,0,City_load_doc_handle)
	
	
	
	local loading_images = {}
	local random_num_values = {}
	local random_num_count = 1
	
	local check_screen_fades = false
	
	--Make sure we don't try to load/unload our always loaded images
	local screen_fade_doc_h = vint_document_find("screen_fade")
	if screen_fade_doc_h ~= 0 then
		--doc is loaded, now check if we are suing the always loaded images...
		if Screen_fade_use_load_images then
			check_screen_fades = true
		end
	end
	
	while #random_num_values < 3 do
		local found_match = false
		local random_num = rand_int(1,#City_load_images)
		for i = 1, 3 do
			if random_num == random_num_values[i] then
				found_match = true
			end
		end
		if found_match == false then
			if check_screen_fades == true then
				--loop through our loaded images and compare them against the city load images...
				for idx, screen_fade_load_image in pairs(Screen_fade_loaded_images) do
					if screen_fade_load_image == City_load_images[random_num] then
						--Found match, don't add it to random_num_values.
						found_match = true
					end
				end
			end
	
			if found_match == false then
				random_num_values[random_num_count] = random_num
				random_num_count = random_num_count + 1
			end
		end
	end
	
	local platform_file_ext = ""
	if game_get_platform() == "PC" then
		platform_file_ext = "_pc"
	end

	for i = 1, #random_num_values do
		loading_images[i] = City_load_images[random_num_values[i]] --.. platform_file_ext
	end
	
	local images = loading_images
	City_load_current_images = images
	
	game_peg_load_with_cb("city_load_set_images", 3, images[1],  images[2], images[3])	
	
end

function city_load_set_images()
	vint_set_property(City_load_data.handles.bmp1_h, "image", City_load_current_images[1])
	vint_set_property(City_load_data.handles.bmp2_h, "image", City_load_current_images[2])
	vint_set_property(City_load_data.handles.bmp3_h, "image", City_load_current_images[3])
	
	--set up the wait time
	local wait_anim_h = vint_object_find("wait_10_anim", 0, City_load_doc_handle)
	local wait_twn_h = vint_object_find("wait_twn", wait_anim_h)
	vint_set_property(wait_twn_h, "end_event", "city_load_show_images")
	vint_set_property(wait_twn_h, "duration", IMAGE_DELAY)
	
	--hide the images until we have dealyed time
	local images_h = vint_object_find("images", 0, City_load_doc_handle)
	vint_set_property(images_h, "visible", false)
	
	lua_play_anim(wait_anim_h, 0, City_load_doc_handle)
	
	-- Tell C code that images are done loading
	city_load_img_load_complete()
end

function city_load_show_images()
	local images_h = vint_object_find("images", 0, City_load_doc_handle)
	vint_set_property(images_h, "visible", true)
	lua_play_anim(City_load_data.handles.transition2_h, 0, City_load_doc_handle)
end

function city_load_hide_images()
	local images_h = vint_object_find("images", 0, City_load_doc_handle)
	vint_set_property(images_h, "visible", false)
	for i, v in pairs(City_load_current_images) do
		game_peg_unload(v)
	end	
end

function city_load_transition()
	vint_set_property(City_load_data.handles.bmp1_h, "alpha", 1)
	vint_set_property(City_load_data.handles.bmp2_h, "alpha", 1)
	vint_set_property(City_load_data.handles.bmp3_h, "alpha", 1)
	debug_print("vint", "city_load_transition, end of anim reached, looping now \n")
	lua_play_anim(City_load_data.handles.transition2_h, 0, City_load_doc_handle)
end

function city_load_cleanup()
	 for i, v in pairs(City_load_current_images) do
		 game_peg_unload(v)
	 end
end
