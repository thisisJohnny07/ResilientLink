import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resilientlink/pages/ongoing_donation.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class CustomerPaymongoScreen extends StatefulWidget {
  const CustomerPaymongoScreen(
      {super.key,
      required this.checkoutUrl,
      required this.donationDriveId,
      required this.donorId,
      required this.amount,
      required this.modeOfPayment});
  final String checkoutUrl;
  final String donationDriveId;
  final String donorId;
  final double amount;
  final String modeOfPayment;
  @override
  State<CustomerPaymongoScreen> createState() => _CustomerPaymongoScreenState();
}

class _CustomerPaymongoScreenState extends State<CustomerPaymongoScreen> {
  // CONTROLLERS
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Checkout');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) async {
            if (change.url!.contains('/payments/success')) {
              String payRef = change.url!.split("=")[1];
              await FirebaseFirestore.instance
                  .collection('money_donation')
                  .add({
                'referenceNumber': payRef,
                'donationDriveId': widget.donationDriveId,
                'donorId': widget.donorId,
                'amount': widget.amount,
                'modeOfPayment': widget.modeOfPayment,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OngoingDonation(
                            initialTabIndex: 1,
                          )));
            } else if (change.url!.contains('/payments/cancelled')) {
              debugPrint('PAYMENT CANCELLED');
            }
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
