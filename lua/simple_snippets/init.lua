local M = {}

function M.setup(opts)
    local source = require("simple_snippets.source")
    require('cmp').register_source('simple_snippets', source)
end

return M
