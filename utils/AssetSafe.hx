// name=utils/AssetSafe.hx
package utils;

import openfl.utils.Assets;
import openfl.assets.AssetType;
import openfl.display.BitmapData;

/**
 * Safe Asset access wrappers.
 *
 * What changed / why:
 * - Avoids direct sys filesystem checks for assets on HTML5 builds.
 * - Uses Assets.exists/getBitmapData when possible.
 * - getBitmapDataSafe returns a 1x1 transparent BitmapData fallback instead of null on web builds
 *   so engine code doesn't crash when an asset is missing at runtime.
 *
 * Usage:
 *   if (utils.AssetSafe.exists("images/sprite.png")) ...
 *   var bd = utils.AssetSafe.getBitmapDataSafe("images/sprite.png");
 */
class AssetSafe {
    public static function exists(path:String, assetType:AssetType = null):Bool {
        #if sys
        try {
            return sys.FileSystem.exists(path);
        } catch (e:Dynamic) {
            // Fallback to Assets
        }
        #end

        if (assetType == null) {
            return Assets.exists(path, AssetType.BINARY) || Assets.exists(path, AssetType.IMAGE) || Assets.exists(path, AssetType.TEXT);
        } else {
            return Assets.exists(path, assetType);
        }
    }

    public static function getBitmapDataSafe(path:String):BitmapData {
        #if sys
        // Desktop: prefer Assets when available, else proceed to other desktop workflows if present.
        if (Assets.exists(path, AssetType.IMAGE)) return Assets.getBitmapData(path);
        #end

        if (Assets.exists(path, AssetType.IMAGE)) {
            return Assets.getBitmapData(path);
        }

        // Fallback: 1x1 transparent bitmap to prevent null-pointer crashes on web.
        trace("AssetSafe.getBitmapDataSafe: missing asset, returning 1x1 transparent image: " + path);
        return new BitmapData(1, 1, true, 0);
    }
}
