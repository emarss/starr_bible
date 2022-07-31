// import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quil;
import 'package:provider/provider.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/services/colors.dart';
// import 'package:starr/services/database_def.dart';
// import 'package:starr/services/database_def.dart';
import 'package:starr/services/routes.dart';
import 'package:starr/services/styles.dart';

Future<bool> initializeApp(BuildContext context) async {
  // await openOrCreateDatabase();
  await Provider.of<BibleProvider>(context, listen: false).getBibles();
  return true;
}

List<String> versionsList = [
  "niv",
  "kjv",
  "nkjv",
  "amp",
  "shona",
  "gnb",
  "esv"
];

void showChangeVersionDialog(BuildContext context) {
  BibleProvider bibleProvider =
      Provider.of<BibleProvider>(context, listen: false);
  AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogBackgroundColor: primaryColor,
      dialogBorderRadius: BorderRadius.circular(4),
      dialogType: DialogType.NO_HEADER,
      padding: EdgeInsets.only(bottom: 16),
      width: MediaQuery.of(context).size.width,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  children: versionsList.map<Widget>((String version) {
                return Theme(
                  data: ThemeData(unselectedWidgetColor: whiteColor),
                  child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: whiteColor,
                      dense: true,
                      value: version,
                      groupValue: bibleProvider.currentVersion,
                      onChanged: (String? uuid) async {
                        await bibleProvider.setCurrentBible(version);
                        Navigator.of(context).pop();
                      },
                      title: Text(
                        "${getBibleName(version)}",
                        style: whiteFS15W400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                );
              }).toList()),
            ],
          ),
        ),
      ))
    ..show();
}

getBibleName(String version) {
  late String name;
  switch (version) {
case "niv":
  name = "New International Version";
  break;
case "kjv":
  name = "King James Version";
  break;
case "nkjv":
  name = "New King James Version";
  break;
case "amp":
  name = "Amplified Version";
  break;
case "shona":
  name = "Shona Version";
  break;
case "gnb":
  name = "Good News Bible Version";
  break;
case "esv":
  name = "English Standard Version";
  break;
    default:
  }

return name;
}

void openSearchScreen(BuildContext context) {
  Navigator.of(context).pushNamed(SearchScreenRoute);
}

showSnackBar(BuildContext context, String message, int seconds) {
  final snackBar = SnackBar(
    duration: Duration(seconds: seconds),
    content: Text(message),
    action: SnackBarAction(
      label: 'Close',
      textColor: Colors.white,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String getSelectedBibleVerses(BuildContext context, List<Verse> _selectedVerses) {
  

  _selectedVerses.sort((a, b) => a.number.compareTo(b.number));

  String text = "${_selectedVerses.first.bookName} ${_selectedVerses.first.chapterNumber} vs. ";
  text = text + getVerses(_selectedVerses);
  text = text + "\n";

  _selectedVerses.forEach((Verse verse) {
    text = text + verse.number.toString() + ". " + verse.text;
    if (_selectedVerses.last != verse) {
      text = text + "\n";
    }
  });
  return text;
}

String getVerses(List<Verse> selectedVerses) {
  if (selectedVerses.length == 1) {
    return selectedVerses.first.number.toString();
  }
  if (integersListIsRange(selectedVerses)) {
    return selectedVerses.first.number.toString() +
        " - " +
        selectedVerses.last.number.toString();
  } else {
    String _verses = "";
    selectedVerses.forEach((element) {
      _verses = _verses + element.number.toString();
      if (selectedVerses.last.number != element.number) {
        _verses = _verses + ", ";
      }
    });

    return _verses;
  }
}

bool integersListIsRange(List<Verse> selectedVerses) {
  int min = selectedVerses.first.number;
  int max = selectedVerses.last.number;
  if (selectedVerses.length == (max - min + 1)) {
    return true;
  }

  return false;
}

String getExceptFromQuillPlainText(String quillPlainText) {
  return "";
  // String content = quil.QuillController(
  //         document: quil.Document.fromJson(jsonDecode(quillPlainText)),
  //         selection: TextSelection.collapsed(offset: 0))
  //     .document
  //     .toPlainText();
  // String jsonContent = jsonEncode(content);
  // List<String> listOfLines =
  //     jsonContent.substring(1, jsonContent.length - 1).split("\\n");

  // if (listOfLines.length > 1) {
  //   return listOfLines.elementAt(0);
  // } else {
  //   return "";
  // }
}


class SearchParameters {
  late String search;
  late List<Verse> results;
  late bool matchExactPhrase;
  late bool searchOT;
  late bool searchNT;

  late List<String> selectedBiblesList;

  ///
  /// Instantiate SearchParameters from map
  ///
  SearchParameters.fromMap(Map<String, dynamic> map) {
    search = map['search'];
    results = map['results'];
    matchExactPhrase = map['matchExactPhrase'];
    searchOT = map['searchOT'];
    searchNT = map['searchNT'];
  }
}

ShapeBorder getShapeBorder(double radius) {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}

OutlinedBorder getOutlinedBorder(double radius) {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
