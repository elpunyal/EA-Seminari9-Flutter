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

          _card('1. ¿Qué es Flutter y Dart?', Icons.flutter_dash, [
            _p('Flutter es un framework de Google para hacer apps de Android, iOS, web y escritorio '
                'con un solo código.'),
            _p('Se programa en Dart, un lenguaje con tipos. En producción compila a código nativo, '
                'y en desarrollo tiene hot reload.'),
          ]),

          _card('2. Todo es un Widget', Icons.widgets_outlined, [
            _p('En Flutter la interfaz es un árbol de widgets: un botón es un widget, un texto es '
                'un widget y hasta el padding o centrar algo es un widget (Padding, Center).'),
            _p('Cada widget tiene un método build() que devuelve otros widgets. '
                'Es parecido a los componentes de React, pero sin JSX ni CSS.'),
          ]),

          _card('3. Estado: StatelessWidget y StatefulWidget', Icons.sync_alt, [
            _bullet('StatelessWidget: no cambia nunca (como un componente sin useState).'),
            _bullet('StatefulWidget: tiene datos que cambian. Se modifican con setState(), '
                'que vuelve a ejecutar build() (como useState).'),
            _bullet('initState(): se ejecuta al crear la pantalla (como useEffect con []).'),
            _bullet('dispose(): se ejecuta al cerrarla, sirve para liberar controllers.'),
          ]),

          _card('4. Equivalencias React Native → Flutter', Icons.compare_arrows, [
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
          ]),

          _card('5. Eventos: onPress vs onPressed', Icons.touch_app_outlined, [
            _p('Los botones de Flutter usan onPressed (o onTap en GestureDetector).'),
            _p('En los campos de texto usamos un TextEditingController, que guarda el texto '
                'escrito, o el callback onChanged.'),
          ]),

          _card('6. Navegación', Icons.alt_route, [
            _p('En Expo Router las pantallas eran ficheros y carpetas. En Flutter usamos '
                'el Navigator:'),
            _bullet('Navigator.push(context, MaterialPageRoute(...)) abre una pantalla.'),
            _bullet('Navigator.pop(context) vuelve atrás (como router.back()).'),
            _bullet('Las pestañas de abajo son un NavigationBar con un IndexedStack.'),
          ]),

          _card('7. Llamadas a la API', Icons.cloud_outlined, [
            _p('Usamos el paquete http en vez de fetch. Hay que convertir el JSON a objetos Dart '
                'a mano (fromJson).'),
            _bullet('En el emulador de Android: http://10.0.2.2:1337'),
            _bullet('En web o iOS: http://localhost:1337'),
            _bullet('Se puede cambiar con --dart-define=API_URL=...'),
          ]),
        ],
      ),
    );
  }
}
