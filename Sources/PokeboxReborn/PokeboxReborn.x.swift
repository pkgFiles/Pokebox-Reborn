import Orion
import PokeboxRebornC

//Pokébox Reborn - Pokémon style notifications
//Rewrite for modern iOS 15.0 - 16.7.5
//based on original from @Skittyblock: https://github.com/Skittyblock/Pokebox
//MARK: - Variables
var tweakPrefs: SettingsModel = SettingsModel()
var isVelvetInstalled: Bool = false

// MARK: - Enums
enum PokeboxStyle {
    case defaultStyle, lightStyle, darkStyle
    
    static func getStyle() -> PokeboxStyle {
        switch tweakPrefs.style {
        case 0: return .defaultStyle
        case 1: return .lightStyle
        case 2: return .darkStyle
        default: break
        }
        
        return .defaultStyle
    }
}

enum PokeboxFont {
    case defaultFont, pokemonFont, silkscreenFont
    
    static func getFont() -> PokeboxFont {
        switch tweakPrefs.font {
        case 0: return .defaultFont
        case 1: return .pokemonFont
        case 2: return .silkscreenFont
        default: break
        }
        
        return .silkscreenFont
    }
}

// MARK: - Initialize Tweak
struct TweakEnabled: HookGroup { let isTweakEnabled: Bool }
struct PokeboxReborn: Tweak {
    init() {
        remLog("Preferences Loading...")
        tweakPrefs = TweakPreferences.preferences.loadPreferences()
        
        let pokeboxTweak = TweakEnabled(isTweakEnabled: tweakPrefs.isEnabled)
        if pokeboxTweak.isTweakEnabled {
            remLog("Tweak is Enabled! :)")
            pokeboxTweak.activate()
        } else {
            remLog("Tweak is Disabled! :(")
        }
    }
}

// MARK: - Hooks
class NCNotificationHook: ClassHook<NCNotificationShortLookViewController> {
    typealias Group = TweakEnabled
    @Property var backgroundImageView: UIImageView?
    @Property var backgroundColorView: UIView?
    @Property var originalSecondaryText: NSString?
    @Property var animationTimers: (background: Timer?, text: Timer?)
    
    func viewDidLoad() {
        orig.viewDidLoad()
        
        if !FileManager().fileExists(atPath: defaultDylibPath + "Velvet2.dylib") {
            //Create alternative background view if Velvet2 is not installed
            if self.backgroundColorView == nil {
                backgroundColorView = UIView(frame: target.viewForPreview.backgroundMaterialView.frame)
                backgroundColorView?.backgroundColor = headerViewColor()
                target.viewForPreview.insertSubview(backgroundColorView!, at: 0)
            }
        } else { isVelvetInstalled = true }
    }
    
    func viewDidLayoutSubviews() {
        orig.viewDidLayoutSubviews()
                
        //Hide the original view with it's shadow
        target.viewForPreview.backgroundMaterialView.isHidden = true
        target.viewForPreview.hasShadow = false
        
        //Background Image
        if self.backgroundImageView == nil {
            backgroundImageView = UIImageView(frame: target.viewForPreview.bounds)
            backgroundImageView?.image = getImageForStyle(defaultAssetsPath).resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 100, bottom: 20, right: 100), resizingMode: .stretch)
            target.viewForPreview.insertSubview(backgroundImageView!, at: 1)
        }
        
        if let pokeImageView = backgroundImageView {
            pokeImageView.frame = target.viewForPreview.bounds
            backgroundColorView?.frame = CGRect(x: 5, y: 5, width: pokeImageView.bounds.width - 10, height: pokeImageView.bounds.height - 10)
            target.viewForPreview.backgroundMaterialView.frame = CGRect(x: 5, y: 5, width: pokeImageView.bounds.width - 10, height: pokeImageView.bounds.height - 10)
            if tweakPrefs.style != 0 { colorFilteredLabels() }
        }
    }
    
    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        
        if target.delegate != nil && target.delegate.isKind(of: SBNotificationBannerDestination.self) {
            if tweakPrefs.isAnimationEnabled {
                //Hide the original notification text
                originalSecondaryText = target.viewForPreview.secondaryText ?? ""
                target.viewForPreview.secondaryText = " "
                
                animationTimers.background = Timer.scheduledTimer(timeInterval: 0, target: target, selector: #selector(setBoundsWhileAnimating(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)
        
        if target.delegate != nil && target.delegate.isKind(of: SBNotificationBannerDestination.self) {
            if tweakPrefs.isAnimationEnabled && target.viewForPreview.secondaryText != nil {
                //Animate text
                let newText = originalSecondaryText ?? ""
                target.viewForPreview.secondaryText = NSString.localizedStringWithFormat("%C", newText.character(at: 0))
                
                let dict: NSMutableDictionary = [:]
                dict.setValue(newText, forKey: "string")
                dict.setValue(0, forKey: "currentCount")
                
                animationTimers.text = Timer.scheduledTimer(timeInterval: Double(tweakPrefs.animationSpeed).rounded(toPlaces: 2), target: target, selector: #selector(animateText(_:)), userInfo: dict, repeats: true)
            }
        }
    }
    
    func viewDidDisappear(_ animated: Bool) {
        orig.viewDidDisappear(animated)
        
        animationTimers.background?.invalidate()
        animationTimers.text?.invalidate()
        animationTimers = (background: nil, text: nil)
    }
    
    //orion:new
    func colorFilteredLabels() {
        //Some UILabels attributes can't be changed, even trying to modify NSAttributedStringKey fails.
        //It seems that @Skitty has hooked for that reason the UILabel class, which is not an really good idea.
        //This is my way to fix all the colors of the Labels.
        guard let notificationContentView: NCNotificationSeamlessContentView = target.viewForPreview.value(forKey: "_notificationContentView") as? NCNotificationSeamlessContentView else { return }
        
        if let dateLabel: UILabel = notificationContentView.value(forKey: "_dateLabel") as? UILabel {
            dateLabel.layer.filters = nil
            dateLabel.textColor = UIColor.gray
        }
        
        if let importantTextLabel: UILabel = notificationContentView.value(forKey: "_importantTextLabel") as? UILabel {
            importantTextLabel.layer.filters = nil
            importantTextLabel.textColor = UIColor.gray
        }
    }
    
    //orion:new
    func animateText(_ timer: Timer) {
        guard let dict: NSMutableDictionary = timer.userInfo as? NSMutableDictionary else { timer.invalidate(); return }
        guard let string: NSString = dict.value(forKey: "string") as? NSString else { timer.invalidate(); return }
        guard let countValue: Int = dict.value(forKey: "currentCount") as? Int else { timer.invalidate(); return }
        
        if tweakPrefs.isAnimationEnabled && target.viewForPreview.secondaryText != nil {
            //Animate text like Pokémon
            var currentCount: Int = countValue
            currentCount += 1
            dict.setValue(currentCount, forKey: "currentCount")
            
            if currentCount > string.length {
                timer.invalidate()
                target.viewForPreview.secondaryText = string
                return
            }
            target.viewForPreview.secondaryText = string.substring(to: currentCount) as NSString
        } else {
            target.viewForPreview.secondaryText = string
        }
    }
    
    //orion:new
    func setBoundsWhileAnimating(_ timer: Timer) {
        guard let pokeImageView = backgroundImageView else { timer.invalidate(); return }
        guard let notificationContentView: NCNotificationSeamlessContentView = target.viewForPreview.value(forKey: "_notificationContentView") as? NCNotificationSeamlessContentView else { timer.invalidate(); return }
        guard let crossfadingContentView = notificationContentView.value(forKey: "_crossfadingContentView") as? UIView else { timer.invalidate(); return }
        
        if !(originalSecondaryText == target.viewForPreview.secondaryText) {
            //Always change the frame of the @property backgroundImageView
            pokeImageView.frame = crossfadingContentView.bounds
            
            //change the frame of the @property backgroundColorView and the Velvet2 layer
            if let colorView = backgroundColorView {
                colorView.frame = CGRect(x: 5, y: 5, width: pokeImageView.bounds.width - 10, height: pokeImageView.bounds.height - 10)
            } else {
                guard let backgroundMaterialSuperview = target.viewForPreview.backgroundMaterialView.superview else { return }
                for subview in backgroundMaterialSuperview.subviews {
                    if subview.isKind(of: UIView.self) {
                        let origBounds = subview.bounds
                        if subview.frame != origBounds {
                            subview.frame = CGRect(x: 5, y: 5, width: pokeImageView.bounds.width - 10, height: pokeImageView.bounds.height - 10)
                        }
                    }
                }
            }
        } else { timer.invalidate() }
    }
    
    //orion:new
    func getImageForStyle(_ imagePath: String) -> UIImage {
        var imageName: String = ""

        switch PokeboxStyle.getStyle() {
        case .defaultStyle:
            if target.traitCollection.userInterfaceStyle == .light {
                imageName = "Pokeballs-Border.png"
            } else {
                imageName = "Pokeballs-Dark-Border.png"
            }
            
        case .lightStyle: imageName = "Pokeballs-Border.png"
        case .darkStyle: imageName = "Pokeballs-Dark-Border.png"
        }
        
        if let image = UIImage(contentsOfFile: imagePath + imageName) {
            return image
        } else {
            remLog("Fetching image Failed.")
            return UIImage()
        }
    }
    
    //orion:new
    func headerViewColor() -> UIColor {
        switch PokeboxStyle.getStyle() {
        case .defaultStyle:
            if target.traitCollection.userInterfaceStyle == .light {
                return UIColor.white
            } else {
                return UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
            }
        case .lightStyle: return UIColor.white
        case .darkStyle: return UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        }
    }
}

class NCNotificationCornerRadiusHook: ClassHook<NCNotificationShortLookView> {
    typealias Group = TweakEnabled
    
    //This will fix the long press cutting off, of the imageView
    //This is setting up to 5, because 0 looks strange. Might be changed in future to 0 either...
    func _continuousCornerRadius() -> Double {
        return 5
    }
}

class NCNotificationLabelsHook: ClassHook<NCNotificationSeamlessContentView> {
    typealias Group = TweakEnabled
    
    // I'VE DIDN'T FOUND A BETTER FUNCTION TO HOOK!
    func layoutSubviews() {
        orig.layoutSubviews()
        
        if tweakPrefs.isOffsetEnabled {
            Ivars<UILabel>(target)._secondaryTextElement.frame.origin.y += CGFloat(tweakPrefs.offsetValue)
        }
    }
    
    func _textFrameForBounds(_ frame: CGRect) -> CGRect {
        if Ivars<NSObject?>(target)._delegate == nil {
            let primaryTextLabel: UILabel = Ivars<UILabel>(target)._primaryTextLabel
            primaryTextLabel.font = getFontForStyle(CGFloat(tweakPrefs.titleSize))
            
            let primarySubtitleTextLabel: UILabel = Ivars<UILabel>(target)._primarySubtitleTextLabel
            primarySubtitleTextLabel.font = getFontForStyle(CGFloat(tweakPrefs.textSize))
            
            let importantTextLabel: UILabel = Ivars<UILabel>(target)._importantTextLabel
            importantTextLabel.font = getFontForStyle(CGFloat(tweakPrefs.textSize))
            
            let footerTextLabel: UILabel = Ivars<UILabel>(target)._footerTextLabel
            footerTextLabel.font = getFontForStyle(CGFloat(tweakPrefs.textSize))
            
            let dateLabel: UILabel = Ivars<UILabel>(target)._dateLabel
            dateLabel.font = getFontForStyle(12)
            
            let secondaryTextElement: UILabel = Ivars<UILabel>(target)._secondaryTextElement
            secondaryTextElement.font = getFontForStyle(CGFloat(tweakPrefs.textSize))
            
            if !isVelvetInstalled {
                if let newTextColor = setTextColor() {
                    primaryTextLabel.textColor = newTextColor
                    primarySubtitleTextLabel.textColor = newTextColor
                    footerTextLabel.textColor = newTextColor
                    secondaryTextElement.textColor = newTextColor
                }
            }
        }
        return orig._textFrameForBounds(frame).insetBy(dx: 0, dy: 4)
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        let origSize = orig.sizeThatFits(size)
        return CGRect(x: 0, y: 0, width: origSize.width, height: origSize.height).insetBy(dx: 0, dy: -4).size
    }
    
    //orion:new
    func getFontForStyle(_ size: CGFloat) -> UIFont {
        switch PokeboxFont.getFont() {
        case .defaultFont: return UIFont(ttfAtPath: defaultAssetsPath + "silkscreen-bold.ttf", size: size)
        case .pokemonFont: return UIFont(ttfAtPath: defaultAssetsPath + "pokemon.ttf", size: size)
        case .silkscreenFont: return UIFont(ttfAtPath: defaultAssetsPath + "silkscreen.ttf", size: size)
        }
    }
    
    //orion:new
    func setTextColor() -> UIColor? {
        switch tweakPrefs.style {
        case 1: return UIColor.black
        case 2: return UIColor.white
        default: break
        }
        return nil
    }
}
