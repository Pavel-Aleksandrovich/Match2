import Foundation

private let key = "match2udkey"

final class UserDefaultsWrapper {
    
    static let shared = UserDefaultsWrapper()
    
    private init() {}
    
    func set(_ string: String) {
        UserDefaults.standard.set(string, forKey: key)
    }
    
    func getString() -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    
}
