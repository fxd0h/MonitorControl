import Cocoa
import MASPreferences
import os.log
import ServiceManagement

class MainPrefsViewController: NSViewController, MASPreferencesViewController {
  var viewIdentifier: String = "Main"
  var toolbarItemLabel: String? = NSLocalizedString("General", comment: "Shown in the main prefs window")
  var toolbarItemImage: NSImage? = NSImage(named: NSImage.preferencesGeneralName)
  let prefs = UserDefaults.standard

  @IBOutlet var versionLabel: NSTextField!
  @IBOutlet var startAtLogin: NSButton!
  @IBOutlet var showContrastSlider: NSButton!
  @IBOutlet var lowerContrast: NSButton!
  @IBOutlet var showRGBSlider: NSButton!
  
  @available(macOS, deprecated: 10.10)
  override func viewDidLoad() {
    super.viewDidLoad()

    let startAtLogin = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])?.first { $0["Label"] as? String == "\(Bundle.main.bundleIdentifier!)Helper" }?["OnDemand"] as? Bool ?? false

    self.startAtLogin.state = startAtLogin ? .on : .off
    self.showContrastSlider.state = self.prefs.bool(forKey: Utils.PrefKeys.showContrast.rawValue) ? .on : .off
    self.lowerContrast.state = self.prefs.bool(forKey: Utils.PrefKeys.lowerContrast.rawValue) ? .on : .off
    self.showRGBSlider.state = self.prefs.bool(forKey: Utils.PrefKeys.showRGB.rawValue) ? .on : .off
    self.setVersionNumber()
  }

  @IBAction func startAtLoginClicked(_ sender: NSButton) {
    let identifier = "\(Bundle.main.bundleIdentifier!)Helper" as CFString

    switch sender.state {
    case .on:
      SMLoginItemSetEnabled(identifier, true)
    case .off:
      SMLoginItemSetEnabled(identifier, false)
    default: break
    }

    #if DEBUG
      os_log("Toggle start at login state: %{public}@", type: .info, sender.state == .on ? "on" : "off")
    #endif
  }

  @IBAction func showContrastSliderClicked(_ sender: NSButton) {
    switch sender.state {
    case .on:
      self.prefs.set(true, forKey: Utils.PrefKeys.showContrast.rawValue)
    case .off:
      self.prefs.set(false, forKey: Utils.PrefKeys.showContrast.rawValue)
    default: break
    }

    #if DEBUG
      os_log("Toggle show contrast slider state: %{public}@", type: .info, sender.state == .on ? "on" : "off")
    #endif

    NotificationCenter.default.post(name: Notification.Name(Utils.PrefKeys.showContrast.rawValue), object: nil)
  }

  @IBAction func showRGBSliderClicked(_ sender: NSButton) {
    switch sender.state {
    case .on:
      self.prefs.set(true, forKey: Utils.PrefKeys.showRGB.rawValue)
    case .off:
      self.prefs.set(false, forKey: Utils.PrefKeys.showRGB.rawValue)
    default: break
    }
    
    #if DEBUG
    os_log("Toggle show RGB slider state: %{public}@", type: .info, sender.state == .on ? "on" : "off")
    #endif
    
    NotificationCenter.default.post(name: Notification.Name(Utils.PrefKeys.showRGB.rawValue), object: nil)
  }

  
  
  @IBAction func lowerContrastClicked(_ sender: NSButton) {
    switch sender.state {
    case .on:
      self.prefs.set(true, forKey: Utils.PrefKeys.lowerContrast.rawValue)
    case .off:
      self.prefs.set(false, forKey: Utils.PrefKeys.lowerContrast.rawValue)
    default: break
    }

    #if DEBUG
      os_log("Toggle lower contrast after brightness state: %{public}@", type: .info, sender.state == .on ? "on" : "off")
    #endif
  }

  fileprivate func setVersionNumber() {
    let versionName = NSLocalizedString("Version", comment: "Version")
    let buildName = NSLocalizedString("Build", comment: "Build")
    let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "error"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "error"
    self.versionLabel.stringValue = "\(versionName) \(versionNumber) (\(buildName) \(buildNumber)) (fxd0h RGB fix)"
  }
}
