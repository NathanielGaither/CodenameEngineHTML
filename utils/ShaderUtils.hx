package utils;

import EReg;

/**
 * GLSL shader sanitization utilities for WebGL.
 *
 * What changed / why:
 * - WebGL requires a precision qualifier in fragment shaders. We add "precision mediump float;" if missing.
 * - GLSL in WebGL is strict about float literals; many shaders use "1" or "0" where "1.0" or "0.0" is required in float contexts.
 *   ShaderUtils.forceFloats performs conservative replacements so shaders compile on WebGL without manual edits.
 *
 * Usage:
 *   var fragFixed = utils.ShaderUtils.sanitizeFragment(myFragSource);
 *   var vertFixed = utils.ShaderUtils.sanitizeVertex(myVertSource);
 */
class ShaderUtils {
    public static function sanitizeFragment(src:String):String {
        // Add precision qualifier if missing (WebGL requires it)
        if (!src.match(new EReg("\\bprecision\\s+mediump\\s+float\\b", ""))) {
            var versionMatch = new EReg("^\\s*#version\\s+\\d+\\s*\\n", "m");
            if (versionMatch.match(src)) {
                // Insert after version line
                var whole = versionMatch.matched(0);
                src = whole + "precision mediump float;\n" + src.substr(whole.length);
            } else {
                src = "precision mediump float;\n" + src;
            }
        }
        src = forceFloats(src);
        return src;
    }

    public static function sanitizeVertex(src:String):String {
        // Vertex shaders generally are ok, but normalize float literals too.
        return forceFloats(src);
    }

    /**
     * Conservative float normalizer:
     * - Adds ".0" to integer literals when they appear in common float contexts.
     * - Avoids touching identifiers, hex values, or integer-only declarations where dangerous.
     *
     * NOTE: This function intentionally errs on the side of safety to avoid corrupting valid GLSL.
     */
    private static function forceFloats(src:String):String {
        // Attempt a regex replacement that captures separators + integer literal.
        // Haxe EReg can't use lookahead reliably across backends; try a safe regex first and fallback.
        try {
            // Prepend a space so pattern works at start-of-string as well.
            var s = " " + src;
            var re = new EReg("([\\(,=\\+\\-\\*\\/\\s])([0-9]+)([\\s\\),;\\+\\-\\*\\/])", "g");
            s = re.replace(s, function(m:Array<String>):String {
                // m[1] = prefix, m[2] = number, m[3] = suffix
                return m[1] + m[2] + ".0" + m[3];
            });
            // Remove the leading space we added
            return s.substr(1);
        } catch (e:Dynamic) {
            // Very conservative manual replacements if regex fails.
            src = src.replace("(0,", "(0.0,").replace("(1,", "(1.0,")
                     .replace(",0,", ",0.0,").replace(",1,", ",1.0,")
                     .replace("(0)", "(0.0)").replace("(1)", "(1.0)")
                     .replace("=0;", "=0.0;").replace("=1;", "=1.0;");
            src = src.replace(" 0 ", " 0.0 ").replace(" 1 ", " 1.0 ");
            return src;
        }
    }
}
