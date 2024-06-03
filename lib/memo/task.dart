import 'package:flutter/material.dart';

class Task {
  final int? id;
  final String content;
  final String updatedAt;
  final String color;

  Task({
    this.id,
    required this.content,
    required this.updatedAt,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'updated_at': updatedAt,
      'color': color,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      content: map['content'],
      updatedAt: map['updated_at'],
      color: map['color'],
    );
  }
}
