# Seminari 9 — Plan para adaptar el proyecto Flutter a la hoja

> **Estado: HECHO.** Este documento era el plan previo; ya está aplicado en el código. Lo que se hizo y cómo quedó está en [SEMINARI9_FLUTTER.md](SEMINARI9_FLUTTER.md) (sección 11) y en [SEMINARI9_CODIGO_RN_A_FLUTTER.md](SEMINARI9_CODIGO_RN_A_FLUTTER.md).
>
> Cambios respecto al plan: se usaron las respuestas por defecto (X roja = "no es la forma principal", Provider para los datos y GetX para el estado de pantalla, `setState` eliminado y pantalla Teoría ampliada). Durante las pruebas aparecieron dos fallos que no estaban en el plan (los autores como ids al crear un libro y `Get.back()` cerrando el aviso), explicados en la sección 8 del documento de código. Lo de Skia se comprobó con la documentación oficial: iOS y Android (API 29+) usan Impeller y la web sigue usando Skia.

> Texto original del plan:

La hoja es el guion de temas de Flutter. Aquí pongo **todos los puntos de la hoja**, cómo está ahora el proyecto y qué cambiaría.

---

## 0. Qué dice la hoja (mi transcripción)

```
* Flutter  (Otras repeticiones ✗)
 - multiplataforma                      ✓
 - Dart + detalles                      ✓ Obj  ✓ Serialización  ✓ async/await  ✓ Future   null safety
 - Install                              ✓
 - Widget / tot.                        Stateless / Full ✓    Tree / Estructura / Scaffold ✓    Style ✓
 - Proyecto                             pubspec.yaml · lib/ · main()
 - Navegación  Push / Pop               ✓ ✗(roja)
 - Routing     GetX                     ✓ ✗(roja)
 - Estado      setState ✗(roja) · Provider ✓ · GetX ✓
 - Renderizado / (multi tachado)        Skia ✓ · multiplataforma
```

**Cómo lo interpreto:** lo que lleva ✓ hay que cubrirlo; lo que lleva ✗ roja no es la forma principal de hacerlo. Por eso **el estado pasa a Provider y GetX** y **`setState` deja de usarse**. Si la X roja significa otra cosa, hay que avisarme y cambio el plan (ver sección 9).

---

## 1. Resumen: qué cambia y qué no

| Tema de la hoja | Ahora | Cambio previsto | Tamaño |
|---|---|---|---|
| Multiplataforma | Funciona, poco explicado | Explicarlo en Teoría y `.md` | Pequeño |
| Dart: objetos | Clases `Author` y `Book` | Explicarlo | Pequeño |
| Dart: serialización | Solo `fromJson` | Añadir `toJson` y usarlo | Pequeño |
| Dart: async/await, Future | En todo el código, sin explicar | Explicarlo en Teoría | Pequeño |
| Dart: null safety | En el código, sin explicar | Explicarlo en Teoría | Pequeño |
| Install | Solo mi instalación | Añadir pasos de instalación | Pequeño |
| Stateless / Stateful | Explicado | Ajustar (ver estado) | Pequeño |
| Tree / Estructura / Scaffold | `Scaffold` usado, no explicado | Explicarlo | Pequeño |
| Style | `ThemeData` y `AppColors`, no explicado | Explicarlo | Pequeño |
| Proyecto (pubspec, lib, main) | Parcial | Explicarlo completo | Pequeño |
| Navegación Push/Pop | `Navigator.push/pop` | Pasa a GetX, se explica como base | **Grande** |
| Routing GetX | No existe | `GetMaterialApp` + rutas con nombre | **Grande** |
| Estado: `setState` | Es lo único que uso | **Se elimina** | **Grande** |
| Estado: Provider | No existe | Estado de libros y autores | **Grande** |
| Estado: GetX | No existe | Controladores de formularios y UI | **Grande** |
| Renderizado (Skia) | No mencionado | Explicarlo en Teoría | Pequeño |

Lo "Grande" toca casi todas las pantallas. Lo "Pequeño" es sobre todo texto y alguna función suelta.

---

## 2. Multiplataforma ✓

- **Ahora:** hay carpetas `android/`, `ios/` y `web/`. Se probó en web. En la pantalla Teoría el apartado 1 lo cita; en los `.md` casi no.
- **Cambiaría:**
  - En `info_screen.dart`, ampliar el apartado 1: un código, tres plataformas (Android, iOS, web), y escritorio con `flutter create --platforms=...`.
  - En `SEMINARI9_FLUTTER.md`, una sección corta con qué plataformas se han generado y cuál se ha probado.
  - En el README, una línea con las plataformas.

---

## 3. Dart + detalles

### 3.1. Objetos ✓
- **Ahora:** `lib/models/author.dart` y `book.dart` son clases con campos `final` y constructor.
- **Cambiaría:** explicarlo en Teoría (clase, constructor con `required`, campos `final`, `factory`) con un ejemplo corto de `Book`.

### 3.2. Serialización ✓
- **Ahora:** solo se convierte JSON → objeto con `fromJson`. Para enviar, los formularios arman un `Map` a mano.
- **Cambiaría:**
  - Añadir `toJson()` en `Author` y `Book`.
  - Que `book_service.dart` y `author_service.dart` reciban el objeto y usen `toJson()` al enviar.
  - Explicar los dos sentidos (`fromJson` / `toJson`) en Teoría.
- **Cuidado:** hoy `removeEmpty` quita los campos vacíos antes de enviar; `toJson` debe seguir haciéndolo (la API da error 422 con campos en blanco).

### 3.3. async/await y Future ✓
- **Ahora:** todos los servicios devuelven `Future` y las pantallas usan `await`.
- **Cambiaría:** apartado nuevo en Teoría con un ejemplo real (`getBooks`) y la comparación con `Promise` de JavaScript.

### 3.4. Null safety
- **Ahora:** se usa (`String?`, `??`, `?.`, `!`) pero no se explica.
- **Cambiaría:** apartado nuevo en Teoría: qué significa `String?`, `??`, `?.` y `!`, con ejemplos del propio proyecto (`book.publisher ?? ''`).

---

## 4. Install ✓

- **Ahora:** el `.md` solo cuenta mi instalación (`~/development/flutter`).
- **Cambiaría:** en el README y en `SEMINARI9_FLUTTER.md`, pasos para instalar Flutter desde cero en Linux (clonar el SDK `stable`, añadirlo al `PATH`, `flutter doctor`), más el enlace a la guía oficial.

---

## 5. Widget / todo

### 5.1. Stateless / Stateful ✓
- **Ahora:** explicado en Teoría; hoy las pantallas usan `StatefulWidget` + `setState`.
- **Cambiaría:** al quitar `setState` (sección 8), las pantallas pasan a `StatelessWidget` + `Obx`/`Consumer`. Se explica la diferencia con ejemplos *antes y después*.

### 5.2. Tree / Estructura / Scaffold ✓
- **Ahora:** `Scaffold` en 9 pantallas, sin explicar.
- **Cambiaría:** un apartado con el árbol de una pantalla real (`Scaffold` → `AppBar` + `body` → `Column` → …) y para qué sirve cada pieza (`Scaffold`, `AppBar`, `body`, `bottomNavigationBar`).

### 5.3. Style ✓
- **Ahora:** `ThemeData` en `main.dart` y colores en `theme/app_colors.dart`.
- **Cambiaría:** explicarlo: tema global (`ThemeData`) frente a estilo del propio widget (`TextStyle`, `BoxDecoration`, `EdgeInsets`) y por qué ya no existe un `StyleSheet`.

---

## 6. Proyecto: `pubspec.yaml`, `lib/`, `main()`

- **Ahora:** `pubspec` y `lib/` salen en `SEMINARI9_FLUTTER.md`; `main()` solo está como comentario en el código.
- **Cambiaría:** apartado con los tres:
  - `pubspec.yaml`: nombre, SDK, dependencias (`http`, `image_picker`, `permission_handler` y las nuevas).
  - `lib/`: estructura de carpetas (con `providers/` y `controllers/` nuevas).
  - `main()` → `runApp()` y el widget raíz.

---

## 7. Navegación Push / Pop y Routing con GetX

- **Ahora:** `Navigator.push(context, MaterialPageRoute(...))` y `Navigator.pop(context)`. El `id` viaja por el constructor. No hay rutas con nombre.
- **Cambiaría:**
  1. Añadir el paquete `get` al `pubspec.yaml`.
  2. En `main.dart`, `MaterialApp` pasa a **`GetMaterialApp`** con `getPages`.
  3. Rutas con los mismos nombres que en Expo Router:

     | Ruta | Pantalla |
     |---|---|
     | `/` | `HomeScreen` (pestañas) |
     | `/books/new` | `BookFormScreen` |
     | `/books/:id` | `BookDetailScreen` |
     | `/books/:id/edit` | `BookFormScreen` (editar) |
     | `/authors/new` | `AuthorFormScreen` |
     | `/authors/:id` | `AuthorDetailScreen` |
     | `/authors/:id/edit` | `AuthorFormScreen` (editar) |

  4. `Navigator.push(...)` → `Get.toNamed('/books/new')`; `Navigator.pop(context)` → `Get.back()`. El `id` se lee con `Get.parameters['id']`.
  5. Los diálogos y avisos (`showDialog`, `showToast`) pasan a `Get.defaultDialog` y `Get.snackbar`; así ya no hace falta pasar `context`.
  6. Push/Pop se **sigue explicando** en Teoría como la base: `Get.toNamed` es `push` y `Get.back` es `pop`.
- **Efecto secundario bueno:** desaparecen casi todos los `if (!mounted) return;` y los avisos `use_build_context_synchronously`, porque ya no se usa `context` después de un `await`.

---

## 8. Estado: `setState` ✗ → Provider ✓ y GetX ✓

La hoja marca los dos. Para no mezclarlos al azar, propongo este reparto:

| Qué | Con qué | Por qué |
|---|---|---|
| Datos que comparten varias pantallas: lista de libros y de autores, carga, error, borrar | **Provider** | Es estado "de la app": la lista y el detalle lo leen y los formularios lo modifican. |
| Estado de una pantalla: formularios (autores/etiquetas elegidos, `guardando`, foto), pestaña activa, vista lista/tarjetas, permisos | **GetX** (controladores + `Obx`) | Es estado "local" de la pantalla, y GetX evita los `setState`. |

### 8.1. Provider
- Añadir `provider` al `pubspec.yaml`.
- Archivos nuevos:
  - `lib/providers/books_provider.dart`: `ChangeNotifier` con `books`, `loading`, `error`, `loadBooks()`, `deleteBook()`.
  - `lib/providers/authors_provider.dart`: igual para autores.
- `main.dart`: `MultiProvider` envolviendo la app.
- `books_screen.dart` y `authors_screen.dart`: quitan `_books`, `_loading`, `_error` y los `setState`; leen con `context.watch<BooksProvider>()`.
- Al crear/editar/borrar, el provider recarga y la lista se actualiza sola, así que **desaparece el `_loadBooks()` tras volver de la pantalla**.

### 8.2. GetX
- Archivos nuevos en `lib/controllers/`:
  - `home_controller.dart` (pestaña activa),
  - `book_form_controller.dart` y `author_form_controller.dart` (valores elegidos, `saving`, `error`, foto),
  - `permissions_controller.dart` (estado de cámara y galería),
  - un controlador (o variables `Rx`) para el modo lista/tarjetas y el texto del buscador.
- Las pantallas pasan a `StatelessWidget`, con `Obx(() => ...)` donde antes había `setState`.
- Los `TextEditingController` de los formularios se quedan en el controlador y se liberan en `onClose()`.

### 8.3. Pantallas afectadas

| Fichero | Cambio |
|---|---|
| `main.dart` | `GetMaterialApp` + `MultiProvider` |
| `screens/home_screen.dart` | `Obx` + `HomeController` |
| `screens/books_screen.dart`, `authors_screen.dart` | Provider + GetX; sin `setState` |
| `screens/book_detail_screen.dart`, `author_detail_screen.dart` | Cargan con Provider o un controlador; sin `setState` |
| `screens/book_form_screen.dart`, `author_form_screen.dart` | Controlador GetX; sin `setState` |
| `screens/permissions_screen.dart` | `PermissionsController` |
| `services/permissions_service.dart` | Sin cambios de fondo; el estado pasa al controlador |
| `widgets/*` | Casi sin cambios (callbacks y navegación se adaptan) |

---

## 9. Renderizado ✓ (Skia / multiplataforma)

- **Ahora:** no se menciona en ningún sitio.
- **Cambiaría:** apartado en Teoría y en `.md` explicando que Flutter **dibuja él mismo cada píxel** en vez de usar componentes nativos del sistema:
  - Motor gráfico: **Skia** (el que aparece en la hoja).
  - Dato a comprobar antes de escribirlo: en las versiones recientes de Flutter, Android e iOS usan **Impeller** como motor nuevo en lugar de Skia, y en web se usa CanvasKit (basado en Skia). Lo verificaré en la documentación oficial antes de ponerlo, para no escribir algo desfasado.
  - Comparación con React Native, que usa los componentes nativos del sistema: por eso la app se ve igual en Android, iOS y web.

---

## 10. Cambios en documentos

| Documento | Cambio |
|---|---|
| `lib/screens/info_screen.dart` (Teoría) | Pasa de 7 apartados a unos 14: multiplataforma, Dart (objetos, serialización, async/Future, null safety), widgets (Stateless/Stateful, árbol/Scaffold, estilo), proyecto, navegación y routing, estado (Provider y GetX), renderizado |
| `SEMINARI9_FLUTTER.md` | Actualizar la sección 5 (cambios de comportamiento) y la 7 (dependencias), que hoy dicen que **no** uso paquetes de estado ni de navegación |
| `SEMINARI9_CODIGO_RN_A_FLUTTER.md` | Regenerar casi entero: cambian las pantallas, los números de línea y los antes y después |
| `README.md` (Flutter) | Instalación, plataformas, estructura nueva y dependencias |
| `EA-Seminari9-Flutter/test/` | Añadir un test sencillo de los providers (opcional) |

---

## 11. Orden de trabajo propuesto

1. Añadir `provider` y `get` al `pubspec.yaml`; comprobar que compilan con esta versión de Flutter (3.47).
2. `main.dart` con `GetMaterialApp`, rutas y `MultiProvider`.
3. Providers de libros y autores.
4. Pantallas de lista (libros y autores).
5. Pantallas de detalle.
6. Formularios con controladores GetX.
7. Pantalla de permisos y pestañas.
8. `toJson` y servicios.
9. Pantalla Teoría y documentos.
10. Probar todo en web con la API (como la primera vez): lista, buscar, crear, editar, borrar, autores, permisos.

---

## 12. Riesgos

- **Versiones:** el paquete `get` y Flutter 3.47 podrían no llevarse bien en alguna versión; lo compruebo en el paso 1 antes de tocar pantallas.
- **Es un cambio grande:** casi todas las pantallas se reescriben, así que repetiré todas las pruebas del navegador.
- **Dos paquetes de estado a la vez:** funciona, pero en un proyecto real suele elegirse uno. Aquí lo justifico en el `.md` porque la hoja pide los dos.
- **Cámara y galería:** no se pueden probar sin móvil o emulador; no cambia respecto a ahora.
- **Los avisos `use_build_context_synchronously`** deberían desaparecer, pero lo confirmo con `flutter analyze`.

---

## 13. Dudas que necesito que me confirmes

1. **¿Qué significa la X roja?** Yo lo he leído como "no es la forma principal": `setState` y `Navigator.push/pop` dejan de usarse en el código, aunque Push/Pop se explique como base.
2. **¿Provider y GetX a la vez**, con el reparto de la sección 8, o prefieres uno solo?
3. **¿Quito del todo `setState`** o dejo alguno en casos mínimos?
4. **¿Hago también los cambios de la pantalla Teoría** para que explique todos los puntos de la hoja?
