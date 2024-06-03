import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'main.dart';

class SettingPage extends HookWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = useValueListenable(themeNotifier) == ThemeMode.dark;
    final languageNotifier = useState('English');

    void _toggleLanguage(String language) {
      languageNotifier.value = language;
    }

    return Scaffold(
      appBar: AppBar(
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black, // ダークモードとライトモードに応じてテキストの色を変更
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
         
        ],
      ),
    );
  }
}
