# Seminari 9: API REST para el BackOffice de Flutter

Backoffice adaptado a **Flutter** y Dart para el **Seminario 9 de EA**. Es la versión de Flutter del backoffice que antes hicimos en React Native: usa **la misma API REST** (`EA-Seminari9-Flutter-API`) y dispone de las pantallas de gestión de autores y libros (listar, buscar en tiempo real, crear, editar y borrar autores y libros, vista en lista o tarjetas, permisos de hardware/cámara y pantalla explicativa de teoría).

Incluye además la solución completa al ejercicio del campo **Editorial (`publisher`)**.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.x (comprueba la instalación con `flutter doctor`).
- [Node.js](https://nodejs.org/) 22 o superior, para el backend.
- [MongoDB](https://www.mongodb.com/), local o en Atlas, para el backend.
- El backend arrancado (carpeta `EA-Seminari9-Flutter-API`, en el puerto 1337).

## Cómo arrancarlo

Hacen falta dos terminales: una para la API y otra para Flutter.

**1. Backend (API)**

```bash
git clone https://github.com/elpunyal/EA-Seminari9-Flutter-API
cd EA-Seminari9-Flutter-API
npm install
cp .env.example .env
npm run seed
npm run dev
```

La API queda disponible en `http://localhost:1337` (y en `http://10.0.2.2:1337` para emuladores Android).

**2. Frontend (Flutter)**

```bash
git clone https://github.com/elpunyal/EA-Seminari9-Flutter
cd EA-Seminari9-Flutter
flutter pub get
flutter run -d chrome   # Para probar directamente en el navegador
# o
flutter run             # Para probar en emulador Android/iOS o móvil conectado por USB
```

Si el proyecto no trae las carpetas de plataforma (`android/`, `ios/`, `web/`), se generan con:

```bash
flutter create --platforms=android,ios,web .
```

## Configuración de Red

La URL de la API se gestiona automáticamente según la plataforma en `lib/config/environment.dart`:
- En **Android Emulator**, redirige automáticamente a `http://10.0.2.2:1337`.
- En **iOS Simulator, Web y escritorio**, utiliza `http://localhost:1337`.
- Para usar otra dirección (por ejemplo, un móvil real en tu red): `flutter run --dart-define=API_URL=http://192.168.1.10:1337`.

## Permisos nativos

- **Android** (`android/app/src/main/AndroidManifest.xml`): permisos `INTERNET` y `CAMERA`, y `android:usesCleartextTraffic="true"` porque la API va por `http`.
- **iOS** (`ios/Runner/Info.plist`): `NSCameraUsageDescription` y `NSPhotoLibraryUsageDescription`.

## Estructura del proyecto

```
lib/
├── main.dart                 punto de entrada: providers y rutas con nombre (GetX)
├── config/environment.dart   URL de la API según la plataforma
├── models/                   Author y Book (con fromJson y toJson)
├── services/                 http_client, author_service, book_service, permissions_service
├── providers/                BooksProvider y AuthorsProvider (estado de los datos, Provider)
├── controllers/              estado de cada pantalla (GetX): formularios, detalles, buscador, pestañas y permisos
├── utils/format.dart         formato de fechas, precios, removeEmpty...
├── theme/app_colors.dart     colores de la app
├── widgets/                  tarjetas, buscador, diálogos, campos...
└── screens/                  las pantallas
```

## Estado y navegación

- **Provider** (`providers/`): guarda los libros y autores que vienen de la API y los comparten varias pantallas.
- **GetX** (`controllers/`): guarda el estado de cada pantalla (`.obs` y `Obx`) y se encarga de las rutas, los diálogos y los avisos.
- No se usa `setState` en ninguna pantalla.

## Rutas (GetX)

| Ruta | Pantalla | Fichero |
|---|---|---|
| `/` | Pestañas: Libros, Autores, Permisos y Teoría | `screens/home_screen.dart` |
| `/books/new` | Nuevo Libro | `screens/book_form_screen.dart` |
| `/books/:id` | Detalle Libro | `screens/book_detail_screen.dart` |
| `/books/:id/edit` | Editar Libro | `screens/book_form_screen.dart` |
| `/authors/new` | Nuevo Autor | `screens/author_form_screen.dart` |
| `/authors/:id` | Detalle Autor | `screens/author_detail_screen.dart` |
| `/authors/:id/edit` | Editar Autor | `screens/author_form_screen.dart` |

## Pantallas

| Pantalla | Fichero | Descripción |
|---|---|---|
| Libros | `screens/books_screen.dart` | Catálogo de libros con buscador en tiempo real (título, ISBN, descripción, **editorial**), pull-to-refresh y vista lista/tarjetas. |
| Nuevo / Editar Libro | `screens/book_form_screen.dart` | Formulario de libro con campo editorial (`publisher`), precarga al editar y selección de foto con cámara/galería (permisos nativos). |
| Detalle Libro | `screens/book_detail_screen.dart` | Vista de detalle de portada grande, editorial, autores, tags y precio. |
| Autores | `screens/authors_screen.dart` | Listado con buscador, pull-to-refresh, edición y diálogo de borrado. |
| Nuevo / Editar Autor | `screens/author_form_screen.dart` | Formulario con roles, estado activo y foto de perfil. |
| Detalle Autor | `screens/author_detail_screen.dart` | Información del autor, biografía y estado. |
| Permisos Nativos | `screens/permissions_screen.dart` | Demostrador interactivo de permisos de Cámara y Galería (`permissions_service.dart`). |
| Teoría & Comparativa | `screens/info_screen.dart` | 15 apartados de Flutter: multiplataforma, Dart, widgets, estado, rutas, renderizado, etc. |

## Comprobar el proyecto

```bash
flutter analyze   # busca errores en el código
flutter test      # ejecuta los tests de formato y de serialización (fromJson / toJson)
```

## Documentación de Cambios

Para consultar el informe completo de cambios con explicaciones y líneas de código modificadas:
- Ver [SEMINARI9_FLUTTER.md](SEMINARI9_FLUTTER.md) (qué se ha cambiado y por qué)
- Ver [SEMINARI9_CODIGO_RN_A_FLUTTER.md](SEMINARI9_CODIGO_RN_A_FLUTTER.md) (código de React Native y su equivalente en Flutter)
