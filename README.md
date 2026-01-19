# CineTrack

Aplicación iOS para explorar y gestionar tus películas favoritas usando la API de The Movie Database (TMDB).

## Requisitos

- iOS 15.0+
- Xcode 14.0+
- API Key de TMDB

## Configuración

### 1. Obtener API Key de TMDB

1. Visita [https://www.themoviedb.org/](https://www.themoviedb.org/)
2. Crea una cuenta o inicia sesión
3. Ve a Configuración → API
4. Solicita una API Key
5. Copia tu API Key

### 2. Configurar la API Key en el proyecto

Abre el archivo `Services/TMDBService.swift` y reemplaza:

```swift
private let apiKey = "TU_API_KEY_AQUI"
```

con tu API Key real:

```swift
private let apiKey = "tu_api_key_aqui"
```

## Estructura del Proyecto

```
CineTrack/
├── Models/
│   ├── Movie.swift              # Modelo de datos de películas
│   └── UserPreference.swift     # Preferencias del usuario
├── Services/
│   └── TMDBService.swift        # Servicio para consumir la API
├── ViewModels/
│   └── MovieViewModel.swift     # ViewModel para gestión de estado
├── Views/
│   ├── ExplorarView.swift       # Vista principal (Explorar)
│   ├── DetailView.swift         # Vista de detalle de película
│   ├── BuscarView.swift         # Vista de búsqueda
│   └── FavoritosView.swift      # Vista de favoritos
├── CineTrackApp.swift           # Punto de entrada de la app
├── ContentView.swift            # Vista principal con navegación
└── Assets.xcassets/             # Recursos gráficos
```

## Funcionalidades

- ✅ Explorar películas populares
- ✅ Buscar películas
- ✅ Ver detalles completos de películas
- ✅ Marcar películas como favoritas
- ✅ Gestionar lista de favoritos

## Instalación en Xcode

1. Abre Xcode
2. Crea un nuevo proyecto iOS → App
3. Nombre: `CineTrack`
4. Interface: SwiftUI
5. Language: Swift
6. Deployment Target: iOS 15.0
7. Reemplaza los archivos generados con los archivos de este proyecto
8. Añade los archivos a tu proyecto arrastrándolos a Xcode
9. Configura tu API Key como se indica arriba
10. Ejecuta el proyecto (⌘R)

## Notas

- Las imágenes se cargan de forma asíncrona desde TMDB
- Los favoritos se almacenan en memoria (se perderán al cerrar la app)
- La búsqueda se realiza en tiempo real mientras escribes
