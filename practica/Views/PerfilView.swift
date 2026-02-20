import SwiftUI

struct PerfilView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var showLogin = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    ZStack {
                        Circle()
                            .fill(AppTheme.surface)
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding(.top)

                    if !profileStore.profile.displayName.isEmpty {
                        Text(profileStore.profile.displayName)
                            .font(AppTheme.titleMedium)
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    HStack(spacing: 16) {
                        VStack {
                            Text("\(viewModel.favoriteMovies.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                            Text("Favoritos")
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)

                        VStack {
                            Text("\(viewModel.favoriteLists.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                            Text("Listas")
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                    }
                    .padding(.horizontal)

                    if profileStore.profile.hasPassword {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cuenta")
                                .font(AppTheme.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textTertiary)
                                .padding(.horizontal)

                            if !profileStore.profile.isLoggedIn {
                                Button("Iniciar sesión") {
                                    showLogin = true
                                }
                                .font(AppTheme.bodyMedium)
                                .foregroundColor(AppTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(AppTheme.cardCornerRadius)
                                .padding(.horizontal)
                            } else {
                                Button("Cerrar sesión") {
                                    profileStore.logout()
                                }
                                .font(AppTheme.bodyMedium)
                                .foregroundColor(AppTheme.error)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(AppTheme.cardCornerRadius)
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer()
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Perfil")
            .sheet(isPresented: $showLogin) {
                LoginSheet(profileStore: profileStore)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginSheet: View {
    @ObservedObject var profileStore: UserProfileStore
    @Environment(\.presentationMode) var presentationMode
    @State private var password = ""
    @State private var showError = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(AppTheme.surface)
                    .foregroundColor(AppTheme.textPrimary)
                    .cornerRadius(AppTheme.posterCornerRadius)

                if showError {
                    Text("Contraseña incorrecta")
                        .foregroundColor(AppTheme.error)
                        .font(AppTheme.caption)
                }

                Spacer()
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Iniciar sesión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        showError = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if profileStore.login(password: password) {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showError = true
                        }
                    }) {
                        Text("Entrar").fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
            .environmentObject(MovieViewModel())
            .environmentObject(UserProfileStore())
    }
}
