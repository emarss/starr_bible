import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:provider/provider.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/services/colors.dart';
import 'package:starr/services/globals.dart';
import 'package:starr/services/routes.dart';
import 'package:starr/services/styles.dart';

class SearchResultsScreen extends StatefulWidget {
  final SearchParameters searchParameters;

  const SearchResultsScreen({Key? key, required this.searchParameters})
      : super(key: key);

  @override
  SearchResultsScreenState createState() => SearchResultsScreenState();
}

class SearchResultsScreenState extends State<SearchResultsScreen> {
  Map<String, HighlightedWord> words = {};
  late String _version;

  @override
  void initState() {
    super.initState();
    words.addAll({
      widget.searchParameters.search.trim(): HighlightedWord(
        onTap: () {},
        textStyle: darkFS16W600Italic,
      )
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _version =
        Provider.of<BibleProvider>(context, listen: false).currentVersion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 66,
        title: Text("Search Results for '${widget.searchParameters.search}'",
            style: whiteFS20W600.merge(condensed).merge(TextStyle(fontSize: 24))),
      ),
      body: Column(children: [
        _buildBibleVersionsRow(),
        SizedBox(height: 6),
        Divider(thickness: 2, height: 0),
        Expanded(
          child: _getPageContent(),
        )
      ]),
    );
  }

  Widget _getPageContent() {
    if (widget.searchParameters.results
        .where((verse) => verse.bibleVersion == _version)
        .isEmpty) {
      return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("No results found for this version")]);
    }
    return ListView(
        padding: EdgeInsets.fromLTRB(2, 8, 2, 100),
        children: widget.searchParameters.results
            .where((verse) => verse.bibleVersion == _version)
            .map<Widget>(
                (Verse resultVerse) => buildChapterVerse(resultVerse))
            .toList());
  }

  Widget buildChapterVerse(Verse verse) {
    return Column(
      children: [
        InkWell(
          onTap: () =>
              Navigator.pushNamed(context, ChapterWithScreenRoute, arguments: {
            'chapterNumber': verse.chapterNumber,
            'bookNumber': verse.bookNumber,
            'bookName': verse.bookName,
            'verseNumber': verse.number
          }),
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(verse.getVerseTitle(), style: muteFS16W500),
                SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: TextHighlight(
                          text: verse.text,
                          words: words,
                          matchCase: false,
                          textStyle: _getVerseTextStyleWithHighlight(
                              verse))),
                ]),
              ],
            ),
          ),
        ),
        Divider(height: 0, thickness: 1.5)
      ],
    );
  }

  TextStyle _getVerseTextStyleWithHighlight(Verse verse) {
    if (verse.number == 3) {
      return darkFS16W400
          .merge(TextStyle(backgroundColor: Colors.green, height: 1.3));
    } else {
      return darkFS16W400;
    }
  }

  Widget _buildBibleVersionsRow() {
    return SizedBox(
        height: 40,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ...versionsList.map<Widget>((String version) {
                return TextButton(
                    style: ButtonStyle(
                      backgroundColor: _version == version
                          ? MaterialStateProperty.all(primaryColor)
                          : MaterialStateProperty.all(faintColor),
                      foregroundColor: _version == version
                          ? MaterialStateProperty.all(whiteColor)
                          : MaterialStateProperty.all(primaryColor),
                    ),
                    onPressed: () async {
                      setState(() {
                        _version = version;
                      });
                    },
                    child: Text(version.toUpperCase()));
              })
            ])));
  }
}
