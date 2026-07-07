-- Append node for preview text to the HUD:
local orig_hud = create_UIBox_HUD
function create_UIBox_HUD()
   sendTraceMessage("Overwriting UI Box to have copy url button", "CardParserTraceLogger")
   local contents = orig_hud()
   local copy_button_row = {n=G.UIT.R, config={id = "copy_button_row", align = "cm", padding = 0.1}, nodes={}}
   table.insert(copy_button_row.nodes, get_copy_button())
   table.insert(contents.nodes[1].nodes[1].nodes[4].nodes[1].nodes, copy_button_row)
   return contents
end

function get_copy_button()
return {n=G.UIT.C, config={button = "copy_url", align = "cm", colour = G.C.RED, r=0.25, padding=0.1}, nodes={
        {n=G.UIT.T, config={text = "Copy calculator url", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
}}
end
