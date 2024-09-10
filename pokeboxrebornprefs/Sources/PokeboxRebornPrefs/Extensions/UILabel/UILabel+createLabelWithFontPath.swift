import UIKit

let defaultAssetsPath: String = {
    var path: String = "/var/jb/Library/Application Support/Pokebox/"
    if !FileManager.default.fileExists(atPath: path) {
        path = "/Library/Application Support/Pokebox/"
    }
    
    return path
}()

extension UILabel {
    func createLabelWithFontPath(text: String, fontSize: CGFloat) -> UILabel {
        let ttfName: String = "silkscreen.ttf"
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.text = text
        label.font = UIFont(ttfAtPath: defaultAssetsPath + ttfName, size: fontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
        
        return label
    }
}
