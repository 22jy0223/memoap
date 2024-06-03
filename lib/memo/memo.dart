import 'package:intl/intl.dart';

class Memo {
  final int? id;
  final String title;
  final String updatedAt;
  final String createdAt;
  final String? content;
  final String? imageBase64;
  bool isPinned;

  Memo({
    this.id,
    this.title = "新規作成",
    String? updatedAt,
    String? createdAt,
    this.content,
    this.imageBase64,
    this.isPinned = false,
  })  : updatedAt = updatedAt ?? DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now().toLocal()),
        createdAt = createdAt ?? DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now().toLocal());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'content': content,
      'imageBase64': imageBase64,
      'isPinned': isPinned ? 1 : 0,
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'],
      title: map['title'],
      updatedAt: map['updated_at'],
      createdAt: map['created_at'],
      content: map['content'],
      imageBase64: map['imageBase64'],
      isPinned: map['isPinned'] == 1,
    );
  }
}
