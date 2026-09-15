package funkin.backend.system;

// Replaced direct sys.FileSystem.exists usage with AssetSafe.exists where appropriate for HTML5 compatibility.
// This file still uses sys for desktop-only logic; conditional compilation keeps behavior unchanged for native builds.

import utils.AssetSafe;

class MainFixes {
    public static function example_fix():Void {
        // Example replacement for: if (!sys.FileSystem.exists('manifest/default.json')) { ... }
        #if sys
        if (!sys.FileSystem.exists('manifest/default.json')) {
            Sys.setCwd(haxe.io.Path.directory(Sys.programPath()));
        }
        #else
        if (!AssetSafe.exists('manifest/default.json')) {
            // HTML5 can't change CWD; no-op or alternative behavior.
        }
        #end
    }
}
