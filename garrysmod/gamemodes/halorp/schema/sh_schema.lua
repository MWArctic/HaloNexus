SCHEMA.name = "HALO: Nexis"
SCHEMA.author = "Artic / Evan"
SCHEMA.desc = ""

nut.util.include("sv_database.lua")
nut.util.include("sh_configs.lua")

nut.util.include("sv_hooks.lua")
nut.util.include("cl_hooks.lua")
nut.util.include("sh_hooks.lua")
nut.util.include("meta/sh_player.lua")
nut.util.include("meta/sh_entity.lua")

ALWAYS_RAISED["weapon_tablet"] = true


    if (SERVER and CLIENT) then




        local SQLITE_ALTER_TABLES = [[

            ALTER TABLE nut_characters ADD COLUMN status TEXT

        ]]



        nut.db.waitForTablesToLoad()

            :next(function() 

                print("QUERY - CLASS") 

                nut.db.query(SQLITE_ALTER_TABLES)

                :catch(function(x)  end)

            end)
 
            :catch(function() end)

            --if (nut.db.module) then

                --nut.db.query(MYSQL_ALTER_TABLES)

            --else


    end

