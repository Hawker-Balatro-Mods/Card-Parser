function SMODS.current_mod.config_tab()
    return {
        n = G.UIT.ROOT,
        config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.BLACK},
        nodes = {{
            n = G.UIT.C,
            config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.CLEAR},
            nodes = {
                create_toggle {
                    label = "Automatically copy url every event",
                    ref_table = cardparse_mod.config,
                    ref_value = "automatic_url_copy",
                    scale = 2,
                }
            },
        }}
    }
end