# CineTrack

App iOS para buscar películas, explorar tendencias, gestionar favoritos y listas personalizadas. Consume la API de The Movie Database (TMDB).

- **Requisitos:** Xcode, iOS 14.4+
- **Entrega:** Proyecto en Xcode + videotour demostrativo.

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
- **Estados de carga:** `ProgressView` mientras se buscan o cargan películas; estados vacíos con mensajes claros ("No tienes favoritos", "Usa los filtros y pulsa Buscar", etc.).

---

## CRUD sobre la colección

- **Consultar:** Búsqueda con filtros (puntuación, género), explorar populares, listar favoritos y películas por lista.
- **Añadir:** Añadir película a favoritos (corazón), crear lista (Nueva lista), añadir película a una lista (Añadir a lista); validación de nombre no vacío al crear lista.
- **Editar:** Estado de visualización (Por ver / Viendo / Visto) y nota personal en el detalle de cada película; persistido en UserDefaults.
- **Eliminar:** Quitar de favoritos (swipe o botón), eliminar película de una lista (swipe en ListaDetailView), eliminar lista (swipe o menú contextual "Eliminar lista").
- **Duplicidad:** No se añade la misma película dos veces a una lista (`list.movieIds.contains`); `savedMovies` y listas se mantienen coherentes.

---

## Videotour

Videotour demostrativo publicado en YouTube:

https://www.youtube.com/watch?v=e7q-YO0JXnk

En el videotour se muestra: navegación (tabs, detalle, modales), colección y detalle, CRUD completo (añadir/quitar favoritos, listas, editar nota/estado), persistencia, búsqueda/filtros, perfil y cambio a portrait/landscape y tema.

---

## Autores

Hecho por Pablo Arenas Mancebo y Mateo Acha Sanchez
