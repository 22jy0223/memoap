import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constant/Painter.dart';

class PaintPage extends StatefulWidget {
  @override
  _PaintPageState createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage> {
  final GlobalKey _globalKey = GlobalKey();
  late PaintController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaintController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'White Board',
          style: GoogleFonts.pacifico(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Painter(
                  paintController: _controller,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "undo",
            onPressed: () {
              if (_controller.canUndo) _controller.undo();
            },
            child: Icon(Icons.undo, color: Colors.white,),
            backgroundColor: Colors.blue, 
          ),

          SizedBox(
            height: 20.0,
          ),

          FloatingActionButton(
            heroTag: "redo",
            onPressed: () {
              if (_controller.canRedo) _controller.redo();
            },
            child: Icon(Icons.redo, color: Colors.white,),
            backgroundColor: Colors.blue, 
          ),

          SizedBox(
            height: 20.0,
          ),

          FloatingActionButton(
            heroTag: "clear",
            onPressed: () => _controller.clear(),
            child: Icon(Icons.clear, color: Colors.white,),
            backgroundColor: Colors.blue, 
          ),
        ],
      ),
    );
  }
}
