Element.DrawTextOnElement = function( self, text )
    local max_distance = 30
	local player_position = self:getPosition()      		-- Vector3
	local camera_position = Camera.getMatrix():getPosition()
	local height = Vector3( 0, 0, 1.1 )
	local size = 1.5
	if isLineOfSightClear( player_position, camera_position ) then 		-- если между игроком и камерой ничего нет
		local label_x, label_y = getScreenFromWorldPosition( player_position + height ) 	-- позиция id над игроком
		local dist_between = getDistanceBetweenPoints3D( player_position, camera_position ) 		-- получаем расстояние между игроком и камерой
		if label_x and label_y then 
			if dist_between < max_distance then 
				dxDrawText( text, label_x, label_y, label_x, label_y,
							tocolor( 255, 250, 0, 255 ),
							size - ( dist_between / max_distance ), "default" ) 	-- изменяем размер текста в зависимости от расстояния
			end			
		end
	end
end


