-- Config home used only by yazi.rg(). Drop straight into ripgrep search on
-- startup so the instance is a single-shot "search -> pick -> exit" picker.
ya.emit("search", { via = "rg" })
