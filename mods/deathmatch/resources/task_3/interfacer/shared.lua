function extend( name )
    local file_path = table.concat( { "Extend/", name, ".lua" }, "" )
    if not fileExists( file_path ) then 
        outputChatBox( "Расширение " .. file_path .. " не существует" )
        return false 
    end

    local file = fileOpen( file_path, true )
    local size = fileGetSize( file )
    if size <= 0 then
        fileClose( file )
        outputChatBox("Модуль " .. name .. " пустой")
        return false
    end

    local chunk = fileRead( file, size )
    fileClose( file )

    return chunk
end

