import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = "AIzaSyC2ifm7vmnY48NFyb-7TCpidC4pOsq9K3k";

class AiChat extends StatefulWidget {
  const AiChat({super.key});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Map<String, String>> messages = [];
  final promptController = TextEditingController();
  bool isLoading = false;

  Future<void> _request() async {
    final prompt = promptController.text;
    if (prompt.isEmpty) return;

    setState(() {
      messages.add({'user': prompt});
      isLoading = true;
      promptController.clear();
    });

    // 事前定義された回答(パターンマッチング)
    final predefinedResponses = {
       '下のプラスボタンは何ですか': '新規作成するためのボタンです。',
        'どうやってメモを保存しますか': '右上のチェックマークをタップしてください。',
        'メモの保存の仕方がわかりません': '右上のチェックマークをタップしてください。',
        'メモを削除するにはどうすればいいですか': 'ホーム画面でメモを長押ししてください。',
        'メモを新しく作るやり方は？': 'ホーム画面下のプラスボタンを押してください！！',
        'メモを新しく作りたい': 'ホーム画面のプラスボタンを押して下さい',
        'メモを編集するには？': 'メモをタップして編集モードに入ります。',
        'メモのタイトルを変更できますか？': 'メモのタイトルをタップして変更できます。',
        '保存したメモはどこにありますか？': 'ホーム画面に表示されます。',
        'メモを共有するにはどうすればいいですか？': 'メモを開いて共有アイコンをタップしてください。',
        'メモを検索する方法は？': '上部の検索バーを使ってメモを検索できます。',
        'ダークモードに変更するには？': '設定画面からテーマを変更できます。',
        'リマインダーを設定できますか？': 'メモを開いてリマインダーアイコンをタップしてください。',
        'アプリの設定はどこで変更できますか？': '右上の設定アイコンをタップしてください。',
        'メモを保存したい':'メモ作成画面の右上から保存できます',
        'メモの保存の仕方は？':'メモ作成画面の右上から保存できます',
        '新規作成のやり方':'ホームの下のプラスボタンから作れます',
        'カレンダー内のプラスボタンは何？':'選択した日付にタスクを追加することができます',
        'カレンダーのプラスボタンはなに？':'選択した日付にタスクを追加することができます',
        'メモを消したいです':'メモ長押しです削除できます'
    };

    String botResponse = predefinedResponses[prompt] ?? '';

    // 事前定義された回答がない場合、AIが回答
    if (botResponse.isEmpty) {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      botResponse = response.text ?? 'エラーが発生しました!';
    }

    setState(() {
      messages.add({'bot': botResponse});
      isLoading = false;
    });
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUserMessage = message.containsKey('user');
    final text = isUserMessage ? message['user']! : message['bot']!;
    final alignment = isUserMessage ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUserMessage ? Colors.blueAccent : Colors.grey[200];
    final textColor = isUserMessage ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isUserMessage ? Radius.circular(15) : Radius.zero,
            bottomRight: isUserMessage ? Radius.zero : Radius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "AiChat",
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: promptController,
                    decoration: InputDecoration(
                      labelText: '何でも聞いてください',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _request,
                  mini: true,
                  child: Icon(Icons.send, color: Colors.white),
                  backgroundColor: Colors.blueAccent,
                  elevation: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
