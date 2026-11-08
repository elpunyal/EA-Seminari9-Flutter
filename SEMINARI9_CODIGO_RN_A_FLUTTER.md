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

---

## 1. Resumen en números

| | React Native | Flutter |
|---|---|---|
| Lenguaje | TypeScript (`.ts`, `.tsx`) | Dart (`.dart`) |
| Ficheros de código | 39 | 28 |
| Líneas de código | 5.434 | 3.787 |
| Estilos | `StyleSheet.create` al final de cada fichero (~40 % de las líneas de pantallas y componentes) | Dentro del propio widget |
| Backend | `EA-Seminari9-Flutter-API` | El mismo, **sin tocar** |

Flutter tiene menos líneas sobre todo por dos motivos: los estilos van dentro del widget (ya no hay un `StyleSheet` aparte de cientos de líneas) y los formularios de crear y editar se han unido en un solo fichero.

---

## 2. Mapa completo de ficheros

### 2.1. Configuración, modelos, servicios y utilidades

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `config/environment.ts` | 1-13 | → | `config/environment.dart` | 1-21 |
| `models/author.model.ts` | 1-22 | → | `models/author.dart` | 1-46 |
| `models/book.model.ts` | 1-34 | → | `models/book.dart` | 1-69 |
| `models/index.ts` | 2 | → | *(no hace falta, Dart importa cada fichero)* | — |
| `services/http.ts` | 1-55 | → | `services/http_client.dart` | 1-78 |
| `services/author.service.ts` | 1-37 | → | `services/author_service.dart` | 1-36 |
| `services/book.service.ts` | 1-37 | → | `services/book_service.dart` | 1-36 |
| `utils/format.ts` | 1-38 | → | `utils/format.dart` | 1-61 (partes 1-43) |
| `utils/api-error.ts` | 1-21 | → | `utils/format.dart` (`errorMessage`) | 45-51 |
| `utils/remove-empty.ts` | 1-15 | → | `utils/format.dart` (`removeEmpty`) | 54-61 |
| `constants/theme.ts` | 1-64 | → | `theme/app_colors.dart` | 1-18 |

### 2.2. Hooks y contexto (en Flutter no existen)

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `hooks/usePermissions.ts` | 1-112 | → | `services/permissions_service.dart` | 1-139 |
| `hooks/useApiList.ts` | 1-66 | → | variables y `_load...()` dentro de cada pantalla | `books_screen.dart` 24-60, `authors_screen.dart` 24-60 |
| `hooks/useForm.ts` | 1-97 | → | `Form` + `TextEditingController` dentro de cada formulario | `book_form_screen.dart` 29-43, `author_form_screen.dart` 25-35 |
| `context/ToastContext.tsx` | 1-83 | → | `widgets/toast.dart` | 1-22 |
| `hooks/use-theme.ts`, `use-color-scheme*.ts` | 1-36 | → | *(no portados: era el tema claro/oscuro de la plantilla de Expo y no se usaba)* | — |

### 2.3. Componentes

| React Native | Líneas | → | Flutter | Líneas |
|---|---|---|---|---|
| `components/BookCard.tsx` | 1-318 (JSX 17-133, estilos 135-318) | → | `widgets/book_card.dart` | 1-292 |
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
| `app/_layout.tsx` + `app/index.tsx` | 18 + 5 | → | `main.dart` | 1-29 |
| `app/(tabs)/_layout.tsx` | 1-72 | → | `screens/home_screen.dart` | 1-64 |
| `app/(tabs)/books/_layout.tsx`, `authors/_layout.tsx` | 19 + 19 | → | *(no hacen falta: `Navigator.push`)* | — |
| `app/(tabs)/books/index.tsx` | 1-275 | → | `screens/books_screen.dart` | 1-235 |
| `app/(tabs)/books/new.tsx` | 1-539 | → | `screens/book_form_screen.dart` (modo crear) | 1-440 |
| `app/(tabs)/books/[id]/edit.tsx` | 1-466 | → | `screens/book_form_screen.dart` (modo editar) | *(el mismo)* |
| `app/(tabs)/books/[id]/index.tsx` | 1-316 | → | `screens/book_detail_screen.dart` | 1-312 |
| `app/(tabs)/authors/index.tsx` | 1-256 | → | `screens/authors_screen.dart` | 1-208 |
| `app/(tabs)/authors/new.tsx` | 1-460 | → | `screens/author_form_screen.dart` (modo crear) | 1-366 |
| `app/(tabs)/authors/[id]/edit.tsx` | 1-403 | → | `screens/author_form_screen.dart` (modo editar) | *(el mismo)* |
| `app/(tabs)/authors/[id]/index.tsx` | 1-283 | → | `screens/author_detail_screen.dart` | 1-268 |
| `app/(tabs)/permissions.tsx` | 1-372 | → | `screens/permissions_screen.dart` | 1-217 |
| `app/(tabs)/info.tsx` | 1-249 | → | `screens/info_screen.dart` | 1-158 |

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

**Qué cambia:** `fetch` → paquete `http`; `res.ok` → comprobar `statusCode` a mano; `res.json()` → `jsonDecode`; `ApiError extends Error` → `ApiException implements Exception`; ya no hay genéricos `<T>` porque se devuelve `dynamic` y cada servicio lo convierte.

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

### 3.3. Modelos — `book.model.ts` (1-34) → `book.dart` (1-69)

```ts
// Antes: una interface (solo existe al compilar, no convierte nada)
export interface Book extends Omit<BookInput, 'authors'> {
  _id: string;
  authors: Author[];
  publisher?: string;
}
```

```dart
// Después: una clase real con fromJson, porque Dart no convierte el JSON solo
class Book {
  final String id;
  final String? publisher;                 // editorial (ejercicio)
  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['_id'] as String,
        publisher: json['publisher'] as String?,
        price: (json['price'] as num?)?.toDouble(),   // puede venir int o double
        ...
      );
}
```

**Qué cambia:** `_id` pasa a `id`; `?` en un tipo (`String?`) equivale a `?:` de TypeScript; el JSON hay que convertirlo a mano.

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

`errorMessage` también pasa a este fichero y `isAbort` desaparece (ver 3.12).

### 3.4b. Permisos — `usePermissions.ts` (1-112) → `permissions_service.dart` (1-139)

| Qué hace | React Native | Flutter |
|---|---|---|
| Pedir cámara | `ImagePicker.requestCameraPermissionsAsync()` (l. 15) | `Permission.camera.request()` (l. 63) |
| Alerta si se deniega | `Alert.alert(...)` (l. 20, 48) | `showDialog` + `AlertDialog` (l. 28) |
| Abrir ajustes | `Linking.openSettings()` (l. 29, 57) | `openAppSettings()` (l. 43) |
| Hacer foto | `ImagePicker.launchCameraAsync({ allowsEditing, aspect: [3,4] })` (l. 74) | `_picker.pickImage(source: camera, imageQuality: 80)` (l. 127) |
| Elegir de galería | `ImagePicker.launchImageLibraryAsync(...)` (l. 91) | `_picker.pickImage(source: gallery, ...)` (l. 136) |
| Guardar estado | `useState` (l. 9-10) | campos `cameraStatus` y `mediaLibraryStatus` de la clase |

**Cambios de comportamiento aquí:** en Android no se pide permiso de galería (el selector del sistema no lo necesita); en web no se piden permisos; no hay recorte 3:4.

### 3.5. Lista de libros — `books/index.tsx` (1-275) → `books_screen.dart` (1-235)

| Qué hace | React Native | Flutter |
|---|---|---|
| Pedir los libros al abrir | `useApiList(bookService.getBooks)` (l. 42) | `initState()` → `_loadBooks()` (l. 35-37, 48) |
| Estado (buscar, vista) | `useState` (l. 44-47) | variables `_search`, `_viewMode` + `setState` (l. 24-30) |
| Filtrar con editorial | `matchesBook` (l. 26-33) | `_matchesBook` (l. 68-74) |
| Lista filtrada | `useMemo` (l. 51) | getter `_filteredBooks` (l. 77-80) |
| Borrar | `confirmDelete` + `<ConfirmModal>` (l. 57, 170) | `_deleteBook` con `confirmDialog` (l. 83) |
| Ir a editar/detalle | `router.push(...)` (l. 72, 80) | `_goTo(Widget)` con `Navigator.push` (l. 106) |
| Lista | `<FlatList>` (l. 134) | `ListView.builder` (l. 212) |
| Arrastrar para refrescar | `<RefreshControl>` (l. 147) | `RefreshIndicator` (l. 180) |

**Antes**

```tsx
const { items: books, loading, error, removeItem, onRefresh, refreshing } =
  useApiList(bookService.getBooks);

const filteredBooks = useMemo(() => {
  if (!search.trim()) return books;
  return books.filter((b) => matchesBook(b, search.trim()));
}, [books, search]);
```

**Después**

```dart
@override
void initState() {            // = useEffect(() => {...}, [])
  super.initState();
  _loadBooks();
}

List<Book> get _filteredBooks {   // = useMemo
  if (_search.trim().isEmpty) return _books;
  return _books.where((b) => _matchesBook(b, _search.trim())).toList();
}
```

**Editorial en el buscador (ejercicio)**

```ts
// Antes (books/index.tsx, l. 26-33)
(book.publisher?.toLowerCase().includes(query) ?? false) ||
```

```dart
// Después (books_screen.dart, l. 68-74)
(book.publisher?.toLowerCase().contains(query) ?? false) ||
```

### 3.6. Formulario de libro — `new.tsx` (1-539) + `[id]/edit.tsx` (1-466) → `book_form_screen.dart` (1-440)

| Qué hace | React Native | Flutter |
|---|---|---|
| Valores del formulario | `useForm` + `INITIAL_VALUES` (new l. 42, 86) | un `TextEditingController` por campo (l. 29-43) |
| Editorial en el formulario | `publisher: ''` (new l. 45) + `<TextInput>` (l. 218-224) | `_publisherCtrl` (l. 33) + `TextFormField` (l. 300) |
| Precargar al editar | `fill({...})` (edit l. 96-107) | `_loadData()` (l. 74-103) |
| Elegir autor / etiqueta | `toggleAuthor`, `toggleTag` (new l. 92, 102) | `_toggleAuthor`, `_toggleTag` (l. 109, 115) |
| Validación | `validate()` (new l. 56-80) | `_validateRequired/Year/Pages/Price` (l. 132-157) |
| Enviar | `handleSubmit` (new l. 124) | `_handleSubmit` (l. 159) |
| Crear / editar | dos ficheros: `createBook` (new l. 145) / `updateBook` (edit l. 160) | un `if (_isEditing)` (l. 189-193) |
| Volver atrás | `router.back()` (new l. 147) | `Navigator.pop(context)` (l. 196) |

**Antes (editorial, `new.tsx`)**

```tsx
type BookFormValues = { ...; publisher: string; ... };
const INITIAL_VALUES = { ...; publisher: ''; ... };

<Field label="Editorial (Publisher)" error={form.errorOf('publisher')} hint="Nombre de la casa editorial">
  <TextInput
    value={form.values.publisher}
    onChangeText={form.handleChangeText('publisher')}
    placeholder="Ej. Editorial Cátedra / Planeta"
  />
</Field>

const payload = removeEmpty({
  ...values,
  publisher: values.publisher.trim() ? values.publisher.trim() : undefined,
  publishedYear: values.publishedYear === '' ? undefined : Number(values.publishedYear),
});
```

**Después**

```dart
final _publisherCtrl = TextEditingController();      // Editorial (ejercicio)

FieldWrapper(
  label: 'Editorial (Publisher)',
  hint: 'Nombre de la casa editorial',
  child: TextFormField(
    controller: _publisherCtrl,
    decoration: inputDecoration('Ej. Editorial Cátedra / Planeta'),
  ),
),

final payload = removeEmpty({
  'publisher': _publisherCtrl.text.trim(),           // si está vacía, removeEmpty la quita
  'publishedYear': int.tryParse(_yearCtrl.text.trim()),
  ...
});
```

**Validación — antes y después**

```ts
// Antes: una función con todas las reglas
if (!values.title.trim()) errors.title = 'El título es obligatorio';
if (values.publishedYear !== '') {
  const year = Number(values.publishedYear);
  if (year < 1450 || year > 2100) errors.publishedYear = 'Año entre 1450 y 2100';
}
```

```dart
// Después: un validator por campo, que devuelve el error o null
String? _validateYear(String? value) {
  if (value == null || value.trim().isEmpty) return null;      // opcional
  final year = int.tryParse(value.trim());
  if (year == null || year < 1450 || year > 2100) return 'Año entre 1450 y 2100';
  return null;
}
```

**Precargar al editar (ejercicio)**

```tsx
// Antes (edit.tsx l. 96-107)
fill({ title: book.title, publisher: book.publisher ?? '', price: book.price?.toString() ?? '' });
```

```dart
// Después (book_form_screen.dart l. 85-95)
_titleCtrl.text = book.title;
_publisherCtrl.text = book.publisher ?? '';
_priceCtrl.text = book.price?.toString() ?? '';
```

### 3.7. Detalle de libro — `[id]/index.tsx` (1-316) → `book_detail_screen.dart` (1-312)

```tsx
// Antes: useEffect + AbortController
useEffect(() => {
  const controller = new AbortController();
  bookService.getBook(id, controller.signal).then(setBook)...
  return () => controller.abort();
}, [id]);
```

```dart
// Después: initState + mounted
@override
void initState() { super.initState(); _loadBook(); }

Future<void> _loadBook() async {
  final book = await BookService.getBook(widget.bookId);
  if (!mounted) return;            // si ya salieron de la pantalla, no seguimos
  setState(() { _book = book; _loading = false; });
}
```

| Parte | React Native | Flutter |
|---|---|---|
| Portada de prueba | l. 69 `picsum.photos/seed/${book._id}/400/500` | l. 167 `picsum.photos/seed/${book.id}/400/500` |
| Etiqueta Editorial | l. 81-86 | l. 196-221 |
| Botón Editar Libro | l. 149 | l. 302 |

### 3.8. Formulario de autor — `authors/new.tsx` (1-460) + `[id]/edit.tsx` (1-403) → `author_form_screen.dart` (1-366)

| Qué hace | React Native | Flutter |
|---|---|---|
| Reglas de validación | `validate()` new l. 49-78 / edit l. 47-76 | `_validateName/Email/Password/Confirm/Website` (l. 106-133) |
| No enviar `confirmPassword` | `const { confirmPassword: _cp, ...formData } = form.values` (new l. 105) | simplemente no se incluye en el mapa del payload (l. 142-151) |
| Precargar al editar | `fill({...})` (edit l. 95-103) | `_loadAuthor()` (l. 70-95) |
| Interruptor activo | `<Switch>` (new l. 263) | `Switch(...)` (l. 323) |
| Crear / editar | `createAuthor` (new l. 112) / `updateAuthor` (edit l. 131) | `if (_isEditing)` (l. 159-163) |

```tsx
// Antes
secureTextEntry
```

```dart
// Después
obscureText: true,
```

### 3.9. Navegación y pestañas — `_layout.tsx` + `(tabs)/_layout.tsx` → `home_screen.dart` + `main.dart`

```tsx
// Antes: Expo Router, las pestañas se declaran en un layout y cada pantalla es un fichero
<Tabs screenOptions={{ tabBarActiveTintColor: '#2563EB' }}>
  <Tabs.Screen name="books" options={{ title: 'Libros', tabBarIcon: ... }} />
  <Tabs.Screen name="authors" options={{ title: 'Autores' }} />
  ...
</Tabs>
```

```dart
// Después: un NavigationBar y un IndexedStack que enseña una pantalla u otra
body: IndexedStack(index: _currentIndex, children: const [
  BooksScreen(), AuthorsScreen(), PermissionsScreen(), InfoScreen(),
]),
bottomNavigationBar: NavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (index) => setState(() => _currentIndex = index),
  destinations: const [ NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Libros'), ... ],
),
```

| Acción | React Native | Flutter |
|---|---|---|
| Ir a una pantalla | `router.push('/(tabs)/books/new')` | `Navigator.push(context, MaterialPageRoute(builder: (_) => BookFormScreen()))` |
| Pasar el id | `params: { id: book._id }` y leerlo con `useLocalSearchParams` | `BookFormScreen(bookId: book.id)` por el constructor |
| Volver | `router.back()` | `Navigator.pop(context)` |
| Recargar al volver | (la lista se recargaba sola al montarse) | `await Navigator.push(...); _loadBooks();` |

### 3.10. Toast — `ToastContext.tsx` (1-83) → `toast.dart` (1-22)

```tsx
// Antes: Provider + Animated (83 líneas)
<ToastContext.Provider value={{ showToast }}>
  {children}
  {message && <Animated.View style={[styles.toastContainer, { opacity: fadeAnim }]}>...</Animated.View>}
</ToastContext.Provider>
// uso: const { showToast } = useToast();  showToast('mensaje');
```

```dart
// Después: Flutter ya trae SnackBar (22 líneas)
void showToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, ...));
}
// uso: showToast(context, 'mensaje');
```

### 3.11. Diálogo de confirmar — `ConfirmModal.tsx` (1-111) → `confirm_dialog.dart` (1-32)

```tsx
// Antes: componente con estado controlado desde fuera
<ConfirmModal open={bookToDelete !== null} title="Confirmar Borrado" onConfirm={confirmDelete} onCancel={() => setBookToDelete(null)} />
```

```dart
// Después: una función que devuelve true/false
final confirmed = await confirmDialog(context, title: 'Confirmar Borrado', message: '...');
if (!confirmed) return;
```

### 3.12. Cancelar peticiones — `AbortController` (en `useApiList`, `[id]/index.tsx`, `edit.tsx`)

```tsx
// Antes
const controller = new AbortController();
...
return () => controller.abort();
// y en api-error.ts: isAbort(err)
```

```dart
// Después: no se cancela la petición; se comprueba al volver
if (!mounted) return;
setState(...);
```

Por eso `isAbort` (api-error.ts l. 13-21) **no existe** en Flutter.

### 3.13. Tarjetas — `BookCard.tsx` / `AuthorCard.tsx` → `book_card.dart` / `author_card.dart`

| Parte | React Native | Flutter |
|---|---|---|
| `viewMode === 'cards'` | `const isCard = viewMode === 'cards'` | `viewMode == ViewMode.list ? _buildList() : _buildCard()` |
| Fila (lista) | `BookCard` l. 27-70 | `book_card.dart` l. 81-155 (`_buildList`) |
| Tarjeta | `BookCard` l. 73-133 | `book_card.dart` l. 158-290 (`_buildCard`) |
| Editorial en la fila | l. 37-41 | l. 117-125 |
| Editorial en la tarjeta | l. 80-85 | l. 205-221 |
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

### 3.14. Pantallas de texto — `permissions.tsx` y `info.tsx`

Aquí no cambia la lógica pero **sí el contenido**:

| Parte | React Native | Flutter |
|---|---|---|
| Título de permisos (permissions l. 41 → `permissions_screen.dart` l. 128) | "Permisos Nativos y el **Bridge**" | "Permisos Nativos y los **Platform Channels**" |
| Explicación (l. 50-58 → l. 155-172) | Habla del Bridge entre JavaScript y el móvil | Habla de Platform Channels entre Dart y el móvil |
| Estado del permiso (l. 67-130 → l. 46-100) | Dos bloques idénticos con ternarios | Un método `_statusBadge(status)` reutilizado |
| Botones 1-4 (l. 136-160 → l. 191-202) | `onPress={requestCameraPermission}`, etc. | `_askCamera`, `_askGallery`, `_openCamera`, `_openGallery` |
| `info.tsx` (1-249) → `info_screen.dart` (1-158) | 7 apartados sobre React Native vs web | 7 apartados sobre Flutter: Flutter y Dart, widgets, estado, tabla de equivalencias, eventos, navegación, API |

Apartados de la teoría:

| N.º | React Native (info.tsx) | Flutter (info_screen.dart) |
|---|---|---|
| 1 | ¿Qué es React Native y Expo? (l. 18) | ¿Qué es Flutter y Dart? (l. 98) |
| 2 | El Bridge (l. 34) | Todo es un Widget (l. 105) |
| 3 | Adiós al DOM: componentes nativos (l. 50) | Estado: Stateless y Stateful (l. 112) |
| 4 | Eventos: onClick vs onPress (l. 91) | Equivalencias RN → Flutter (l. 120) |
| 5 | Pantallas y Router de Expo (l. 107) | Eventos: onPress vs onPressed (l. 133) |
| 6 | Props, State y Hooks (l. 122) | Navegación (l. 139) |
| 7 | Llamadas a la API (l. 136) | Llamadas a la API (l. 147) |

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

---

## 5. Lo que NO he portado (y por qué)

| React Native | Motivo |
|---|---|
| `hooks/use-theme.ts`, `use-color-scheme.ts`, `use-color-scheme.web.ts` | Tema claro/oscuro de la plantilla de Expo; la app no lo usaba |
| `constants/theme.ts` (1-64) | Solo se aprovechan los colores que se repetían: están en `theme/app_colors.dart` |
| `books/_layout.tsx`, `authors/_layout.tsx` | Expo Router los usaba para apilar pantallas; en Flutter lo hace `Navigator` |
| `app/index.tsx` (5 líneas) | Era una redirección; Flutter arranca directo en `HomeScreen` |
| `models/index.ts` | En Dart se importa cada fichero directamente |
| `isAbort` y `AbortController` | No hay cancelación de peticiones; se usa `mounted` |
| Recorte de foto `aspect: [3, 4]` | `image_picker` no lo ofrece |
| `scripts/reset-project.js`, `.oxlintrc.json`, `app.json`, `tsconfig.json` | Configuración propia de Expo/TypeScript; en Flutter es `pubspec.yaml` y `analysis_options.yaml` |

---

## 6. Ficheros nuevos que no existían en React Native

| Fichero | Para qué |
|---|---|
| `widgets/photo_picker_section.dart` | El bloque de foto (cámara/galería) estaba copiado en los dos formularios |
| `widgets/error_banner.dart` | El cuadro rojo de error estaba copiado en todas las pantallas |
| `widgets/field_wrapper.dart` → `inputDecoration()` | El estilo común de los campos de texto (antes `styles.input` repetido en cada fichero) |
| `widgets/role_badge.dart` → `ActiveBadge` | La etiqueta "Activo/Inactivo", que antes estaba escrita a mano en 3 sitios |
| `theme/app_colors.dart` | Los colores repetidos en todos los `StyleSheet` |
| `test/format_test.dart` | Un test de las funciones de formato |

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

Al generar el proyecto con `flutter create`, la web venía con el nombre del paquete `ea_seminari8_flutter` en el título. Lo he actualizado:

- `web/index.html`: `<title>Backoffice Libros y Autores</title>` y metadato de iOS `apple-mobile-web-app-title`.
- `web/manifest.json`: `"name": "Backoffice Libros y Autores"`, `"short_name": "Backoffice"` y descripción del proyecto.

### 7.3. Nombre visible de la app en Android e iOS

- **Android (`android/app/src/main/AndroidManifest.xml`, l. 7):** he cambiado `android:label="ea_seminari8_flutter"` por `android:label="Backoffice Autores y Libros"` para que en el emulador y en el cajón de aplicaciones del móvil salga el nombre real del backoffice y no el nombre del paquete.
- **iOS (`ios/Runner/Info.plist`, l. 17-19):** he añadido `CFBundleDisplayName` con `"Backoffice Libros"` y actualizado `CFBundleName` a `ea_seminari9_flutter`.
