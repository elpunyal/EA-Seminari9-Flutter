import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Pantalla de teoría. En React Native comparaba RN con la web;
// aquí la he cambiado para comparar Flutter con React Native.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // Tarjeta con título y contenido (cada apartado de la teoría)
  Widget _card(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _p(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF475569))),
      );

  // Trozo de código en una caja gris
  Widget _code(String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4, color: Color(0xFFE2E8F0)),
        ),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text('• $text',
            style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569))),
      );

  // Fila de la tabla de equivalencias (React Native | Flutter)
  Widget _tableRow(String rn, String flutter, {bool header = false}) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: header ? FontWeight.w800 : FontWeight.w500,
      color: header ? AppColors.text : const Color(0xFF475569),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      decoration: BoxDecoration(
        color: header ? AppColors.chipBg : Colors.transparent,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(rn, style: style)),
          Expanded(child: Text(flutter, style: style.copyWith(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Flutter vs React Native'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Resumen de Conceptos de Clase',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lo que he aprendido al pasar el proyecto de React Native a Flutter.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),

          // ---------- Flutter ----------
          _card('1. ¿Qué es Flutter? Multiplataforma', Icons.flutter_dash, [
            _p('Flutter es un framework de Google para hacer apps con un solo código. '
                'Con el mismo proyecto sale Android, iOS, web y escritorio.'),
            _bullet('Este proyecto tiene las carpetas android/, ios/ y web/ (se generan con flutter create).'),
            _bullet('Lo he probado en el navegador con flutter run -d chrome.'),
            _bullet('Se programa en Dart y en desarrollo tiene hot reload (cambias el código y se ve al momento).'),
          ]),

          // ---------- Dart y detalles ----------
          _card('2. Dart: objetos y serialización', Icons.data_object, [
            _p('En Dart los datos van en clases. La API manda JSON, así que hay que convertirlo '
                'a objeto (fromJson) y al revés (toJson). Esto es la serialización.'),
            _code('class Book {\n'
                '  final String title;\n'
                '  final String? publisher;\n'
                '  Book({required this.title, this.publisher});\n\n'
                '  // JSON -> objeto\n'
                '  factory Book.fromJson(Map<String, dynamic> json) =>\n'
                '      Book(title: json[\'title\'], publisher: json[\'publisher\']);\n\n'
                '  // objeto -> JSON\n'
                '  Map<String, dynamic> toJson() =>\n'
                '      {\'title\': title, \'publisher\': publisher};\n'
                '}'),
            _p('En TypeScript bastaba con una interface; en Dart hay que escribir esta conversión (models/book.dart).'),
          ]),

          _card('3. Dart: async/await y Future', Icons.hourglass_empty, [
            _p('Pedir datos a la API tarda, así que la función devuelve un Future (como una Promise de JavaScript). '
                'Con await esperamos a que termine y con async marcamos la función.'),
            _code('Future<List<Book>> getBooks() async {\n'
                '  final res = await request(\'/books\');\n'
                '  return (res[\'books\'] as List)\n'
                '      .map((b) => Book.fromJson(b)).toList();\n'
                '}'),
          ]),

          _card('4. Dart: null safety', Icons.shield_outlined, [
            _p('En Dart una variable normal nunca puede ser null. Si puede serlo, se añade ? al tipo.'),
            _bullet('String título: nunca null.   String? editorial: puede ser null.'),
            _bullet('?? da un valor por defecto: book.publisher ?? \'\''),
            _bullet('?. solo sigue si no es null: book.price?.toString()'),
            _bullet('! le dice a Dart "te aseguro que no es null": Get.parameters[\'id\']!'),
          ]),

          _card('5. Instalar Flutter', Icons.download_outlined, [
            _bullet('Bajar el SDK: git clone https://github.com/flutter/flutter.git -b stable'),
            _bullet('Añadir flutter/bin al PATH.'),
            _bullet('flutter doctor: comprueba que todo está bien.'),
            _bullet('flutter create --platforms=android,ios,web . crea las carpetas de cada plataforma.'),
            _bullet('flutter pub get descarga las dependencias; flutter run arranca la app.'),
          ]),

          // ---------- Widgets ----------
          _card('6. Todo es un Widget', Icons.widgets_outlined, [
            _p('En Flutter la interfaz es un árbol de widgets: un botón es un widget, un texto es '
                'un widget y hasta el padding o centrar algo es un widget (Padding, Center).'),
            _p('Cada widget tiene un método build() que devuelve otros widgets. '
                'Es parecido a los componentes de React, pero sin JSX ni CSS.'),
          ]),

          _card('7. StatelessWidget y StatefulWidget', Icons.sync_alt, [
            _bullet('StatelessWidget: no guarda datos que cambien (como un componente sin useState).'),
            _bullet('StatefulWidget: tiene un State con datos que cambian y se repinta con setState().'),
            _bullet('initState() / dispose(): al crear y al cerrar la pantalla (como useEffect).'),
            _p('En este proyecto ya no uso setState: casi todas las pantallas son StatelessWidget y '
                'el estado está en Provider y GetX (apartado 13).'),
          ]),

          _card('8. Estructura de una pantalla: Scaffold', Icons.account_tree_outlined, [
            _p('Scaffold es el esqueleto de una pantalla. Dentro se colocan las partes y cada una es un widget:'),
            _code('Scaffold\n'
                ' ├─ appBar: AppBar          (la barra de arriba)\n'
                ' ├─ body:  Column / ListView (el contenido)\n'
                ' │    ├─ Text, TextField...\n'
                ' │    └─ ElevatedButton\n'
                ' └─ bottomNavigationBar: NavigationBar (las pestañas)'),
            _p('Ese árbol se puede ver en las pantallas de este proyecto (por ejemplo home_screen.dart).'),
          ]),

          _card('9. Estilo (Style)', Icons.palette_outlined, [
            _p('En React Native los estilos iban en un StyleSheet. En Flutter van dentro del propio widget '
                'y hay un tema global:'),
            _bullet('ThemeData en main.dart: colores y fuentes de toda la app.'),
            _bullet('theme/app_colors.dart: los colores que se repetían en los StyleSheet.'),
            _bullet('TextStyle, BoxDecoration, EdgeInsets: el estilo de cada widget.'),
            _code('Container(\n'
                '  padding: const EdgeInsets.all(12),\n'
                '  decoration: BoxDecoration(color: AppColors.primary,\n'
                '      borderRadius: BorderRadius.circular(10)),\n'
                '  child: Text(\'Hola\', style: TextStyle(color: Colors.white)),\n'
                ')'),
          ]),

          // ---------- Proyecto ----------
          _card('10. El proyecto: pubspec.yaml, lib/ y main()', Icons.folder_outlined, [
            _bullet('pubspec.yaml: nombre, versión y dependencias (como el package.json): http, image_picker, permission_handler, provider y get.'),
            _bullet('lib/: todo el código Dart (models, services, providers, controllers, screens, widgets).'),
            _bullet('lib/main.dart: tiene main(), lo primero que se ejecuta. Llama a runApp() con el widget raíz.'),
            _code('void main() {\n'
                '  runApp(const MyApp());\n'
                '}'),
          ]),

          _card('11. Equivalencias React Native → Flutter', Icons.compare_arrows, [
            _tableRow('React Native', 'Flutter', header: true),
            _tableRow('<View>', 'Container / Column / Row'),
            _tableRow('<Text>', 'Text'),
            _tableRow('<TextInput>', 'TextField / TextFormField'),
            _tableRow('<Pressable>', 'GestureDetector / InkWell'),
            _tableRow('<Image>', 'Image.network / Image.file'),
            _tableRow('<FlatList>', 'ListView.builder'),
            _tableRow('<ScrollView>', 'SingleChildScrollView'),
            _tableRow('RefreshControl', 'RefreshIndicator'),
            _tableRow('StyleSheet', 'Propiedades del widget'),
            _tableRow('useState', 'Rx (GetX) / ChangeNotifier'),
            _tableRow('Expo Router', 'GetX (rutas con nombre)'),
          ]),

          // ---------- Navegación, routing y estado ----------
          _card('12. Navegación (push / pop) y routing con GetX', Icons.alt_route, [
            _p('La navegación funciona como una pila de pantallas: push mete una pantalla y pop saca la de arriba.'),
            _code('// Navigator de Flutter\n'
                'Navigator.push(context, MaterialPageRoute(builder: (_) => Pantalla()));\n'
                'Navigator.pop(context);\n\n'
                '// GetX hace lo mismo con rutas con nombre\n'
                'Get.toNamed(\'/books/new\');   // push\n'
                'Get.back();                  // pop'),
            _p('Las rutas se declaran en main.dart con GetMaterialApp y getPages, igual que las carpetas de Expo Router:'),
            _bullet('/ → HomeScreen (las pestañas)'),
            _bullet('/books/new, /books/:id, /books/:id/edit'),
            _bullet('/authors/new, /authors/:id, /authors/:id/edit'),
            _p('El :id se lee con Get.parameters[\'id\'] (en Expo era useLocalSearchParams).'),
          ]),

          _card('13. Estado: setState, Provider y GetX', Icons.account_tree, [
            _bullet('setState: lo básico de un StatefulWidget. Funciona, pero hay que pasar los datos a mano entre pantallas.'),
            _bullet('Provider: guarda el estado en una clase ChangeNotifier. Al hacer notifyListeners() se repintan las pantallas que la miran con context.watch().'),
            _bullet('GetX: variables observables con .obs; un Obx(() => ...) se repinta solo cuando cambian.'),
            _p('Cómo lo reparto en este proyecto:'),
            _bullet('Provider → los datos de la API que comparten varias pantallas: lista de libros y de autores (BooksProvider, AuthorsProvider).'),
            _bullet('GetX → el estado de cada pantalla: formularios, buscador, vista lista/tarjetas, pestaña activa y permisos (carpeta controllers/).'),
            _code('// Provider\n'
                'final provider = context.watch<BooksProvider>();\n'
                'provider.books ...\n\n'
                '// GetX\n'
                'final search = \'\'.obs;\n'
                'Obx(() => Text(search.value));'),
          ]),

          // ---------- Renderizado ----------
          _card('14. Renderizado: Skia e Impeller', Icons.brush_outlined, [
            _p('React Native usa los componentes nativos de cada sistema. Flutter no: dibuja él mismo '
                'cada píxel de la pantalla con su motor gráfico. Por eso la app se ve igual en Android, iOS y web (multiplataforma).'),
            _bullet('Skia: el motor gráfico clásico de Flutter. Hoy la web sigue usando Skia.'),
            _bullet('Impeller: el motor nuevo. Es el único en iOS y está activado por defecto en Android (API 29 o más); en Android más antiguos usa OpenGL.'),
            _p('(Comprobado con la documentación oficial de Flutter sobre Impeller: docs.flutter.dev/perf/impeller)'),
          ]),

          _card('15. Llamadas a la API', Icons.cloud_outlined, [
            _p('Usamos el paquete http en vez de fetch. El JSON se convierte a objetos Dart con fromJson (apartado 2).'),
            _bullet('En el emulador de Android: http://10.0.2.2:1337'),
            _bullet('En web o iOS: http://localhost:1337'),
            _bullet('Se puede cambiar con --dart-define=API_URL=...'),
          ]),
        ],
      ),
    );
  }
}
