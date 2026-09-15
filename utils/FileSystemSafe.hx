package utils;

import openfl.utils.Assets;
import StringTools;

/**
 * Cross-platform filesystem helpers.
 *
 * What changed / why:
 * - All direct sys.io.File / sys.FileSystem calls are wrapped with #if sys guards.
 * - HTML5 fallback uses openfl.utils.Assets where possible (text, binary).
 * - readDirectory provides an HTML5 fallback: filters Assets.list() by path prefix.
 * - writeText is a no-op on HTML5 (can't write to bundle); desktop behavior preserved.
 *
 * Usage:
 *   utils.FileSystemSafe.readText("assets/data/config.json");
 *   utils.FileSystemSafe.readDirectory("assets/songs");
 */
class FileSystemSafe {
    public static function readText(path:String):String {
        #if sys
        // Desktop/native: keep original behavior.
        return sys.io.File.getContent(path);
        #else
        // HTML5/JS: prefer Assets.getText
        try {
            if (Assets.exists(path, openfl.assets.AssetType.TEXT)) {
                return Assets.getText(path);
            }
        } catch (e:Dynamic) {
            // Assets.getText not available or failed
        }
        // Last resort: return empty string and log a message (avoid throwing in web builds)
        trace("FileSystemSafe.readText: Assets.getText failed for: " + path);
        return "";
        #end
    }

    public static function readBytes(path:String):haxe.io.Bytes {
        #if sys
        return sys.io.File.getBytes(path);
        #else
        try {
            if (Assets.exists(path, openfl.assets.AssetType.BINARY)) {
                return Assets.getBytes(path);
            }
            // Some projects pack images as AssetType.IMAGE; handle that if needed:
            if (Assets.exists(path, openfl.assets.AssetType.IMAGE)) {
                // openfl returns BitmapData / ByteArray depending on platform; attempt getBytes
                return Assets.getBytes(path);
            }
        } catch (e:Dynamic) {
            // ignore and fallback
        }
        trace("FileSystemSafe.readBytes: no asset: " + path);
        return haxe.io.Bytes.alloc(0);
        #end
    }

    /**
     * Directory listing fallback:
     * - On sys (desktop) uses sys.FileSystem.readDirectory
     * - On HTML5 uses Assets.list() if available and filters results by prefix.
     *
     * Note: openfl.utils.Assets.list() availability depends on OpenFL/Lime versions.
     * If list() is not present, create a build-time asset manifest (JSON) and read it via Assets.
     */
    public static function readDirectory(path:String):Array<String> {
        #if sys
        return sys.FileSystem.readDirectory(path);
        #else
        var out:Array<String> = [];
        var prefix = path.replace("\\", "/");
        if (!StringTools.endsWith(prefix, "/")) prefix += "/";

        // Attempt to use Assets.list (wrapped in try to avoid runtime errors if not present)
        try {
            // NOTE: Some OpenFL versions expose Assets.list(); others don't.
            // If this throws, catch below and return empty array with a helpful trace.
            var all = Assets.list(); // returns Array<String> in supported versions
            for (p in all) {
                var normalized = p.replace("\\", "/");
                if (StringTools.startsWith(normalized, prefix)) out.push(normalized);
            }
        } catch (e:Dynamic) {
            trace("FileSystemSafe.readDirectory: Assets.list() unavailable; consider adding a manifest. Requested: " + path);
        }
        return out;
        #end
    }

    /**
     * Safe writeText: preserved on desktop, no-op on HTML5.
     * Use IndexedDB/localStorage if you need persistence on web builds (not implemented here).
     */
    public static function writeText(path:String, content:String):Void {
        #if sys
        sys.io.File.saveContent(path, content);
        #else
        trace("FileSystemSafe.writeText: ignored on HTML5: " + path);
        #end
    }
}
