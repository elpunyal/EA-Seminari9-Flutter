# Seminari 9 — Flutter

## Cambios: de React Native (Expo) a Flutter

Este documento explica todo lo que he añadido y cambiado al pasar el backoffice de **autores y libros** de React Native a **Flutter**. He dejado el proyecto original sin tocar y he creado uno nuevo en la carpeta `EA-Seminari9-Flutter/`.

> **Estado:** Flutter 3.47 (canal stable) instalado en `~/development/flutter`. La app **compila sin errores** (`flutter analyze` sin avisos, `flutter build web` y 5 tests correctos) y la he probado en el navegador (Chrome) contra la API real con MongoDB. Los resultados están en la sección 10. **No la he probado en un móvil ni emulador** (no hay Android SDK instalado).
>
> **Última versión:** la app se ha adaptado a la **hoja de temas** de Flutter: el estado pasa a **Provider** y **GetX** (ya no hay `setState`), la navegación usa **rutas con nombre de GetX**, se añade `toJson` y la pantalla Teoría explica todos los puntos de la hoja. Está en la sección 11. El plan está en [SEMINARI9_PLAN_HOJA_FLUTTER.md](SEMINARI9_PLAN_HOJA_FLUTTER.md) y el detalle del código en [SEMINARI9_CODIGO_RN_A_FLUTTER.md](SEMINARI9_CODIGO_RN_A_FLUTTER.md).

---

## 1. Qué he hecho (resumen)

- He creado un proyecto nuevo `EA-Seminari9-Flutter/` con la misma funcionalidad que la app de React Native.
- **El backend (`EA-Seminari9-Flutter-API`) no lo he cambiado.** Flutter usa la misma API REST (puerto 1337).
- He portado las 4 pestañas: **Libros, Autores, Permisos y Teoría**.
- He mantenido el campo **Editorial (`publisher`)** del ejercicio: se ve en listado, tarjetas y detalle, se edita en el formulario y el buscador también busca por editorial.
- He puesto comentarios sencillos en el código explicando cada parte y comparándola con React Native.
- **Estado con Provider y GetX** (sin `setState`), **rutas con nombre con GetX** y **serialización con `toJson`**, como pedía la hoja de temas (sección 11).

---

## 2. Estructura del proyecto Flutter

```
EA-Seminari9-Flutter/
├── pubspec.yaml                  (dependencias, como package.json)
└── lib/
    ├── main.dart                 (punto de entrada: providers y rutas)
    ├── config/environment.dart
    ├── models/       author.dart, book.dart              (fromJson y toJson)
    ├── services/     http_client.dart, author_service.dart,
    │                 book_service.dart, permissions_service.dart
    ├── providers/    books_provider.dart, authors_provider.dart     (Provider)
    ├── controllers/  home, books_list, authors_list, book_form, author_form,
    │                 book_detail, author_detail, permissions        (GetX)
    ├── utils/        format.dart
    ├── theme/        app_colors.dart
    ├── widgets/      (componentes reutilizables)
    └── screens/      (pantallas)
```

---

## 3. Equivalencia fichero por fichero

| React Native (original) | Flutter (nuevo) | Qué ha cambiado |
|---|---|---|
| `package.json` | `pubspec.yaml` | Dependencias de Dart: `http`, `image_picker`, `permission_handler`, **`provider`** y **`get`**. |
| `app/_layout.tsx`, `app/index.tsx` | `lib/main.dart` | `runApp(MyApp())`, un `MultiProvider` y un **`GetMaterialApp`** con el tema y las rutas con nombre. |
| `app/(tabs)/_layout.tsx` | `screens/home_screen.dart` + `controllers/home_controller.dart` | Pestañas con `NavigationBar` + `IndexedStack`; la pestaña activa está en GetX. |
| `config/environment.ts` | `config/environment.dart` | Misma lógica (`10.0.2.2` en Android). Se cambia con `--dart-define=API_URL=...`. |
| `models/author.model.ts`, `book.model.ts` | `models/author.dart`, `book.dart` | Clases con `fromJson` **y `toJson`** (en TypeScript bastaba con `interface`). |
| `services/http.ts` | `services/http_client.dart` | `fetch` → paquete `http`. `ApiError` → `ApiException`. |
| `services/author.service.ts`, `book.service.ts` | `services/author_service.dart`, `book_service.dart` | Mismos endpoints (GET, POST, PUT, DELETE). Crear y editar reciben el objeto y usan `toJson`. |
| `utils/format.ts`, `remove-empty.ts`, `api-error.ts` | `utils/format.dart` | Junté las tres cosas en un solo fichero. |
| `hooks/usePermissions.ts` | `services/permissions_service.dart` + `controllers/permissions_controller.dart` | Los hooks no existen en Flutter: el servicio es una clase normal (sin `context`) y el estado está en GetX. |
| `hooks/useForm.ts` | `controllers/book_form_controller.dart`, `author_form_controller.dart` | `Form`, `TextFormField` y `TextEditingController` dentro de un controlador de GetX. |
| `hooks/useApiList.ts` | `providers/books_provider.dart`, `authors_provider.dart` | Un **Provider** (`ChangeNotifier`) con `books`, `loading`, `error`, `loadBooks()` y `deleteBook()`. |
| `context/ToastContext.tsx` | `widgets/toast.dart` | GetX ya trae avisos (`Get.rawSnackbar`), no hace falta un Provider propio ni el `context`. |
| `components/ConfirmModal.tsx` | `widgets/confirm_dialog.dart` | Usa `Get.dialog` / `AlertDialog`. |
| `components/Field.tsx` | `widgets/field_wrapper.dart` | Etiqueta + campo + error. Incluye el estilo común de los inputs. |
| `components/SearchBar.tsx` | `widgets/search_field.dart` | `TextField` con lupa y botón X. |
| `components/ViewToggle.tsx` | `widgets/view_toggle.dart` | Misma idea: lista / tarjetas (`enum ViewMode`). |
| `components/RoleBadge.tsx` | `widgets/role_badge.dart` | Además añadí `ActiveBadge` (Activo/Inactivo). |
| `components/BookCard.tsx` | `widgets/book_card.dart` | Modo lista y modo tarjeta, con editorial. |
| `components/AuthorCard.tsx` | `widgets/author_card.dart` | Modo lista y modo tarjeta. |
| `books/index.tsx` | `screens/books_screen.dart` + `controllers/books_list_controller.dart` | Lista, buscador, pull-to-refresh, borrar. Datos del Provider; buscador y vista de GetX. |
| `books/new.tsx` + `books/[id]/edit.tsx` | `screens/book_form_screen.dart` + `controllers/book_form_controller.dart` | **Unidos en un solo fichero** (ver abajo). La lógica está en el controlador. |
| `books/[id]/index.tsx` | `screens/book_detail_screen.dart` + `controllers/book_detail_controller.dart` | Detalle del libro. |
| `authors/index.tsx` | `screens/authors_screen.dart` | Lista de autores. |
| `authors/new.tsx` + `authors/[id]/edit.tsx` | `screens/author_form_screen.dart` + `controllers/author_form_controller.dart` | **Unidos en un solo fichero**. |
| `authors/[id]/index.tsx` | `screens/author_detail_screen.dart` + `controllers/author_detail_controller.dart` | Detalle del autor. |
| `permissions.tsx` | `screens/permissions_screen.dart` | Demostrador de permisos (estado en `PermissionsController`). |
| `info.tsx` | `screens/info_screen.dart` | Teoría (reescrita: 15 apartados, uno por cada tema de la hoja). |
| — | `widgets/error_banner.dart` | **Nuevo:** el cuadro rojo de error se repetía en todas las pantallas. |
| — | `widgets/photo_picker_section.dart` | **Nuevo:** el bloque de foto con cámara/galería se repetía en los 2 formularios. |
| — | `theme/app_colors.dart` | **Nuevo:** los colores que antes estaban repetidos en los `StyleSheet`. |

---

## 4. Conceptos: cómo se traduce cada cosa

| React Native | Flutter |
|---|---|
| `<View>` | `Container`, `Column`, `Row` |
| `<Text>` | `Text` |
| `<TextInput onChangeText>` | `TextFormField` con `TextEditingController` |
| `<Pressable onPress>` | `GestureDetector(onTap)`, `InkWell`, botones con `onPressed` |
| `<FlatList>` | `ListView.builder` |
| `RefreshControl` | `RefreshIndicator` |
| `<ScrollView>` | `SingleChildScrollView` |
| `<ActivityIndicator>` | `CircularProgressIndicator` |
| `<Switch>` | `Switch` |
| `StyleSheet.create` | Propiedades directas del widget (`padding`, `decoration`...) |
| `useState` | `.obs` + `Obx` (GetX) o `ChangeNotifier` (Provider). Ya no se usa `setState()` |
| `useEffect(() => {}, [])` | `onInit()` del controlador de GetX (o `initState()`) |
| `useMemo` para filtrar | Se calcula dentro del `Obx` |
| `router.push()` / `router.back()` | `Get.toNamed()` / `Get.back()` (antes `Navigator.push()` / `Navigator.pop()`) |
| `Alert.alert` | `Get.dialog` + `AlertDialog` |
| `Ionicons` | `Icons` (vienen con Flutter) |
| `fetch` | paquete `http` |
| `expo-image-picker` | paquete `image_picker` |
| Permisos con `ImagePicker.request...` | paquete `permission_handler` |
| `Context` / hooks de estado compartido | `Provider` (`ChangeNotifier`) |
| Expo Router (rutas por carpetas) | rutas con nombre de GetX (`getPages`) |

---

## 5. Cambios de comportamiento (lo que NO es una copia exacta)

1. **Formularios unidos.** En React Native había `new.tsx` y `edit.tsx` casi idénticos. En Flutter hice una sola pantalla con un parámetro opcional: si recibe `bookId` / `authorId` edita, si no, crea. Así hay menos código repetido.
2. **Navegación.** En lugar de Expo Router (rutas por carpetas) uso **GetX**: las rutas se declaran en `main.dart` (`/books/new`, `/books/:id`, `/books/:id/edit`...) y se navega con `Get.toNamed(...)` y `Get.back()`. El `id` se lee con `Get.parameters['id']`. (La primera versión usaba `Navigator.push`; está explicada como base en la pantalla Teoría.)
3. **Sin `useForm`.** Cada formulario tiene un controlador de GetX con los `TextEditingController`, los valores elegidos (`.obs`) y los `validator` de `TextFormField` y `Form`. Las reglas son las mismas (título e ISBN obligatorios, año 1450–2100, email válido, contraseña de 8+ caracteres, web con `http(s)://`...). Para los autores del libro, que no es un campo de texto, hago la comprobación a mano y enseño el error al pulsar Guardar.
4. **Toast con GetX.** Ya no hay `ToastProvider`; el aviso sale con `showToast('mensaje')` (usa `Get.rawSnackbar`, sin `context`).
5. **Permisos de galería.** En Android, `image_picker` usa el selector de fotos del sistema y **no necesita permiso**, así que ahí no se pide. En iOS sí se pide con `permission_handler`. En web no se piden permisos (lo gestiona el navegador). La cámara se pide en Android e iOS.
6. **Recortar foto.** En React Native la foto se podía recortar con aspecto 3:4 (`allowsEditing`, `aspect`). Con `image_picker` no hay recorte, solo `imageQuality: 80`.
7. **Foto solo de muestra.** Igual que en React Native, la foto elegida solo se enseña en pantalla; **no se sube** a la API (la API no tiene endpoint para eso).
8. **Pantalla de teoría reescrita.** Antes comparaba React Native con la web (Bridge, DOM...). Ahora habla de Flutter y cubre los 15 temas de la hoja (multiplataforma, Dart, widgets, estado, rutas, renderizado...). En la pantalla de permisos cambié "Bridge" por **Platform Channels**.
9. **Pull-to-refresh y spinner.** El spinner de carga se enseña solo la primera vez; al arrastrar hacia abajo sale el indicador normal de refresco.
10. **Sin `mounted` ni `setState`.** Con Provider y GetX ya no hay `setState` en todo el proyecto, y desaparecen las comprobaciones `if (!mounted) return;`. Los controladores de GetX se crean y se borran solos con la pantalla.
11. **Sin cancelar peticiones.** React Native usaba `AbortController` para cancelar. En Flutter no lo implemento. Tampoco he puesto un tiempo máximo de espera (timeout) a las peticiones.
12. **Recarga automática de las listas.** Al guardar un libro o autor, el formulario le dice al Provider que vuelva a pedir los datos (`provider.loadBooks()`), así que la lista se actualiza sola al volver.
13. **`Get.back()` y los avisos.** Con GetX, si hay un aviso abierto, `Get.back()` cierra el aviso en vez de la pantalla. Por eso en los formularios se vuelve atrás **primero** y se enseña el aviso **después**.

---

## 6. Ejercicio de la Editorial (`publisher`) en Flutter

- **Modelo** (`models/book.dart`): campo `String? publisher`.
- **Formulario** (`book_form_screen.dart` y `controllers/book_form_controller.dart`): `TextFormField` con `publisherCtrl`; se precarga al editar; si está vacío `removeEmpty` lo quita antes de enviar (el servicio hace `removeEmpty(book.toJson())`).
- **Listado** (`book_card.dart`): "Editorial: ..." en modo lista y en modo tarjeta.
- **Detalle** (`book_detail_screen.dart`): etiqueta con la editorial.
- **Buscador** (`books_screen.dart`, función `_matchesBook`): busca por título, ISBN, **editorial** y descripción.

---

## 7. Dependencias (`pubspec.yaml`)

| Paquete | Para qué |
|---|---|
| `http` | Llamadas a la API (sustituye a `fetch`) |
| `image_picker` | Cámara y galería (sustituye a `expo-image-picker`) |
| `permission_handler` | Pedir permisos y ver su estado |
| **`provider`** | Estado de los datos de la API (libros y autores) con `ChangeNotifier` |
| **`get`** | Rutas con nombre (routing), estado reactivo (`.obs` y `Obx`), diálogos y avisos |

**Reparto del estado (decisión mía, porque la hoja pide los dos):**

| Qué | Con qué | Por qué |
|---|---|---|
| Datos que comparten varias pantallas: lista de libros y de autores, carga, error, borrar | **Provider** | Es estado "de la app": la lista, el detalle y los formularios lo usan. |
| Estado de cada pantalla: formularios, buscador, vista lista/tarjetas, pestaña activa, permisos | **GetX** | Es estado "local" de la pantalla y GetX evita los `setState`. |

En un proyecto real suele elegirse un solo gestor de estado; aquí uso los dos porque aparecen los dos en la hoja.

---

## 8. Cómo ejecutarlo

Flutter está instalado en `~/development/flutter`. Para usarlo en la terminal:

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

**1. MongoDB + backend (sin cambios en el código)**

```bash
# MongoDB (yo lo he levantado con Docker)
docker run -d --name mongo-seminari -p 27017:27017 mongo:7

cd EA-Seminari9-Flutter-API
npm install
cp .env.example .env
npm run seed
npm run dev          # http://localhost:1337
```

**2. App Flutter**

```bash
cd EA-Seminari9-Flutter
flutter pub get
flutter run -d chrome        # web
flutter run                  # móvil / emulador conectado
# con otra URL de API:
flutter run --dart-define=API_URL=http://192.168.1.10:1337
```

Las carpetas `android/`, `ios/` y `web/` ya están generadas con
`flutter create --platforms=android,ios,web .` (conservó mi `lib/main.dart`). Borré `test/widget_test.dart` porque probaba el contador de ejemplo y añadí `test/format_test.dart` y `test/models_test.dart` (serialización).

---

## 9. Configuración nativa (ya hecha)

**Android** — `android/app/src/main/AndroidManifest.xml`: añadidos los permisos `INTERNET` y `CAMERA`, y `android:usesCleartextTraffic="true"` en `<application>` porque la API va por `http` y no `https`.

**iOS** — `ios/Runner/Info.plist`: añadidos `NSCameraUsageDescription` y `NSPhotoLibraryUsageDescription` con el motivo de uso.

> Pendiente para iOS (no se puede hacer en Linux): al abrir el proyecto en un Mac, `permission_handler` necesita activar `PERMISSION_CAMERA=1` y `PERMISSION_PHOTOS=1` en el `Podfile`. Ver <https://pub.dev/packages/permission_handler>.

---

## 10. Pruebas realizadas

Probado en Chrome (Flutter web) contra la API real con los datos del `seed` (12 libros y 5 autores), **ya con Provider, GetX y rutas con nombre**:

| Prueba | Resultado |
|---|---|
| `flutter analyze` | Sin ningún aviso |
| `flutter build web` | Compila |
| `flutter test` (formato, `removeEmpty` y serialización: 5 tests) | Pasan |
| Lista de libros con editorial | Correcto: 12 libros, con "Editorial: ..." |
| Buscador de libros en tiempo real | Correcto: "fundaci" deja solo *Fundación*; "asimov" no da resultados porque no busca por autor (igual que el original) |
| Ruta de "Nuevo" | Correcto: `/#/books/new` |
| Formulario vacío | Muestra los errores de título, ISBN y autores |
| Crear libro con editorial | Correcto: vuelve a la lista (`/`), pasa de 12 a 13 **sin recargar** y la API lo guarda con su autor |
| Detalle de libro | Correcto: ruta `/#/books/<id>` con portada, autor y editorial |
| Editar libro | Correcto: ruta `/#/books/<id>/edit`, precarga todos los datos; al guardar vuelve al detalle, que se recarga con la editorial nueva ("Editorial Editada") y sale el aviso |
| Borrar libro | Correcto: sale el diálogo de confirmación y la API vuelve a 12 |
| Pestaña Autores | Correcto: 5 autores con rol (Administrador / Autor) y nacionalidad |
| Crear autor | Correcto: ruta `/#/authors/new`, validaciones, vuelve a la lista (de 5 a 6) y la API lo guarda |
| Pestañas Permisos y Teoría | Se ven bien; Teoría con los 15 apartados |

Después de las pruebas borré el libro y el autor de prueba (la API vuelve a tener 12 libros y 5 autores).

**No probado:** móvil o emulador (cámara, galería y permisos reales), editar y borrar autores desde la interfaz, detalle de autor, vista de tarjetas y pull-to-refresh.

**Fallos encontrados y arreglados al probar** (detalle en `SEMINARI9_CODIGO_RN_A_FLUTTER.md`, sección 8):
- Al crear un libro salía "error inesperado" aunque la API lo guardaba: la API devuelve los autores como ids al crear y `Book.fromJson` esperaba objetos. Arreglado y con test nuevo.
- Después de guardar, la pantalla se quedaba en el formulario: con GetX, `Get.back()` cierra primero el aviso si está abierto. Arreglado volviendo atrás antes de mostrar el aviso.

Notas:
- Al teclear de forma automática en la web, los primeros caracteres de algunos campos pueden perderse. Es un problema de la herramienta de prueba, que escribe antes de que el campo termine de enfocarse; a mano no pasa.
- Un test de `flutter test` que llamaba a la API se quedaba colgado dentro del entorno de test (con `dart` normal sí conectaba), así que los tests de `test/` no llaman a la API y el flujo con la API se probó en el navegador.
- El `EJERCICIO.md`, `GUIA.md` y `cambios.pdf` del proyecto original siguen explicando la versión React Native y no los he adaptado.

---

## 11. Adaptación a la hoja de temas

La hoja (guion de Flutter) pedía estos temas. Esto es dónde está cada uno **en el proyecto** (el plan previo está en [SEMINARI9_PLAN_HOJA_FLUTTER.md](SEMINARI9_PLAN_HOJA_FLUTTER.md)):

| Tema de la hoja | Dónde está |
|---|---|
| Multiplataforma | Carpetas `android/`, `ios/` y `web/`; Teoría, apartado 1 |
| Dart: objetos | `models/author.dart` y `book.dart`; Teoría, apartado 2 |
| Dart: serialización | `fromJson` y **`toJson`** en los modelos; los servicios envían con `removeEmpty(book.toJson())`; Teoría, apartado 2; `test/models_test.dart` |
| Dart: async/await y Future | Todos los servicios y controladores; Teoría, apartado 3 |
| Dart: null safety | `String?`, `??`, `?.`, `!` en todo el código; Teoría, apartado 4 |
| Install | README y Teoría, apartado 5 |
| Widget / todo | Teoría, apartado 6 |
| Stateless / Stateful | Casi todas las pantallas son `StatelessWidget`; Teoría, apartado 7 |
| Tree / Estructura / Scaffold | `Scaffold` en cada pantalla; Teoría, apartado 8 |
| Style | `ThemeData` en `main.dart` y `theme/app_colors.dart`; Teoría, apartado 9 |
| Proyecto: `pubspec.yaml`, `lib/`, `main()` | Teoría, apartado 10 |
| Navegación Push / Pop | `Get.toNamed` (push) y `Get.back` (pop); se explica en Teoría, apartado 12 |
| Routing con GetX | `GetMaterialApp` y `getPages` en `main.dart` l. 33-52 |
| Estado: `setState` | **Ya no se usa** (se explica como base en Teoría, apartado 13) |
| Estado: Provider | `providers/books_provider.dart` y `authors_provider.dart` |
| Estado: GetX | `controllers/` (8 controladores) con `.obs` y `Obx` |
| Renderizado (Skia) | Teoría, apartado 14 (comprobado con la documentación oficial de Flutter 3.47) |
