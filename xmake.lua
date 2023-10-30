add_repositories("liteldev-repo https://github.com/LiteLDev/xmake-repo.git")
add_requires("scriptx",
    {configs = {backend = get_config("backend")}})

option("backend")
    set_values("lua", "nodejs", "python310", "quickjs")
    set_default("lua")

target("leviscript")
    add_files("src/**.cc")
    add_includedirs("include")
    add_packages(
        "scriptx"
    )
    add_rules("mode.debug", "mode.release")
    set_basename("leviscript_$(backend)")
    set_kind("shared")
    set_languages("cxx20")
