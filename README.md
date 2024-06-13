# simple_snippets.nvim

a simple snippets for nvim-cmp.

# install

lazy.nvim :

```lua
return {
    "whitelies125/simple_snippets.nvim",
    config = function(_, opts)
        require("simple_snippets").setup()
    end
}
```

add your snippets in `snippets.lua`:

```lua
local completion_items = {
    { prefix = "if", insertText = "if (${1:condition}) {\n\t$2\n}\n$0" },
    { prefix = "for", insertText = "for (${1:int} ${2:x} = ${3:0}; $2 < ${4:N}; ++$2) {\n\t$0\n}" },
}
```

add source into nvim-cmp:

```lua
sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'simple_snippets' },
})
```
