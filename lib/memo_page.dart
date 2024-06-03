import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';  

import 'database/database.dart';
import 'memo/memo.dart';

class MemoPage extends StatefulWidget {
  final Memo memo;

  const MemoPage({Key? key, required this.memo}) : super(key: key);

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  File? _selectedImage;
  late QuillController _controller;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo.title);
    _initializeMemo();
  }

  Future<void> _initializeMemo() async {
    if (widget.memo.content != null) {
      setState(() {
        _controller = QuillController(
          document: Document.fromJson(jsonDecode(widget.memo.content!)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      });
    } else {
      _controller = QuillController.basic();
    }

    if (widget.memo.imageBase64 != null && widget.memo.imageBase64!.isNotEmpty) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/image.png';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(base64Decode(widget.memo.imageBase64!));
      setState(() {
        _selectedImage = imageFile;
      });
    } else {
      setState(() {
        _selectedImage = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${pickedFile.name}';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(await pickedFile.readAsBytes());
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  void _shareMemo() {
    final String title = widget.memo.title;
    final String content = _controller.document.toPlainText();
    final String message = '$title\n$content';

    Share.share(message);
  }

  Future<void> _saveAsPdf() async {
    final pdf = pw.Document();

    // フォントを読み込む
    final ByteData fontData = await rootBundle.load('assets/fonts/NotoSansJP-Black.ttf');
    final Uint8List ttf = fontData.buffer.asUint8List();
    final pw.Font font = pw.Font.ttf(ttf.buffer.asByteData());

    // タイトルと内容を追加
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(widget.memo.title, style: pw.TextStyle(fontSize: 24, font: font)),
              pw.SizedBox(height: 16),
              pw.Text(_controller.document.toPlainText(), style: pw.TextStyle(font: font)),
            ],
          );
        },
      ),
    );

    // 画像を追加
    if (_selectedImage != null) {
      final Uint8List bytes = await _selectedImage!.readAsBytes();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pw.MemoryImage(bytes)));
          },
        ),
      );
    }

    // PDFを保存
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${widget.memo.title}.pdf'; // タイトルをファイル名に使用
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // 保存したファイルのパスを表示
    print('PDF saved at: ${file.path}');
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: '画像を選択',
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'メモを共有',
            onPressed: _shareMemo,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _saveAsPdf();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("PDFに変換しました")),
              );
            },
            tooltip: 'PDFとして保存',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'メモを保存',
            onPressed: () async {
              String currentTime = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now().toLocal());

              String? imageBase64;
              if (_selectedImage != null) {
                final bytes = await _selectedImage!.readAsBytes();
                imageBase64 = base64Encode(bytes);
              }

              final memoToSave = Memo(
                id: widget.memo.id,
                title: _titleController.text,
                content: jsonEncode(_controller.document.toDelta().toJson()),
                updatedAt: currentTime,
                imageBase64: imageBase64,
                isPinned: widget.memo.isPinned,
              );
              if (widget.memo.id == null) {
                insertMemo(memoToSave);
              } else {
                updateRecord(memoToSave);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('メモを保存しました')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              controller: _titleController,
              onChanged: (value) {
                
              },
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                hintText: 'タイトル',
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(),
                        child: QuillEditor.basic(
                          scrollController: ScrollController(),
                          focusNode: FocusNode(),
                          configurations: QuillEditorConfigurations(
                            controller: _controller,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Image.file(_selectedImage!, height: 300, width: 400),
                    ),
                  QuillToolbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          QuillToolbarSearchButton(
                            controller: _controller,
                          ),
                          QuillToolbarColorButton(
                            isBackground: true,
                            controller: _controller,
                          ),
                          QuillToolbarLinkStyleButton(
                            controller: _controller,
                          ),
                          QuillToolbarHistoryButton(
                            isUndo: true,
                            controller: _controller,
                          ),
                          QuillToolbarHistoryButton(
                            isUndo: false,
                            controller: _controller,
                          ),
                          QuillToolbarToggleStyleButton(
                            options: const QuillToolbarToggleStyleButtonOptions(),
                            controller: _controller,
                            attribute: Attribute.bold,
                          ),
                          QuillToolbarToggleStyleButton(
                            options: const QuillToolbarToggleStyleButtonOptions(),
                            controller: _controller,
                            attribute: Attribute.italic,
                          ),
                          QuillToolbarToggleStyleButton(
                            controller: _controller,
                            attribute: Attribute.underline,
                          ),
                          QuillToolbarToggleCheckListButton(
                            controller: _controller,
                          ),
                          QuillToolbarToggleStyleButton(
                            controller: _controller,
                            attribute: Attribute.ol,
                          ),
                          QuillToolbarToggleStyleButton(
                            controller: _controller,
                            attribute: Attribute.ul,
                          ),
                          QuillToolbarFontSizeButton(
                            controller: _controller
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
