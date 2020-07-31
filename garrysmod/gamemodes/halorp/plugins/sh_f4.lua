

if SERVER then return end







function PLUGIN:PluginLoaded()
  



end

 
local showf4Menu = true
hook.Add("Think", "ShowMenu", function( ) 
    if input.IsKeyDown(KEY_F4) and showf4Menu then  

        function nut.meta.item:GetIcon() 
            return self.Icon
            end
       showf4Menu = false  


       SHOWF4MENU()  
        
        
    elseif not input.IsKeyDown(KEY_F4) then
        showf4Menu = true 
    end
   end)   


  