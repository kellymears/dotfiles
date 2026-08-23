-- Loaded by yazi at startup. Plugins that need wiring beyond a fetcher entry
-- in yazi.toml get set up here.

-- git.yazi: draws per-file git status in the linemode. `order` is where the
-- sign sits relative to other linemode contributors.
require("git"):setup({ order = 1500 })
