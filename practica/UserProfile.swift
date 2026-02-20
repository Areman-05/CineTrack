import Foundation

/// Perfil de usuario local (nombre, contraseña). Persistido en UserDefaults / Keychain.
struct UserProfile {
    var displayName: String
    var hasPassword: Bool
    var isLoggedIn: Bool

    static let defaultProfile = UserProfile(displayName: "", hasPassword: false, isLoggedIn: false)
}

/// Almacén del perfil: guardar/cargar y comprobar contraseña.
final class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile

    private let nameKey = "cineTrack.userName"
    private let hasPasswordKey = "cineTrack.hasPassword"
    private let isLoggedInKey = "cineTrack.isLoggedIn"
    private let passwordKey = "cineTrack.password"

    init() {
        let name = UserDefaults.standard.string(forKey: nameKey) ?? ""
        let hasPassword = UserDefaults.standard.bool(forKey: hasPasswordKey)
        let isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        profile = UserProfile(displayName: name, hasPassword: hasPassword, isLoggedIn: isLoggedIn)
    }

    func createAccount(name: String, password: String) {
        profile.displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.hasPassword = true
        profile.isLoggedIn = true
        UserDefaults.standard.set(profile.displayName, forKey: nameKey)
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

    func setPassword(_ password: String) {
        profile.hasPassword = true
        profile.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: hasPasswordKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
    }
}
