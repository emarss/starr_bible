import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/services/colors.dart';
import 'package:starr/services/globals.dart';
import 'package:starr/services/routes.dart';
import 'package:starr/services/styles.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int currentIndex = 0;

  late String _currentVersion;
  List<Verse> _currentBibleVersesPerBook = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentVersion = Provider.of<BibleProvider>(context).currentVersion;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPageData(),
      builder: (context, snapshot) {
        if(snapshot.hasData == false){
            
            return Scaffold(
                body: Center(
                    child: CircularProgressIndicator()));
          }
        return Scaffold(
            appBar: AppBar(
              toolbarHeight: 66,
              elevation: 0,
              title: Row(
                children: [
                  Text("Holy Bible", style: whiteFS20W600.merge(condensed).merge(TextStyle(fontSize: 24))),
                  SizedBox(width: 8),
                  Text("(${_currentVersion.toUpperCase()})",
                      style: whiteFS18W700),
                ],
              ),
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
            drawer: buildDrawer(context),
            body: SizedBox.expand(
                child: Scaffold(
              appBar: PreferredSize(
                preferredSize: new Size.fromHeight(60),
                child: Container(
                  color: primaryColor,
                  child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    indicatorWeight: 2,
                    indicatorColor: tertiaryDarkColor,
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width /3,
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Old Testament", style: whiteFS18W700)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width /3,
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("New Testament", style: whiteFS18W700)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width /3,
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Bookmarks", style: whiteFS18W700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: TabBarView(controller: tabController, children: [
                ListView(
                    padding: EdgeInsets.only(left: 8, right: 8, bottom: 100),
                    children: _currentBibleVersesPerBook
                        .where((element) => element.isOldTestament())
                        .map<Widget>((Verse verse) {
                      return BookTile(verse: verse);
                    }).toList()),
                ListView(
                    padding: EdgeInsets.only(left: 8, right: 8, bottom: 100),
                    children: _currentBibleVersesPerBook
                        .where((element) => element.isNewTestament())
                        .map<Widget>((Verse verse) {
                      return BookTile(verse: verse);
                    }).toList()),
                ListView(
                    padding: EdgeInsets.only(left: 8, right: 8, bottom: 100),
                    children: _currentBibleVersesPerBook
                        .where((element) => element.isNewTestament())
                        .map<Widget>((Verse verse) {
                      return BookTile(verse: verse);
                    }).toList()),
              ]),
            )));
      }
    );
  }

  Future<bool> _loadPageData() async {
    _currentBibleVersesPerBook = await Provider.of<BibleProvider>(context).getOneVersePerBook();
    return true;
  }
}

class BookTile extends StatelessWidget {
  final Verse verse;
  const BookTile({
    Key? key,
    required this.verse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6),
        OutlinedButton(
          style: ButtonStyle(
            // backgroundColor: MaterialStateProperty.all(whiteColor),
            padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(vertical: 20, horizontal: 16)),
          ),
          onPressed: () => Navigator.pushNamed(context, BookScreenRoute,
              arguments: {'bookNumber': verse.bookNumber, 'bookName': verse.bookName}),
          child: Row(
            children: [
              Icon(Icons.book, color: primaryColor),
              SizedBox(width: 16),
              Expanded(child: Text(verse.bookName, style: muteFS18W500)),
              SizedBox(width: 16),
              Icon(Icons.chevron_right, color: muteColor),
            ],
          ),
        ),
      ],
    );
  }
}

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            color: primaryColor,
            margin: EdgeInsets.zero,
            elevation: 0.0,
            child: Row(
              children: [
                SizedBox(width: 12),
                Image.asset('assets/images/logo.png', width: 100),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Holy Bible",
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      "Emarss Technologies",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      "www.emarss.co.zw",
                      style: TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    Icon(CupertinoIcons.home, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Home', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "HomePageRoute");
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.highlight, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Highlights', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "DictionaryPageRoute");
                },
              ),
              // ListTile(
              //   title: Row(
              //     children: [
              //       Icon(Icons.checklist, color: primaryColor),
              //       SizedBox(width: 20.0),
              //       Text('Reading Plans', style: muteFS16W500)
              //     ],
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.pushNamed(context, "DictionaryPageRoute");
              //   },
              // ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.comment_bank_outlined, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Personal Notes', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "ActivationPageRoute");
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.history, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Reading History', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "AboutPageRoute");
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(CupertinoIcons.settings, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Settings', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "ActivationPageRoute");
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.help_outline, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Help', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "HelpPageRoute");
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.feedback_outlined, color: primaryColor),
                    SizedBox(width: 20.0),
                    Text('Feedback', style: muteFS16W500)
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "FeedbackPageRoute");
                },
              ),
            ],
          ),
        )
      ],
    ),
  );
}
