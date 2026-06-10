import Foundation

private var bundleKey: UInt8 = 0

extension Bundle {
    
    private static var _bundle: Bundle? {
        get {
            return objc_getAssociatedObject(self, &bundleKey) as? Bundle
        }
        set {
            objc_setAssociatedObject(self, &bundleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            _bundle = nil
            return
        }
        _bundle = Bundle(path: path)
    }
    
    static func localizedString(for key: String) -> String {
        guard let bundle = _bundle else {
            return NSLocalizedString(key, comment: "")
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

func L10n(_ key: String) -> String {
    return Bundle.localizedString(for: key)
}
