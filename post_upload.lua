local parser = require "parser"

ngx.req.read_body()
local body = ngx.req.get_body_data()

local p, err = parser.new(body, ngx.var.http_content_type)
if not p then
    ngx.say("failed to create parser: ", err)
    return
end

local filePath, originFileName, extName
while true do
    local part_body, name = p:parse_part()
    if not part_body then
        break
    end
    if name == 'fileUpload.path' then
        filePath = part_body
    end
    if name == 'fileUpload.name' then
        originFileName = part_body
    end
end

os.execute('mkdir -p '..filePath..'.d/')
os.execute('mv '..filePath..' '..filePath..'.d/'..originFileName)
os.execute('mv '..filePath..'.d '..filePath)

ngx.header['Content-Type'] = 'text/plain'
ngx.header['X-Frame-Options'] = 'GOFORIT'
ngx.say(filePath:match('/opt/upload(.*)')..'/'..originFileName)
