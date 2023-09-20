local INVITE_SPAM = {}

function getClientTeamMembers() 
    return getPlayersInTeam( getPlayerTeam( getLocalPlayer() ) )
 end

function getClientTeamName()
    return getTeamName( getPlayerTeam( getLocalPlayer() ) )
end

function destroyWindow( window )
    if isElement ( window ) then
        destroyElement( window )
    end
end

function createTeamWindow()
    local team = getPlayerTeam( getLocalPlayer() )
    if team then 
        TEAM_WINDOW = guiCreateWindow( 0.25, 0.25, 0.4, 0.5, getTeamName( team ), true )  
        local tab_panel = guiCreateTabPanel( 0, 0.05, 1, 1, true, TEAM_WINDOW )          
        local members_tab = guiCreateTab( "Список участников", tab_panel )                
        local city_tab = guiCreateTab( "Управление городом", tab_panel ) 
        local delete_label = guiCreateLabel( 0.55, 0.05, 0.4, 0.1, "Выберите игрока из списка", true, members_tab )
        local delete_button = guiCreateButton( 0.55, 0.11, 0.4, 0.1, "Уволить", true, members_tab )
        local invite_label = guiCreateLabel( 0.55, 0.3, 0.4, 0.1, "Введите ID игрока", true, members_tab )
        local invite_edit = guiCreateEdit( 0.54, 0.36, 0.2, 0.1, "", true, members_tab )
        guiEditSetMaxLength ( invite_edit, 8 )
        local invite_button = guiCreateButton( 0.76, 0.36, 0.2, 0.1, "Пригласить", true, members_tab )
        local members_grid = guiCreateGridList( 0.01, 0.01, 0.5, 0.98, true, members_tab )
        guiGridListSetSelectionMode( members_grid, 0 )
        guiGridListAddColumn( members_grid, "ID", 0.22 )
        guiGridListAddColumn( members_grid, "Имя", 0.7 )
        
        local leader = getElementData( team, "leader" )
        for _, player in pairs( getClientTeamMembers() ) do  -- заполняем список участников фракции
            local id = getElementData( player, "player_id" )
            local name = getPlayerName( player )
            if player == leader then
               name = name.." (Лидер)"
            end
            guiGridListAddRow( members_grid, id, name )
        end
        
        if leader ~= getLocalPlayer() then  -- если клиент не лидер отключаем элементы
            guiSetEnabled( city_tab, false )
            guiSetEnabled( delete_button, false )
            guiSetEnabled( invite_button, false )
            guiSetEnabled( invite_edit, false )
        end

        showCursor( true )

        addEventHandler( "onClientGUIClick", invite_button, function( button )
            if button == "left" then 
                local team_name = getClientTeamName()
                local player_id = guiGetText( invite_edit )
                local sender = getPlayerName( getLocalPlayer() ) 
                local current_time = getTickCount()
                if INVITE_SPAM[ player_id ] and current_time - INVITE_SPAM[ player_id ] < 60000 then    -- если инвайт был менее минуты назад
                    local time_left = string.format( "%d", ( 60000 - ( current_time - INVITE_SPAM[ player_id ] ) ) / 1000 )
                    outputChatBox("Приглашать можно раз в минуту. Ожидайте "..time_left.." сек.")
                else
                    INVITE_SPAM[player_id] = getTickCount() -- сохраняем время последнего инвайта для данного игрока
                    triggerServerEvent( "inviteToTeam", resourceRoot, player_id, team_name, sender )
                end
            end
        end, false )

        addEventHandler( "onClientGUIClick", delete_button, function( button )
            if button == "left" then 
                local player_id = guiGridListGetItemText( members_grid, guiGridListGetSelectedItem( members_grid ) )
                triggerServerEvent( "deletePlayerFromTeam", resourceRoot, player_id )
            end
        end, false)
    end   
end


function createInviteWindow( player_id, team_name, sender )          -- окошко приглашения
    local invite_window = guiCreateWindow( 0.35, 0.7, 0.3, 0.2, "Приглашение", true )
    local invite_label = guiCreateLabel( 0.1, 0.2, 0.8, 0.2, sender.." приглашает вас вступить во фракцию \""..team_name.."\"", true, invite_window)
    local yes_button = guiCreateButton( 0.08, 0.6, 0.4, 0.2, "Принять", true, invite_window )
    local no_button = guiCreateButton( 0.52, 0.6, 0.4, 0.2, "Отклонить", true, invite_window )
    local progress = guiCreateProgressBar( 0.02, 0.9, 0.96, 0.1, true, invite_window )
    guiLabelSetHorizontalAlign( invite_label, "center", true )
    guiLabelSetVerticalAlign( invite_label, "center", true )

    local start_tick = getTickCount()
    showCursor( true )

    addEventHandler( "onClientRender", root, function()   
        if isElement( invite_window ) then
            x = ( getTickCount() - start_tick ) / 150       -- исчезает с экрана через 15 сек
            guiProgressBarSetProgress (progress, x ) 
            if x > 100 then
                destroyWindow( invite_window )
                start_tick = nil
                showCursor( false )
            end
        end
    end )
  
    function onGUIButtonClick( button )
        if button == "left" then
            if source == yes_button then
                triggerServerEvent( "acceptInvite", resourceRoot, player_id, team_name )  -- принял приглашение
                destroyWindow ( invite_window )
                showCursor( false )
            elseif source == no_button then
                destroyWindow( invite_window )
                showCursor( false )
            end
        end
    end
    addEventHandler( "onClientGUIClick", getRootElement(), onGUIButtonClick )
end 

addEvent( "invitePlayerToTeam", true )
addEventHandler( "invitePlayerToTeam", resourceRoot, createInviteWindow )

bindKey ("p", "down", function( button, press )   
    if isElement( TEAM_WINDOW ) then 
        destroyElement( TEAM_WINDOW )
        showCursor( false )
    else
        createTeamWindow()
    end        
end )

