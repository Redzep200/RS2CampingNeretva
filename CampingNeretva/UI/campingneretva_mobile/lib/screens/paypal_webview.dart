import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;
  final Function(String orderId) onSuccess;
  final Function() onCancel;
  final Function(String error) onError;

  const PayPalWebView({
    super.key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
    required this.onSuccess,
    required this.onCancel,
    required this.onError,
  });

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (progress == 100) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onPageStarted: (String url) {
                _checkForRedirect(url);
              },
              onPageFinished: (String url) {
                _checkForRedirect(url);
              },
              onWebResourceError: (WebResourceError error) {
                widget.onError('WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _checkForRedirect(String url) {
    if (url.startsWith(widget.returnUrl)) {
      // Extract order ID from URL parameters
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'];
      if (token != null) {
        widget.onSuccess(token);
      } else {
        widget.onError('No order token found in return URL');
      }
    } else if (url.startsWith(widget.cancelUrl)) {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => widget.onCancel(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
