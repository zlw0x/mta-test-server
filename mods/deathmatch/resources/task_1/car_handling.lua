isEngineStart = {} -- машины, в которых побывали

function enterCar( player, seat, jacked, door )
    vehicle = getPedOccupiedVehicle( player )
    if isEngineStart[vehicle] ~= nil then
        setVehicleEngineState( vehicle, isEngineStart[vehicle] ) -- если уже заводили - берем последнее состояние
    else
        setVehicleEngineState( vehicle, false ) -- если не заводили - заглушена
    end

    unbindKey ( player, "l")
    unbindKey ( player, "e")
    unbindKey ( player, "lshift")

    bindKey ( player, "l", "down", function() -- фары
            if ( getVehicleOverrideLights ( vehicle ) ~= 2 ) then  
                setVehicleOverrideLights ( vehicle, 2 )           
            else
                setVehicleOverrideLights ( vehicle, 1 )            
            end
        end)  
    bindKey ( player, "e", "down", function() -- двигатель
            if ( getVehicleEngineState ( vehicle ) ) then  
                setVehicleEngineState ( vehicle, false )
                isEngineStart[vehicle] = false -- сохраняем состояние
            else
                setVehicleEngineState ( vehicle, true )
                isEngineStart[vehicle] = true
            end
        end)
    bindKey ( player, "lshift", "down", function() -- дополнительно
            local x, y, z = getElementPosition( vehicle )
            if isVehicleOnGround( vehicle ) then
                setElementPosition( vehicle, x,  y, z + 1)
            end
        end)

end
addEventHandler( "onVehicleEnter", root, enterCar )


