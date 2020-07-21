obs           = obslua
sf 			= string.format
logging = true

function log (item)
    if logging then print (item) end
end

function show_hide_source(source,action)
    -- Turn on or off sources within a scene
    -- The variable "scene" comes from the sceneChange function
    local scene1 = obs.obs_scene_from_source(scene)
	local sceneitem = obs.obs_scene_find_source(scene1, source)
    if sceneitem ~= nil then
        if action == 1 then
            status = obs.obs_sceneitem_set_visible(sceneitem, true)
        else
            status = obs.obs_sceneitem_set_visible(sceneitem, false)
        end
	end
    --obs.obs_scene_release(scene1)
end

--  Automation for PreService Scene
--  Set  C2 camera to the cross, C1 camera to the Chancel
function preser()
    obs.timer_remove(preser)
    log ("Inside PreService routine")
    --  Move camera C2 to Cross
    --  Move camera C1 to Wide Chancel Table
    --  PHASE 1 - Move C1 to Cross
    show_hide_source("C1 to Cross", 1)
end

--  Automation for Prelude Scene
function pre()
    obs.timer_remove(pre)
    if count == 0 then
        log ("Begin Prelude routine")
        -- Turn on C2 camera, wait 10 sec
        obs.timer_add(pre,4000)
    end
    if count == 1 then
        -- Turn on Prelude Banner, wait 10 sec
        show_hide_source("Prelude Banner",1)
        obs.timer_add(pre,8000)
    end
    if count == 2 then
        -- Turn off Prelude Banner, wait 20 sec
        show_hide_source("Prelude Banner",2)
        obs.timer_add(pre,20000)
    end
    if count == 3 then
        --  Switch to C1 camera
        --  Move C2 camera to WIDE Chancel Table, wait 40 sec
        --  PHASE 1 - Move C1 to WIDE Chancel Table
        show_hide_source ("C1 to WIDE Chancel Table", 1)
        obs.timer_add(pre,40000)
    end
    if count == 4 then
        -- Switch to C2 camera for duration of the Prelude
        -- Move C1 camera to Pulpit
        -- PHASE 1 - Move C1 to Flowers
        show_hide_source ("C1 to WIDE Chancel Table", 2)
        show_hide_source("C1 to Flowers", 1)
        obs.timer_add(pre,10000)
    end
    if count == 5 then
        --  Turn on Flowers Banner
        show_hide_source("C1 to Flowers", 2)
        show_hide_source("Flowers Banner", 1)
        obs.timer_add(pre,10000)
    end
    if count == 6 then
        --  Turn OFF Flowers Banner
        show_hide_source("Flowers Banner", 2)
    end

    count = count + 1
end

--  Automation for Church At Work Scene
--  Camera C1 is the source for this scene
function caw()
    obs.timer_remove(caw)
    if count == 0 then
        -- Move C2 camera to Lectern
        --  PHASE 1 - Move C1 to Pulpit
        show_hide_source ("C1 to Pulpit", 1)
        obs.timer_add(caw,4000)
        log ("Begin Church at Work routine")
    end
    if count == 1 then
        -- Turn on appropriate banner 
        -- If "Other" then no banner
        if caw_speaker ~= "Other" then
            banner = caw_speaker .. " Banner"
            show_hide_source(banner, 1)
            --  PHASE 1 - Turn off the C1 move
            show_hide_source ("C1 to Pulpit", 2)
            obs.timer_add(caw,5000)
        end
    end
    if count == 2 then
        -- Turn off banner
        if caw_speaker ~= "Other" then
            show_hide_source(banner, 2)
        end
    end
    
    count = count + 1
end

-- Automation for Hymn 1 Scene
-- Camera C2 is the source for this scene
function h1()
    obs.timer_remove(h1)
    if count == 0 then
        -- PHASE 1 - Move C1 to Lectern
        show_hide_source ("C1 to Lectern", 1)
        log ("Begin Hymn 1 routine")
        obs.timer_add(h1,4000)
    end
    if count == 1 then
        -- Turn on Hymn 1 banner
        show_hide_source ("C1 to Lectern", 2)
        show_hide_source("Hymn-1 Banner", 1)
        obs.timer_add(h1,8000)
    end
    if count == 2 then
        -- Turn off Hymn 1 banner
        show_hide_source("Hymn-1 Banner", 2)
    end
    
    count = count + 1
end

-- Automation for Litany Scene
-- Both cameras can be active for this scene
-- Note that active view is C2-Lectern from the Hymn 1 Scene
function lit()
    obs.timer_remove(lit)
    if count == 0 then
        log ("Begin litany routine litany location is -> " .. lit_location)
        -- Change camera to C1 if Litany is at the Pulpit
        -- And move C2 to Pulpit
        -- If Litany is at the Lectern, move C1 to Lectern
        -- Need both cameras pointing to the same location in prep for Invocation
        if lit_location == "Pulpit" then
            --  PHASE 1 - Move C1 to Pulpit
            show_hide_source("C1 to Pulpit", 1)
        end
        obs.timer_add(lit,4000)
    end
    if count == 1 then
        --  PHASE 1 - Turn off C1 to Pulpit just in case
        show_hide_source("C1 to Pulpit", 2)
        -- Turn on Litany Banner
        show_hide_source("Litany Banner", 1)
        obs.timer_add(lit,5000)
    end
    if count == 2 then
        -- Turn OFF Litany Banner
        show_hide_source("Litany Banner", 2)
    end
    
    count = count + 1
end

-- Automation for Invocation Scene
-- May add the "Litany Speaker" banner here 
-- Both cameras will be pointing to the same spot since there is
-- no way of knowing which source will be active for the Invocation Scene
-- If the Invocation is at the Pulpit, change to C1 and move C2 to Lectern
-- If the Invocation is at the Lectern, change to C2 and move C1 to Pulpit
function inv()
    obs.timer_remove(inv)
    log ("Inside Invocation routine")
    if count == 0 then
        if lit_location == "Pulpit" then
            -- Set Source to camera C1
            -- Move C2 to Lectern
        else
            -- Set Source to camera C2
            -- Move C1 to Pulpit
        end
    end

    count = count + 1
end

-- Automation for Scripture Scene
-- Camera C1 is the source for this Scene
function scr()
    obs.timer_remove(scr)
    if count == 0 then
        log ("Begin Scripture routine")
        --  PHASE 1 - Make sure C1 is at Pulpit
        show_hide_source("C1 to Pulpit", 1)
        obs.timer_add(scr,4000)
    end
    if count == 1 then
        -- Turn on Scripture Banner
        show_hide_source("Scripture Banner", 1)
        obs.timer_add(scr,12000)
    end
    if count == 2 then
        -- Turn OFF Scripture Banner
        show_hide_source("Scripture Banner", 2)
        show_hide_source("C1 to Pulpit", 2)
    end
    
    count = count + 1
end

-- Automation for Hymn 2 Scene
-- Camera C2 is the source for this scene
function h2()
    obs.timer_remove(h2)
    if count == 0 then
        -- PHASE 1 - Move C1 to Lectern
        show_hide_source("C1 to Lectern", 1)
        log ("Begin Hymn 2 routine")
        obs.timer_add(h2,4000)
    end
    if count == 1 then
        -- Turn on Hymn 2 Banner
        show_hide_source("Hymn-2 Banner", 1)
        obs.timer_add(h2,8000)
    end
    if count == 2 then
        -- Turn OFF Hymn 2 Banner
        show_hide_source("Hymn-2 Banner", 2)
        show_hide_source("C1 to Lectern", 2)
    end
    
    count = count + 1
end

--  Automation for Worship Music Scene
function wmus()
    obs.timer_remove(wmus)
    log ("Inside Worship Music routine")
end

--  Automation for Sermon Scene
--  Camera C1 is the source for this scene
function ser()
    obs.timer_remove(ser)
    if count == 0 then
        -- PHASE 1 - Move C1 to Pulpit
        show_hide_source("C1 to Pulpit", 1)
        log ("Begin Sermon routine")
        obs.timer_add(ser,4000)
    end
    if count == 1 then
        -- Turn on Sermon Title Banner
        show_hide_source("Sermon Title Banner", 1)
        obs.timer_add(ser,5000)
    end
    if count == 2 then
        -- Turn OFF Sermon Title Banner
        show_hide_source("Sermon Title Banner", 2)
        show_hide_source("C1 to Pulpit", 2)
        obs.timer_add(ser,2000)
    end
    if count == 3 then
        -- Turn on Sermon Speaker Banner
        if sermon_speaker ~= "Other" then
            banner = sermon_speaker .. " Banner"
            show_hide_source(banner, 1)
            obs.timer_add(ser,5000)
        end
    end
    if count == 4 then
        -- Turn OFF Sermon Speaker Banner
        if sermon_speaker ~= "Other" then
            show_hide_source(banner, 2)
        end
    end
    
    count = count + 1
end

--  Automation for Musical Benediction Scene
--  Camera C2 is the source for this scene
function mben()
    obs.timer_remove(mben)
    if count == 0 then
        -- Move camera C1 to Floor
        --  PHASE 1 - Move C1 to Lectern
        show_hide_source("C1 to Lectern", 1)
        log ("Begin Musical Benediction routine")
        obs.timer_add(mben,4000)
    end
    if count == 1 then
        -- Turn on Musical Benedition Banner
        show_hide_source("Benediction Banner", 1)
        obs.timer_add(mben,8000)
    end
    if count == 2 then
        -- Turn OFF Musical Benediction Banner
        show_hide_source("Benediction Banner", 2)
        show_hide_source("C1 to Lectern", 2)
    end
    
    count = count + 1
end

--  Automation for Pastoral Benediction Scene
--  C1 is active Camera
function pben()
    obs.timer_remove(pben)
    -- Move C2 to flowers
    -- PHASE 1 Move C1 to Floor Middle
    show_hide_source("C1 to Floor Middle", 1)
    log ("Begin Pastoral Benediction routine")
end

--  Automation for Postlude Scene
--  Camera C2 is the initial active camera source
function pos()
    obs.timer_remove(pos)
    if count == 0 then
        -- Move C1 to Cross
        --  PHASE 1 - Move C1 to flowers
        show_hide_source("C1 to Flowers", 1)
        log ("Begin Postlude routine")
        obs.timer_add(pos,6000)
    end
    if count == 1 then
        -- Turn on Postlude Banner
        show_hide_source("Postlude Banner", 1)
        obs.timer_add(pos,8000)
    end
    if count == 2 then
        -- Turn OFF Postlude Banner
        show_hide_source("Postlude Banner", 2)
        show_hide_source("C1 to Flowers", 2)
        obs.timer_add(pos,30000)
    end
    if count == 3 then
        --  Switch to camera C1
        --  PHASE 1 - Move C1 to Cross
        show_hide_source("C1 to Cross", 1)
        obs.timer_add(pos,4000)
    end
    if count == 4 then
        -- PHASE 1 - Turn off C1 to Cross Move
        show_hide_source("C1 to Cross", 2)
    end

    count = count + 1
end

--  this function is called when the scene is changed
function sceneChange(event)
    if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then
        -- Get the scene name of the current scene     
        scene = obs.obs_frontend_get_current_scene()
        cur_scene = obs.obs_source_get_name(scene)
        log ("in sceneChange scene is --> " .. cur_scene)

        --  Reset the scene automation counter
        count = 0

        -- Find which scene is active from our list
        sc_index = 0
        for i = 1, table.getn(scenes) do 
            if scenes[i] == cur_scene then
                sc_index = i 
            end
        end

        --  Call the correct callback function based on the scene
        if sc_index > 0 then
            cb_routine = callback_routines[sc_index]
            obs.timer_add(cb_routine, 500)
        end
        obs.obs_source_release(scene)
    end
end

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
    local props = obs.obs_properties_create()
    
    --  This property defines who will deliver the Church At Work segment
    local cawsp =
        obs.obs_properties_add_list(
            props,'caw-speaker','Church At Work Speaker',
            obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

    --  This property defines who will deliver the Litany
    local litsp =
        obs.obs_properties_add_list(
            props,'lit-speaker','Litany Speaker',
            obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

    --  This property defines where the Litany will be located
    local litloc =
        obs.obs_properties_add_list(
            props,
            'litany-loc',
            'Location of Litany',
            obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(litloc,  "Lectern", "Lectern")
    obs.obs_property_list_add_string(litloc,  "Pulpit", "Pulpit")

    --  This property defines what the Worship Music will be
    local wormus =
        obs.obs_properties_add_list(
            props, 'wor-music', 'Worship Music Type',
            obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(wormus,  "Soloist", "Soloist")
    obs.obs_property_list_add_string(wormus,  "Pre-Recorded Media", "Pre-Recorded Media")
    obs.obs_property_list_add_string(wormus,  "Choir", "Choir")

    --  If there is a soloist, this property defines the soloist location
    local sololoc =
       obs.obs_properties_add_list(
           props, 'solo-location', 'Soloist Location',
           obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(sololoc,  "Lectern", "Lectern")
    obs.obs_property_list_add_string(sololoc,  "Pulpit", "Pulpit")

     --  This property defines who will deliver the Sermon
    local sersp =
        obs.obs_properties_add_list(
            props,'ser-speaker','Sermon Speaker',
            obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)   

    -- Populate the litany, church-at-work and sermon speaker properties
    for i = 1,6 do
        obs.obs_property_list_add_string(litsp,  speakers[i], speakers[i])
        obs.obs_property_list_add_string(cawsp,  speakers[i], speakers[i])
        obs.obs_property_list_add_string(sersp,  speakers[i], speakers[i])
    end
 
	return props
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
	caw_speaker = obs.obs_data_get_string(settings, "caw-speaker")
	lit_speaker = obs.obs_data_get_string(settings, "lit-speaker")
    lit_location = obs.obs_data_get_string(settings, "litany-loc")
    worship_music = obs.obs_data_get_string(settings, "wor-music")
    solo_location = obs.obs_data_get_string(settings, "solo-location")
    sermon_speaker = obs.obs_data_get_string(settings, "ser-speaker")
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "caw-speaker", "Freeman")
    obs.obs_data_set_default_string(settings, "lit-speaker", "Harner")
    obs.obs_data_set_default_string(settings, "litany-loc", "Pulpit")
    obs.obs_data_set_default_string(settings, "ser-speaker", "Freeman")
    obs.obs_data_set_default_string(settings, "wor-music", "Soloist")
    obs.obs_data_set_default_string(settings, "solo-location", "Lectern")
end

--  script_load is called when the script is loaded
--  Set it up to call "sceneChange" on a scene event
function script_load(settings)
	obs.obs_frontend_add_event_callback(sceneChange)
end

function script_description()
    return 'Automate camera movement and banners within worship scenes\n' ..
           'by Pat Lewallen  2020'
end

scenes    = {"PreService", "Prelude", "Church At Work", "Hymn 1", "Litany", "Invocation", "Scripture",
                "Hymn 2", "Worship Music", "Sermon", "Musical Benediction", "Pastoral Benediction",
                    "Postlude"}
callback_routines = {preser, pre, caw, h1, lit, inv, scr, h2, wmus, ser, mben, pben, pos}

speakers = {"Freeman", "Sparks", "Harner", "Gessner", "Guest Speaker", "Other"}