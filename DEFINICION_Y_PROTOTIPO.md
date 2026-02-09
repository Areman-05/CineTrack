# CineTrack – Definición y prototipo (con mejoras de la profesora)

## 1. Descripción general

- **Nombre:** CineTrack  
- **Descripción:** App para organizar contenido pendiente (películas y series), explorar tendencias, ver detalles (reparto, sinopsis, puntuaciones) y gestionar una lista de Favoritos. Dirigida a usuarios que consumen streaming; catálogo unificado donde marcar qué ver y consultar información.

---

## 2. API y datos

- **API:** TMDB – https://www.themoviedb.org/documentation/api  
- **Uso:** Listado de populares al iniciar, detalles por título, búsqueda.  
- **Errores:** Alert si no hay conexión; Empty State si no hay resultados; ProgressView durante la carga.

---

## 3. Modelo de datos (mejorado según feedback)

### Distinción película / serie
- Se distingue el tipo de contenido con la propiedad **`mediaType`** en el modelo (valor `movie` o `tv`), para mostrar “Película” o “Serie” en la UI.

### Estado de visualización
- **UserPreference** incluye **`watchStatus`** con tres estados: **“Previsto ver”**, **“Viendo”**, **“Visto”**, para que el usuario pueda marcar en qué estado está cada título.

### Favoritos y nota personal
- **UserPreference** tiene **`isFavorite: Bool`** y **`personalNote: String`** (por película/serie, asociado por `id`).

### Modelo enriquecido
- **Movie:** id, title, overview, posterPath, voteAverage, releaseDate, **mediaType** (movie/tv).  
- **UserPreference:** isFavorite, personalNote, **watchStatus** (previsto ver / viendo / visto).  
- **Structs adicionales:** **MovieResponse** (results), **Genre** (id, name), **MovieDetail** (con géneros).

---

## 4. Prototipo de pantallas

### MainView (Explorar / Inicio)
- **Distribución:** NavigationView con ScrollView de tarjetas verticales. TabView inferior con “Inicio” y “Favoritos”.  
- **Elementos:** Lista de películas/series con imagen, título y puntuación (estrellas).  
- **Interacción:** Scroll para ver tendencias; toque en un elemento navega al detalle.

### DetailView (Detalle)
- **Distribución:** Imagen de cabecera, título en negrita, sinopsis.  
- **Elementos:** Botón de corazón (favoritos), label de género, opción de estado (previsto ver / viendo / visto) y nota personal.  
- **Interacción:** Leer info; marcar favorita (corazón relleno/vacío); cambiar estado y editar nota.

### SearchView (Buscador)
- **Distribución:** Barra de búsqueda superior y lista de resultados.  
- **Elementos:** TextField de búsqueda y botón “Limpiar”.  
- **Interacción:** Al escribir, la lista se actualiza en tiempo real (API).  
- **Extra (mejora):** Filtros por **título**, **puntuación** y **género** para obtener mejor puntuación en la entrega 2.

### Favoritos (pantalla explícita)
- **Distribución:** Tab “Favoritos” en el TabView; pantalla con lista de títulos guardados por el usuario.  
- **Elementos:** Lista de películas/series marcadas como favoritas, con imagen, título, puntuación y estado (previsto ver / viendo / visto).  
- **Interacción:** Toque en un elemento abre el detalle; desde detalle o desde la lista se puede quitar de favoritos o editar nota/estado.

---

## 5. CRUD (recomendación para entrega 2)

- **Crear:** Añadir a favoritos / a “mi lista”.  
- **Leer:** Ver listado (Explorar, Favoritos) y detalle.  
- **Actualizar:** Cambiar estado (previsto ver / viendo / visto) y editar nota personal.  
- **Eliminar:** Quitar de favoritos / de la lista.  

Los commits se harán por funcionalidad, con mensajes en español y simples.

---

## 6. Extra

- **Extra elegido:** Búsqueda de información.  
- **Ampliación:** No solo por título; también por **puntuación** y **género** (y otros criterios que se implementen) para mejorar la nota en la entrega 2.
