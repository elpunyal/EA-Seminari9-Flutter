# Seminari 9 — Flutter

## Cambios: de React Native (Expo) a Flutter

Este documento explica todo lo que he añadido y cambiado al pasar el backoffice de **autores y libros** de React Native a **Flutter**. He dejado el proyecto original sin tocar y he creado uno nuevo en la carpeta `EA-Seminari9-Flutter/`.

> **Estado:** he instalado Flutter 3.47 (canal stable) en `~/development/flutter` y la app **compila sin errores** (`flutter analyze` sin avisos y `flutter build web` correcto). La he probado en el navegador (Chrome) contra la API real con MongoDB. Los resultados están en la sección 10. **No la he probado en un móvil ni emulador** (no hay Android SDK instalado).

---

## 1. Qué he hecho (resumen)

- He creado un proyecto nuevo `EA-Seminari9-Flutter/` con la misma funcionalidad que la app de React Native.
- **El backend (`EA-Seminari9-Flutter-API`) no lo he cambiado.** Flutter usa la misma API REST (puerto 1337).
- He portado las 4 pestañas: **Libros, Autores, Permisos y Teoría**.
- He mantenido el campo **Editorial (`publisher`)** del ejercicio: se ve en listado, tarjetas y detalle, se edita en el formulario y el buscador también busca por editorial.
- He puesto comentarios sencillos en el código explicando cada parte y comparándola con React Native.

---

## 2. Estructura del proyecto Flutter

```
EA-Seminari9-Flutter/
├── pubspec.yaml                  (dependencias, como package.json)
└── lib/
    ├── main.dart                 (punto de entrada)
    ├── config/environment.dart
    ├── models/    author.dart, book.dart
    ├── services/  http_client.dart, author_service.dart,
    │              book_service.dart, permissions_service.dart
    ├── utils/     format.dart
    ├── theme/     app_colors.dart
    ├── widgets/   (componentes reutilizables)
    └── screens/   (pantallas)
```

---

## 3. Equivalencia fichero por fichero

| React Native (original) | Flutter (nuevo) | Qué ha cambiado |
|---|---|---|
| `package.json` | `pubspec.yaml` | Dependencias de Dart: `http`, `image_picker`, `permission_handler`. |
| `app/_layout.tsx`, `app/index.tsx` | `lib/main.dart` | `runApp(MyApp())` y un `MaterialApp` con el tema. |
| `app/(tabs)/_layout.tsx` | `screens/home_screen.dart` | Pestañas con `NavigationBar` + `IndexedStack`. |
| `config/environment.ts` | `config/environment.dart` | Misma lógica (`10.0.2.2` en Android). Se cambia con `--dart-define=API_URL=...`. |
| `models/author.model.ts`, `book.model.ts` | `models/author.dart`, `book.dart` | Clases con `fromJson` (en TypeScript bastaba con `interface`). |
| `services/http.ts` | `services/http_client.dart` | `fetch` → paquete `http`. `ApiError` → `ApiException`. |
| `services/author.service.ts`, `book.service.ts` | `services/author_service.dart`, `book_service.dart` | Mismos endpoints (GET, POST, PUT, DELETE). |
| `utils/format.ts`, `remove-empty.ts`, `api-error.ts` | `utils/format.dart` | Junté las tres cosas en un solo fichero. |
| `hooks/usePermissions.ts` | `services/permissions_service.dart` | Los hooks no existen en Flutter: es una clase normal. |
| `hooks/useForm.ts` | (dentro de cada formulario) | Se usan `Form`, `TextFormField` y `TextEditingController`. |
| `hooks/useApiList.ts` | (dentro de cada lista) | Variables `_books`, `_loading`, `_error` y `setState`. |
| `context/ToastContext.tsx` | `widgets/toast.dart` | Flutter ya trae `SnackBar`, no hace falta un Provider. |
| `components/ConfirmModal.tsx` | `widgets/confirm_dialog.dart` | Usa `showDialog` / `AlertDialog`. |
| `components/Field.tsx` | `widgets/field_wrapper.dart` | Etiqueta + campo + error. Incluye el estilo común de los inputs. |
| `components/SearchBar.tsx` | `widgets/search_field.dart` | `TextField` con lupa y botón X. |
| `components/ViewToggle.tsx` | `widgets/view_toggle.dart` | Misma idea: lista / tarjetas (`enum ViewMode`). |
| `components/RoleBadge.tsx` | `widgets/role_badge.dart` | Además añadí `ActiveBadge` (Activo/Inactivo). |
| `components/BookCard.tsx` | `widgets/book_card.dart` | Modo lista y modo tarjeta, con editorial. |
| `components/AuthorCard.tsx` | `widgets/author_card.dart` | Modo lista y modo tarjeta. |
| `books/index.tsx` | `screens/books_screen.dart` | Lista, buscador, pull-to-refresh, borrar. |
| `books/new.tsx` + `books/[id]/edit.tsx` | `screens/book_form_screen.dart` | **Unidos en un solo fichero** (ver abajo). |
| `books/[id]/index.tsx` | `screens/book_detail_screen.dart` | Detalle del libro. |
| `authors/index.tsx` | `screens/authors_screen.dart` | Lista de autores. |
| `authors/new.tsx` + `authors/[id]/edit.tsx` | `screens/author_form_screen.dart` | **Unidos en un solo fichero**. |
| `authors/[id]/index.tsx` | `screens/author_detail_screen.dart` | Detalle del autor. |
| `permissions.tsx` | `screens/permissions_screen.dart` | Demostrador de permisos. |
| `info.tsx` | `screens/info_screen.dart` | Teoría (reescrita, ver abajo). |
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
| `useState` | `StatefulWidget` + `setState()` |
| `useEffect(() => {}, [])` | `initState()` |
| `useMemo` para filtrar | Un getter (`get _filteredBooks`) |
| `router.push()` / `router.back()` | `Navigator.push()` / `Navigator.pop()` |
| `Alert.alert` | `showDialog` + `AlertDialog` |
| `Ionicons` | `Icons` (vienen con Flutter) |
| `fetch` | paquete `http` |
| `expo-image-picker` | paquete `image_picker` |
| Permisos con `ImagePicker.request...` | paquete `permission_handler` |

---

## 5. Cambios de comportamiento (lo que NO es una copia exacta)

1. **Formularios unidos.** En React Native había `new.tsx` y `edit.tsx` casi idénticos. En Flutter hice una sola pantalla con un parámetro opcional: si recibe `bookId` / `authorId` edita, si no, crea. Así hay menos código repetido.
2. **Navegación.** En lugar de Expo Router (rutas por carpetas) uso `Navigator.push`. El `id` se pasa por el constructor de la pantalla. Cuando una pantalla se cierra con `await`, la lista se recarga sola.
3. **Sin `useForm`.** La validación usa los `validator` de `TextFormField` y `Form`. Las reglas son las mismas (título e ISBN obligatorios, año 1450–2100, email válido, contraseña de 8+ caracteres, web con `http(s)://`...). Para los autores del libro, que no es un campo de texto, hago la comprobación a mano y enseño el error al pulsar Guardar.
4. **Toast con SnackBar.** Ya no hay `ToastProvider`; el aviso sale con `showToast(context, 'mensaje')`.
5. **Permisos de galería.** En Android, `image_picker` usa el selector de fotos del sistema y **no necesita permiso**, así que ahí no se pide. En iOS sí se pide con `permission_handler`. En web no se piden permisos (lo gestiona el navegador). La cámara se pide en Android e iOS.
6. **Recortar foto.** En React Native la foto se podía recortar con aspecto 3:4 (`allowsEditing`, `aspect`). Con `image_picker` no hay recorte, solo `imageQuality: 80`.
7. **Foto solo de muestra.** Igual que en React Native, la foto elegida solo se enseña en pantalla; **no se sube** a la API (la API no tiene endpoint para eso).
8. **Pantalla de teoría reescrita.** Antes comparaba React Native con la web (Bridge, DOM...). Ahora habla de Flutter: widgets, `StatelessWidget` / `StatefulWidget`, `setState`, tabla de equivalencias RN → Flutter, navegación y llamadas a la API. En la pantalla de permisos cambié "Bridge" por **Platform Channels**.
9. **Pull-to-refresh y spinner.** El spinner de carga se enseña solo la primera vez; al arrastrar hacia abajo sale el indicador normal de refresco.
10. **`mounted`.** Después de cada `await` compruebo `if (!mounted) return;` antes de usar `setState` o el `context`, para que no falle si el usuario ya salió de la pantalla.
11. **Sin cancelar peticiones.** React Native usaba `AbortController` para cancelar. En Flutter no lo implemento; en su lugar uso `mounted`. Tampoco he puesto un tiempo máximo de espera (timeout) a las peticiones.

---

## 6. Ejercicio de la Editorial (`publisher`) en Flutter

- **Modelo** (`models/book.dart`): campo `String? publisher`.
- **Formulario** (`book_form_screen.dart`): `TextFormField` con `_publisherCtrl`; se precarga al editar; si está vacío `removeEmpty` lo quita antes de enviar.
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

No he usado paquetes de estado (Provider, Riverpod, Bloc) ni de navegación (go_router) para mantenerlo sencillo y parecido a lo que se vio en clase.

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
`flutter create --platforms=android,ios,web .` (conservó mi `lib/main.dart`). Borré `test/widget_test.dart` porque probaba el contador de ejemplo y añadí `test/format_test.dart`.

---

## 9. Configuración nativa (ya hecha)

**Android** — `android/app/src/main/AndroidManifest.xml`: añadidos los permisos `INTERNET` y `CAMERA`, y `android:usesCleartextTraffic="true"` en `<application>` porque la API va por `http` y no `https`.

**iOS** — `ios/Runner/Info.plist`: añadidos `NSCameraUsageDescription` y `NSPhotoLibraryUsageDescription` con el motivo de uso.

> Pendiente para iOS (no se puede hacer en Linux): al abrir el proyecto en un Mac, `permission_handler` necesita activar `PERMISSION_CAMERA=1` y `PERMISSION_PHOTOS=1` en el `Podfile`. Ver <https://pub.dev/packages/permission_handler>.

---

## 10. Pruebas realizadas

Probado en Chrome (Flutter web) contra la API real con los datos del `seed` (12 libros y 5 autores):

| Prueba | Resultado |
|---|---|
| `flutter analyze` | Sin problemas |
| `flutter build web` | Compila |
| `flutter test` (formato y `removeEmpty`) | Pasa |
| Lista de libros con editorial | Correcto: 12 libros, con "Editorial: ..." |
| Buscador de libros en tiempo real | Correcto: "fundaci" deja solo *Fundación*; "asimov" no da resultados porque no busca por autor (igual que el original) |
| Formulario vacío | Muestra los errores de título, ISBN y autores |
| Crear libro con editorial | Correcto: pasa de 12 a 13 y la API lo guarda con su autor |
| Editar libro | Correcto: precarga título, ISBN, editorial y autor |
| Borrar libro | Correcto: sale el diálogo de confirmación y la API vuelve a 12 |
| Pestaña Autores | Correcto: 5 autores con rol (Administrador / Autor) y nacionalidad |
| Pestañas Permisos y Teoría | Se ven bien |

**No probado:** móvil o emulador (cámara, galería y permisos reales), detalle de libro/autor, crear/editar/borrar autores desde la interfaz, vista de tarjetas y pull-to-refresh.

Notas:
- Al teclear de forma automática en la web, los primeros caracteres de algunos campos se perdieron (por ejemplo la editorial quedó como "torial Flutter"). Es un problema de la herramienta de prueba, que escribe antes de que el campo termine de enfocarse; a mano no pasa.
- Un test de `flutter test` que llamaba a la API se quedaba colgado dentro del entorno de test (con `dart` normal sí conectaba), así que lo quité y probé el flujo directamente en el navegador.
- Puede haber avisos de "deprecated" según la versión de Flutter. Ya cambié `Switch.activeColor` por `activeThumbColor`.
- El `EJERCICIO.md`, `GUIA.md` y `cambios.pdf` del proyecto original siguen explicando la versión React Native y no los he adaptado.
