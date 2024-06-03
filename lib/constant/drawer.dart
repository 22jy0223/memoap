import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mem/PaintPage.dart';
import 'package:mem/inquiry.dart';

import '../ai_chat.dart';
import '../calendar.dart';
import '../setting_page.dart';
import 'drawer_tile.dart';
import 'package:google_fonts/google_fonts.dart';


class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: Icon(Icons.egg_rounded)),
          DrawerTile(
            title: "Home",
            titleStyle: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context),
          ),
          DrawerTile(
            title: "Setting",
            titleStyle: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
          DrawerTile(
            title: "AI",
            titleStyle: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            leading: const Icon(Icons.mark_unread_chat_alt_sharp),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AiChat()),
              );
            },
          ),
          DrawerTile(
            title: "WhiteBoard",
            titleStyle: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            leading: const Icon(Icons.format_paint),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaintPage()),
              );
            },
          ),
          DrawerTile(
            title: "Calendar",
            titleStyle: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            leading: const Icon(Icons.calendar_month),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
          ),
          DrawerTile(
            title: "Inquiry",
            titleStyle: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            leading: const Icon(Icons.question_mark_outlined),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => inquiry()),
              );
            },
          ),
        ],
      ),
    );
  }
}
