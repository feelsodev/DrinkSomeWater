import Foundation

enum Environment {
    enum Key: String {
        case apiBaseURL = "API_BASE_URL"
        case admobAppId = "ADMOB_APP_ID"
        case admobBannerId = "ADMOB_BANNER_ID"
        case admobNativeId = "ADMOB_NATIVE_ID"
        case logLevel = "LOG_LEVEL"
        case enableAnalytics = "ENABLE_ANALYTICS"
        case enableDebugMenu = "ENABLE_DEBUG_MENU"
    }
    
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var isTestFlight: Bool {
        guard !isDebug else { return false }
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }
    
    static var apiBaseURL: String {
        value(for: .apiBaseURL) ?? "https://api.drinksomewater.com"
    }
    
    static var admobAppId: String {
        value(for: .admobAppId) ?? ""
    }
    
    static var admobBannerId: String {
        value(for: .admobBannerId) ?? ""
    }
    
    static var admobNativeId: String {
        value(for: .admobNativeId) ?? ""
    }
    
    static var logLevel: String {
        value(for: .logLevel) ?? "error"
    }
    
    static var enableAnalytics: Bool {
        value(for: .enableAnalytics) == "YES"
    }
    
    static var enableDebugMenu: Bool {
        value(for: .enableDebugMenu) == "YES"
    }
    
    private static func value(for key: Key) -> String? {
        Bundle.main.infoDictionary?[key.rawValue] as? String
    }
}
