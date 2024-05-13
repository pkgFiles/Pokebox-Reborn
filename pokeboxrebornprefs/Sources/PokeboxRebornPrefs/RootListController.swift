import Preferences
import CoreGraphics
import PokeboxRebornPrefsC

class RootListController: PSListController, UNUserNotificationCenterDelegate {
    
    let pokeView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 225))
    let pokeImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let pokeTitleLabel: UILabel = UILabel().createLabelWithFontPath(text: "Pokebox Reborn", fontSize: 38)
    let pokeSubtitleLabel: UILabel = UILabel().createLabelWithFontPath(text: "by @pkgFiles", fontSize: 22)

    override init(forContentSize contentSize: CGSize) {
        super.init(forContentSize: contentSize)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill"), style: .plain, target: self, action: #selector(respringDevice))
        
        //pokeView
        pokeView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
        
        //pokeImage
        if let pokeImage = UIImage(contentsOfFile: prefsAssetsPath + "pikachu.png") {
            pokeImageView.image = pokeImage
            pokeImageView.contentMode = .scaleAspectFit
            pokeImageView.translatesAutoresizingMaskIntoConstraints = false
            pokeView.addSubview(pokeImageView)
        }
        
        //pokeLabels
        pokeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pokeSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pokeView.addSubview(pokeTitleLabel)
        pokeView.addSubview(pokeSubtitleLabel)
        
        NSLayoutConstraint.activate([
            pokeTitleLabel.topAnchor.constraint(equalTo: pokeView.topAnchor, constant: (pokeView.frame.height / 2) - 20),
            pokeTitleLabel.leadingAnchor.constraint(equalTo: pokeView.leadingAnchor),
            pokeTitleLabel.trailingAnchor.constraint(equalTo: pokeView.trailingAnchor),
            pokeTitleLabel.heightAnchor.constraint(equalToConstant: 25),
            pokeSubtitleLabel.topAnchor.constraint(equalTo: pokeTitleLabel.topAnchor, constant: 50),
            pokeSubtitleLabel.leadingAnchor.constraint(equalTo: pokeView.leadingAnchor),
            pokeSubtitleLabel.trailingAnchor.constraint(equalTo: pokeView.trailingAnchor),
            pokeSubtitleLabel.heightAnchor.constraint(equalToConstant: 25),
            pokeImageView.trailingAnchor.constraint(equalTo: pokeView.trailingAnchor, constant: -75),
            pokeImageView.bottomAnchor.constraint(equalTo: pokeView.bottomAnchor, constant: 5),
            pokeImageView.heightAnchor.constraint(equalToConstant: 31),
            pokeImageView.widthAnchor.constraint(equalToConstant: 48)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavBarThemed(enabled: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavBarThemed(enabled: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .light {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    //MARK: - Actions
    @objc func testNotification() {
        remLog("Test Notification")
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "Pokebox"
        content.body = "Testing your notifications!"
        content.badge = 0

        let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request: UNNotificationRequest = UNNotificationRequest(identifier: "com.pkgfiles.pokeboxrebornprefs.notify", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @objc func respringDevice() {
        respring()
    }
    
    //MARK: - Functions
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner])
        }
    }
    
    func setNavBarThemed(enabled isEnabled: Bool) {
        if #available(iOS 13.0, *) {
            guard let bar: UINavigationBar = self.navigationController?.navigationController?.navigationBar else { return }
            let appearance = UINavigationBarAppearance()
            
            if isEnabled {
                // NavigationBar background color
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
                appearance.shadowColor = UIColor.clear
                
                // NavigationBar icon
                let imagePath: String = prefsAssetsPath + "icon.png"
                let iconView = UIImageView(frame: CGRect(x: bar.frame.maxX / 2, y: bar.frame.maxY / 2, width: 29, height: 29))
                iconView.image = UIImage(contentsOfFile: imagePath)
                navigationItem.titleView = iconView
                
                bar.isTranslucent = false
                bar.tintColor = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
                bar.standardAppearance = appearance
                bar.scrollEdgeAppearance = appearance
            } else {
                bar.isTranslucent = true
                bar.tintColor = UINavigationBar.appearance().tintColor
                bar.standardAppearance = UINavigationBar.appearance().standardAppearance
                bar.scrollEdgeAppearance = UINavigationBar.appearance().scrollEdgeAppearance
            }
            
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    //MARK: - TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableHeaderView = pokeView
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    //MARK: - Required
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
