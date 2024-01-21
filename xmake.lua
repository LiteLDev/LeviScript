add_rules("mode.debug", "mode.release", "mode.releasedbg")

add_repositories("liteldev-repo https://github.com/LiteLDev/xmake-repo.git")
add_requires("levilamina 0.5.1")
add_requires("scriptx 0.1.0", {configs={backend=get_config("backend")}})

if not has_config("vs_runtime") then
    set_runtimes("MD")
end

option("backend")
    set_default("lua")
    set_values("lua", "nodejs", "python310", "quickjs")

package("scriptx")
    add_configs("backend", {default = "lua", values = {"lua", "nodejs", "python310", "quickjs"}})
    add_includedirs(
        "include/scriptx/src/include/",
        "include/$(backend)/"
    )
    add_linkdirs(
        "lib/scriptx/"
    )
    add_urls("https://github.com/LiteLDev/ScriptX/releases/download/v$(version)/scriptx-windows-x64.zip")
    add_versions("0.1.0", "c0077eed8daf0e50a455cfde6396c2c04ba4d7a03a40424aa7da3571f9e8b7b4")

    on_install(function (package)
        local backend = package:config("backend")

        local backend_info = {
            ["lua"] = {
                backend = "lua",
                scriptx = "Lua",
            },
            ["nodejs"] = {
                backend = "libnode",
                scriptx = "V8",
            },
            ["python310"] = {
                backend = "python310",
                scriptx = "Python",
            },
            ["quickjs"] = {
                backend = "quickjs",
                scriptx = "QuickJs",
            },
        }

        -- ScriptX
        os.cp("include/scriptx/*", package:installdir("include", "scriptx"))
        os.cp("lib/scriptx/" .. backend_info[backend].scriptx .. ".lib",
            package:installdir("lib", "scriptx"))
        package:add("defines", "SCRIPTX_BACKEND=" .. backend_info[backend].scriptx)
        package:add("defines", "SCRIPTX_BACKEND_TRAIT_PREFIX=../backend/" .. backend_info[backend].scriptx .. "/trait/Trait")

        -- Backend
        os.cp("include/" .. backend_info[backend].backend .. "/*",
            package:installdir("include", backend_info[backend].backend))
        os.cp("lib/" .. backend_info[backend].backend .. ".lib",
            package:installdir("lib"))
    end)

target("plugin")
    add_cxflags(
        "/EHa",
        "/utf-8"
    )
    add_defines(
        "_HAS_CXX23=1" -- To enable C++23 features
    )
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
    add_shflags(
        "/DELAYLOAD:bedrock_server.dll"
    )
    set_basename("leviscript-$(backend)")
    set_exceptions("none")
    set_kind("shared")
    set_languages("cxx20")
