// name=utils/VideoPlayer.hx
package utils;

import openfl.utils.Assets;

/**
 * Cross-platform video playback abstraction.
 *
 * What changed / why:
 * - Native video playback calls (hxCodec/hxvlc/etc) are guarded with #if desktop && !html5 so they are not compiled into web builds.
 * - HTML5 fallback attempts to create a <video> element and play the asset. This avoids native-only dependencies on web.
 * - Fallback is intentionally simple and muted (to satisfy autoplay policies); adapt for your UI if you need controls or sound.
 *
 * Usage:
 *   utils.VideoPlayer.play("assets/video/intro.mp4");
 *   utils.VideoPlayer.stopAll();
 */
class VideoPlayer {
    public static function play(path:String):Void {
        #if desktop && !html5
        // Desktop native playback: put your hxCodec/hxvlc calls here.
        try {
            // Example placeholders guarded by defines; uncomment and adapt to your native video library:
            // #if hxCodec
            // hxCodec.play(path);
            // #end
            // #if hxvlc
            // hxvlc.play(path);
            // #end
            trace("VideoPlayer.play: native desktop playback attempted for: " + path);
        } catch (e:Dynamic) {
            trace("VideoPlayer.play: native video error: " + e);
        }
        #else
        // HTML5 / JS fallback: inject a video element and play it.
        #if js
        try {
            // Keep this minimal and muted to comply with autoplay rules in many browsers.
            untyped __js__('(function(src){' +
                'var v = document.createElement("video");' +
                'v.src = src;' +
                'v.autoplay = true; v.muted = true; v.playsInline = true;' +
                'v.style.position = "absolute"; v.style.left = "0"; v.style.top = "0";' +
                'v.style.pointerEvents = "none"; v.style.zIndex = "99999";' +
                'document.body.appendChild(v);' +
                'v.play().catch(function(e){ console.log("Video play failed:", e); });' +
                'return v; })(src)', path);
            trace("VideoPlayer.play: HTML5 fallback used for: " + path);
        } catch (e:Dynamic) {
            trace("VideoPlayer.play: HTML5 fallback injection failed: " + e);
        }
        #else
        // Non-js, non-desktop: no-op
        trace("VideoPlayer.play: skipped: no-supported-platform for " + path);
        #end
        #end
    }

    /**
     * Remove HTML5 video elements created by this fallback (safe no-op on desktop).
     */
    public static function stopAll():Void {
        #if js
        try {
            untyped __js__('(function(){' +
                'var vids=document.querySelectorAll("video");' +
                'for(var i=0;i<vids.length;i++){ try{ vids[i].pause(); vids[i].parentNode.removeChild(vids[i]); } catch(e){} }' +
                '})()');
        } catch (e:Dynamic) {
            // ignore
        }
        #else
        // Desktop: if you keep handles to native players, stop them here.
        #end
    }
}
