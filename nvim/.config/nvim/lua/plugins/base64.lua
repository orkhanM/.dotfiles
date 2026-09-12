return {
	"taybart/b64.nvim",
	keymaps = {
		vim.keymap.set("v", "<leader>b64e", '<Cmd>lua require("b64").encode()<CR>', { desc = "Base64 encode" }),
		vim.keymap.set("v", "<leader>b64d", '<Cmd>lua require("b64").decode()<CR>', { desc = "Base64 Decode" }),
	},
}
