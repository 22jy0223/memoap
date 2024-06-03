import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mem/add_task.dart';
import 'package:mem/database/taskdatabase.dart';
import 'package:mem/memo/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'database/database.dart';
import 'memo/memo.dart';
import 'memo_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Memo> memos = [];
  List<Task> tasks = [];
  Map<DateTime, List<dynamic>> events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final loadedMemos = await getMemos();
    final loadedTasks = await getTasks();
    setState(() {
      memos = loadedMemos;
      tasks = loadedTasks;
      _groupEventsByDate();
    });
  }

  void _groupEventsByDate() {
    events = {};
    for (var memo in memos) {
      DateTime memoDate = DateFormat('yyyy/MM/dd').parse(memo.updatedAt).toLocal();
      DateTime eventDate = DateTime(memoDate.year, memoDate.month, memoDate.day);
      if (events[eventDate] == null) {
        events[eventDate] = [];
      }
      events[eventDate]!.add(memo);
    }
    for (var task in tasks) {
      DateTime taskDate = DateFormat('yyyy/MM/dd').parse(task.updatedAt).toLocal();
      DateTime eventDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
      if (events[eventDate] == null) {
        events[eventDate] = [];
      }
      events[eventDate]!.add(task);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _deleteTask(int id) async {
    await deleteTask(id);
    load();
  }

  Color _getMarkerColor(dynamic event) {
    return event is Memo ? Colors.black : Color(int.parse(event.color, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Note Task',
          style: GoogleFonts.notoSansJp(),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color.fromARGB(255, 170, 209, 240),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return Container();
                    var event = events.first;
                    Color markerColor = _getMarkerColor(event);
                    return Container(
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                      width: 7.0,
                      height: 7.0,
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(
                      '日付を選択してください',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                  )
                : ListView(
                    children: _getEventsForDay(_selectedDay!).map<Widget>((event) {
                      Color eventColor = event is Task ? Color(int.parse(event.color, radix: 16)) : Colors.black;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 4.0,
                        child: ListTile(
                          title: Text(
                            event is Memo ? event.title : event.content,
                            style: GoogleFonts.notoSansJp(
                              color: eventColor,
                              fontSize: 16,
                            ),
                          ),
                          trailing: event is Task && event.id != null
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    if (event.id != null) {
                                      _deleteTask(event.id!);
                                    }
                                  },
                                )
                              : null,
                          onTap: () async {
                            if (event is Memo) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemoPage(memo: event),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _selectedDay == null
                  ? null
                  : () async {
                      Task? newTask = await Navigator.push<Task?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskPage(selectedDate: _selectedDay!),
                        ),
                      );
                      if (newTask != null) {
                        load();
                      }
                    },
              child: const Icon(Icons.add, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedDay == null ? Colors.grey : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: GoogleFonts.notoSansJp(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
