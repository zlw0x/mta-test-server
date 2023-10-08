-- Получене информации о фракциии 

local faction = nil

addEvent( "refreshFactionData", true )
addEventHandler( "refreshFactionData", resourceRoot, function( fact_data )
    faction = fact_data
end)


-- Окно фракции

local faction_window = nil

function FactionWindow() 
    if isElement( faction_window ) then        -- если окно существет - закрываем
        destroyElement( faction_window )
        showCursor( false )
    else   
        if faction then 
            faction_window = guiCreateWindow( 0.25, 0.25, 0.4, 0.5, faction.name, true ) 
            local tab_panel = guiCreateTabPanel( 0, 0.05, 1, 1, true, faction_window )   

            -- вкладка список участников
            local members_tab = guiCreateTab( "Список участников", tab_panel )                
            local delete_label = guiCreateLabel( 0.55, 0.05, 0.4, 0.1, "Выберите игрока из списка", true, members_tab )
            local delete_button = guiCreateButton( 0.55, 0.11, 0.4, 0.1, "Уволить", true, members_tab )
            local invite_label = guiCreateLabel( 0.55, 0.3, 0.4, 0.1, "Введите ID игрока", true, members_tab )
            local invite_edit = guiCreateEdit( 0.54, 0.36, 0.2, 0.1, "", true, members_tab )
            guiEditSetMaxLength ( invite_edit, 8 )
            local invite_button = guiCreateButton( 0.76, 0.36, 0.2, 0.1, "Пригласить", true, members_tab )
            local members_grid = guiCreateGridList( 0.01, 0.01, 0.5, 0.98, true, members_tab )
            guiGridListSetSelectionMode( members_grid, 0 )
            guiGridListAddColumn( members_grid, "ID", 0.15 )
            guiGridListAddColumn( members_grid, "Имя", 0.5 )
            guiGridListAddColumn( members_grid, "Должность", 0.28 )
        
            for member, rang in pairs( faction.members ) do         -- заполняем список участников фракции
                local id = getElementData( member, "player_id" )
                local name = getPlayerName( member )
                guiGridListAddRow( members_grid, id, name, rang )
            end
        
            if faction.leader ~= localPlayer then               -- если клиент не лидер отключаем элементы
                guiSetEnabled( city_tab, false )
                guiSetEnabled( delete_button, false )
                guiSetEnabled( invite_button, false )
                guiSetEnabled( invite_edit, false )
            end

            showCursor( true )

            addEventHandler( "onClientGUIClick", invite_button, function( button )
                if button == "left" then 
                    local player_id = guiGetText( invite_edit ) 
                    triggerServerEvent( "invitePlayerToFaction", resourceRoot, player_id )
                end
            end, false )

            addEventHandler( "onClientGUIClick", delete_button, function( button )
                if button == "left" then 
                    local player_id = guiGridListGetItemText( members_grid, guiGridListGetSelectedItem( members_grid ) )
                    triggerServerEvent( "deletePlayerFromFaction", resourceRoot, player_id )
                end
            end, false )


            --вкладка управление городом

            -- local city_tab = guiCreateTab( "Управление городом", tab_panel ) 
            -- local city_name_label = guiCreateLabel( 0.1, 0.02, 0.8, 0.1, "Изменить название города (доступно 1 раз сутки)", true, city_tab )
            -- local city_name_edit = guiCreateEdit( 0.1, 0.1, 0.45, 0.1, "", true, city_tab )
            -- local city_name_button = guiCreateButton( 0.6, 0.1, 0.3, 0.1, "Изменить", true, city_tab )
            
            -- local apply_button = guiCreateButton( 0.2, 0.9, 0.2, 0.05, "Применить", true, city_tab )
            -- local reset_button = guiCreateButton( 0.7, 0.9, 0.2, 0.05, "Сбросить", true, city_tab )

            -- addEventHandler("onClientGuiClick", resourceRoot, function() 
            --     if source == tax_plus_button1 then
            --         outputChatBox("+")
            --     elseif source == tax_minus_button1 then
            --         outputChatBox("-")
            --     end
            
            
            -- end )
            





        end
    end   
end



-- Окно пришглашения

function inviteWindow( faction_name )        
    local sender = getPlayerName( source ) 
    invite_window = guiCreateWindow( 0.35, 0.7, 0.3, 0.2, "Приглашение", true )
    local invite_label = guiCreateLabel( 0.1, 0.2, 0.8, 0.2, sender.." приглашает вас вступить во фракцию \""..faction_name.."\"", true, invite_window)
    local yes_button = guiCreateButton( 0.08, 0.6, 0.4, 0.2, "Принять", true, invite_window )
    local no_button = guiCreateButton( 0.52, 0.6, 0.4, 0.2, "Отклонить", true, invite_window )
    local progress = guiCreateProgressBar( 0.02, 0.9, 0.96, 0.1, true, invite_window )
    guiLabelSetHorizontalAlign( invite_label, "center", true )
    guiLabelSetVerticalAlign( invite_label, "center", true )

    local start_tick = getTickCount()
    showCursor( true )

    addEventHandler( "onClientRender", root, function()   -- исчезает с экрана через 15 сек
        if isElement( invite_window ) then        
            x = ( getTickCount() - start_tick ) / 150       
            guiProgressBarSetProgress ( progress, x ) 
            if x > 100 then
                destroyElement( invite_window )
                invite_window = nil
                start_tick = nil
                showCursor( false )
            end
        end
    end )

    addEventHandler( "onClientGUIClick", root, function( button )
        if button == "left" and isElement( invite_window ) then
            if source == yes_button then
                triggerServerEvent( "acceptInvite", resourceRoot )  -- принять приглашение
                destroyElement( invite_window )
                showCursor( false )
            elseif source == no_button then
                destroyElement( invite_window )
                showCursor( false )
            end
        end
    end )
end
addEvent( "createInviteWindow", true )
addEventHandler( "createInviteWindow", root, inviteWindow )




bindKey ( "p", "down", function()
    triggerServerEvent("getFactData", resourceRoot)    
    FactionWindow()
end)



