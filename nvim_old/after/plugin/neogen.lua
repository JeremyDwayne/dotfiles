local status, neogen = pcall(require, "neogen")
if (not status) then return end

neogen.setup {
    enabled = true, --if you want to disable Neogen
    input_after_comment = true, -- (default: true) automatic jump (with insert mode) on inserted annotation
    languages = {
        ruby = {
            template = {
                annotation_convention = "yard"
            }
        },
    }
}
