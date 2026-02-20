import SwiftUI

/// Pantalla de bienvenida con logo "CineTrack" y barra de carga.
/// Compatible con iOS 14.4.
struct SplashView: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text("CineTrack")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .tracking(1.2)

                Text("Tus películas y series")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.textSecondary)

                Spacer()

                VStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.surface)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.accent)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 48)

                    Text("Cargando...")
                        .font(AppTheme.caption)
                        .foregroundColor(AppTheme.textTertiary)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8)) {
                progress = 1.0
            }
        }
    }
}

#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
#endif
