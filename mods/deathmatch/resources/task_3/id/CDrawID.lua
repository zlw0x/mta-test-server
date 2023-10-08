loadstring( exports.interfacer:extend( "ShPlayer" ) )()
loadstring( exports.interfacer:extend( "CElement" ) )()

local SCREEN_W, SCREEN_H = guiGetScreenSize()
local radius = 30

function drawID()
	local player_position = localPlayer:getPosition()
    for _, player in pairs( getElementsWithinRange(player_position, radius, "player" ) ) do 	-- UPD: (6)  получаем игроков в радиусе
		local player_id = player:GetID()
        if player_id and player ~= localPlayer then 
		    player:DrawTextOnElement( player_id )
        end
		local local_player_id = localPlayer:GetID()
		if local_player_id then
        	dxDrawText( "ID: "..local_player_id, 10, SCREEN_H - 30, SCREEN_W, SCREEN_H, 
					tocolor ( 255, 250, 0, 255 ), 1.5, "default" )
		end
	end
end
addEventHandler( "onClientRender", root, drawID )
