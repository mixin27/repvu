import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../infrastructure/github_authenticator.dart';

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({
    Key? key,
    required this.authorizationUrl,
    required this.onAuthorizationCodeRedirectAttempt,
  }) : super(key: key);

  final Uri authorizationUrl;
  final void Function(Uri redirectUrl) onAuthorizationCodeRedirectAttempt;

  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  void initState() {
    super.initState();

    // Enable hybrid composition for android.
    // Keybord for WebView
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.authorizationUrl.toString(),
          onWebViewCreated: (controller) {
            controller.clearCache();
            CookieManager().clearCookies();
          },
          navigationDelegate: (navReq) {
            if (navReq.url.startsWith(
              GithubAuthenticator.redirectUrl.toString(),
            )) {
              widget.onAuthorizationCodeRedirectAttempt(
                Uri.parse(navReq.url),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
