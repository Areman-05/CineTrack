import Foundation

// MARK: - Perfil de usuario

struct UserProfile {
    var displayName: String = ""
    var hasPassword: Bool = false
    var isLoggedIn: Bool = false
}

// MARK: - Store del perfil (ObservableObject)

final class UserProfileStore: ObservableObject {
    @Published var profile = UserProfile()

    private let nameKey = "userName"
    private let hasPasswordKey = "hasPassword"
    private let isLoggedInKey = "isLoggedIn"
    private let passwordKey = "userPassword"

    init() {
        profile.displayName = UserDefaults.standard.string(forKey: nameKey) ?? ""
        profile.hasPassword = UserDefaults.standard.bool(forKey: hasPasswordKey)
        profile.isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
    }

    func createAccount(name: String, password: String) {
        profile.displayName = name
        profile.hasPassword = true
        profile.isLoggedIn = true
        UserDefaults.standard.set(name, forKey: nameKey)
        UserDefaults.standard.set(true, forKey: hasPasswordKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
    }

    func login(password: String) -> Bool {
        let stored = UserDefaults.standard.string(forKey: passwordKey) ?? ""
        if stored == password {
            profile.isLoggedIn = true
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
            return true
        }
        return false
    }

    func logout() {
        profile.isLoggedIn = false
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
    }
}
