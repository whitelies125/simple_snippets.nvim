local source = {}

local cmp = require 'cmp'

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
    return 'simple_snippets'
end

--[[
以下参考: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_completion

补全流程:
Client                          Server
|        Completion Request         |
|---------------------------------->|
|             Response              |
|<----------------------------------|
|   Completion Item Solve Request   |
|---------------------------------->|
|             Response              |
|<----------------------------------|

T1：Client 发送补全上下文，向 Server 请求补全项列表
T2：Server 回复可供 Client 选择的补全项列表，但并不携带各项的详细信息
T3：Client 选择某个补全项，向 Server 请求该补全项的详细信息
T4：Server 回复该补全项的详细信息
注意到，该流程在逻辑上可以简化为 Server 在 T2 的回复消息中携带所有补全项的详细信息，
但 LSP 官网文档解释为，出于性能方面考虑，所以拆分为 T1-T2，T3-T4 两个流程。

详细：
A typical use case is for example:
the textDocument/completion request doesn’t fill in the documentation property for returned completion items since it is expensive to compute.
By default the request can only delay the computation of the detail and documentation properties.
T2 Response 并不会填写 Completion Item 的 documentation 属性, 因为其计算成本很高
默认情况下，只能够延迟计算 detail 和 documentation 属性
--]]

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
    local response = {}

    local completion_items = require("simple_snippets.snippets")
    -- response 是一个table，数据成员为 CompletionItem(不填写详细信息: detail 和 documentation)
    for _, item in pairs(completion_items) do
        table.insert(response, {
            -- 显示该补全项时显示的文本.
            label = item.prefix,
            -- 当选择该补全项时，要插入的文本.
            -- 若省略，则使用 label 作为 insertText
            insertText = item.insertText,
            -- 该补全项的类型，编辑器根据 kind 选择图标
            -- 各种类型的定义，详见 CompletionItemKind
            kind = cmp.lsp.CompletionItemKind.Snippet,
            -- 指示插入文本(insertText)的形式为文本(Text)还是代码片段(Snippet)
            -- Text: 单纯对 insertText 进行普通的文本插入
            -- Snippet: 将 insertText 视为代码片段(如 inserText 可能包含 $1,{$2:foo} 等内容), 会对其进行一些处理.
            insertTextFormat = cmp.lsp.InsertTextFormat.Snippet,
            -- 指示如何处理空白与缩进
            -- asIs: 按 insertText 的内容原样处理
            -- AdjustIndentation: 由编辑器处理新行的前导空格
            insertTextMode = cmp.lsp.InsertTextMode.AdjustIndentation,
            -- 由用户自定义的额外信息
            --[[
            data = {
                prefix = item.prefix,
                insertText = item.insertText,
            },
            --]]
        })
    end
    callback(response)
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
    -- response 是该补全项的详细信息, 即填写补全项的 detail 和 documentation 字段
    -- detail 就是一个字符串，通常写关于该补全项的简短描述信息，例如该函数的用法，参数，返回值等
    -- documentation 则是关于该补全项的文档内容
    -- completion_item.detail = "there is a string"
    local insertText = completion_item.insertText
    local preview = string.format("```%s\n%s\n```", vim.bo.filetype, insertText)
    completion_item.documentation = {
        -- 指示 value 的 格式
        -- PlainText: 指示 value 为普通的文本(text)
        -- Markdonw: 指示 value 为 markdown 语法的文本
        kind = cmp.lsp.MarkupKind.Markdown,
        -- 用于显示预览的字符串
        value = preview,
    }
    callback(completion_item)
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
    callback(completion_item)
end

return source
