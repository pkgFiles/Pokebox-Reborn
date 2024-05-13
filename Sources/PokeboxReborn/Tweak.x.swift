import Orion
import PokeboxRebornC

//Pokébox - Pokémon style notifications
//Rewrite for modern iOS 15.0 - 16.0
//based on original from @Skitty: https://github.com/Skittyblock/Pokebox
//MARK: - Variables
let tweakPrefs: SettingsModel = TweakPreferences.preferences.settings

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
struct LoadingTweak: Tweak {
    
    init() {
        do {
            remLog("Preferences Loading...")
            try TweakPreferences.preferences.loadPreferences()
        } catch let error as NSError {
            remLog(error.localizedDescription)
            return
        }
        
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
    @Property var originalSecondaryText: NSString?

    func viewDidLayoutSubviews() {
        orig.viewDidLayoutSubviews()
        
        //Hide the original view with it's shadow
        target.viewForPreview.backgroundMaterialView.isHidden = true
        target.viewForPreview.hasShadow = false
        
        //Background Image
        if self.backgroundImageView == nil {
            backgroundImageView = UIImageView(frame: target.viewForPreview.bounds)
            backgroundImageView?.image = getImageForStyle(defaultAssetsPath).resizableImage(withCapInsets: UIEdgeInsets(top: 35, left: 100, bottom: 35, right: 100), resizingMode: .stretch)
            target.viewForPreview.insertSubview(backgroundImageView!, at: 0)
        }
        
        if let pokeImageView = backgroundImageView {
            if #unavailable(iOS 16.0), tweakPrefs.isOffsetEnabled { target.viewForPreview.frame.size.height += CGFloat(tweakPrefs.offsetValue) }
            pokeImageView.frame = target.viewForPreview.bounds
        }
    }
    
    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        
        if target.delegate != nil && target.delegate.isKind(of: SBNotificationBannerDestination.self) {
            if tweakPrefs.isAnimationEnabled {
                //Hide the original notification text
                originalSecondaryText = target.viewForPreview.secondaryText ?? ""
                target.viewForPreview.secondaryText = " "
                
                /*
                var padText: NSString = " "
                for i in 0...target.viewForPreview.secondaryText.length {
                    if target.viewForPreview.secondaryText.utf8String?[i] == CChar("\n") {
                        padText = NSString.localizedStringWithFormat("%@\n", padText)
                    } else {
                        padText = NSString.localizedStringWithFormat("%@⠀", padText)
                    }
                }
                */
            }
        }
    }
    
    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)
        
        if target.delegate != nil && target.delegate.isKind(of: SBNotificationBannerDestination.self) {
            if tweakPrefs.isAnimationEnabled {
                //Animate text
                let newText = originalSecondaryText ?? ""
                target.viewForPreview.secondaryText = NSString.localizedStringWithFormat("%C", newText.character(at: 0))
                
                let dict: NSMutableDictionary = [:]
                dict.setValue(newText, forKey: "string")
                dict.setValue(0, forKey: "currentCount")
                
                let timer: Timer = Timer.scheduledTimer(timeInterval: Double(tweakPrefs.animationSpeed).rounded(toPlaces: 2), target: target, selector: #selector(animateText(_:)), userInfo: dict, repeats: true)
                timer.fire()
            }
        }
    }
    
    //orion:new
    func animateText(_ timer: Timer) {
        guard let dict: NSMutableDictionary = timer.userInfo as? NSMutableDictionary else { return }
        guard let string: NSString = dict.value(forKey: "string") as? NSString else { return }
        guard let countValue: Int = dict.value(forKey: "currentCount") as? Int else { return }
        
        if tweakPrefs.isAnimationEnabled {
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
    func getImageForStyle(_ imagePath: String) -> UIImage {
        var imageName: String = ""
     
        switch PokeboxStyle.getStyle() {
        case .defaultStyle:
            if target.traitCollection.userInterfaceStyle == .light {
                imageName = "Pokeballs.png"
            } else {
                imageName = "Pokeballs-Dark.png"
            }
            
        case .lightStyle: imageName = "Pokeballs.png"
        case .darkStyle: imageName = "Pokeballs-Dark.png"
        }
        
        if let image = UIImage(contentsOfFile: imagePath + imageName) {
            return image
        } else {
            remLog("Fetching image Failed.")
            return UIImage()
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
    @Property var alternateDateLabel: UILabel?
    @Property var alternateImportantTextLabel: UILabel?
    
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
            
            if let newTextColor = setTextColor() {
                primaryTextLabel.textColor = newTextColor
                primarySubtitleTextLabel.textColor = newTextColor
                footerTextLabel.textColor = newTextColor
                secondaryTextElement.textColor = newTextColor
            }
            
            if tweakPrefs.style != 0 {
                createAlternativeLabels()
            }
        }
        
        return orig._textFrameForBounds(frame)
    }
    
    //orion:new
    func createAlternativeLabels() {
        //Some UILabels attributes can't be changed, even trying to modify NSAttributedStringKey fails.
        //It seems that @Skitty has hooked for that reason the UILabel class, which is not an really good idea.
        //This is my way to fix all the colors of the Labels.
        
        //Get the original Labels with its attributes:
        let dateLabel: UILabel = Ivars<UILabel>(target)._dateLabel
        let importantTextLabel: UILabel = Ivars<UILabel>(target)._importantTextLabel
        
        //Setup alternativeLabels
        if self.alternateDateLabel == nil {
            alternateDateLabel = initAlternateLabel(origFrame: dateLabel.frame)
        }
        
        if self.alternateImportantTextLabel == nil {
            alternateImportantTextLabel = initAlternateLabel(origFrame: importantTextLabel.frame)
        }
        
        alternateDateLabel?.frame = dateLabel.frame
        alternateImportantTextLabel?.frame = importantTextLabel.frame
        
        alternateDateLabel?.text = dateLabel.text
        alternateImportantTextLabel?.text = importantTextLabel.text
        
        alternateDateLabel?.font = dateLabel.font
        alternateImportantTextLabel?.font = importantTextLabel.font
        
        /*
         let badgedIconView: UIView = Ivars<UIView>(target)._badgedIconView
         
         if self.alternateBadgedIconView == nil {
             alternateBadgedIconView = UIImageView(frame: badgedIconView.frame)
             target.addSubview(alternateBadgedIconView!)
         }
         
         alternateBadgedIconView?.frame = badgedIconView.frame
         alternateBadgedIconView?.image = badgedIconView.asImage()
         alternateBadgedIconView?.frame.origin.y = badgedIconView.frame.origin.y + CGFloat(tweakPrefs.offsetValue / 2)
         
         badgedIconView.removeFromSuperview()
        */
        
        //Remove original Labels from Superview
        dateLabel.removeFromSuperview()
        importantTextLabel.removeFromSuperview()
    }
    
    //orion:new
    func initAlternateLabel(origFrame: CGRect) -> UILabel {
        let label = UILabel(frame: origFrame)
        label.textColor = UIColor.gray
        target.addSubview(label)
        
        return label
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
