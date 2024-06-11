local completion_items = {
    { prefix = "if", insertText = "if (${1:condition}) {\n\t$2\n}\n$0" },
    { prefix = "for", insertText = "for (${1:int} ${2:x} = ${3:0}; $2 < ${4:N}; ++$2) {\n\t$0\n}" },
}

return completion_items
