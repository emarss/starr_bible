import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/screens/book.dart';
import 'package:starr/screens/chapter.dart';
import 'package:starr/screens/home.dart';
import 'package:starr/screens/index.dart';
import 'package:starr/screens/search.dart';
import 'package:starr/screens/search_results.dart';
import 'package:starr/services/colors.dart';
import 'package:starr/services/routes.dart';
import 'package:starr/services/styles.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => BibleProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holy Bible',
      scrollBehavior: CupertinoScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: faintColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)))),
                textStyle: MaterialStateProperty.all(whiteFS16W500),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 10, horizontal: 24)),
                backgroundColor: MaterialStateProperty.all(primaryColor),
                foregroundColor: MaterialStateProperty.all(whiteColor))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)))),
          textStyle: MaterialStateProperty.all(primaryFS16W500),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
        )),
        appBarTheme: AppBarTheme(
            // titleSpacing: 0,
            systemOverlayStyle:
                SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
            elevation: 1,
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: whiteColor)),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _routes(),
    );
  }

  RouteFactory _routes() {
    return (settings) {
      Widget screen;
      Map<String, dynamic>? arguments;
      if (settings.arguments != null) {
        arguments = settings.arguments as Map<String, dynamic>;
      }

      switch (settings.name) {
        case HomeScreenRoute:
          screen = HomeScreen();
          break;
        case SearchScreenRoute:
          screen = SearchScreen();
          break;
        case BookScreenRoute:
          screen = BookScreen(
              bookNumber: arguments!['bookNumber'],
              bookName: arguments['bookName']);
          break;
        case ChapterScreenRoute:
          screen = ChapterScreen(
              bookNumber: arguments!['bookNumber'],
              chapterNumber: arguments['chapterNumber'],
              bookName: arguments['bookName']);
          break;
        case ChapterWithScreenRoute:
          screen = ChapterScreen(
              bookNumber: arguments!['bookNumber'],
              chapterNumber: arguments['chapterNumber'],
              verseNumber: arguments['verseNumber'],
              bookName: arguments['bookName']);
          break;
        case SearchResultsScreenRoute:
          screen = SearchResultsScreen(
              searchParameters: arguments!['searchParameters']);
          break;

        default:
          screen = IndexScreen();
          break;
      }

      return CupertinoPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
