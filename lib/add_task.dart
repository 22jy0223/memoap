import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mem/memo/task.dart';
import 'package:mem/database/taskdatabase.dart';

class AddTaskPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddTaskPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _contentController = TextEditingController();
  Color _selectedColor = Colors.red;

  Future<void> _saveTask() async {
    String currentTime = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now().toLocal());

    final task = Task(
      content: _contentController.text,
      updatedAt: DateFormat('yyyy/MM/dd').format(widget.selectedDate),
      color: _selectedColor.value.toRadixString(16), 
    );

    await insertTask(task);
    Navigator.pop(context, task);
  }

  Future<void> _deleteTask(int id) async {
    await deleteTask(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'タスク内容',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '例(風呂掃除)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Select Color: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    Color? pickedColor = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Select Color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Done'),
                          ),
                        ],
                      ),
                    );
                    if (pickedColor != null) {
                      setState(() {
                        _selectedColor = pickedColor;
                      });
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).canvasColor,
                  ),
                  child: MaterialButton(
                    onPressed: () {},
                    child: Text(
                      'Choose Color',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _saveTask,
                  child: Icon(Icons.check,color: Colors.white,),
                  style: ElevatedButton.styleFrom(
              backgroundColor : Colors.blue,
            ),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
