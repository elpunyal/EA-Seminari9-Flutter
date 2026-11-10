# Ejercicio: chat sencillo en Flutter

Proponemos hacer un **chat sencillo** en Flutter, **sin websockets**, para practicar lo que hemos visto en clase.

## Qué hay que hacer

1. **Modelo `Message`**: guarda el texto, el emisor y la fecha. Tiene `fromJson` y `toJson`.
2. **`ChatProvider`**: guarda la lista de mensajes y tiene un método `send` que llama a `notifyListeners()`.
3. **`ChatScreen`**: una pantalla con:
   - un `Scaffold`
   - un `ListView.builder` que muestra los mensajes (los propios a la derecha)
   - un `TextField` y un botón **Enviar**
4. **Ruta `/chat`**: se llega a la pantalla con `Get.toNamed('/chat')`.
5. **Controlador GetX**: con variables `.obs` y `Obx`, guarda el texto escrito y desactiva el botón Enviar si el campo está vacío.

**Condición:** no se puede usar `setState` en ningún momento.
