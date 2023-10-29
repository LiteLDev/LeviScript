add_rules("mode.debug", "mode.release")

add_repositories("liteldev-repo https://github.com/LiteLDev/xmake-repo.git")
add_requires("scriptx", {configs = {backend = "lua"}})

target("leviscript")
    set_kind("shared")
    set_languages("cxx20")

    add_files("src/**.cc")
    add_includedirs("include")
    add_packages(
        "scriptx"
    )
