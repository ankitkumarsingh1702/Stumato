import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HfsMiniStoreScreen extends StatelessWidget {
  final String storeName;
  final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Optionally, update a loading bar or progress indicator
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith("http") || request.url.startsWith("https")) {
            return NavigationDecision.navigate; // Allow navigation for normal URLs
          } else {
            // For unknown URL schemes (like UPI payments)
            _launchExternalApp(request.url);
            return NavigationDecision.prevent; // Prevent the WebView from trying to load this URL
          }
        },
      ),
    );

  HfsMiniStoreScreen({required this.storeName, Key? key}) : super(key: key) {
    _controller.loadRequest(
      Uri.parse('https://hushh-for-students-store-vone.mini.site'), // URL to load
    );
  }

  static Future<void> _launchExternalApp(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E), // Background color to match your design
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1C1E),
        title: Text(
          storeName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller), // Display the WebView in full screen
    );
  }
}
