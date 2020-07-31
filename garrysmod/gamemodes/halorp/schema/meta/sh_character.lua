local CHAR = nut.meta.character

 nut.char.registerVar("status", {
            default = {},
            isLocal = true,
            field = "status",

            OnSet = function(character, value, Replication, receiver)
                local status = character.status
                local client = character:GetPlayer()
                status = value
                if (Replication and IsValid(client)) then
                    net.Start("CharacterStatusAlert")
                    net.WriteUInt(character:GetID(), 32)
                    net.WriteString(key)
                    net.WriteType(value)
                    net.Send(receiver or client)
                end
                character.vars.status = status
            end,
            OnGet = function(character, key, default)
                local status = character.vars.status or {}

                if (key) then
                    if (!status) then
                        return default
                    end

                    local value = status[key]

                    return value == nil and default or value
                else
                    return default or status
                end
            end
        })