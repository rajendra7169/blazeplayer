import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppWebViewGoogleImage extends StatefulWidget {
  final String query;
  final bool isDark;
  final Function(String imageUrl) onImageSelected;
  const InAppWebViewGoogleImage({
    super.key,
    required this.query,
    required this.isDark,
    required this.onImageSelected,
  });

  @override
  State<InAppWebViewGoogleImage> createState() =>
      _InAppWebViewGoogleImageState();
}

class _InAppWebViewGoogleImageState extends State<InAppWebViewGoogleImage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        widget.isDark ? const Color(0xFF232323) : Colors.white,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await _controller.runJavaScript('''
              document.querySelectorAll('img').forEach(function(img) {
                img.onclick = function(e) {
                  window.flutter_inappwebview.postMessage(img.src);
                };
              });
            ''');
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          final imageUrl = message.message;
          widget.onImageSelected(imageUrl);
        },
      )
      ..loadRequest(
        Uri.parse(
          'https://www.google.com/search?tbm=isch&q=${Uri.encodeComponent(widget.query)}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? const Color(0xFF232323) : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: isDark ? Colors.white : Colors.black,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Spacer(),
                        Image.asset(
                          isDark
                              ? 'assets/logo/logo_white.png'
                              : 'assets/logo/logo.png',
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: isDark
                                  ? [Colors.white, Colors.white]
                                  : [
                                      const Color(0xFFFFA726),
                                      const Color(0xFFFF7043),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Blaze Player',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Spacer(flex: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox.expand(
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
