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
        onPageFinished: (String url) {
          // Here we need to use the context, so we pass it as a parameter later
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) async {
          if (request.url.startsWith("http") || request.url.startsWith("https")) {
            return NavigationDecision.navigate; // Allow navigation for normal URLs
          } else {
            // For unknown URL schemes (like UPI payments)
            await _launchExternalApp(request.url);
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
    try {
      if (url.startsWith("upi://")) {
        // Handle UPI URL schemes
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'No UPI app found to handle this request.';
        }
      } else if (await canLaunchUrl(Uri.parse(url))) {
        // Handle normal URLs
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Use 'const' to improve performance
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
      body: WebViewWidget(controller: _controller), // Display the WebView in full screen
    );
  }
}
