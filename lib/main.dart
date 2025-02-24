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

  /// Текст сообщения об ошибке.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Регистрация платформенного виджета для отображения HTML элемента <img>.
    if (kIsWeb) {
      _imageElement = html.ImageElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..onDoubleClick.listen((_) => _toggleFullscreen())
        ..onError.listen((_) {
          setState(() {
            _errorMessage = 'Failed to load image. Please check the URL.';
          });
        });

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

  /// Проверяет, является ли введённая строка валидным URL.
  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            labelText: 'Enter image URL',
                            border: const OutlineInputBorder(),
                            errorText: _errorMessage,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            final url = _urlController.text;

                            if (_isValidUrl(url)) {
                              _errorMessage = null;
                              if (kIsWeb) {
                                _imageElement.src = url;
                              }
                            } else {
                              _errorMessage = 'Invalid URL. Please enter a valid image URL.';
                            }
                          });
                        },
                        child: const Text('Show Image'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Центрированное отображение изображения.
            Expanded(
              child: Center(
                child: kIsWeb
                    ? _errorMessage != null
                    ? Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                )
                    : const HtmlElementView(viewType: 'imageElement')
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
