if SERVER then
  
  -- Random
  
  util.AddNetworkString("bigdogmat_whitelist_open")

  -- Setup default whitelist
  
  local whitelist = {
    lookup     = {},
    count      = 0,
    kickreason = "You're not whitelisted!",
  }
  
  -- Save whitelist in JSON format.
  
  local function WhitelistSave()
    file.Write("bigdogmat_whitelist/whitelist.txt", util.TableToJSON(whitelist))
  end
  hook.Add("ShutDown", "bigdogmat_whitelist_save", WhitelistSave)
  
  -- Create dir and save default whitelist or
  -- load existing whitelist.
  
  if not file.Exists("bigdogmat_whitelist", "DATA") then
    file.CreateDir("bigdogmat_whitelist")
    WhitelistSave()
  elseif file.Exists("bigdogmat_whitelist/whitelist.txt", "DATA") then
    local json = file.Read("bigdogmat_whitelist/whitelist.txt", "DATA")
    if json then
      whitelist = util.JSONToTable(json) or whitelist
    end
      
    print("Whitelist loaded!")
    print(whitelist.count .. " player(s) whitelisted!")
  end
  
  -- Helper functions
  
  local function WhitelistUpdate(mode, id)
    if id == "" then return end
    if (mode == -1 and not whitelist.lookup[id]) or (mode == 1 and whitelist.lookup[id]) then return end
    
    whitelist.lookup[id] = (mode == 1 and true or nil)
    whitelist.count = whitelist.count + mode
  end
  
  local function WhitelistMenuOpen(ply)
    net.Start("bigdogmat_whitelist_open")
      net.WriteUInt(whitelist.count, 11)
      for k, _ in pairs(whitelist.lookup) do
        net.WriteString(k)
      end
      net.WriteString(whitelist.kickreason)
    net.Send(ply)
  end
  
  -- Actually commands
  
  concommand.Add("whitelist_save", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    WhitelistSave()
  end)
  
  concommand.Add("whitelist_kickreason", function(ply, command, args, arg)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    if not arg or arg == "" then return end
    
    whitelist.kickreason = arg
  end)
  
  concommand.Add("whitelist_add", function(ply, command, args, arg)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    if not arg or arg == "" then return end
    
    WhitelistUpdate(1, arg)
  end)

  concommand.Add("whitelist_remove", function(ply, command, args, arg)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    if not arg or arg == "" then return end
    
    WhitelistUpdate(-1, arg)
  end)
  
  concommand.Add("whitelist", function(ply)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return end
    
    WhitelistMenuOpen(ply)
  end)
  
  hook.Add("PlayerSay", "bigdogmat_whitelist_command", function(ply, text)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return end
    
    if string.lower(text) == "!whitelist" then
      WhitelistMenuOpen(ply)
      return ""
    end
  end)
  
  -- Finally the actual whitelist hook
  
  hook.Add("CheckPassword", "bigdogmat_whitelist_kick", function(steamID)
    if not (whitelist.lookup[util.SteamIDFrom64(steamID)] or game.SinglePlayer()) and whitelist.count > 0 then
      return false, whitelist.kickreason
    end
  end)
  
else
  
  local whitelist = {
    lookup = {},
    count  = 0,
  }
  
  local function AddID(id, panel, first)
    if id == "" then return end
    if whitelist.lookup[id] then return end
    
    whitelist.lookup[id] = panel:AddLine(id):GetID()
    whitelist.count = whitelist.count + 1
    
    if first then return end
    
    LocalPlayer():ConCommand("whitelist_add " .. id)
  end
  
  local function RemoveID(id, panel)
    if id == "" then return end
    if not whitelist.lookup[id] then return end
  
    panel:RemoveLine(whitelist.lookup[id])
    whitelist.lookup[id] = nil
    whitelist.count = whitelist.count - 1
    LocalPlayer():ConCommand("whitelist_remove " .. id)
  end
    
  net.Receive("bigdogmat_whitelist_open", function()
  
    whitelist.lookup = {}
    whitelist.count = 0

    local menu_base = vgui.Create("DFrame")
    menu_base:SetTitle("Whitelist")
    menu_base:ShowCloseButton(false)
    function menu_base:Paint(w, h)
    
      draw.RoundedBox(6, 0, 0, w, h, Color(149, 165, 166))
      
    end
    menu_base:SetSize(325, 300)
    menu_base:Center()
    menu_base:MakePopup()
    
    local menu_close = menu_base:Add("DButton")
    menu_close:SetText("")
    function menu_close:Paint(w, h)
    
      draw.RoundedBox(8, 0, 0, w, h, Color(189, 195, 199))
      draw.SimpleText("X", "Default", w / 2, 3, Color(0, 0, 0), TEXT_ALIGN_CENTER)
      
    end
    function menu_close:DoClick()
    
      LocalPlayer():ConCommand("whitelist_save")
      menu_base:Close()
      
    end
    menu_close:SetSize(18, 18)
    menu_close:SetPos(302, 5)
    
    local menu_list = menu_base:Add("DListView")
    menu_list:SetMultiSelect(true)
    menu_list:AddColumn("SteamID")
    for i = 1, net.ReadUInt(11) do 
      AddID(net.ReadString(), menu_list, true)
    end
    function menu_list:DoDoubleClick(line, panel)
    
      RemoveID(panel:GetValue(1), menu_list)
      
    end
    menu_list:SetSize(160, 206)
    menu_list:SetPos(10, 36)
    
    local menu_list_remove = menu_base:Add("DButton")
    menu_list_remove:SetText("Remove Selected")
    function menu_list_remove:DoClick()
    
      for k, v in ipairs(menu_list:GetSelected()) do
        RemoveID(v:GetValue(1), menu_list)
      end
      
    end
    menu_list_remove:SetSize(160, 20)
    menu_list_remove:SetPos(10, 244)
    
    local menu_list_remove_all = menu_base:Add("DButton")
    menu_list_remove_all:SetText("Remove All")
    function menu_list_remove_all:DoClick()
    
      menu_base:SetVisible(false)
      
      local confirm_box = vgui.Create("DFrame")
      confirm_box:SetTitle("")
      confirm_box:ShowCloseButton(false)
      function confirm_box:Paint(w, h)
      
        draw.RoundedBox(6, 0, 0, w, h, Color(149, 165, 166))
        draw.SimpleText("Are you sure?", "Default", w / 2, 15, Color(0, 0, 0), TEXT_ALIGN_CENTER)
        
      end
      confirm_box:SetSize(150, 70)
      confirm_box:Center()
      confirm_box:MakePopup()
      
      local confirm_box_yes = confirm_box:Add("DButton")
      confirm_box_yes:SetText("I'm sure")
      function confirm_box_yes:DoClick()
      
        for k, _ in pairs(whitelist.lookup) do
          RemoveID(k, menu_list)
        end
        
        menu_base:SetVisible(true)
        confirm_box:Close()
        
      end
      confirm_box_yes:SetSize(60, 22)
      confirm_box_yes:SetPos(10, 40)
      
      local confirm_box_no = confirm_box:Add("DButton")
      confirm_box_no:SetText("No")
      function confirm_box_no:DoClick()
      
        menu_base:SetVisible(true)
        confirm_box:Close()
        
      end
      confirm_box_no:SetSize(60, 22)
      confirm_box_no:SetPos(80, 40)
      
    end
    menu_list_remove_all:SetSize(160, 20)
    menu_list_remove_all:SetPos(10, 266)
    
    local menu_mode = menu_base:Add("DCheckBoxLabel") 
    menu_mode:SetText("64Bit")
    menu_mode:SetValue(0)
    menu_mode:SetDark(true)
    menu_mode:SizeToContents()
    menu_mode:SetPos(267, 60)
    
    local menu_text_entry = menu_base:Add("DTextEntry")
    menu_text_entry:SetText("SteamID or 64Bit ID")
    function menu_text_entry:GetSteamID()
    
      return menu_mode:GetChecked() and util.SteamIDFrom64(menu_text_entry:GetValue()) or menu_text_entry:GetValue()
      
    end
    menu_text_entry:SetSize(135, 22)
    menu_text_entry:SetPos(180, 36)
    
    local menu_check_id = menu_base:Add("DButton")
    menu_check_id:SetText("Check ID")
    function menu_check_id:DoClick()
    
      menu_base:SetVisible(false)
      
      local id = menu_text_entry:GetSteamID()
      
      local whitelisted_box = vgui.Create("DFrame")
      whitelisted_box:SetTitle("")
      whitelisted_box:ShowCloseButton(false)
      function whitelisted_box:Paint(w, h)
      
        draw.RoundedBox(6, 0, 0, w, h, Color(149, 165, 166))
        draw.SimpleText("SteamID: '" .. id .. "' is " .. (whitelist.lookup[id] and "whitelisted!" or "not whitelisted!"), "Default", w / 2, 15, Color(0, 0, 0), TEXT_ALIGN_CENTER)
        
      end
      whitelisted_box:SetSize(300, 70)
      whitelisted_box:Center()
      whitelisted_box:MakePopup()
      
      local whitelisted_close = whitelisted_box:Add("DButton")
      whitelisted_close:SetText("Close")
      function whitelisted_close:DoClick()
      
        menu_base:SetVisible(true)
        whitelisted_box:Close()
        
      end
      whitelisted_close:SetSize(284, 22)
      whitelisted_close:SetPos(8, 40)
      
    end
    menu_check_id:SetSize(80, 15)
    menu_check_id:SetPos(180, 60)
    
    local menu_add_id = menu_base:Add("DButton")
    menu_add_id:SetText("Add ID")
    function menu_add_id:DoClick()
    
      AddID(menu_text_entry:GetSteamID(), menu_list)
      
    end
    menu_add_id:SetSize(135, 20)
    menu_add_id:SetPos(180, 77)
    
    local menu_remove_id = menu_base:Add("DButton")
    menu_remove_id:SetText("Remove ID")
    function menu_remove_id:DoClick()
    
      RemoveID(menu_text_entry:GetSteamID(), menu_list)
      
    end
    menu_remove_id:SetSize(135, 20)
    menu_remove_id:SetPos(180, 99)
    
    local menu_kick_text = menu_base:Add("DTextEntry")
    menu_kick_text:SetText(net.ReadString())
    menu_kick_text:SetSize(135, 22)
    menu_kick_text:SetPos(180, 131)
    
    local menu_kick_set = menu_base:Add("DButton")
    menu_kick_set:SetText("Set Kick Message")
    function menu_kick_set:DoClick()
    
      LocalPlayer():ConCommand("whitelist_kickreason " .. menu_kick_text:GetValue())
      
    end
    menu_kick_set:SetSize(135, 20)
    menu_kick_set:SetPos(180, 155)
    
  end)
  
end