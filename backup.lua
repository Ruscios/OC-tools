------------------------------
local version="0.9.7b"
------------------------------
local serialization=require("serialization")
local component=require("component")
local computer=require("computer")
local unicode=require("unicode")
local s={} --functions
local files={}
local path={}
local f

--add browse backup, load backup & send backup, return backup_size, split backups
--add automatic raid detection
--add table conversion in backup
--on stop remove function from request-handler
--add authentication to prevent hacking
--add registration

local function open(filename,mode)
    for i=1,#path,1 do
        files[i]=io.open(path[i]..filename,mode)
    end
end

local function close()
    for i=1,#path,1 do
        files[i]:close()
    end
    files={}
end

-----------------------

function s.initialize(handler)
    local file=io.open("/backup_path","r") 
    if file==nil then
        file=io.open("/backup_path","w")
        local running=true
        while running do
            print("Enter storage location #"..tostring(#path+1)..", default for default, quit for quit")
            io.flush()
            local tmp2=io.read()
            if tmp2=="default" then
                path[#path+1]="/"
            elseif tmp2=="quit" or tmp2=="q" then
                running=false
            else 
                path[#path+1]=tmp2
            end
        end
        if #path>=1 then 
            file:write(serialization.serialize(path))
        end
        file:close()
    else
        path=serialization.unserialize(file:read("*all"))
        file:close()
    end
    
    f=handler
end


function s.backup(file_name,data)
    open(file_name,"a")
    for i=1,#files do
        files[i]:write(data.."\n")
    end
    close()
end

function s.stop()
    for i=1,#files,1 do
        if files[i]~=nil then
            files[i]:close()
        end
    end
end

function s.getBackup(file_name)
    open(file_name,"r")
    local inp=files[1]:read("*all")
    local ret={}
    while true do
        local t=inp:find("\n")
        if t then 
            ret[#ret+1]=unicode.sub(inp,1,t-1)
            inp=unicode.sub(inp,t+1)
        else
            break
        end
    end
    close()
    return ret
end

return s