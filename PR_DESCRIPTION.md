PR: html5: wrap sys.* and native video, add WebGL shader sanitizers for HTML5 compatibility

This PR adds cross-platform utility wrappers and conservative automated replacements to improve HTML5/WebGL compatibility.

What I added:
- utils/FileSystemSafe.hx: wraps sys.io.File and sys.FileSystem calls and provides Assets fallbacks for HTML5.
- utils/AssetSafe.hx: safe asset resolution and 1x1 BitmapData fallback.
- utils/VideoPlayer.hx: guards native video playback; provides HTML5 <video> fallback.
- utils/ShaderUtils.hx: inserts precision qualifiers and normalizes float literals for WebGL shaders.
- tools/generate_assets_manifest.js: optional manifest generator to emulate Assets.list() on older OpenFL.
- tools/refactor_wrappers.py: conservative replacement script to update code to use wrappers (.bak files are created for changed files).

Planned code replacements performed by the script (manual review recommended):
- sys.io.File.getContent(...) -> utils.FileSystemSafe.readText(...)
- sys.io.File.getBytes(...) -> utils.FileSystemSafe.readBytes(...)
- sys.io.File.saveContent(...) -> utils.FileSystemSafe.writeText(...)
- sys.FileSystem.readDirectory(...) -> utils.FileSystemSafe.readDirectory(...)
- sys.FileSystem.exists(...) -> utils.AssetSafe.exists(...)
- Assets.getBitmapData(...) -> utils.AssetSafe.getBitmapDataSafe(...)
- hxCodec.play(...) / hxvlc.play(...) -> utils.VideoPlayer.play(...)
- Wrap WebGL shader uploads with ShaderUtils.sanitizeFragment/Vertex where applicable.

Notes:
- Automated replacements should be reviewed, especially shader uploads and any multi-line/complex usages. The script creates ".bak" backups.
- I did not force replacements for ambiguous shader cases; please search for gl.shaderSource usages and apply ShaderUtils manually if needed.

Test checklist (run locally):
- Build desktop and verify native behaviors unchanged.
- Build HTML5, verify no sys.* runtime errors, assets load, shaders compile, and video fallback behaves gracefully.

If you want, I can run the refactor script on this branch and commit the modified files; otherwise you can run the script locally to review changes first.
