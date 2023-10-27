add_rules("mode.debug", "mode.release")

target("LeviScript")
    set_kind("shared")
    add_files("src/**.cc")
