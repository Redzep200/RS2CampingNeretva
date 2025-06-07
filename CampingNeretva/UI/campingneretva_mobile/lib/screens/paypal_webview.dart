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
              onNavigationRequest: (NavigationRequest request) {
                final url = request.url;

                if (url.startsWith(widget.returnUrl)) {
                  _checkForRedirect(url);
                  return NavigationDecision.prevent;
                } else if (url.startsWith(widget.cancelUrl)) {
                  _checkForRedirect(url);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
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
    print('WebView URL: $url'); // Add this for debugging

    // Check for PayPal success parameters in URL
    if (url.contains('token=') &&
        (url.contains('PayerID=') || url.contains('approval=true'))) {
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'];
      final payerId = uri.queryParameters['PayerID'];

      print('Success detected - Token: $token, PayerID: $payerId');

      if (token != null) {
        Future.delayed(const Duration(seconds: 1), () {
          widget.onSuccess(token);
        });
      } else {
        widget.onError('No token found in success URL');
      }
    } else if (url.startsWith('myapp://paypal-success')) {
      final uri = Uri.parse(url);
      final token =
          uri.queryParameters['token'] ?? uri.queryParameters['PayerID'];

      if (token != null) {
        Future.delayed(const Duration(seconds: 1), () {
          widget.onSuccess(token);
        });
      } else {
        widget.onError('No token found in return URL');
      }
    } else if (url.startsWith('myapp://paypal-cancel') ||
        url.contains('cancel=true')) {
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
