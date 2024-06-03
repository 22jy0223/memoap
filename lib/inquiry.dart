import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class inquiry extends StatefulWidget {


  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<inquiry> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  var connectionStatus;

  int? position = 1; // num を int? に変更

  final key = UniqueKey();

  void doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  void startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  // インターネット接続チェック
  Future<void> check() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connectionStatus = true;
      }
    } on SocketException catch (_) {
      connectionStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: check(), // Future or nullを取得
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('不具合を報告'),
          ),
          body: connectionStatus == true
              ? IndexedStack(
            index: position ?? 0, // null許容演算子を使用してnullの場合は0を使用
            children: [
              WebView(
                initialUrl: 'https://docs.google.com/forms/d/e/1FAIpQLSckAYP4wY6FsQbyeNvWc5BE-WWFHQ1qAtPkV9EHt0-dqcGOuQ/viewform?usp=sf_link',
                javascriptMode: JavascriptMode.unrestricted,
                // JavaScriptを有効化
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                key: key,
                onPageFinished: doneLoading,
                // indexを０にしてWebViewを表示
                onPageStarted: startLoading, // indexを1にしてプログレスインジケーターを表示
              ),
              // プログレスインジケーターを表示
              Container(
                child: Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.blue),
                ),
              ),
            ],
          )
          // インターネットに接続されていない場合の処理
              : SafeArea(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 120,
                      bottom: 20,
                    ),
                    child: Container(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                    ),
                    child: Text(
                      'インターネットに接続されていません',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
