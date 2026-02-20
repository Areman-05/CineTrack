# CineTrack

App iOS para buscar películas, explorar tendencias, gestionar favoritos y listas personalizadas. Consume la API de The Movie Database (TMDB).

- **Requisitos:** Xcode, iOS 14.4+
- **Entrega:** Proyecto en Xcode + videotour demostrativo.

---

## Instrucciones

1. Clonar el repositorio o descargar el proyecto.
2. Abrir `practica.xcodeproj` en Xcode.
3. Seleccionar un simulador o dispositivo (iPhone) y ejecutar (⌘R).
4. La API de TMDB se usa con una API key incluida en el proyecto; no es necesario configurar nada para probar.

---

## Arquitectura MVVM

- **Models:** `Movie`, `MovieResponse`, `Genre`, `GenreListResponse`, `FavoriteList`, `UserPreference`, `UserProfile`. Coherentes con la API de TMDB y con la lógica de favoritos/listas.
- **ViewModels:** `MovieViewModel` (`ObservableObject`) centraliza estados (`@Published`), llamadas al servicio TMDB, persistencia en UserDefaults, favoritos, listas y preferencias por película. `UserProfileStore` gestiona perfil y sesión.
- **Views:** Solo presentación y binding; sin lógica de negocio. Usan `@EnvironmentObject` para el ViewModel y `@State` para estado local de la UI.
- **Servicios:** `TMDBService` (singleton) encapsula URLSession y peticiones a la API (búsqueda, descubrir, populares, géneros).
- **Organización:** Carpetas `Views/`, `ViewModels/`, `Services/` y modelos en la raíz del target; código modular y separación clara de responsabilidades.

---

## Navegación y pantallas

- **TabView** con 4 pestañas: Inicio (buscador), Explorar, Favoritos, Perfil.
- **NavigationView** en cada tab y en pantallas de detalle; presentaciones modales con `.sheet` (Nueva lista, Añadir a lista, Login).
- Pantallas: Buscador (Inicio), Explorar, Favoritos, Perfil, Detalle de película, Detalle de lista. Diseño con paleta `AppTheme` (tema oscuro).
- Orientaciones portrait y landscape soportadas; tema fijado a oscuro con `preferredColorScheme(.dark)` (coherente con el diseño tipo cine).

---

## Consumo de API y manejo de errores

- **URLSession** en `TMDBService`: `fetchPopularMovies`, `searchMovies`, `discoverMovies`, `fetchMovieGenres`.
- Datos mostrados en **List** y **ScrollView** (búsqueda, explorar, favoritos, listas).
- **Errores:** `TMDBError` con `LocalizedError`; mensajes mostrados en UI (por ejemplo en Buscador y Explorar con `errorMessage` / `exploreErrorMessage` y botón Reintentar).
- **Estados de carga:** `ProgressView` mientras se buscan o cargan películas; estados vacíos con mensajes claros (“No tienes favoritos”, “Usa los filtros y pulsa Buscar”, etc.).

---

## CRUD sobre la colección

- **Consultar:** Búsqueda con filtros (puntuación, género), explorar populares, listar favoritos y películas por lista.
- **Añadir:** Añadir película a favoritos (corazón), crear lista (Nueva lista), añadir película a una lista (Añadir a lista); validación de nombre no vacío al crear lista.
- **Editar:** Estado de visualización (Por ver / Viendo / Visto) y nota personal en el detalle de cada película; persistido en UserDefaults.
- **Eliminar:** Quitar de favoritos (swipe o botón), eliminar película de una lista (swipe en ListaDetailView), eliminar lista (swipe o menú contextual “Eliminar lista”).
- **Duplicidad:** No se añade la misma película dos veces a una lista (`list.movieIds.contains`); `savedMovies` y listas se mantienen coherentes.

---

## Extra implementado

Se cubren varios aspectos valorables como extra:

1. **Persistencia:** UserDefaults para preferencias por película (`UserPreference`: favorito, nota, estado), películas guardadas (`savedMovies`), listas de favoritos (`favoriteLists`) y perfil (nombre, contraseña, sesión). Se guarda y recupera al abrir la app.
2. **Búsqueda y filtrado:** Buscador con texto, puntuación mínima y género; integración con `discoverMovies` y `searchMovies` de TMDB; resultados en lista sin duplicados innecesarios.
3. **Pantalla de preferencias / perfil:** Perfil con estadísticas (favoritos, listas), inicio/cierre de sesión y nombre de usuario persistido; opciones aplicadas en la app.

---

## Gestión de assets

- **AppIcon:** AppIcon.appiconset configurado con las resoluciones necesarias para iPhone, iPad y marketing. Hay que añadir las imágenes correspondientes a cada tamaño en el catálogo de assets.
- **Display Name:** Definido en `Info.plist` como `CFBundleDisplayName: CineTrack` para que el nombre visible en el dispositivo sea “CineTrack”.
- **Paleta:** Colores y tipografía centralizados en `AppTheme` (Swift); se usa `AccentColor.colorset` en el proyecto. La paleta de la aplicación está definida y aplicada de forma consistente en las vistas.

---

## Buenas prácticas

- Nombres en lowerCamelCase (variables/funciones) y UpperCamelCase (tipos); tipado explícito y optionals manejados correctamente.
- Constantes para claves de UserDefaults y URLs en el servicio; modificadores de acceso (`private` donde corresponde).
- Comentarios en partes clave (MARK, cabeceras de modelos y servicios); indentación y formato coherentes.
- Estructura en grupos: Views, ViewModels, Services y modelos identificables.

---

## Videotour

Videotour demostrativo (máximo 5 minutos) publicado en YouTube (modo oculto):

**[ENLACE AL VIDEOTOUR AQUÍ]**

En el videotour se muestra: navegación (tabs, detalle, modales), colección y detalle, CRUD completo (añadir/quitar favoritos, listas, editar nota/estado), extra (persistencia, búsqueda/filtros, perfil) y, si aplica, cambio a portrait/landscape y tema.

---

## Repositorio

- Proyecto entregado vía GitHub Classroom y Sallenet.
- Commits con mensajes descriptivos de los cambios realizados.
