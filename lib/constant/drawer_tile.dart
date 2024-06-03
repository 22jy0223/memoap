
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class DrawerTile extends StatelessWidget{
  final String title;
  final Widget leading;
  final void Function()? onTap;
  final TextStyle titleStyle;

  const DrawerTile({
    super.key,
    required this.title,
    required this.leading,
    required this.onTap, 
    required this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.roboto().merge(titleStyle),
                    // ),
        ),
        leading: leading,
        onTap: onTap,
      ),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}