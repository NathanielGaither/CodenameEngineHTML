package funkin.backend.system;

import utils.FileSystemSafe;

#if sys
// This file is only intended to show a localized replacement example for fixWorkingDirectory usage.
#end

class FixWorkingDirectoryBridge {
    public static function fixWorkingDirectoryBridge():Void {
        #if windows
        if (!Main.noCwdFix && !FileSystemSafe.readDirectory('manifest').length) {
            Sys.setCwd(haxe.io.Path.directory(Sys.programPath()));
        }
        #end
    }
}
