lib_mg_valleys_3d = {}
lib_mg_valleys_3d.name = "lib_mg_valleys_3d"
lib_mg_valleys_3d.ver_max = 0
lib_mg_valleys_3d.ver_min = 1
lib_mg_valleys_3d.ver_rev = 0
lib_mg_valleys_3d.ver_str = lib_mg_valleys_3d.ver_max .. "." .. lib_mg_valleys_3d.ver_min .. "." .. lib_mg_valleys_3d.ver_rev
lib_mg_valleys_3d.authorship = "ShadMOrdre.  Additional credits to Termos' Islands mod; Gael-de-Sailleys' Valleys; duane-r Valleys_c, burli mapgen, and paramats' mapgens"
lib_mg_valleys_3d.license = "LGLv2.1"
lib_mg_valleys_3d.copyright = "2020"
lib_mg_valleys_3d.path_mod = minetest.get_modpath(minetest.get_current_modname())
lib_mg_valleys_3d.path_world = minetest.get_worldpath()

local S
local NS
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	-- S = function(s) return s end
	-- internationalization boilerplate
	S, NS = dofile(lib_mg_valleys_3d.path_mod.."/intllib.lua")
end
lib_mg_valleys_3d.intllib = S

minetest.log(S("[MOD] lib_mg_valleys_3d:  Loading..."))
minetest.log(S("[MOD] lib_mg_valleys_3d:  Version:") .. S(lib_mg_valleys_3d.ver_str))
minetest.log(S("[MOD] lib_mg_valleys_3d:  Legal Info: Copyright ") .. S(lib_mg_valleys_3d.copyright) .. " " .. S(lib_mg_valleys_3d.authorship) .. "")
minetest.log(S("[MOD] lib_mg_valleys_3d:  License: ") .. S(lib_mg_valleys_3d.license) .. "")


	local abs   = math.abs
	local max   = math.max
	local min   = math.min
	local floor = math.floor

	lib_mg_valleys_3d.heightmap = {}
	lib_mg_valleys_3d.fillermap = {}
	lib_mg_valleys_3d.biomemap = {}
	lib_mg_valleys_3d.rivermap = {}
	--lib_mg_valleys_3d.densitymap = {}
	lib_mg_valleys_3d.surfacemap = {}
	lib_mg_valleys_3d.slopemap = {}

	lib_mg_valleys_3d.water_level = 1
	lib_mg_valleys_3d.mgvalleys_river_size = 5
	-- mg_dim = 2d, 3d
	lib_mg_valleys_3d.mg_dim = "3d"

	lib_mg_valleys_3d.use_heat_scalar = false

	lib_mg_valleys_3d.mg_world_scale = 1

	lib_mg_valleys_3d.mg_noise_spread = 600
	lib_mg_valleys_3d.mg_noise_scale = 25
	--lib_mg_valleys_3d.mg_noise_offset = 0
	lib_mg_valleys_3d.mg_noise_offset = -4
	lib_mg_valleys_3d.mg_noise_octaves = 8
	lib_mg_valleys_3d.mg_noise_persist = 0.3
	lib_mg_valleys_3d.mg_noise_lacunarity = 2.19

	local min_ocean = lib_materials.ocean_depth
	local min_beach = lib_materials.beach_depth
	local max_beach = lib_materials.maxheight_beach
	local max_highland = lib_materials.maxheight_highland
	local max_mountain = lib_materials.maxheight_mountain

	local m_top1 = 12.5
	local m_top2 = 37.5
	local m_top3 = 62.5
	local m_top4 = 87.5

	local m_biome1 = 25
	local m_biome2 = 50
	local m_biome3 = 75

	local nobj_val_terrain = nil
	local nbuf_val_terrain = nil
	local nobj_val_river = nil
	local nbuf_val_river = nil
	local nobj_val_depth = nil
	local nbuf_val_depth = nil
	local nobj_val_profile = nil
	local nbuf_val_profile = nil
	local nobj_val_slope = nil
	local nbuf_val_slope = nil
	local nobj_val_fill = nil
	local nbuf_val_fill = nil

	local nobj_val_dirt = nil
	local nbuf_val_dirt = nil

	local nobj_filler_depth = nil
	local nbuf_filler_depth = nil

	local nobj_heatmap = nil
	local nbuf_heatmap = nil
	local nobj_heatblend = nil
	local nbuf_heatblend = nil
	local nobj_humiditymap = nil
	local nbuf_humiditymap = nil
	local nobj_humidityblend = nil
	local nbuf_humidityblend = nil

	local c_air			= minetest.get_content_id("air")
	local c_ignore			= minetest.get_content_id("ignore")

--[[
	local c_desertsand		= minetest.get_content_id("default:desert_sand")
	local c_desertsandstone		= minetest.get_content_id("default:desert_sandstone")
	local c_desertstone		= minetest.get_content_id("default:desert_stone")
	local c_sand			= minetest.get_content_id("default:sand")
	local c_sandstone		= minetest.get_content_id("default:sandstone")
	local c_silversand		= minetest.get_content_id("default:silver_sand")
	local c_silversandstone		= minetest.get_content_id("default:silver_sandstone")
	local c_stone			= minetest.get_content_id("default:stone")
	local c_brick			= minetest.get_content_id("default:stonebrick")
	local c_block			= minetest.get_content_id("default:stone_block")
	local c_desertstoneblock	= minetest.get_content_id("default:desert_stone_block")
	local c_desertstonebrick	= minetest.get_content_id("default:desert_stonebrick")
	local c_obsidian		= minetest.get_content_id("default:obsidian")
	local c_dirt			= minetest.get_content_id("default:dirt")
	local c_dirtdry			= minetest.get_content_id("default:dry_dirt")
	local c_dirtgrass		= minetest.get_content_id("default:dirt_with_grass")
	local c_dirtdrygrass		= minetest.get_content_id("default:dirt_with_dry_grass")
	local c_dirtdrydrygrass		= minetest.get_content_id("default:dry_dirt_with_dry_grass")
	local c_dirtperm		= minetest.get_content_id("default:permafrost")
	local c_top			= minetest.get_content_id("default:dirt_with_grass")
	local c_coniferous		= minetest.get_content_id("default:dirt_with_coniferous_litter")
	local c_rainforest		= minetest.get_content_id("default:dirt_with_rainforest_litter")
	local c_snow			= minetest.get_content_id("default:dirt_with_snow")
	local c_ice			= minetest.get_content_id("default:ice")
	local c_water			= minetest.get_content_id("default:water_source")
--]]

--
	local c_mossy			= minetest.get_content_id("lib_materials:stone_cobble_mossy")
	local c_gravel			= minetest.get_content_id("lib_materials:stone_gravel")
	local c_lava			= minetest.get_content_id("lib_materials:liquid_lava_source")

	local c_desertsand		= minetest.get_content_id("lib_materials:sand_desert")
	local c_desertsandstone		= minetest.get_content_id("lib_materials:stone_sandstone_desert")
	local c_desertstone		= minetest.get_content_id("lib_materials:stone_desert")
	local c_sand			= minetest.get_content_id("lib_materials:sand")
	local c_sandstone		= minetest.get_content_id("lib_materials:stone_sandstone")
	local c_silversand		= minetest.get_content_id("lib_materials:sand_silver")
	local c_silversandstone		= minetest.get_content_id("lib_materials:stone_sandstone_silver")
	local c_stone			= minetest.get_content_id("lib_materials:stone")
	local c_brick			= minetest.get_content_id("lib_materials:stone_brick")
	local c_block			= minetest.get_content_id("lib_materials:stone_block")
	local c_desertstoneblock	= minetest.get_content_id("lib_materials:stone_desert_brick")
	local c_desertstonebrick	= minetest.get_content_id("lib_materials:stone_desert_block")
	local c_obsidian		= minetest.get_content_id("lib_materials:stone_obsidian")
	local c_dirt			= minetest.get_content_id("lib_materials:dirt")
	local c_dirtdry			= minetest.get_content_id("lib_materials:dirt_dry")
	local c_dirtgrass		= minetest.get_content_id("lib_materials:dirt_with_grass")
	local c_dirtdrygrass		= minetest.get_content_id("lib_materials:dirt_with_grass_dry")
	local c_dirtdrydrygrass		= minetest.get_content_id("lib_materials:dirt_dry_with_grass_dry")
	local c_dirtperm		= minetest.get_content_id("lib_materials:dirt_permafrost")
	local c_top			= minetest.get_content_id("lib_materials:dirt_with_grass_green")
	local c_coniferous		= minetest.get_content_id("lib_materials:dirt_with_litter_coniferous")
	local c_rainforest		= minetest.get_content_id("lib_materials:dirt_with_litter_rainforest")
	local c_snow			= minetest.get_content_id("lib_materials:dirt_with_snow")
	local c_ice			= minetest.get_content_id("lib_materials:ice")
	local c_water			= minetest.get_content_id("lib_materials:liquid_water_source")
	local c_river			= minetest.get_content_id("lib_materials:liquid_water_river_source")
--


--#	Valleys Noises
	local np_val_terrain = {
		flags = "defaults",
		lacunarity = 2,
		offset = -10,
		scale = 50,
		spread = {x = 1024, y = 1024, z = 1024},
		seed = 5202,
		octaves = 6,
		persist = 0.4,
	}
	local np_val_river = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0,
		scale = 1,
		spread = {x = 256, y = 256, z = 256},
		seed = -6050,
		octaves = 5,
		persist = 0.6,
	}
	local np_val_depth = {
		flags = "defaults",
		lacunarity = 2,
		offset = 5,
		scale = 4,
		spread = {x = 512, y = 512, z = 512},
		seed = -1914,
		octaves = 1,
		persist = 1,
	}
	local np_val_profile = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0.6,
		scale = 0.5,
		spread = {x = 512, y = 512, z = 512},
		seed = 777,
		octaves = 1,
		persist = 1,
	}
	local np_val_slope = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0.5,
		scale = 0.5,
		spread = {x = 128, y = 128, z = 128},
		seed = 746,
		octaves = 1,
		persist = 1,
	}
	local np_val_fill = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0,
		scale = 1,
		spread = {x = 256, y = 512, z = 256},
		seed = 1993,
		octaves = 6,
		persist = 0.8,
	}
	local np_val_dirt = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0,
		scale = 1.2,
		spread = {x = 256, y = 256, z = 256},
		seed = 1605,
		octaves = 3,
		persist = 0.5,
	}

	np_vval_filler_depth = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0,
		scale = 1.2,
		spread = {x = 150, y = 150, z = 150},
		seed = 261,
		octaves = 3,
		persistence = 0.7,
	}

	local np_heat = {
		flags = "defaults",
		lacunarity = 2,
		offset = 50,
		scale = 50,
		spread = {x = (1000), y = (1000), z = (1000)},
		seed = 5349,
		octaves = 3,
		persist = 0.5,
	}
	local np_heat_blend = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0,
		scale = 1.5,
		spread = {x = 8, y = 8, z = 8},
		seed = 13,
		octaves = 2,
		persist = 1,
	}
	local np_humid = {
		flags = "defaults",
		lacunarity = 2,
		offset = 50,
		scale = 50,
		spread = {x = (1000), y = (1000), z = (1000)},
		seed = 842,
		octaves = 3,
		persist = 0.5,
	}
	local np_humid_blend = {
		flags = "defaults",
		lacunarity = 2,
		offset = 0,
		scale = 1.5,
		spread = {x = 8, y = 8, z = 8},
		seed = 90003,
		octaves = 2,
		persist = 1,
	}

--##	
--##	Create a table of biome ids, so I can use the biomemap.
--##	

	lib_mg_valleys_3d.biome_info = {}

	for name, desc in pairs(minetest.registered_biomes) do

		if desc then

			lib_mg_valleys_3d.biome_info[desc.name] = {}

			lib_mg_valleys_3d.biome_info[desc.name].b_name = desc.name
			lib_mg_valleys_3d.biome_info[desc.name].b_cid = minetest.get_biome_id(name)

			lib_mg_valleys_3d.biome_info[desc.name].b_top = c_dirtgrass
			lib_mg_valleys_3d.biome_info[desc.name].b_top_depth = 1
			lib_mg_valleys_3d.biome_info[desc.name].b_filler = c_dirt
			lib_mg_valleys_3d.biome_info[desc.name].b_filler_depth = 4
			lib_mg_valleys_3d.biome_info[desc.name].b_stone = c_stone
			lib_mg_valleys_3d.biome_info[desc.name].b_water_top = c_water
			lib_mg_valleys_3d.biome_info[desc.name].b_water_top_depth = 1
			lib_mg_valleys_3d.biome_info[desc.name].b_water = c_water
			lib_mg_valleys_3d.biome_info[desc.name].b_river = c_river
			----lib_mg_valleys_3d.biome_info[desc.name].b_riverbed = c_gravel
			----lib_mg_valleys_3d.biome_info[desc.name].b_riverbed_depth = 2
			----lib_mg_valleys_3d.biome_info[desc.name].b_cave_liquid = c_lava
			----lib_mg_valleys_3d.biome_info[desc.name].b_dungeon = c_mossy
			----lib_mg_valleys_3d.biome_info[desc.name].b_dungeon_alt = c_brick
			----lib_mg_valleys_3d.biome_info[desc.name].b_dungeon_stair = c_block
			----lib_mg_valleys_3d.biome_info[desc.name].b_node_dust = c_air
			lib_mg_valleys_3d.biome_info[desc.name].vertical_blend = 0
			lib_mg_valleys_3d.biome_info[desc.name].min_pos = {x=-31000, y=-31000, z=-31000}
			lib_mg_valleys_3d.biome_info[desc.name].max_pos = {x=31000, y=31000, z=31000}
			lib_mg_valleys_3d.biome_info[desc.name].b_miny = -31000
			lib_mg_valleys_3d.biome_info[desc.name].b_maxy = 31000
			lib_mg_valleys_3d.biome_info[desc.name].b_heat = 50
			lib_mg_valleys_3d.biome_info[desc.name].b_humid = 50
		

			if desc.node_top and desc.node_top ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_top = minetest.get_content_id(desc.node_top) or c_dirtgrass
			end

			if desc.depth_top then
				lib_mg_valleys_3d.biome_info[desc.name].b_top_depth = desc.depth_top or 1
			end

			if desc.node_filler and desc.node_filler ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_filler = minetest.get_content_id(desc.node_filler) or c_dirt
			end

			if desc.depth_filler then
				lib_mg_valleys_3d.biome_info[desc.name].b_filler_depth = desc.depth_filler or 4
			end

			if desc.node_stone and desc.node_stone ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_stone = minetest.get_content_id(desc.node_stone) or c_stone
			end

			if desc.node_water_top and desc.node_water_top ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_water_top = minetest.get_content_id(desc.node_water_top) or c_water
			end

			if desc.depth_water_top then
				lib_mg_valleys_3d.biome_info[desc.name].b_water_top_depth = desc.depth_water_top or 1
			end

			if desc.node_water and desc.node_water ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_water = minetest.get_content_id(desc.node_water) or c_water
			end
			if desc.node_river_water and desc.node_river_water ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_river = minetest.get_content_id(desc.node_river_water) or c_river
			end

--[[
			if desc.node_riverbed and desc.node_riverbed ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_riverbed = minetest.get_content_id(desc.node_riverbed)
			end

			if desc.depth_riverbed then
				lib_mg_valleys_3d.biome_info[desc.name].b_riverbed_depth = desc.depth_riverbed or 2
			end

			if desc.node_cave_liquid and desc.node_cave_liquid ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_cave_liquid = minetest.get_content_id(desc.node_cave_liquid)
			end

			if desc.node_dungeon and desc.node_dungeon ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_dungeon = minetest.get_content_id(desc.node_dungeon)
			end

			if desc.node_dungeon_alt and desc.node_dungeon_alt ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_dungeon_alt = minetest.get_content_id(desc.node_dungeon_alt)
			end

			if desc.node_dungeon_stair and desc.node_dungeon_stair ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_dungeon_stair = minetest.get_content_id(desc.node_dungeon_stair)
			end

			if desc.node_dust and desc.node_dust ~= "" then
				lib_mg_valleys_3d.biome_info[desc.name].b_node_dust = minetest.get_content_id(desc.node_dust)
			end
--]]
			if desc.vertical_blend then
				lib_mg_valleys_3d.biome_info[desc.name].vertical_blend = desc.vertical_blend or 0
			end

			if desc.y_min then
				lib_mg_valleys_3d.biome_info[desc.name].b_miny = desc.y_min or -31000
			end

			if desc.y_max then
				lib_mg_valleys_3d.biome_info[desc.name].b_maxy = desc.y_max or 31000
			end

			lib_mg_valleys_3d.biome_info[desc.name].min_pos = desc.min_pos or {x=-31000, y=-31000, z=-31000}
			if desc.y_min then
				lib_mg_valleys_3d.biome_info[desc.name].min_pos.y = math.max(lib_mg_valleys_3d.biome_info[desc.name].min_pos.y, desc.y_min)
			end

			lib_mg_valleys_3d.biome_info[desc.name].max_pos = desc.max_pos or {x=31000, y=31000, z=31000}
			if desc.y_max then
				lib_mg_valleys_3d.biome_info[desc.name].max_pos.y = math.min(lib_mg_valleys_3d.biome_info[desc.name].max_pos.y, desc.y_max)
			end

			if desc.heat_point then
				lib_mg_valleys_3d.biome_info[desc.name].b_heat = desc.heat_point or 50
			end

			if desc.humidity_point then
				lib_mg_valleys_3d.biome_info[desc.name].b_humid = desc.humidity_point or 50
			end


		end
	end

	local function get_heat_scalar(z)

		if lib_mg_valleys_3d.use_heat_scalar == true then
			local t_z = abs(z)
			local t_heat = 0
			local t_heat_scale = 0.0071875 
			local t_heat_factor = 0
	
			--local t_heat_mid = ((lib_mg_valleys_3d.mg_map_size * lib_mg_valleys_3d.mg_world_scale) * 0.25)
			local t_heat_mid = 15000
			local t_diff = abs(t_heat_mid - t_z)
	
			if t_z >= t_heat_mid then
				t_heat_factor = t_heat_scale * -1
			elseif t_z <= t_heat_mid then
				t_heat_factor = t_heat_scale
			end
	
			local t_map_scale = t_heat_factor
			return t_diff * t_map_scale
		else
			return 0
		end
	end
--[[
	local function max_noise_val(noiseprm)
		local height = 0					--	30		18
		local scale = noiseprm.scale				--	18		10.8
		for i=1,noiseprm.octaves do				--	10.8		6.48
			height=height + scale				--	6.48		3.88
			scale = scale * noiseprm.persist		--	3.88		2.328
		end							--	-----		------
		return height+noiseprm.offset				--			41.496 + (-4)
	end								--			37.496
	
	local function min_noise_val(noiseprm)
		local height = 0
		local scale = noiseprm.scale
		for i=1,noiseprm.octaves do
			height=height - scale
			scale = scale * noiseprm.persist
		end	
		return height+noiseprm.offset
	end
	local heat_min = min_noise_val(np_heat)
	local heat_max = max_noise_val(np_heat)
	local heat_min_blend = min_noise_val(np_heat_blend)
	local heat_max_blend = max_noise_val(np_heat_blend)
	local humid_min = min_noise_val(np_humid)
	local humid_max = max_noise_val(np_humid)
	local humid_min_blend = min_noise_val(np_humid_blend)
	local humid_max_blend = max_noise_val(np_humid_blend)

	local biome_heat = {}
	local biome_humid = {}
	for h = heat_min, heat_max do
		biome_heat[h] = {}
		if h < m_top1 then
			biome_heat[h] = "cold"
		elseif h >= m_top1 and h < m_top2 then
			biome_heat[h] = "cool"
		elseif h >= m_top2 and h < m_top3 then
			biome_heat[h] = "temperate"
		elseif h >= m_top3 and h < m_top4 then
			biome_heat[h] = "warm"
		elseif h >= m_top4 then
			biome_heat[h] = "hot"
		else

		end
	end
	for h = humid_min, humid_max do
		biome_humid[h] = {}
		if h < m_top1 then
			biome_humid[h] = "_arid"
		elseif h >= m_top1 and h < m_top2 then
			biome_humid[h] = "_semiarid"
		elseif h >= m_top2 and h < m_top3 then
			biome_humid[h] = "_temperate"
		elseif h >= m_top3 and h < m_top4 then
			biome_humid[h] = "_semihumid"
		elseif h >= m_top4 then
			biome_humid[h] = "_humid"
		else

		end
	end
--]]
	local function rangelim(v, min, max)
		if v < min then return min end
		if v > max then return max end
		return v
	end

	local function get_biome_name(heat,humid,y)

		local t_heat, t_humid, t_altitude, t_name

		if heat < m_top1 then
			t_heat = "cold"
		elseif heat >= m_top1 and heat < m_top2 then
			t_heat = "cool"
		elseif heat >= m_top2 and heat < m_top3 then
			t_heat = "temperate"
		elseif heat >= m_top3 and heat < m_top4 then
			t_heat = "warm"
		elseif heat >= m_top4 then
			t_heat = "hot"
		else

		end

		if humid < m_top1 then
			t_humid = "_arid"
		elseif humid >= m_top1 and humid < m_top2 then
			t_humid = "_semiarid"
		elseif humid >= m_top2 and humid < m_top3 then
			t_humid = "_temperate"
		elseif humid >= m_top3 and humid < m_top4 then
			t_humid = "_semihumid"
		elseif humid >= m_top4 then
			t_humid = "_humid"
		else

		end

		if y < min_beach then
			t_altitude = "_ocean"
		elseif y >= min_beach and y < max_beach then
			t_altitude = "_beach"
		elseif y >= max_beach and y < max_highland then
			t_altitude = ""
		elseif y >= max_highland and y < max_mountain then
			t_altitude = "_mountain"
		elseif y >= max_mountain then
			t_altitude = "_strato"
		else
			t_altitude = ""
		end

		if t_heat and t_heat ~= "" and t_humid and t_humid ~= "" then
			t_name = t_heat .. t_humid .. t_altitude
		else
			if (t_heat == "hot") and (t_humid == "_humid") and (heat > 90) and (humid > 90) and (t_altitude == "_beach") then
				t_name = "hot_humid_swamp"
			elseif (t_heat == "hot") and (t_humid == "_semihumid") and (heat > 90) and (humid > 80) and (t_altitude == "_beach") then
				t_name = "hot_semihumid_swamp"
			elseif (t_heat == "warm") and (t_humid == "_humid") and (heat > 80) and (humid > 90) and (t_altitude == "_beach") then
				t_name = "warm_humid_swamp"
			elseif (t_heat == "temperate") and (t_humid == "_humid") and (heat > 57) and (humid > 90) and (t_altitude == "_beach") then
				t_name = "temperate_humid_swamp"
			else
				t_name = "temperate_temperate"
			end
		end

		if y >= -31000 and y < -20000 then
			t_name = "generic_mantle"
		elseif y >= -20000 and y < -15000 then
			t_name = "stone_basalt_01_layer"
		elseif y >= -15000 and y < -10000 then
			t_name = "stone_brown_layer"
		elseif y >= -10000 and y < -6000 then
			t_name = "stone_sand_layer"
		elseif y >= -6000 and y < -5000 then
			t_name = "desert_stone_layer"
		elseif y >= -5000 and y < -4000 then
			t_name = "desert_sandstone_layer"
		elseif y >= -4000 and y < -3000 then
			t_name = "generic_stone_limestone_01_layer"
		elseif y >= -3000 and y < -2000 then
			t_name = "generic_granite_layer"
		elseif y >= -2000 and y < min_ocean then
			t_name = "generic_stone_layer"
		else
			
		end

		return t_name

	end

	local function get_valleys_height(z,x,dim)

		if (dim ~= "2d") or (dim ~= "3d") then
			dim = "2d"
		end

		-- Mapgen parameters
		local river_size_factor = lib_mg_valleys_3d.mgvalleys_river_size / 100
		local water_level       = lib_mg_valleys_3d.water_level

		-- Check if in a river channel
		local v_rivers = minetest.get_perlin(np_val_river):get_2d({x=x,y=z})
			--if abs(v_rivers) <= river_size_factor then
			--	-- TODO: Add riverbed calculation
			--	return nil
			--end
	
		local valley    = minetest.get_perlin(np_val_depth):get_2d({x=x,y=z})
		local valley_d  = valley * valley
		local base      = valley_d + minetest.get_perlin(np_val_terrain):get_2d({x=x,y=z})
		local river     = abs(v_rivers) - river_size_factor
		local tv        = max(river / minetest.get_perlin(np_val_profile):get_2d({x=x,y=z}), 0)
		local valley_h  = valley_d * (1 - math.exp(-tv * tv))
		local surface_y = base + valley_h
		local slope     = valley_h * minetest.get_perlin(np_val_slope):get_2d({x=x,y=z})

--# 2D Generation
		if dim == "2d" then

			local n_fill = minetest.get_perlin(np_val_fill):get_3d({x=x,y=surface_y,z=z})

			local surface_delta = n_fill - surface_y;
			local density = slope * n_fill - surface_delta;
	
			return density
		end
--
	
--# 3D Noise
		if dim == "3d" then
			-- TODO: Find proper limits for this check
			for y = 128, -128, -1 do
				-- TODO: May be better if this 3D noise map is fetched for the hole Y column at once
				local surface_delta = y - surface_y;
				local n_fill = minetest.get_perlin(np_val_fill):get_3d({x=x,y=y,z=z})
					--local density = slope * nobj_val_fill:get_3d({x=x, y=y, z=z}) - surface_delta;
					--local density = slope * nobj_val_fill:get_2d({x=x,y=z}) - surface_delta;
				local density = slope * n_fill - surface_delta;
		
				if density > 0 then -- If solid
					return y + 1;
				end
			end
		end
--

		return nil;
	end

	local mapgen_times = {
		liquid_lighting = {},
		loop2d = {},
		loop3d = {},
		mainloop = {},
		make_chunk = {},
		noisemaps = {},
		preparation = {},
		setdata = {},
		writing = {},
	}

	local data = {}


	minetest.register_on_generated(function(minp, maxp, seed)
		
		-- Start time of mapchunk generation.
		local t0 = os.clock()
		
		local sidelen = maxp.x - minp.x + 1
		local permapdims2d = {x = sidelen, y = sidelen, z = 0}
		local permapdims3d = {x = sidelen, y = sidelen, z = sidelen}

		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		data = vm:get_data()
		local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local csize = vector.add(vector.subtract(maxp, minp), 1)
	
		nobj_val_terrain = nobj_val_terrain or minetest.get_perlin_map(np_val_terrain, permapdims2d)
		nbuf_val_terrain = nobj_val_terrain:get_2d_map({x=minp.x,y=minp.z})
		nobj_val_river = nobj_val_river or minetest.get_perlin_map(np_val_river, permapdims2d)
		nbuf_val_river = nobj_val_river:get_2d_map({x=minp.x,y=minp.z})
		nobj_val_depth = nobj_val_depth or minetest.get_perlin_map(np_val_depth, permapdims2d)
		nbuf_val_depth = nobj_val_depth:get_2d_map({x=minp.x,y=minp.z})
		nobj_val_profile = nobj_val_profile or minetest.get_perlin_map(np_val_profile, permapdims2d)
		nbuf_val_profile = nobj_val_profile:get_2d_map({x=minp.x,y=minp.z})
		nobj_val_slope = nobj_val_slope or minetest.get_perlin_map(np_val_slope, permapdims2d)
		nbuf_val_slope = nobj_val_slope:get_2d_map({x=minp.x,y=minp.z})
		--nobj_val_fill = nobj_val_fill or minetest.get_perlin_map(np_val_fill, permapdims2d)
		--nbuf_val_fill = nobj_val_fill:get_2d_map({x=minp.x,y=minp.z})
		--nobj_val_fill = nobj_val_fill or minetest.get_perlin_map(np_val_fill, permapdims3d)
		--nbuf_val_fill = nobj_val_fill:get_3d_map({x=minp.x,y=minp.y,z=minp.z})
	
		nobj_val_dirt = nobj_val_dirt or minetest.get_perlin_map(np_val_dirt, permapdims2d)
		nbuf_val_dirt = nobj_val_dirt:get_2d_map({x=minp.x,y=minp.z})
		nobj_filler_depth = nobj_filler_depth or minetest.get_perlin_map(np_vval_filler_depth, permapdims2d)
		nbuf_filler_depth = nobj_filler_depth:get_2d_map({x=minp.x,y=minp.z})

		nobj_heatmap = nobj_heatmap or minetest.get_perlin_map(np_heat, permapdims3d)
		nbuf_heatmap = nobj_heatmap:get_2d_map({x=minp.x,y=minp.z})
		nobj_heatblend = nobj_heatblend or minetest.get_perlin_map(np_heat_blend, permapdims3d)
		nbuf_heatblend = nobj_heatblend:get_2d_map({x=minp.x,y=minp.z})
		nobj_humiditymap = nobj_humiditymap or minetest.get_perlin_map(np_humid, permapdims3d)
		nbuf_humiditymap = nobj_humiditymap:get_2d_map({x=minp.x,y=minp.z})
		nobj_humidityblend = nobj_humidityblend or minetest.get_perlin_map(np_humid_blend, permapdims3d)
		nbuf_humidityblend = nobj_humidityblend:get_2d_map({x=minp.x,y=minp.z})
	
		-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
		local t1 = os.clock()
	
		local write = false

		-- Mapgen parameters
		local river_size_factor = lib_mg_valleys_3d.mgvalleys_river_size / 100
		local water_level       = lib_mg_valleys_3d.water_level
		local mg_dim = lib_mg_valleys_3d.mg_dim	

--
	--2D HEIGHTMAP GENERATION
		local index2d = 0
	
		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do
	
				index2d = (z - minp.z) * csize.x + (x - minp.x) + 1

	--## VALLEYS CALCULATION

				-- Check if in a river channel
				local v_rivers = minetest.get_perlin(np_val_river):get_2d({x=x,y=z})
				local abs_rivers = abs(v_rivers)
	
	--## HEIGHTMAP CALCULATION
				local valley    = nbuf_val_depth[z-minp.z+1][x-minp.x+1]
				local valley_d  = valley * valley
				local base      = valley_d + nbuf_val_terrain[z-minp.z+1][x-minp.x+1]
				local river     = abs_rivers - river_size_factor
				local tv        = max(river / nbuf_val_profile[z-minp.z+1][x-minp.x+1])
				local valley_h  = valley_d * (1 - math.exp(-tv * tv))
				local surface_y = base + valley_h
				local slope     = valley_h * nbuf_val_slope[z-minp.z+1][x-minp.x+1]

				lib_mg_valleys_3d.surfacemap[index2d] = surface_y
				lib_mg_valleys_3d.slopemap[index2d] = slope

			--# 2D Generation
				local n_fill = minetest.get_perlin(np_val_fill):get_3d({x=x,y=surface_y,z=z})
				--local n_fill = nbuf_val_fill[z-minp.z+1][y-minp.y+1][x-minp.x+1]

				local surface_delta = n_fill - surface_y;
				local density = slope * n_fill - surface_delta;

				local t_y = density
				--local t_y = get_valleys_height(z,x,"2d")

				--lib_mg_valleys_3d.heightmap[index2d] = -31000
				--lib_mg_valleys_3d.heightmap[index2d] = density
				lib_mg_valleys_3d.heightmap[index2d] = t_y

	--## BIOME GENERATION
				local nheat = (nbuf_heatmap[z-minp.z+1][x-minp.x+1] + nbuf_heatblend[z-minp.z+1][x-minp.x+1]) + get_heat_scalar(z)
				local nhumid = nbuf_humiditymap[z-minp.z+1][x-minp.x+1] + nbuf_humidityblend[z-minp.z+1][x-minp.x+1]

				lib_mg_valleys_3d.biomemap[index2d] = get_biome_name(nheat,nhumid,t_y)

	--## RIVERS CALCULATION
				local river_course = false
				if abs_rivers <= river_size_factor then
					-- TODO: Add riverbed calculation
					river_course = true
				end
				lib_mg_valleys_3d.rivermap[index2d] = river_course

	--## FILLER CALCULATION

				--lib_mg_valleys_3d.fillermap[index2d] = nbuf_filler_depth[z-minp.z+1][x-minp.x+1]
				lib_mg_valleys_3d.fillermap[index2d] = nbuf_filler_depth[z-minp.z+1][x-minp.x+1] + nbuf_val_dirt[z-minp.z+1][x-minp.x+1]

			end
		end
--
		local t2 = os.clock()

--
	--2D HEIGHTMAP FROM 3D NOISE GENERATION
		local index2d = 0
		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do

					index2d = (z - minp.z) * csize.x + (x - minp.x) + 1

		--## HEIGHTMAP CALCULATION
					local surface_y = lib_mg_valleys_3d.surfacemap[index2d]
					local slope     = lib_mg_valleys_3d.slopemap[index2d]

					local surface_delta = y - surface_y;
					local n_fill = minetest.get_perlin(np_val_fill):get_3d({x=x,y=y,z=z})
					--local n_fill = nbuf_val_fill[z-minp.z+1][y-minp.y+1][x-minp.x+1]
					local density = slope * n_fill - surface_delta;

					if density > 0 then -- If solid
						lib_mg_valleys_3d.heightmap[index2d] = y + 1;
					end

				end
			end
		end
--
		local t3 = os.clock()

		--local t4 = os.clock()
	

	--2D HEIGHTMAP RENDER
		local index2d = 0
		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
				 
					index2d = (z - minp.z) * csize.x + (x - minp.x) + 1   
					local ivm = a:index(x, y, z)

					local write_3d = false

					local theight = lib_mg_valleys_3d.heightmap[index2d]
					local t_rivermap = lib_mg_valleys_3d.rivermap[index2d]

	--## SET BIOME
					local t_biome_name = lib_mg_valleys_3d.biomemap[index2d]

	--## FILLER CALCULATION
					local fill_depth = 4
					local top_depth = 1
					local tfilldepth = lib_mg_valleys_3d.fillermap[index2d]

	--## TERRAIN 3D GENERATION
					local surface_y = lib_mg_valleys_3d.surfacemap[index2d]
					local slope     = lib_mg_valleys_3d.slopemap[index2d]

					local surface_delta = y - surface_y;
					local n_fill = minetest.get_perlin(np_val_fill):get_3d({x=x,y=y,z=z})
					local density = slope * n_fill - surface_delta;

					if density > 0 then -- If solid
						write_3d = true
					elseif y <= lib_mg_valleys_3d.water_level then
						if theight <= lib_mg_valleys_3d.water_level then
							write_3d = true
						end
					end
	
	--## BIOME GENERATION

					local t_air = c_air
					local t_ignore = c_ignore
					local t_top = c_top
					local t_filler = c_dirt
					local t_stone = c_stone
					local t_water = c_water
					local t_river = c_river

					t_stone = lib_mg_valleys_3d.biome_info[t_biome_name].b_stone
					t_filler = lib_mg_valleys_3d.biome_info[t_biome_name].b_filler
					fill_depth = tfilldepth
					t_top = lib_mg_valleys_3d.biome_info[t_biome_name].b_top
					top_depth = 1
					t_water = lib_mg_valleys_3d.biome_info[t_biome_name].b_water
					t_river = lib_mg_valleys_3d.biome_info[t_biome_name].b_river

	--## NODE PLACEMENT FROM HEIGHTMAP

					local t_node = t_ignore

				--2D Terrain
					if write_3d == true then
						if y < (theight - (fill_depth + top_depth)) then
							t_node = t_stone
						elseif y >= (theight - (fill_depth + top_depth)) and y < (theight - top_depth) then
							if t_rivermap == true then
								t_filler = c_gravel
							end
							t_node = t_filler
						elseif y >= (theight - top_depth) and y <= theight then
							if t_rivermap == true then
								t_top = t_river
							end
							t_node = t_top
						elseif y > theight and y <= lib_mg_valleys_3d.water_level then
						--Water Level (Sea Level)
							t_node = t_water
						end
					end

					data[ivm] = t_node
					write = true

				end
			end
		end
		
		local t4 = os.clock()
	
		if write then
			vm:set_data(data)
		end
	
		local t5 = os.clock()
		
		if write then
	
			minetest.generate_ores(vm,minp,maxp)
			minetest.generate_decorations(vm,minp,maxp)
				
			vm:set_lighting({day = 0, night = 0})
			vm:calc_lighting()
			vm:update_liquids()
		end
	
		local t6 = os.clock()
	
		if write then
			vm:write_to_map()
		end
	
		local t7 = os.clock()
	
		-- Print generation time of this mapchunk.
		local chugent = math.ceil((os.clock() - t0) * 1000)
		print ("[lib_mg_valleys_3d] Mapchunk generation time " .. chugent .. " ms")
	
		table.insert(mapgen_times.noisemaps, 0)
		table.insert(mapgen_times.preparation, t1 - t0)
		table.insert(mapgen_times.loop2d, t2 - t1)
		table.insert(mapgen_times.loop3d, t3 - t2)
		table.insert(mapgen_times.mainloop, t4 - t3)
		table.insert(mapgen_times.setdata, t5 - t4)
		table.insert(mapgen_times.liquid_lighting, t6 - t5)
		table.insert(mapgen_times.writing, t7 - t6)
		table.insert(mapgen_times.make_chunk, t7 - t0)
	
		-- Deal with memory issues. This, of course, is supposed to be automatic.
		local mem = math.floor(collectgarbage("count")/1024)
		if mem > 1000 then
			print("lib_mg_valleys_3d is manually collecting garbage as memory use has exceeded 500K.")
			collectgarbage("collect")
		end
	end)

	local function mean( t )
		local sum = 0
		local count= 0
	
		for k,v in pairs(t) do
			if type(v) == 'number' then
				sum = sum + v
				count = count + 1
			end
		end
	
		return (sum / count)
	end

	minetest.register_on_shutdown(function()

		if lib_mg_valleys_3d.mg_add_voronoi == true then
			lib_mg_valleys_3d.save_neighbors()
		end

		if #mapgen_times.make_chunk == 0 then
			return
		end
	
		local average, standard_dev
		minetest.log("lib_mg_v6 lua Mapgen Times:")
	
		average = mean(mapgen_times.liquid_lighting)
		minetest.log("  liquid_lighting: - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.loop2d)
		minetest.log(" 2D Noise loops: - - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.loop3d)
		minetest.log(" 3D Noise loops: - - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.mainloop)
		minetest.log(" Main Render loops: - - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.make_chunk)
		minetest.log("  makeChunk: - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.noisemaps)
		minetest.log("  noisemaps: - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.preparation)
		minetest.log("  preparation: - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.setdata)
		minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)
	
		average = mean(mapgen_times.writing)
		minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)
	end)





minetest.log(S("[MOD] lib_mg_v6:  Successfully loaded."))


