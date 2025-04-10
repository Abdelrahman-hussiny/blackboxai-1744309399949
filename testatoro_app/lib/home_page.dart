import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  final String _baseUrl = 'https://www.testatoro.com';

  @override
  void initState() {
    super.initState();
    // Initialize WebView with platform-specific settings
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
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
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (!request.url.startsWith(_baseUrl)) {
              if (request.url.contains('instagram.com') ||
                  request.url.contains('facebook.com') ||
                  request.url.contains('whatsapp.com')) {
                try {
                  if (await canLaunchUrl(Uri.parse(request.url))) {
                    await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
                    return NavigationDecision.prevent;
                  }
                } catch (e) {
                  // If app is not installed, open in browser
                  if (await canLaunchUrl(Uri.parse(request.url))) {
                    await launchUrl(Uri.parse(request.url));
                    return NavigationDecision.prevent;
                  }
                }
              } else {
                if (await canLaunchUrl(Uri.parse(request.url))) {
                  await launchUrl(Uri.parse(request.url));
                  return NavigationDecision.prevent;
                }
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_baseUrl));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await _webViewController.canGoBack()) {
                _webViewController.goBack();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
              onPressed: () async {
                if (await _webViewController.canGoForward()) {
                  _webViewController.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                _webViewController.loadRequest(Uri.parse(_baseUrl));
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                _webViewController.loadRequest(Uri.parse('$_baseUrl/cart'));
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () async {
                final url = await _webViewController.currentUrl();
                if (url != null) {
                  await Share.share(url);
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                _webViewController.reload();
              },
              child: WebViewWidget(
                controller: _webViewController,
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
