import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Displays a mini store using WebView.
class HfsMiniStoreScreen extends StatelessWidget {
  final String storeName;
  final String url;

  final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update progress indicator if needed
        },
        onPageStarted: (String url) {
          // Handle actions when a new page starts loading
        },
        onPageFinished: (String url) {
          // Handle actions when a page has finished loading
        },
        onHttpError: (HttpResponseError error) {
          // Manage HTTP errors
        },
        onWebResourceError: (WebResourceError error) {
          // Manage loading errors
        },
        onNavigationRequest: (NavigationRequest request) async {
          if (request.url.startsWith("http") || request.url.startsWith("https")) {
            return NavigationDecision.navigate;
          } else {
            await _launchExternalApp(request.url);
            return NavigationDecision.prevent;
          }
        },
      ),
    );

  HfsMiniStoreScreen({required this.storeName, required this.url, Key? key}) : super(key: key) {
    _controller.loadRequest(Uri.parse(url));
  }

  /// Launch external applications for specific URL schemes.
  static Future<void> _launchExternalApp(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Cannot launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(
          storeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
