import UIKit

struct SettingsModel: DictionaryConvertor, Codable {
    var isEnabled: Bool = false
    var isAnimationEnabled: Bool = true
    var style: Int = 0
    var font: Int = 2
    var titleSize: Int = 14
    var textSize: Int = 14
    var animationSpeed: Float = 0.10
    var isOffsetEnabled: Bool = false
    var offsetValue: Int = 4
}
