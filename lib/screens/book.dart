import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/services/globals.dart';
import 'package:starr/services/routes.dart';
import 'package:starr/services/styles.dart';

class BookScreen extends StatefulWidget {
  final int bookNumber;
  final String bookName;

  const BookScreen({Key? key, required this.bookName, required this.bookNumber})
      : super(key: key);

  @override
  BookScreenState createState() => BookScreenState();
}

class BookScreenState extends State<BookScreen> {
  late List<Verse> _firstVersesForEachChapterForBook = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(builder: (context, value, child) {
      return FutureBuilder(
          future: _loadPageData(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                toolbarHeight: 66,
                title: Text(_firstVersesForEachChapterForBook.first.bookName,
                    style: whiteFS20W600.merge(condensed).merge(TextStyle(fontSize: 24))),
                actions: [
                  IconButton(
                    onPressed: () {
                      openSearchScreen(context);
                    },
                    icon: Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () {
                      showChangeVersionDialog(context);
                    },
                    icon: Icon(Icons.more_vert),
                  )
                ],
              ),
              body: GridView.count(
                  crossAxisCount: 5,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 100),
                  children: _firstVersesForEachChapterForBook
                      .map<Widget>(
                          (Verse number) => buildBookChapterTile(verse: number))
                      .toList()),
            );
          });
    });
  }

  buildBookChapterTile({required Verse verse}) {
    return OutlinedButton(
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: () =>
            Navigator.pushNamed(context, ChapterScreenRoute, arguments: {
              'chapterNumber': verse.chapterNumber,
              'bookNumber': widget.bookNumber,
              'bookName': verse.bookName
            }),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${verse.chapterNumber}",
                style: primaryFS13W700.merge(TextStyle(fontSize: 30))),
            SizedBox(height: 8),
            Text("Chapter", style: muteFS14W500),
          ],
        ));
  }

  Future<bool> _loadPageData() async {
    _firstVersesForEachChapterForBook = await Provider.of<BibleProvider>(context)
        .getFirstVerseForChapterForBook(widget.bookNumber);
    return true;
  }
}
