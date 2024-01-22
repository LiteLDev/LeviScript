add_rules("mode.debug", "mode.release", "mode.releasedbg")

add_repositories("liteldev-repo https://github.com/LiteLDev/xmake-repo.git")
add_requires("levilamina 0.5.1")
add_requires("scriptx", {configs={backend=get_config("backend")}})

if not has_config("vs_runtime") then
    set_runtimes("MD")
end

option("backend")
    set_default("lua")
    set_values("libnode", "lua", "python310", "quickjs")

package("scriptx")
    add_configs("backend", {default = "lua", values = {"libnode", "lua", "python310", "quickjs"}})
    add_includedirs(
        "include/scriptx/src/include/"
    )
    add_linkdirs(
        "lib/",
        "lib/scriptx/"
    )
    add_urls("https://github.com/LiteLDev/ScriptX/releases/download/v$(version)/scriptx-windows-x64.zip")
    add_versions("0.1.0", "c0077eed8daf0e50a455cfde6396c2c04ba4d7a03a40424aa7da3571f9e8b7b4")

    on_install(function (package)
        os.cp("*", package:installdir())
    end)

    on_load(function (package)
        print("Loading")
        local backend = package:config("backend")

        local scriptx_backend = {
            lua = "Lua",
            nodejs = "V8",
            python310 = "Python",
            quickjs = "QuickJs",
        }
        
        package:add("defines", "SCRIPTX_BACKEND=" .. scriptx_backend[backend])
        package:add("defines", "SCRIPTX_BACKEND_TRAIT_PREFIX=../backend/" .. scriptx_backend[backend] .. "/trait/Trait")
        package:add("includedirs", "include/" .. backend .. "/")
        package:add("links", backend)
        package:add("links", scriptx_backend[backend])
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
