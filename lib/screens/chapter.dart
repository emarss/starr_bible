import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share/share.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/services/colors.dart';
import 'package:starr/services/globals.dart';
import 'package:starr/services/styles.dart';

class ChapterScreen extends StatefulWidget {
  final int chapterNumber;
  final int bookNumber;
  final String bookName;
  final int? verseNumber;

  const ChapterScreen(
      {Key? key,
      required this.chapterNumber,
      required this.bookNumber,
      this.verseNumber,
      required this.bookName})
      : super(key: key);

  @override
  ChapterScreenState createState() => ChapterScreenState();
}

class ChapterScreenState extends State<ChapterScreen> {
  List<Verse> _selectedVerses = [];
  late int _chapterNumber;
  List<Verse> _versesList = [];
  late bool _thisChapterIsFirst;
  late bool _thisChapterIsLast;
  AutoScrollController _scrollController = new AutoScrollController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chapterNumber = widget.chapterNumber;
    if (WidgetsBinding.instance != null && widget.verseNumber != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {
            _scrollController.scrollToIndex(widget.verseNumber!,
                preferPosition: AutoScrollPosition.begin);
          }));
    }
  }

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
                title: Text("${_versesList.first.bookName} $_chapterNumber",
                    style: whiteFS20W600
                        .merge(condensed)
                        .merge(TextStyle(fontSize: 24))),
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
              bottomNavigationBar: _selectedVerses.isEmpty
                  ? buildFirstNavBar()
                  : buildSecondNavBar(),
              body: Stack(
                alignment: Alignment.center,
                children: [
                  Column(children: [
                    _buildBibleVersionsRow(),
                    SizedBox(height: 6),
                    Divider(thickness: 2, height: 0),
                    Expanded(
                      child: ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(2, 8, 2, 100),
                          children: _versesList
                              .map<Widget>(
                                  (Verse verse) => buildChapterVerse(verse))
                              .toList()),
                    ),
                  ]),
                  if (_isLoading)
                    Column(
                      children: [
                        SizedBox(height: 50),
                        Expanded(
                            child: Card(
                                color: muteColor.withOpacity(0.1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: CircularProgressIndicator(strokeWidth: 6, color: primaryColor,)),
                                  ],
                                ))),
                      ],
                    ),
                ],
              ));
        },
      );
    });
  }

  BottomNavigationBar buildFirstNavBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      currentIndex: 0,
      showUnselectedLabels: false,
      elevation: 0,
      onTap: (int value) {
        _firstNavBarItemTapped(value);
      },
      items: [
        BottomNavigationBarItem(
            label: "Prev Chapter",
            icon: Icon(Icons.skip_previous,
                color: _thisChapterIsFirst ? lightMuteColor : primaryColor)),
        BottomNavigationBarItem(
            label: "Chapter Notes",
            icon: Icon(Icons.open_in_browser, color: primaryColor)),
        BottomNavigationBarItem(
            label: "Next Chapter",
            icon: Icon(Icons.skip_next,
                color: _thisChapterIsLast ? lightMuteColor : primaryColor)),
      ],
    );
  }

  BottomNavigationBar buildSecondNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int value) {
        _secondNavBarItemTapped(value);
      },
      elevation: 0,
      items: [
        BottomNavigationBarItem(
            label: "Bookmark", icon: Icon(Icons.bookmark, color: primaryColor)),
        BottomNavigationBarItem(
            label: "Highlight",
            icon: Icon(Icons.highlight, color: primaryColor)),
        BottomNavigationBarItem(
            label: "Add Note", icon: Icon(Icons.note_add, color: primaryColor)),
        BottomNavigationBarItem(
            label: "Share", icon: Icon(Icons.share, color: primaryColor)),
        BottomNavigationBarItem(
            label: "Copy to Clipboard",
            icon: Icon(Icons.copy, color: primaryColor)),
        BottomNavigationBarItem(
            label: "Clear All",
            icon: Icon(Icons.clear_all, color: primaryColor)),
      ],
    );
  }

  Widget buildChapterVerse(Verse verse) {
    return AutoScrollTag(
      key: ValueKey(verse.number),
      controller: _scrollController,
      index: verse.number,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              _toggleSelectVerse(verse);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              color: verse.number == widget.verseNumber
                  ? primaryColor.withOpacity(0.1)
                  : faintColor,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Text(verse.text,
                        style: _getVerseTextStyleWithHighlight(verse))),
                SizedBox(width: 4),
                Text(verse.number.toString(), style: _getVerseTextStyle(verse)),
                if (verse.isBookmarked == 1)
                  Icon(Icons.bookmark, color: primaryColor, size: 20)
              ]),
            ),
          ),
          Divider(height: 0)
        ],
      ),
    );
  }

  void _toggleSelectVerse(Verse verse) {
    setState(() {
      if (_selectedVerses.any((_verse) => _verse.number == verse.number)) {
        _selectedVerses.removeWhere((_verse) => _verse.number == verse.number);
      } else {
        _selectedVerses.add(verse);
      }
    });
  }

  void _clearSelectedVerses() {
    setState(() {
      _selectedVerses.clear();
    });
  }

  void _copySelectedVersesToClipboard() {
    String _text = _getSelectedBibleVerses();
    FlutterClipboard.copy(_text).then(
        (value) => showSnackBar(context, "Selection copied to clipboard", 2));
  }

  void _shareSelectedVerses() {
    String _text = _getSelectedBibleVerses();
    Share.share(_text);
  }

  void _secondNavBarItemTapped(int value) {
    if (value == 5) {
      _clearSelectedVerses();
      return;
    }
    if (value == 4) {
      _copySelectedVersesToClipboard();
      _clearSelectedVerses();
      return;
    }
    if (value == 3) {
      _shareSelectedVerses();
      _clearSelectedVerses();
      return;
    }
    if (value == 0) {
      _bookmarkSelectedVerses();
      _clearSelectedVerses();
      return;
    }
  }

  String _getSelectedBibleVerses() {
    return getSelectedBibleVerses(context, _selectedVerses);
  }

  TextStyle _getVerseTextStyle(Verse verse) {
    if (_selectedVerses.any((_verse) => _verse.number == verse.number)) {
      return primaryFS17W500;
    } else {
      return darkFS17W400;
    }
  }

  TextStyle _getVerseTextStyleWithHighlight(Verse verse) {
    if (verse.isHighlighted == 1) {
      return _getVerseTextStyle(verse)
          .merge(TextStyle(backgroundColor: Colors.green));
    } else {
      return _getVerseTextStyle(verse);
    }
  }

  Widget _buildBibleVersionsRow() {
    BibleProvider _bibleProvider =
        Provider.of<BibleProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
          height: 40,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ...versionsList.map<Widget>((String version) {
                  return TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            _bibleProvider.currentVersion == version
                                ? MaterialStateProperty.all(primaryColor)
                                : MaterialStateProperty.all(faintColor),
                        foregroundColor:
                            _bibleProvider.currentVersion == version
                                ? MaterialStateProperty.all(whiteColor)
                                : MaterialStateProperty.all(primaryColor),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await _bibleProvider.setCurrentBible(version);
                      },
                      child: Text(version.toUpperCase()));
                })
              ]))),
    );
  }

  void _firstNavBarItemTapped(int value) {
    if (value == 0) {
      if (_thisChapterIsFirst == false) {
        setState(() {
          _chapterNumber = _chapterNumber - 1;
        });
      }
      return;
    }
    if (value == 1) {
      return;
    }
    if (value == 2) {
      if (_thisChapterIsLast == false) {
        setState(() {
          _chapterNumber = _chapterNumber + 1;
        });
      }
      return;
    }
  }

  Future<bool> _loadPageData() async {
    _versesList = await Provider.of<BibleProvider>(context, listen: false)
        .getChapterVerses(_chapterNumber, bookNumber: widget.bookNumber);
    _thisChapterIsLast =
        await Provider.of<BibleProvider>(context, listen: false)
            .isChapterLastInBook(_chapterNumber, bookNumber: widget.bookNumber);
    _thisChapterIsFirst = await Provider.of<BibleProvider>(context,
            listen: false)
        .isChapterFirstInBook(_chapterNumber, bookNumber: widget.bookNumber);

    _isLoading = false;
    return true;
  }

  Future<void> _bookmarkSelectedVerses() async {
    await Provider.of<BibleProvider>(context, listen: false)
        .bookmark(_selectedVerses);
  }
}
