require("log")

function _G.print(...)
    local ret = {}
    for i = 1, select('#', ...) do
      	table.insert(ret, tostring(select(i, ...)))
    end
    log.info(table.concat(ret, '\t'))
end