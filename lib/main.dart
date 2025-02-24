import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Основной метод приложения.
void main() {
  runApp(const MyApp());
}

/// Корневой виджет приложения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ImageWithContextMenu(),
      ),
    );
  }
}

/// Виджет, который содержит функционал для отображения изображения и контекстного меню.
class ImageWithContextMenu extends StatefulWidget {
  const ImageWithContextMenu({super.key});

  @override
  _ImageWithContextMenuState createState() => _ImageWithContextMenuState();
}

class _ImageWithContextMenuState extends State<ImageWithContextMenu> {
  /// Контроллер для ввода URL изображения.
  final TextEditingController _urlController = TextEditingController();

  /// Содержит HTML элемент изображения для отображения на вебе.
  late html.ImageElement _imageElement;

  /// Флаг видимости контекстного меню.
  bool _menuVisible = false;

  @override
  void initState() {
    super.initState();

    // Регистрация платформенного виджета для отображения HTML элемента <img>.
    if (kIsWeb) {
      _imageElement = html.ImageElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..onDoubleClick.listen((_) => _toggleFullscreen());

      ui.platformViewRegistry.registerViewFactory(
        'imageElement',
            (int viewId) => _imageElement,
      );
    }
  }

  /// Переключение полноэкранного режима.
  void _toggleFullscreen() {
    if (!kIsWeb) return;
    final document = html.window.document;
    if (document.fullscreenElement != null) {
      document.exitFullscreen();
    } else {
      document.documentElement?.requestFullscreen();
    }
  }

  /// Переключение видимости контекстного меню.
  void _toggleContextMenu() {
    setState(() {
      _menuVisible = !_menuVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Поле для ввода URL изображения и кнопка для его отображения.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Enter image URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (kIsWeb && _urlController.text.isNotEmpty) {
                        setState(() {
                          _imageElement.src = _urlController.text;
                        });
                      }
                    },
                    child: const Text('Show Image'),
                  ),
                ],
              ),
            ),

            // Центрированное отображение изображения.
            Expanded(
              child: Center(
                child: kIsWeb
                    ? const HtmlElementView(viewType: 'imageElement')
                    : const Text('Image display is only supported on Web.'),
              ),
            ),
          ],
        ),

        // Фон для затемнения экрана при видимом контекстном меню.
        if (_menuVisible)
          GestureDetector(
            onTap: _toggleContextMenu,
            child: Container(
              color: Colors.black45, // Полупрозрачный фон.
            ),
          ),

        // Контекстное меню с кнопками.
        if (_menuVisible)
          Positioned(
            right: 16,
            bottom: 80,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Enter fullscreen'),
                      onTap: () {
                        if (kIsWeb) html.document.documentElement?.requestFullscreen();
                        _toggleContextMenu();
                      },
                    ),
                    ListTile(
                      title: const Text('Exit fullscreen'),
                      onTap: () {
                        if (kIsWeb) html.document.exitFullscreen();
                        _toggleContextMenu();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Кнопка FloatingActionButton для вызова контекстного меню.
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _toggleContextMenu,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
