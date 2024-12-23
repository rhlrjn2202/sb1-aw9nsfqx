import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../utils/connectivity_service.dart';
import '../utils/cookie_manager.dart';
import '../utils/storage_manager.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) async {
            // Save cookies and local storage after page loads
            await CookieManager.saveCookies(_controller);
            final localStorage = await _controller.runJavaScriptReturningResult(
              'JSON.stringify(localStorage)'
            ) as String;
            await StorageManager.saveLocalStorage(localStorage);
            
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle any JS messages if needed
        },
      )
      ..loadRequest(Uri.parse('https://eaglesfood.netlify.app'));

    _restoreUserSession();
  }

  Future<void> _restoreUserSession() async {
    // Restore cookies
    await CookieManager.restoreCookies(_controller);
    
    // Restore localStorage
    final localStorage = await StorageManager.getLocalStorage();
    if (localStorage != null) {
      await _controller.runJavaScript(
        'Object.assign(localStorage, JSON.parse($localStorage))'
      );
    }
  }

  Future<void> _refreshPage() async {
    if (await ConnectivityService.hasInternetConnection()) {
      setState(() {
        _hasError = false;
        _isLoading = true;
      });
      _controller.reload();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (!_hasError) WebViewWidget(controller: _controller),
              if (_isLoading) const LoadingView(),
              if (_hasError)
                ErrorView(
                  onRetry: _refreshPage,
                ),
            ],
          ),
        ),
      ),
    );
  }
}