add_repositories("liteldev-repo https://github.com/LiteLDev/xmake-repo.git")
add_requires("levilamina 0.2.1")
add_requires("scriptx", {configs = {backend = get_config("backend")}})

if not has_config("vs_runtime") then
    set_runtimes("MD")
end

option("backend")
    set_default("lua")
    set_values("lua", "nodejs", "python310", "quickjs")

target("plugin")
    add_files(
        "src/**.cpp"
    )
    add_includedirs(
        "src"
    )
    add_packages(
        "levilamina",
        "scriptx"
    )
    add_rules(
        "mode.debug",
        "mode.release",
        "mode.releasedbg"
    )
    add_shflags(
        "/DELAYLOAD:bedrock_server.dll"
    )
    set_basename("leviscript-$(backend)")
    set_kind("shared")
    set_languages("cxx20")
    set_strip("all")
