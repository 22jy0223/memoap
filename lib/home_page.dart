import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constant/app_color.dart';
import 'constant/drawer.dart';
import 'database/database.dart';
import 'memo/memo.dart';
import 'memo_page.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    List<Memo> memos = [];
    String searchQuery = '';

    @override void initState() {
        super.initState();
        load();
    }

    void load()async {
        final loadedMemos = await getMemos();
        setState(() {
            memos = loadedMemos;
            sortMemos();
        });
    }

    void sortMemos() {
        memos.sort((a, b) {
            if(a.isPinned && !b.isPinned) {
                return -1;
            } else if (!a.isPinned && b.isPinned) {
                return 1;
            } else {
                return b
                    .updatedAt
                    .compareTo(a.updatedAt);
            }
        });
    }

    void navigateToMemoPage(Memo memo)async {
        await Navigator.push(
            context,
            MaterialPageRoute(builder : (context) => MemoPage(memo : memo),),
        );

        setState(() {
            load();
        });
    }

    void togglePinStatus(Memo memo)async {
        memo.isPinned = !memo.isPinned;
        await updateMemoPinStatus(memo.id !, memo.isPinned);

        setState(() {
            load();
        });
    }

    @override Widget build(BuildContext context) {
        return Scaffold(
                            backgroundColor : Theme.of(context).scaffoldBackgroundColor,
                            drawer : MyDrawer(),
                            appBar : AppBar(
                    backgroundColor : Theme.of(context).appBarTheme.backgroundColor,
                    actions : [IconButton(
                            icon : const Icon(Icons.search, color : Colors.black),
                            onPressed : () {
                                showSearch(
                                    context : context,
                                    delegate : MemoSearch(memos : memos, togglePinStatus : togglePinStatus, sortMemos : sortMemos,),
                                );
                            },
                        )],
                ),
                            body : ListView.builder(
                            itemCount : memos.length,
                            itemBuilder : (context, index) {
                        final memo = memos[index];
                        return Card(
                                    elevation : 4,
                                    margin : const EdgeInsets.symmetric(vertical : 6, horizontal : 10),
                                    shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(15),),
                                    child : ListTile(
                                        contentPadding : const EdgeInsets.all(16),
                                        tileColor : Theme.of(context).cardColor,
                                        title : Text(
                                            memo.title,
                                            style : GoogleFonts.notoSansJp(fontSize : 20, color : Theme.of(context).textTheme.bodyText1 !.color),
                                        ),
                                        subtitle : Text(
                                            memo.updatedAt,
                                            style : GoogleFonts.notoSansJp(fontSize : 14, color : Theme.of(context).textTheme.bodyText2 !.color),
                                        ),
                                        trailing : IconButton(icon : Icon(
                                            memo.isPinned
                                                ? Icons.star
                                                : Icons.star_border,
                                            color : memo.isPinned
                                                ? Colors.yellow
                                                : Colors.grey,
                                        ), onPressed : () {
                                            togglePinStatus(memo);
                                        },),
                                        onTap : () {
                                            navigateToMemoPage(memo);
                                        },
                                        onLongPress : () {
                                            showDeleteConfirmationDialog(context, memo);
                                        },
                                    ),
                                );
                            },
                        ),
                            floatingActionButton : FloatingActionButton(onPressed : () {
                            navigateToMemoPage(Memo());
                        }, backgroundColor : Colors.blueAccent, child : const Icon(
                                Icons.add,
                                color : Colors.white
                            ),),
                            floatingActionButtonLocation : FloatingActionButtonLocation.centerFloat,
                        );
                    }

                    Future<void> showDeleteConfirmationDialog(BuildContext context, Memo memo)async {
                        return showDialog<void>(
                            context : context,
                            barrierDismissible : false,
                            builder : (
                                BuildContext context
                            ) {
                                return AlertDialog(
                                    shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(15),),
                                    title : Text('削除の確認', style : GoogleFonts.notoSansJp()),
                                    content : Text('このメモを削除しますか？', style : GoogleFonts.notoSansJp()),
                                    actions : <Widget> [
                                        TextButton(
                                            child : Text('いいえ', style : GoogleFonts.notoSansJp()),
                                            onPressed : () {
                                                Navigator
                                                    .of(context)
                                                    .pop();
                                            },
                                        ),
                                        TextButton(
                                            child : Text('はい', style : GoogleFonts.notoSansJp()),
                                            onPressed : () {
                                                deleteRecord(memo.id !).then((_) {
                                                    Navigator
                                                        .of(context)
                                                        .pop();
                                                    setState(() {
                                                        load();
                                                    });
                                                });
                                            },
                                        )
                                    ],
                                );
                            },
                        );
                    }
                }

              class MemoSearch extends SearchDelegate<String> {
    final List<Memo> memos;
    final Function(Memo) togglePinStatus;
    final Function sortMemos;

    MemoSearch({
        required this.memos, 
        required this.togglePinStatus, 
        required this.sortMemos
    });

    @override
    List<Widget>? buildActions(BuildContext context) {
        return [IconButton(icon: const Icon(Icons.clear), onPressed: () {
            query = '';
            showSuggestions(context);
        })];
    }

    @override
    Widget? buildLeading(BuildContext context) {
        return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
            close(context, '');
        });
    }

    @override
    Widget buildResults(BuildContext context) {
        final results = memos
            .where((memo) =>
                memo.title.toLowerCase().contains(query.toLowerCase()) ||
                memo.content!.toLowerCase().contains(query.toLowerCase())
            )
            .toList();

        sortMemos();
        return ListView(
            children: results.map((memo) {
                final matchedText = _getMatchedText(memo);
                return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        tileColor: Theme.of(context).cardColor,
                        title: Text(
                            memo.title,
                            style: GoogleFonts.notoSansJp(
                                fontSize: 20,
                                color: Theme.of(context).textTheme.bodyText1!.color
                            ),
                        ),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    memo.updatedAt,
                                    style: GoogleFonts.notoSansJp(
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodyText2!.color
                                    ),
                                ),
                                const SizedBox(height: 4),
                                if (matchedText != null)
                                    Text(
                                        matchedText,
                                        style: GoogleFonts.notoSansJp(
                                            fontSize: 14,
                                            color: Colors.blue
                                        ),
                                    ),
                            ],
                        ),
                        trailing: IconButton(
                            icon: Icon(
                                memo.isPinned ? Icons.star : Icons.star_border,
                                color: memo.isPinned ? Colors.yellow : Colors.grey,
                            ),
                            onPressed: () async {
                                await togglePinStatus(memo);
                                sortMemos();
                                showResults(context);
                            },
                        ),
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MemoPage(memo: memo)),
                            );
                        },
                    ),
                );
            }).toList(),
        );
    }

    @override
    Widget buildSuggestions(BuildContext context) {
        final suggestions = memos
            .where((memo) =>
                memo.title.toLowerCase().contains(query.toLowerCase()) ||
                memo.content!.toLowerCase().contains(query.toLowerCase())
            )
            .toList();

        return ListView(
            children: suggestions.map((memo) {
                final matchedText = _getMatchedText(memo);
                return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        tileColor: Theme.of(context).cardColor,
                        title: Text(
                            memo.title,
                            style: GoogleFonts.notoSansJp(
                                fontSize: 20,
                                color: Theme.of(context).textTheme.bodyText1!.color
                            ),
                        ),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    memo.updatedAt,
                                    style: GoogleFonts.notoSansJp(
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodyText2!.color
                                    ),
                                ),
                                const SizedBox(height: 4),
                                if (matchedText != null)
                                    Text(
                                        matchedText,
                                        style: GoogleFonts.notoSansJp(
                                            fontSize: 14,
                                            color: Colors.blue
                                        ),
                                    ),
                            ],
                        ),
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MemoPage(memo: memo)),
                            );
                        },
                    ),
                );
            }).toList(),
        );
    }

    String? _getMatchedText(Memo memo) {
    final titleMatchIndex = memo.title.toLowerCase().indexOf(query.toLowerCase());
    if (titleMatchIndex != -1) {
        return null; // No need to show content match if title matches
    }

    // Parse and clean the content
    final content = memo.content ?? '[]';
    final contentList = jsonDecode(content) as List;
    final cleanedContent = contentList.map((item) => item['insert'] as String).join();

    final contentMatchIndex = cleanedContent.toLowerCase().indexOf(query.toLowerCase());
    if (contentMatchIndex != -1) {
        final snippetLength = 40; // Length of the snippet before and after the match
        final start = contentMatchIndex - snippetLength > 0 ? contentMatchIndex - snippetLength : 0;
        final end = contentMatchIndex + query.length + snippetLength < cleanedContent.length ? contentMatchIndex + query.length + snippetLength : cleanedContent.length;
        var snippet = cleanedContent.substring(start, end);

        // Strip out any unwanted characters (if necessary)
        snippet = snippet.replaceAll(RegExp(r'\s+'), ' ').trim(); // Replace multiple whitespace with a single space and trim

        final snippetStart = start == 0 ? '' : '...';
        final snippetEnd = end == cleanedContent.length ? '' : '...';

        return '$snippetStart$snippet$snippetEnd';
    }

    return null;
}
}


