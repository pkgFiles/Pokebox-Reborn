import Foundation

class TweakPreferences {
    var settings: SettingsModel!
    static let preferences = TweakPreferences()
    
    private var plistPath: String {
        let fileManager = FileManager()
        let plistIdentifier: String = "com.pkgfiles.pokeboxrebornprefs.plist"
        var plistPath: String = "/var/mobile/Library/Preferences/" + plistIdentifier
        
        if !fileManager.fileExists(atPath: "/var/LIY/") && fileManager.fileExists(atPath: "/var/jb/") {
            plistPath = "/var/jb/var/mobile/Library/Preferences/" + plistIdentifier
        }
        
        return plistPath
    }
    
    func createPreferences() {
        let mirror = Mirror(reflecting: SettingsModel())
        var data: [String: Any] = [:]
        
        for child in mirror.children {
            guard let key = child.label else { return }
            data.updateValue(child.value, forKey: key)
        }
        
        let defaultSettings = NSDictionary(dictionary: data)
        defaultSettings.write(toFile: plistPath, atomically: true)
    }
    
    func updatePreferences() {
        guard let plistData: NSDictionary = NSDictionary(contentsOfFile: plistPath) else { return }
        let plistKeys: [String] = plistData.allKeys as! [String]
        let settingsData = SettingsModel().toDictionary()
        
        for i in settingsData {
            if !plistKeys.contains(i.key) {
                remLog("The Key: \(i.key) don't exist! Adding to .plist...")
                plistData.setValue(i.value, forKey: i.key)
                plistData.write(toFile: plistPath, atomically: true)
            }
        }
    }
    
    func loadPreferences() throws {
        if let data = FileManager().contents(atPath: plistPath) {
            do {
                self.settings = try PropertyListDecoder().decode(SettingsModel.self, from: data)
                remLog(self.settings!)
            } catch {
                remLog("Preferences Updating...")
                updatePreferences()
                try loadPreferences()
            }
        } else {
            if !FileManager().fileExists(atPath: plistPath) {
                remLog("Preferences don't exist... Creating...")
                createPreferences()
                try loadPreferences()
            }
        }
    }
}
