# Seminari 9 — Código: qué he cambiado de React Native a Flutter

Este documento compara **el código**, no solo la idea. Para cada fichero pongo:

- en qué **líneas** está el código original (React Native / TypeScript),
- en qué **líneas** está el equivalente nuevo (Flutter / Dart),
- y el **antes y después** de las partes importantes.

> **Cómo leer los números de línea:** son líneas reales de los ficheros tal y como están ahora. El paso de TypeScript a Dart no se puede hacer línea por línea (el código no tiene la misma forma), así que cada fila relaciona un **bloque** con su equivalente. Si cambias los ficheros, los números se desplazarán.

Rutas (desde `EA-Seminari8-React-Native-main/`):

- Original: `EA-Seminari8-React-Native/src/...`
- Nuevo: `EA-Seminari9-Flutter/lib/...`

Para ver qué se ha hecho y por qué, mira también [SEMINARI9_FLUTTER.md](SEMINARI9_FLUTTER.md).

> **Esta versión del documento** ya incluye los cambios que pedía la hoja de temas: estado con **Provider** y **GetX** (sin `setState`), rutas con nombre con **GetX**, `toJson` y la pantalla de Teoría ampliada. El plan previo está en [SEMINARI9_PLAN_HOJA_FLUTTER.md](SEMINARI9_PLAN_HOJA_FLUTTER.md).

---

## 1. Resumen en números

| | React Native | Flutter |
|---|---|---|
| Lenguaje | TypeScript (`.ts`, `.tsx`) | Dart (`.dart`) |
| Ficheros de código | 39 | 38 |
| Líneas de código | 5.434 | 3.964 |
| Estilos | `StyleSheet.create` al final de cada fichero (~40 % de las líneas de pantallas y componentes) | Dentro del propio widget |
| Estado | `useState`, `useReducer`, hooks propios | **Provider** (datos) + **GetX** (pantallas) |
| Navegación | Expo Router (carpetas) | **GetX** (`GetMaterialApp` + rutas con nombre) |
| Backend | `EA-Seminari9-Flutter-API` | El mismo, **sin tocar** |

Flutter tiene menos líneas sobre todo porque los estilos van dentro del widget y los formularios de crear y editar se han unido en un solo fichero. Al pasar a Provider y GetX hay **más ficheros** (providers y controladores) pero cada pantalla es más corta que antes.

---

## 2. Mapa completo de ficheros

### 2.1. Configuración, modelos, servicios y utilidades

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `config/environment.ts` | 1-13 | → | `config/environment.dart` | 1-21 |
| `models/author.model.ts` | 1-22 | → | `models/author.dart` | 1-63 |
| `models/book.model.ts` | 1-34 | → | `models/book.dart` | 1-89 |
| `models/index.ts` | 2 | → | *(no hace falta, Dart importa cada fichero)* | — |
| `services/http.ts` | 1-55 | → | `services/http_client.dart` | 1-78 |
| `services/author.service.ts` | 1-37 | → | `services/author_service.dart` | 1-37 |
| `services/book.service.ts` | 1-37 | → | `services/book_service.dart` | 1-38 |
| `utils/format.ts` | 1-38 | → | `utils/format.dart` | 1-61 (partes 1-45) |
| `utils/api-error.ts` | 1-21 | → | `utils/format.dart` (`errorMessage`) | 47-52 |
| `utils/remove-empty.ts` | 1-15 | → | `utils/format.dart` (`removeEmpty`) | 54-61 |
| `constants/theme.ts` | 1-64 | → | `theme/app_colors.dart` | 1-18 |

### 2.2. Hooks y contexto → Providers, controladores y servicios

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `hooks/useApiList.ts` (lista de la API) | 1-66 | → | `providers/books_provider.dart` | 1-42 |
| | | → | `providers/authors_provider.dart` | 1-37 |
| `hooks/useForm.ts` + `useState` de `books/new.tsx` y `edit.tsx` | 1-97 | → | `controllers/book_form_controller.dart` | 1-180 |
| `hooks/useForm.ts` + `useState` de `authors/new.tsx` y `edit.tsx` | | → | `controllers/author_form_controller.dart` | 1-157 |
| `useEffect` + `useState` de `books/[id]/index.tsx` | 24-45 | → | `controllers/book_detail_controller.dart` | 1-33 |
| `useEffect` + `useState` de `authors/[id]/index.tsx` | 24-45 | → | `controllers/author_detail_controller.dart` | 1-32 |
| `useState` de la lista (`search`, `viewMode`) | `books/index.tsx` 44-47 | → | `controllers/list_ui_controller.dart` | 1-18 |
| `useState` de pestañas (Expo Router) | `(tabs)/_layout.tsx` | → | `controllers/home_controller.dart` | 1-10 |
| `useState` de `permissions.tsx` | 15-39 | → | `controllers/permissions_controller.dart` | 1-35 |
| `hooks/usePermissions.ts` | 1-112 | → | `services/permissions_service.dart` | 1-106 |
| `context/ToastContext.tsx` | 1-83 | → | `widgets/toast.dart` | 1-19 |
| `hooks/use-theme.ts`, `use-color-scheme*.ts` | 1-36 | → | *(no portados: era el tema claro/oscuro de la plantilla de Expo y no se usaba)* | — |

### 2.3. Componentes

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `components/BookCard.tsx` | 1-318 (JSX 17-133, estilos 135-318) | → | `widgets/book_card.dart` | 1-274 |
| `components/AuthorCard.tsx` | 1-296 (JSX 16-115, estilos 117-296) | → | `widgets/author_card.dart` | 1-220 |
| `components/ConfirmModal.tsx` | 1-111 | → | `widgets/confirm_dialog.dart` | 1-32 |
| `components/Field.tsx` | 1-46 | → | `widgets/field_wrapper.dart` | 1-72 |
| `components/SearchBar.tsx` | 1-62 | → | `widgets/search_field.dart` | 1-53 |
| `components/ViewToggle.tsx` | 1-76 | → | `widgets/view_toggle.dart` | 1-63 |
| `components/RoleBadge.tsx` | 1-43 | → | `widgets/role_badge.dart` | 1-55 |
| *(repetido en `new.tsx` y `edit.tsx`)* | — | → | `widgets/photo_picker_section.dart` **nuevo** | 1-145 |
| *(repetido en todas las pantallas)* | — | → | `widgets/error_banner.dart` **nuevo** | 1-32 |

### 2.4. Pantallas

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `app/_layout.tsx` + `app/index.tsx` | 18 + 5 | → | `main.dart` (providers + rutas) | 1-56 |
| `app/(tabs)/_layout.tsx` | 1-72 | → | `screens/home_screen.dart` | 1-65 |
| `app/(tabs)/books/_layout.tsx`, `authors/_layout.tsx` | 19 + 19 | → | *(las rutas están en `main.dart`, l. 45-51)* | — |
| `app/(tabs)/books/index.tsx` | 1-275 | → | `screens/books_screen.dart` | 1-180 |
| `app/(tabs)/books/new.tsx` | 1-539 | → | `screens/book_form_screen.dart` (modo crear) | 1-285 |
| `app/(tabs)/books/[id]/edit.tsx` | 1-466 | → | `screens/book_form_screen.dart` (modo editar) | *(el mismo)* |
| `app/(tabs)/books/[id]/index.tsx` | 1-316 | → | `screens/book_detail_screen.dart` | 1-269 |
| `app/(tabs)/authors/index.tsx` | 1-256 | → | `screens/authors_screen.dart` | 1-153 |
| `app/(tabs)/authors/new.tsx` | 1-460 | → | `screens/author_form_screen.dart` (modo crear) | 1-229 |
| `app/(tabs)/authors/[id]/edit.tsx` | 1-403 | → | `screens/author_form_screen.dart` (modo editar) | *(el mismo)* |
| `app/(tabs)/authors/[id]/index.tsx` | 1-283 | → | `screens/author_detail_screen.dart` | 1-230 |
| `app/(tabs)/permissions.tsx` | 1-372 | → | `screens/permissions_screen.dart` | 1-195 |
| `app/(tabs)/info.tsx` | 1-249 | → | `screens/info_screen.dart` | 1-282 |

---

## 3. Antes y después del código importante

### 3.1. Llamadas a la API — `http.ts` (líneas 15-55) → `http_client.dart` (líneas 21-78)

**Antes (React Native)**

```ts
export async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const url = `${environment.apiUrl}${path}`;
  try {
    res = await fetch(url, { ...options, headers: { Accept: 'application/json', ... } });
  } catch (err) {
    throw new ApiError(`No se puede conectar con la API en ${url}...`, 0);
  }
  if (!res.ok) {
    const body = await res.json().catch(() => null);
    throw new ApiError(body?.message ?? `Error HTTP ${res.status}`, res.status);
  }
  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}
```

**Después (Flutter)**

```dart
Future<dynamic> request(String path, {String method = 'GET', Map<String, dynamic>? body}) async {
  final url = Uri.parse('${Environment.apiUrl}$path');
  try {
    switch (method) {                       // en JS bastaba con fetch(url, {method})
      case 'POST': res = await http.post(url, headers: headers, body: jsonEncode(body)); break;
      case 'PUT':  res = await http.put(url, headers: headers, body: jsonEncode(body)); break;
      case 'DELETE': res = await http.delete(url, headers: headers); break;
      default: res = await http.get(url, headers: headers);
    }
  } catch (_) {
    throw ApiException('No se puede conectar con la API en $url...', 0);
  }
  if (res.statusCode < 200 || res.statusCode >= 300) { /* lee data['message'] */ }
  if (res.statusCode == 204 || res.body.isEmpty) return null;
  return jsonDecode(utf8.decode(res.bodyBytes));
}
```

**Qué cambia:** `fetch` → paquete `http`; `res.ok` → comprobar `statusCode` a mano; `res.json()` → `jsonDecode`; `ApiError extends Error` → `ApiException implements Exception`; ya no hay genéricos `<T>` porque se devuelve `dynamic` y cada servicio lo convierte. La lectura con `utf8.decode(res.bodyBytes)` (l. 62 y 77) se explica en el apartado 7.1.

### 3.2. URL de la API — `environment.ts` (1-13) → `environment.dart` (8-19)

```ts
// Antes
const envApiUrl = process.env.EXPO_PUBLIC_API_URL;
if (Platform.OS === 'android') return 'http://10.0.2.2:1337';
return 'http://localhost:1337';
```

```dart
// Después
static const String _envApiUrl = String.fromEnvironment('API_URL');   // --dart-define=API_URL=...
if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:1337';
return 'http://localhost:1337';
```

### 3.3. Modelos y serialización — `book.model.ts` (1-34) → `book.dart` (1-89) y `author.dart` (1-63)

```ts
// Antes: una interface (solo existe al compilar, no convierte nada)
export interface Book extends Omit<BookInput, 'authors'> {
  _id: string;
  authors: Author[];
  publisher?: string;
}
```

```dart
// Después: una clase real. Dart no convierte el JSON solo, así que hay DOS conversiones:
class Book {
  final String id;
  final String? publisher;                 // editorial (ejercicio)

  // JSON -> objeto (book.dart l. 45-71)
  factory Book.fromJson(Map<String, dynamic> json) { ... }

  // objeto -> JSON (book.dart l. 74-89)  NUEVO
  Map<String, dynamic> toJson() => {
        'title': title,
        'authors': authors.map((a) => a.id).toList(),   // la API solo quiere los ids
        'publisher': publisher,
        ...
      };
}
```

**Qué cambia:**

- `_id` pasa a `id`; `?` en un tipo (`String?`) equivale a `?:` de TypeScript.
- **`toJson` es nuevo:** antes los formularios montaban un mapa a mano (`removeEmpty({...values})`). Ahora el formulario crea un objeto `Book` y el servicio hace `removeEmpty(book.toJson())`.
- `Author` gana el campo `password` (`author.dart` l. 14), que solo se usa para **enviar** (la API nunca la devuelve), y su propio `toJson` (l. 47-62).
- **`fromJson` de `Book` y los ids (`book.dart` l. 45-56):** al **crear** un libro, la API contesta con `authors` como lista de ids (texto) y no como objetos. Por eso solo convierto los que son objetos:

```dart
final authors = <Author>[];
for (final a in (json['authors'] as List<dynamic>? ?? [])) {
  if (a is Map<String, dynamic>) {
    authors.add(Author.fromJson(a));
  }
}
```

### 3.4. Utilidades — `format.ts` (1-38) y `remove-empty.ts` (1-15) → `format.dart`

```ts
// Antes
export function removeEmpty<T extends object>(data: T): Partial<T> {
  for (const key of Object.keys(data)) {
    const isEmpty = value === null || value === undefined || (typeof value === 'string' && value.trim() === '');
    if (!isEmpty) result[key] = value;
  }
}
```

```dart
// Después
Map<String, dynamic> removeEmpty(Map<String, dynamic> data) {
  final result = <String, dynamic>{};
  data.forEach((key, value) {
    final isEmpty = value == null || (value is String && value.trim().isEmpty);
    if (!isEmpty) result[key] = value;
  });
  return result;
}
```

`errorMessage` también pasa a este fichero (l. 47-52) y `isAbort` desaparece (ver 3.13). Un detalle: `active: false` **no** se considera vacío, así que sigue enviándose.

### 3.5. Permisos — `usePermissions.ts` (1-112) → `permissions_service.dart` (1-106)

| Qué hace | React Native | Flutter |
|---|---|---|
| Pedir cámara | `ImagePicker.requestCameraPermissionsAsync()` (l. 15) | `Permission.camera.request()` (l. 46) |
| Alerta si se deniega | `Alert.alert(...)` (l. 20, 48) | `Get.dialog(AlertDialog(...))` (l. 18) |
| Abrir ajustes | `Linking.openSettings()` (l. 29, 57) | `openAppSettings()` (l. 32) |
| Hacer foto | `ImagePicker.launchCameraAsync({ allowsEditing, aspect: [3,4] })` (l. 74) | `_picker.pickImage(source: camera, imageQuality: 80)` (l. 95) |
| Elegir de galería | `ImagePicker.launchImageLibraryAsync(...)` (l. 91) | `_picker.pickImage(source: gallery, ...)` (l. 103) |
| Guardar estado | `useState` (l. 9-10) | campos `cameraStatus` y `mediaLibraryStatus` de la clase |

**Cambios de esta versión:** los métodos **ya no reciben `BuildContext`** (antes `takePhoto(context)`, ahora `takePhoto()`): los diálogos se abren con `Get.dialog`. Eso quita los avisos `use_build_context_synchronously`. En Android no se pide permiso de galería (el selector del sistema no lo necesita), en web no se piden permisos y no hay recorte 3:4.

### 3.6. Estado de los datos — `useApiList.ts` (1-66) → **Provider** (`books_provider.dart`, `authors_provider.dart`)

El estado "de la app" (la lista de libros y de autores) lo comparten la lista, el detalle y los formularios. Eso es lo que hace un **Provider**.

**Antes (React Native)**

```ts
const { items: books, loading, error, removeItem, onRefresh, refreshing } =
  useApiList(bookService.getBooks);
```

**Después (Flutter, `books_provider.dart`)**

```dart
class BooksProvider extends ChangeNotifier {
  List<Book> books = [];
  bool loading = true;
  String error = '';

  Future<void> loadBooks() async {                // l. 16-25
    try { books = await BookService.getBooks(); error = ''; }
    catch (e) { error = errorMessage(e); }
    loading = false;
    notifyListeners();                            // avisa a las pantallas
  }

  Future<bool> deleteBook(String id) async { ... }   // l. 28-41, quita el libro de la lista local
}
```

| Pieza | Dónde |
|---|---|
| Crear los providers y pedir los datos al arrancar | `main.dart` l. 27-31 (`MultiProvider` + `..loadBooks()`) |
| Mirar el estado (la pantalla se repinta sola) | `books_screen.dart` l. 46: `context.watch<BooksProvider>()` |
| Recargar tras guardar | `book_form_screen.dart` l. 53-58: `provider.loadBooks()` |

**Efecto:** ya no existe el `_loadBooks()` que había que llamar al volver de otra pantalla: el formulario recarga el provider y la lista se actualiza sola.

### 3.7. Lista de libros — `books/index.tsx` (1-275) → `books_screen.dart` (1-180)

| Qué hace | React Native | Flutter |
|---|---|---|
| Pedir los libros | `useApiList(bookService.getBooks)` (l. 42) | `BooksProvider` (se crea en `main.dart`) |
| Estado (buscar, vista) | `useState` (l. 44-47) | `ListUiController` de GetX (`list_ui_controller.dart`) |
| Filtrar con editorial | `matchesBook` (l. 26-33) | `_matchesBook` (l. 18-25) |
| Lista filtrada | `useMemo` (l. 51) | dentro del `Obx` (l. 58-61) |
| Borrar | `confirmDelete` + `<ConfirmModal>` (l. 57, 170) | `_deleteBook` con `confirmDialog` (l. 32-41) |
| Ir a editar/detalle | `router.push(...)` (l. 72, 80) | `Get.toNamed('/books/${book.id}')` (l. 165-166) |
| Lista | `<FlatList>` (l. 134) | `ListView.builder` (l. 156) |
| Arrastrar para refrescar | `<RefreshControl>` (l. 147) | `RefreshIndicator` (l. 124) |

**Antes**

```tsx
const filteredBooks = useMemo(() => {
  if (!search.trim()) return books;
  return books.filter((b) => matchesBook(b, search.trim()));
}, [books, search]);
```

**Después**

```dart
final provider = context.watch<BooksProvider>();                 // PROVIDER: los datos
final ui = Get.put(ListUiController(), tag: 'books');            // GETX: buscador y vista

Obx(() {                                                         // se repinta al cambiar el buscador
  final search = ui.search.value.trim();
  final filtered = search.isEmpty
      ? provider.books
      : provider.books.where((b) => _matchesBook(b, search)).toList();
  ...
})
```

**Editorial en el buscador (ejercicio)**

```ts
// Antes (books/index.tsx, l. 31)
(book.publisher?.toLowerCase().includes(query) ?? false) ||
```

```dart
// Después (books_screen.dart, l. 22)
(book.publisher?.toLowerCase().contains(query) ?? false) ||
```

### 3.8. Formulario de libro — `new.tsx` (1-539) + `[id]/edit.tsx` (1-466) → `book_form_controller.dart` (1-180) + `book_form_screen.dart` (1-285)

Ahora el formulario se reparte en dos ficheros: el **controlador GetX** (la lógica) y la **pantalla** (solo dibuja).

| Qué hace | React Native | Flutter |
|---|---|---|
| Valores del formulario | `useForm` + `INITIAL_VALUES` (new l. 42, 86) | un `TextEditingController` por campo (controlador l. 24-30) |
| Autores/etiquetas/idioma elegidos | `form.values.authors` (new l. 92-110) | `selectedAuthors`, `selectedTags`, `language` con `.obs` (l. 33-35) |
| Editorial | `publisher: ''` (new l. 45) + `<TextInput>` (l. 218-224) | `publisherCtrl` (controlador l. 26) + `TextFormField` (pantalla l. 130) |
| Precargar al editar | `fill({...})` (edit l. 96-107) | `loadData()` (controlador l. 65-85) |
| Elegir autor / etiqueta | `toggleAuthor`, `toggleTag` (new l. 92, 102) | `toggleAuthor`, `toggleTag` (controlador l. 89, 93) |
| Validación | `validate()` (new l. 56-80) | `validateRequired/Year/Pages/Price` (controlador l. 108-133) |
| Enviar | `handleSubmit` (new l. 124) | `submit()` (controlador l. 135-179) |
| Crear / editar | dos ficheros: `createBook` (new l. 145) / `updateBook` (edit l. 160) | un `if (isEditing)` (controlador l. 164-168) |
| Volver atrás | `router.back()` (new l. 147) | `Get.back()` (controlador l. 171) |
| Recargar la lista | (la lista se recargaba sola al montarse) | `provider.loadBooks()` (pantalla l. 53-58) |

**Antes (editorial, `new.tsx`)**

```tsx
const payload = removeEmpty({
  ...values,
  publisher: values.publisher.trim() ? values.publisher.trim() : undefined,
  publishedYear: values.publishedYear === '' ? undefined : Number(values.publishedYear),
});
await bookService.createBook(payload);
```

**Después (`book_form_controller.dart` l. 146-167)**

```dart
final book = Book(                                    // ahora creamos un objeto Book
  id: bookId ?? '',
  title: titleCtrl.text.trim(),
  publisher: publisherCtrl.text.trim(),               // editorial: si está vacía el servicio la quita
  authors: authors.where((a) => selectedAuthors.contains(a.id)).toList(),
  publishedYear: int.tryParse(yearCtrl.text.trim()),
  ...
);
if (isEditing) {
  await BookService.updateBook(bookId!, book);        // el servicio hace removeEmpty(book.toJson())
} else {
  await BookService.createBook(book);
}
```

**Estado reactivo — antes y después**

```tsx
// Antes: useState / useReducer, se repinta toda la pantalla
const [saving, setSaving] = useState(false);
setSaving(true);
```

```dart
// Después: GetX. .obs crea el valor observable y Obx repinta SOLO esa parte
final saving = false.obs;                    // controlador l. 40
saving.value = true;

Obx(() => ElevatedButton(                    // pantalla l. 247-252
  onPressed: c.saving.value ? null : () => _save(context, c),
  ...
))
```

**Precargar al editar (ejercicio)**

```tsx
// Antes (edit.tsx l. 96-107)
fill({ title: book.title, publisher: book.publisher ?? '', price: book.price?.toString() ?? '' });
```

```dart
// Después (book_form_controller.dart l. 70-83)
titleCtrl.text = book.title;
publisherCtrl.text = book.publisher ?? '';
priceCtrl.text = book.price?.toString() ?? '';
```

**Id desde la ruta**

```dart
// book_form_screen.dart l. 62-63: si la ruta es /books/:id/edit hay id; si es /books/new, es null
final id = Get.parameters['id'];
final c = Get.put(BookFormController(id), tag: id ?? 'new');
```

### 3.9. Detalle de libro — `[id]/index.tsx` (1-316) → `book_detail_controller.dart` (1-33) + `book_detail_screen.dart` (1-269)

```tsx
// Antes: useEffect + AbortController
useEffect(() => {
  const controller = new AbortController();
  bookService.getBook(id, controller.signal).then(setBook)...
  return () => controller.abort();
}, [id]);
```

```dart
// Después: controlador GetX. onInit es como useEffect(() => {...}, [])
class BookDetailController extends GetxController {
  final book = Rxn<Book>();          // Rxn = observable que puede ser null
  final loading = true.obs;
  final error = ''.obs;

  @override
  void onInit() { super.onInit(); loadBook(); }          // l. 18-21
  Future<void> loadBook() async { ... }                  // l. 23-32
}

// y en la pantalla (book_detail_screen.dart l. 66-77):
final id = Get.parameters['id']!;
final c = Get.put(BookDetailController(id), tag: id);
body: Obx(() => _buildBody(c)),
```

| Parte | React Native | Flutter |
|---|---|---|
| Portada de prueba | l. 69 `picsum.photos/seed/${book._id}/400/500` | l. 134 `picsum.photos/seed/${book.id}/400/500` |
| Etiqueta Editorial | l. 81-86 | l. 156-175 |
| Botón Editar Libro | l. 149 | l. 249-259 (`Get.toNamed('/books/${book.id}/edit')` y recarga al volver) |

### 3.10. Formulario de autor — `authors/new.tsx` (1-460) + `[id]/edit.tsx` (1-403) → `author_form_controller.dart` (1-157) + `author_form_screen.dart` (1-229)

| Qué hace | React Native | Flutter |
|---|---|---|
| Reglas de validación | `validate()` new l. 49-78 / edit l. 47-76 | `validateName/Email/Password/Confirm/Website` (controlador l. 89-117) |
| No enviar `confirmPassword` | `const { confirmPassword: _cp, ...formData } = form.values` (new l. 105) | el modelo `Author` ni tiene `confirmPassword` (controlador l. 126-136) |
| Precargar al editar | `fill({...})` (edit l. 95-103) | `loadAuthor()` (controlador l. 60-76) |
| Interruptor activo | `<Switch>` (new l. 263) | `Switch(...)` con `active.obs` (pantalla l. 182) |
| Crear / editar | `createAuthor` (new l. 112) / `updateAuthor` (edit l. 131) | `if (isEditing)` (controlador l. 142-146) |
| Recargar la lista | — | `provider.loadAuthors()` (pantalla l. 42-47) |

```tsx
// Antes
secureTextEntry
```

```dart
// Después
obscureText: true,
```

### 3.11. Navegación y routing — Expo Router → **GetX**

Aquí hay **tres versiones** de lo mismo, para ver la evolución:

```tsx
// 1) React Native (Expo Router): las pantallas eran ficheros y carpetas
router.push({ pathname: '/(tabs)/books/[id]/edit', params: { id: book._id } });
router.back();
```

```dart
// 2) Flutter, primera versión: Navigator (push / pop) y el id por el constructor
await Navigator.push(context, MaterialPageRoute(builder: (_) => BookFormScreen(bookId: book.id)));
Navigator.pop(context);
```

```dart
// 3) Flutter, versión actual (GetX): rutas con nombre, como en Expo Router
Get.toNamed('/books/${book.id}/edit');        // push
Get.back();                                    // pop
final id = Get.parameters['id'];               // leer el :id (antes useLocalSearchParams)
```

Las rutas se declaran **una vez** en `main.dart` (l. 45-51), con el mismo reparto que tenían las carpetas de Expo Router:

| Ruta | Pantalla | React Native |
|---|---|---|
| `/` | `HomeScreen` (4 pestañas) | `(tabs)/_layout.tsx` |
| `/books/new` | `BookFormScreen` | `books/new.tsx` |
| `/books/:id` | `BookDetailScreen` | `books/[id]/index.tsx` |
| `/books/:id/edit` | `BookFormScreen` | `books/[id]/edit.tsx` |
| `/authors/new` | `AuthorFormScreen` | `authors/new.tsx` |
| `/authors/:id` | `AuthorDetailScreen` | `authors/[id]/index.tsx` |
| `/authors/:id/edit` | `AuthorFormScreen` | `authors/[id]/edit.tsx` |

> **Orden importante:** `/books/new` va **antes** que `/books/:id`, porque si no GetX entendería "new" como un id.

**Las pestañas** (`(tabs)/_layout.tsx`, 1-72 → `home_screen.dart`, 1-65):

```tsx
// Antes: Expo Router, las pestañas se declaran en un layout
<Tabs screenOptions={{ tabBarActiveTintColor: '#2563EB' }}>
  <Tabs.Screen name="books" options={{ title: 'Libros', tabBarIcon: ... }} />
```

```dart
// Después: la pestaña activa vive en HomeController (GetX); Obx repinta al cambiar
final c = Get.put(HomeController());
Obx(() => Scaffold(
  body: IndexedStack(index: c.currentIndex.value, children: const [BooksScreen(), AuthorsScreen(), ...]),
  bottomNavigationBar: NavigationBar(
    selectedIndex: c.currentIndex.value,
    onDestinationSelected: c.changeTab,
    ...
```

| Acción | React Native | Flutter (ahora) |
|---|---|---|
| Ir a una pantalla | `router.push('/(tabs)/books/new')` | `Get.toNamed('/books/new')` |
| Pasar el id | `params: { id: book._id }` | va en la ruta: `'/books/${book.id}'` |
| Leer el id | `useLocalSearchParams` | `Get.parameters['id']` |
| Volver | `router.back()` | `Get.back()` |
| Esperar al volver | — | `await Get.toNamed(...)` y recargar |

### 3.12. Toast y diálogo — `ToastContext.tsx` (1-83) → `toast.dart` (1-19) y `ConfirmModal.tsx` (1-111) → `confirm_dialog.dart` (1-32)

```tsx
// Antes: Provider + Animated (83 líneas) -> showToast('mensaje') con useToast()
<ToastContext.Provider value={{ showToast }}> ... </ToastContext.Provider>
```

```dart
// Después: GetX ya trae avisos, y no hace falta pasar el context (19 líneas)
void showToast(String message) {
  Get.rawSnackbar(messageText: Text(message, ...), snackPosition: SnackPosition.BOTTOM, ...);
}
// uso: showToast('mensaje');          (antes: showToast(context, 'mensaje'))
```

```tsx
// Antes: componente con estado controlado desde fuera
<ConfirmModal open={bookToDelete !== null} onConfirm={confirmDelete} onCancel={() => setBookToDelete(null)} />
```

```dart
// Después: una función que devuelve true/false (confirm_dialog.dart l. 9-31)
final confirmed = await confirmDialog(title: 'Confirmar Borrado', message: '...');
if (!confirmed) return;
```

> **Detalle de GetX (descubierto probando):** si hay un aviso abierto, `Get.back()` cierra **el aviso** y no la pantalla. Por eso en los formularios primero se hace `Get.back()` y **después** `showToast(...)` (`book_form_controller.dart` l. 169-172, `author_form_controller.dart` l. 147-149).

### 3.13. Cancelar peticiones — `AbortController`

```tsx
// Antes
const controller = new AbortController();
...
return () => controller.abort();
// y en api-error.ts: isAbort(err)
```

```dart
// Después: no se cancela la petición. Los controladores de GetX viven mientras la pantalla
// existe y se borran solos al cerrarla (onClose).
```

Por eso `isAbort` (api-error.ts l. 13-21) **no existe** en Flutter. Además, al usar controladores y providers ya no hay `if (!mounted) return;` con `setState`: **no queda ningún `setState` en el proyecto.**

### 3.14. Tarjetas — `BookCard.tsx` / `AuthorCard.tsx` → `book_card.dart` / `author_card.dart`

| Parte | React Native | Flutter |
|---|---|---|
| `viewMode === 'cards'` | `const isCard = viewMode === 'cards'` | `viewMode == ViewMode.list ? _buildList() : _buildCard()` (book_card l. 66) |
| Fila (lista) | `BookCard` l. 27-70 | `book_card.dart` l. 70-146 (`_buildList`) |
| Tarjeta | `BookCard` l. 73-133 | `book_card.dart` l. 147-272 (`_buildCard`) |
| Editorial en la fila | l. 37-41 | l. 106-113 |
| Editorial en la tarjeta | l. 80-85 | l. 187-203 |
| Fila de autor | `AuthorCard` l. 22-54 | `author_card.dart` l. 67-132 |
| Tarjeta de autor | `AuthorCard` l. 56-115 | `author_card.dart` l. 134-218 |

```tsx
// Antes
<Pressable style={styles.listRow} onPress={onPress}>
  <Image source={{ uri: coverUrl }} style={styles.listCover} />
  {book.publisher ? <Text>Editorial: {book.publisher}</Text> : null}
```

```dart
// Después
InkWell(
  onTap: onTap,
  child: Row(children: [
    _cover(52, 72, 200, 300),
    if (book.publisher != null && book.publisher!.isNotEmpty)
      Text('Editorial: ${book.publisher}'),
```

**Truco de sintaxis:** `{cond ? <X/> : null}` de JSX se convierte en `if (cond) X()` dentro de la lista de hijos.

### 3.15. Pantallas de texto — `permissions.tsx` y `info.tsx`

**`permissions.tsx` (1-372) → `permissions_screen.dart` (1-195)**

| Parte | React Native | Flutter |
|---|---|---|
| Estado (`useState`) | l. 15-39 | `PermissionsController` (GetX, `permissions_controller.dart` 1-35) |
| Título (l. 41) y explicación (l. 50-58) | "el **Bridge** entre JavaScript y el móvil" | "los **Platform Channels** entre Dart y el móvil" (l. 99, 126-140) |
| Estado del permiso (l. 67-130) | Dos bloques idénticos con ternarios | Un método `_statusBadge(status)` dentro de un `Obx` (l. 155-160) |
| Botones 1-4 (l. 136-160) | `onPress={requestCameraPermission}`, etc. | `c.askCamera`, `c.askGallery`, `c.openCamera`, `c.openGallery` (l. 167-173) |

**`info.tsx` (1-249) → `info_screen.dart` (1-282)**: pasa de 7 apartados sobre React Native a **15 apartados sobre Flutter**, uno por cada tema de la hoja:

| N.º | `info_screen.dart` | Tema de la hoja |
|---|---|---|
| 1 | ¿Qué es Flutter? Multiplataforma (l. 114) | multiplataforma |
| 2 | Dart: objetos y serialización (l. 123) | Dart: Obj, Serialización |
| 3 | Dart: async/await y Future (l. 140) | Dart: async/await, Future |
| 4 | Dart: null safety (l. 150) | Dart: null safety |
| 5 | Instalar Flutter (l. 158) | Install |
| 6 | Todo es un Widget (l. 167) | Widget / tot. |
| 7 | StatelessWidget y StatefulWidget (l. 174) | Stateless / full |
| 8 | Estructura de una pantalla: Scaffold (l. 182) | Tree / Estructura / Scaffold |
| 9 | Estilo (l. 193) | Style |
| 10 | El proyecto: pubspec.yaml, lib/ y main() (l. 208) | Proyecto |
| 11 | Equivalencias React Native → Flutter (l. 217) | — |
| 12 | Navegación (push / pop) y routing con GetX (l. 233) | Navegación, Routing |
| 13 | Estado: setState, Provider y GetX (l. 248) | Estado |
| 14 | Renderizado: Skia e Impeller (l. 264) | Renderizado |
| 15 | Llamadas a la API (l. 272) | — |

El apartado 14 está comprobado con la documentación oficial de Flutter 3.47 (<https://docs.flutter.dev/perf/impeller>): Impeller es el único motor en iOS, está activado por defecto en Android API 29 o más (en versiones antiguas usa OpenGL) y **la web sigue usando Skia**.

---

## 4. Tabla de sintaxis: lo que he ido cambiando una y otra vez

| TypeScript / React Native | Dart / Flutter |
|---|---|
| `const x = 1` / `let x` | `final x = 1` / `var x` |
| `string \| undefined` / `x?: string` | `String?` |
| `x ?? 'a'` | `x ?? 'a'` (igual) |
| `x?.length` | `x?.length` (igual) |
| `` `Hola ${nombre}` `` | `'Hola $nombre'` o `'Hola ${a.b}'` |
| `arr.map(x => ...)` | `arr.map((x) => ...).toList()` (hay que acabar con `.toList()`) |
| `arr.filter(...)` | `arr.where(...).toList()` |
| `arr.includes(x)` | `arr.contains(x)` |
| `str.includes('a')` | `str.contains('a')` |
| `[...arr, x]` | `[...arr, x]` (igual) |
| `async/await` + `Promise<T>` | `async/await` + `Future<T>` |
| `try { } catch (err) { }` | `try { } catch (e) { }` |
| `{ cond ? <A /> : null }` | `if (cond) A(),` |
| `style={{ padding: 12 }}` | `padding: const EdgeInsets.all(12)` |
| `flexDirection: 'row'` | `Row(children: [...])` |
| `flexDirection: 'column'` | `Column(children: [...])` |
| `gap: 8` | `SizedBox(width: 8)` o `Wrap(spacing: 8)` |
| `fontWeight: '700'` | `fontWeight: FontWeight.w700` |
| `Number(x)` | `int.tryParse(x)` / `double.tryParse(x)` |
| `value.toFixed(2)` | `value.toStringAsFixed(2)` |
| `/regex/.test(x)` | `RegExp(r'regex').hasMatch(x)` |
| `console.error(...)` | `debugPrint(...)` |
| `useState(0)` | `0.obs` (GetX) y se lee con `.value` |
| Componente que se repinta con el estado | `Obx(() => ...)` |
| `useEffect(() => {...}, [])` | `onInit()` del controlador (o `initState`) |
| `router.push('/ruta')` | `Get.toNamed('/ruta')` |
| `router.back()` | `Get.back()` |
| `Alert.alert(...)` | `Get.dialog(AlertDialog(...))` |
| Estado compartido (Context / hooks) | `ChangeNotifier` + `context.watch<...>()` (Provider) |

---

## 5. Lo que NO he portado (y por qué)

| React Native | Motivo |
|---|---|
| `hooks/use-theme.ts`, `use-color-scheme.ts`, `use-color-scheme.web.ts` | Tema claro/oscuro de la plantilla de Expo; la app no lo usaba |
| `constants/theme.ts` (1-64) | Solo se aprovechan los colores que se repetían: están en `theme/app_colors.dart` |
| `books/_layout.tsx`, `authors/_layout.tsx` | Expo Router los usaba para apilar pantallas; en Flutter lo hacen las rutas de `main.dart` |
| `app/index.tsx` (5 líneas) | Era una redirección; Flutter arranca directo en la ruta `/` |
| `models/index.ts` | En Dart se importa cada fichero directamente |
| `isAbort` y `AbortController` | No hay cancelación de peticiones |
| Recorte de foto `aspect: [3, 4]` | `image_picker` no lo ofrece |
| `scripts/reset-project.js`, `.oxlintrc.json`, `app.json`, `tsconfig.json` | Configuración propia de Expo/TypeScript; en Flutter es `pubspec.yaml` y `analysis_options.yaml` |

---

## 6. Ficheros nuevos que no existían en React Native

| Fichero | Para qué |
|---|---|
| `providers/books_provider.dart`, `authors_provider.dart` | Estado de los datos de la API (Provider) |
| `controllers/*.dart` (7 ficheros) | Estado de cada pantalla (GetX): formularios, detalles, buscador, pestañas y permisos |
| `widgets/photo_picker_section.dart` | El bloque de foto (cámara/galería) estaba copiado en los dos formularios |
| `widgets/error_banner.dart` | El cuadro rojo de error estaba copiado en todas las pantallas |
| `widgets/field_wrapper.dart` → `inputDecoration()` | El estilo común de los campos de texto (antes `styles.input` repetido en cada fichero) |
| `widgets/role_badge.dart` → `ActiveBadge` | La etiqueta "Activo/Inactivo", que antes estaba escrita a mano en 3 sitios |
| `theme/app_colors.dart` | Los colores repetidos en todos los `StyleSheet` |
| `test/format_test.dart`, `test/models_test.dart` | Tests de las funciones de formato y de la serialización (`fromJson` / `toJson`) |

---

## 7. Ajustes de plataforma y refinamientos aplicados

Además de portar el código de `src/` a `lib/`, he modificado estos ficheros de configuración nativa y el cliente HTTP para que la app quede bien integrada:

### 7.1. Decodificación UTF-8 en `http_client.dart` (líneas 62 y 77)

En Dart, leer directamente `res.body` puede corromper tildes o caracteres en castellano/catalán si el header de la API no define el charset. He asegurado la lectura con `utf8.decode(res.bodyBytes)` tanto en el manejo de errores como en el parseo del JSON de respuesta:

```dart
// En lectura de errores:
final data = jsonDecode(utf8.decode(res.bodyBytes));

// En respuesta correcta (evita fallos en títulos como "Ficción" o autores como "García Márquez"):
return jsonDecode(utf8.decode(res.bodyBytes));
```

### 7.2. Título y metadatos en Web (`web/index.html` y `web/manifest.json`)

Al generar el proyecto con `flutter create`, la web venía con el nombre del paquete `ea_seminari9_flutter` en el título. Lo he actualizado:

- `web/index.html`: `<title>Backoffice Libros y Autores</title>` y metadato de iOS `apple-mobile-web-app-title`.
- `web/manifest.json`: `"name": "Backoffice Libros y Autores"`, `"short_name": "Backoffice"` y descripción del proyecto.

### 7.3. Nombre visible de la app en Android e iOS

- **Android (`android/app/src/main/AndroidManifest.xml`, l. 7):** he cambiado `android:label="ea_seminari9_flutter"` por `android:label="Backoffice Autores y Libros"` para que en el emulador y en el cajón de aplicaciones del móvil salga el nombre real del backoffice y no el nombre del paquete.
- **iOS (`ios/Runner/Info.plist`, l. 17-19):** he añadido `CFBundleDisplayName` con `"Backoffice Libros"` y actualizado `CFBundleName` a `ea_seminari9_flutter`.

### 7.4. Nombre del paquete: de `seminari8` a `seminari9`

Se cambió `ea_seminari8_flutter` por `ea_seminari9_flutter` en `pubspec.yaml`, el import de `test/format_test.dart`, el `namespace` y `applicationId` de `android/app/build.gradle.kts`, la carpeta y el `package` de `MainActivity.kt`, y los identificadores de iOS (`com.example.eaSeminari9Flutter`).

### 7.5. Dependencias nuevas (`pubspec.yaml`)

| Paquete | Versión | Para qué |
|---|---|---|
| `provider` | `^6.1.5+1` | Estado de los datos (`ChangeNotifier`) |
| `get` | `^4.7.3` | Rutas con nombre, estado reactivo (`.obs` y `Obx`), diálogos y avisos |

---

## 8. Problemas encontrados al probar (y cómo se arreglaron)

Al probar la versión con Provider y GetX en el navegador contra la API salieron dos fallos reales:

1. **"Ha ocurrido un error inesperado" al crear un libro, aunque la API sí lo guardaba.** La API contesta a un `POST /books` con los autores como lista de **ids** (texto), no como objetos, y `Book.fromJson` intentaba convertir cada id en un `Author`. Arreglado en `book.dart` l. 45-56 (apartado 3.3) y con un test nuevo en `test/models_test.dart`. (Este fallo lo había introducido yo mismo al simplificar el código antes: había quitado el filtro de objetos.)
2. **Después de guardar, la pantalla se quedaba en el formulario.** Con GetX, si hay un aviso abierto, `Get.back()` cierra el aviso y no la pantalla. Arreglado llamando a `Get.back()` antes que a `showToast` (apartado 3.12).
