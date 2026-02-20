import SwiftUI

struct PerfilView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var showCreatePassword = false
    @State private var showLogin = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    if !profileStore.profile.displayName.isEmpty {
                        Text(profileStore.profile.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    HStack(spacing: 16) {
                        VStack {
                            Text("\(viewModel.favoriteMovies.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Favoritos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                        VStack {
                            Text("\(viewModel.favoriteLists.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Listas")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cuenta")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        if !profileStore.profile.hasPassword {
                            Button("Crear contraseña") {
                                showCreatePassword = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else if !profileStore.profile.isLoggedIn {
                            Button("Iniciar sesión") {
                                showLogin = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            Button("Cerrar sesión") {
                                profileStore.logout()
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Perfil")
            .sheet(isPresented: $showCreatePassword) {
                CreatePasswordSheet(profileStore: profileStore)
            }
            .sheet(isPresented: $showLogin) {
                LoginSheet(profileStore: profileStore)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CreatePasswordSheet: View {
    @ObservedObject var profileStore: UserProfileStore
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Nombre (opcional)", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Repetir contraseña", text: $confirm)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Crear contraseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        if password != confirm {
                            errorMessage = "Las contraseñas no coinciden"
                        } else if password.count < 4 {
                            errorMessage = "Mínimo 4 caracteres"
                        } else {
                            profileStore.createAccount(name: name, password: password)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
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
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if showError {
                    Text("Contraseña incorrecta")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
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
                    Button("Entrar") {
                        if profileStore.login(password: password) {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showError = true
                        }
                    }
                    .fontWeight(.semibold)
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
