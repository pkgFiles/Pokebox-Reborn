import Preferences
import PokeboxRebornPrefsC

extension RootListController {
    
    var prefsAssetsPath: String {
        var path: String = "/var/jb/Library/PreferenceBundles/PokeboxRebornPrefs.bundle/"
        if !FileManager.default.fileExists(atPath: path) {
            path = "/Library/PreferenceBundles/PokeboxRebornPrefs.bundle/"
        }
        
        return path
    }
    
    private var plistPath: String {
        let fileManager = FileManager()
        var plistPath: String = "/var/mobile/Library/Preferences/"
        
        if !fileManager.fileExists(atPath: "/var/LIY/") && fileManager.fileExists(atPath: "/var/jb/") {
            plistPath = "/var/jb/var/mobile/Library/Preferences/"
        }
        
        return plistPath
    }
    
    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            } else {
                let specifiers = loadSpecifiers(fromPlistName: "Root", target: self)
                setValue(specifiers, forKey: "_specifiers")
                return specifiers
            }
        }
        set {
            super.specifiers = newValue
        }
    }
    
    override func readPreferenceValue(_ specifier: PSSpecifier!) -> Any! {
        guard let defaultPath = specifier.properties["defaults"] as? String else {
            return super.readPreferenceValue(specifier)
        }

        let path = "\(plistPath)\(defaultPath).plist"
        let settings = NSDictionary(contentsOfFile: path)

        return settings?[specifier.property(forKey: "key") as Any] ?? specifier.property(forKey: "default")
    }
    
    override func setPreferenceValue(_ value: Any!, specifier: PSSpecifier!) {
        let path = "\(plistPath)\(specifier.properties["defaults"] as! String).plist"
        let prefs = NSMutableDictionary(contentsOfFile:path) ?? NSMutableDictionary()
        
        prefs.setValue(value, forKey: specifier.property(forKey: "key") as! String)
        prefs.write(toFile: path, atomically: true)
    }
}
