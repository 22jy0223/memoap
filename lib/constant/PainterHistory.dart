import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/*
 * ペイントデータ
 */
class _PaintData {
  final Path path; 

  _PaintData({
    required this.path, 
  });
}

/*
 * ペイントの履歴を管理するクラス
 */
class PaintHistory {
  // ペイントの履歴リスト
  List<MapEntry<_PaintData, Paint>> _paintList = [];
  // ペイント先リスト
  List<MapEntry<_PaintData, Paint>> _undoneList = [];
  // 背景ペイント
  Paint _backgroundPaint = Paint();
  // ドラッグ中フラグ
  bool _inDrag = false;
  // カレントペイント
  Paint currentPaint = Paint();

  /*
   * undo可能か
   */
  bool canUndo() => _paintList.isNotEmpty;

  /*
   * redo可能か
   */
  bool canRedo() => _undoneList.isNotEmpty;

  /*
   * undo
   */
  void undo() {
    if (!_inDrag && canUndo()) {
      _undoneList.add(_paintList.removeLast());
    }
  }

  /*
   * redo
   */
  void redo() {
    if (!_inDrag && canRedo()) {
      _paintList.add(_undoneList.removeLast());
    }
  }

  /*
   * クリア
   */
  void clear() {
    if (!_inDrag) {
      _paintList.clear();
      _undoneList.clear();
    }
  }

  /*
   * 背景色セッター
   */
  set backgroundColor(color) => _backgroundPaint.color = color;

  /*
   * 線ペイント開始
   */
  void addPaint(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      Path path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);
      _PaintData data = _PaintData(path: path);
      _paintList.add(MapEntry<_PaintData, Paint>(data, currentPaint));
    }
  }

  /*
   * 線ペイント更新
   */
  void updatePaint(Offset nextPoint) {
    if (_inDrag) {
      _PaintData data = _paintList.last.key;
      Path path = data.path;
      path.lineTo(nextPoint.dx, nextPoint.dy);
    }
  }

  /*
   * 線ペイント終了
   */
  void endPaint() {
    _inDrag = false;
  }

  /*
   * 描写
   */
  void draw(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        0.0,
        0.0,
        size.width,
        size.height,
      ),
      _backgroundPaint,
    );

    /*
     * 線描写
     */
    for (MapEntry<_PaintData, Paint> data in _paintList) {
      if (data.key.path != null) {
        canvas.drawPath(data.key.path, data.value);
      }
    }
  }
}
