import SwiftUI

/// Vista de perfil: datos del usuario, estadísticas, login/logout y crear contraseña.
/// Compatible con iOS 14.4.
struct PerfilView: View {
    var body: some View {
        NavigationView {
            PerfilViewContent()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

/// Contenido del perfil (reutilizable en tab y al hacer push desde Inicio).
struct PerfilViewContent: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @EnvironmentObject private var profileStore: UserProfileStore
    @State private var showCreatePassword = false
    @State private var showLogin = false
    @State private var loginError = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    if !profileStore.profile.displayName.isEmpty {
                        Text(profileStore.profile.displayName)
                            .font(AppTheme.titleMedium)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    statsSection
                    authSection
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCreatePassword) {
            CreatePasswordSheet(profileStore: profileStore)
        }
        .sheet(isPresented: $showLogin) {
            LoginSheet(profileStore: profileStore, error: $loginError)
        }
    }

    private var avatarSection: some View {
        ZStack {
            Circle()
                .fill(AppTheme.surface)
                .frame(width: 88, height: 88)
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(.top, 8)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tu actividad")
                .font(AppTheme.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textTertiary)

            HStack(spacing: 16) {
                statCard(value: "\(viewModel.favoriteMovies.count)", label: "Favoritos")
                statCard(value: "\(viewModel.favoriteLists.count)", label: "Listas")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(AppTheme.titleLarge)
                .foregroundColor(AppTheme.accent)
            Text(label)
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cardCornerRadius)
    }

    @ViewBuilder
    private var authSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cuenta")
                .font(AppTheme.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textTertiary)

            if !profileStore.profile.hasPassword {
                Button(action: { showCreatePassword = true }) {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Crear contraseña")
                            .font(AppTheme.bodyMedium)
                    }
                    .foregroundColor(AppTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
            } else if !profileStore.profile.isLoggedIn {
                Button(action: { showLogin = true }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Iniciar sesión")
                            .font(AppTheme.bodyMedium)
                    }
                    .foregroundColor(AppTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: { profileStore.logout() }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar sesión")
                            .font(AppTheme.bodyMedium)
                    }
                    .foregroundColor(AppTheme.error)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

/// Sheet para crear contraseña (y opcionalmente nombre). Guarda el perfil.
struct CreatePasswordSheet: View {
    @ObservedObject var profileStore: UserProfileStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("Nombre (opcional)", text: $name)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)

                    SecureField("Contraseña", text: $password)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)

                    SecureField("Repetir contraseña", text: $confirm)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)

                    if let msg = errorMessage {
                        Text(msg)
                            .font(AppTheme.caption)
                            .foregroundColor(AppTheme.error)
                    }
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Crear contraseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if password != confirm {
                            errorMessage = "Las contraseñas no coinciden"
                        } else if password.count < 4 {
                            errorMessage = "Mínimo 4 caracteres"
                        } else {
                            profileStore.createAccount(name: name, password: password)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Guardar")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppTheme.accent)
                }
            })
        }
    }
}

/// Sheet para iniciar sesión con contraseña.
struct LoginSheet: View {
    @ObservedObject var profileStore: UserProfileStore
    @Binding var error: Bool
    @Environment(\.presentationMode) private var presentationMode
    @State private var password = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    SecureField("Contraseña", text: $password)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal, 20)
                    if error {
                        Text("Contraseña incorrecta")
                            .font(AppTheme.caption)
                            .foregroundColor(AppTheme.error)
                    }
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("Iniciar sesión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        error = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if profileStore.login(password: password) {
                            error = false
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            error = true
                        }
                    }) {
                        Text("Entrar")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppTheme.accent)
                }
            })
        }
    }
}

#if DEBUG
struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
            .environmentObject(MovieViewModel())
            .environmentObject(UserProfileStore())
    }
}
#endif
