import UIKit

let defaultAssetsPath: String = {
    var path: String = "/var/jb/Library/Application Support/Pokebox/"
    if !FileManager.default.fileExists(atPath: path) {
        path = "/Library/Application Support/Pokebox/"
    }
    
    return path
}()

let defaultDylibPath: String = {
    var path: String = "/var/jb/Library/MobileSubstrate/DynamicLibraries/"
    if !FileManager.default.fileExists(atPath: path, isDirectory: UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)) {
        path = "/Library/MobileSubstrate/DynamicLibraries/"
    }
    
    return path
}()

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
