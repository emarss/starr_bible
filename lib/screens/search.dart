import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:starr/models/bible.dart';
import 'package:starr/services/globals.dart';
import 'package:starr/services/routes.dart';
import 'package:starr/services/styles.dart';

import 'includes/dialogs.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  TextEditingController _searchController = TextEditingController();
  List<Verse> _results = [];
  bool _matchExactPhrase = false;
  bool _searchOT = true;
  bool _searchNT = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 66,
          title: Text("Search", style: whiteFS20W600.merge(condensed).merge(TextStyle(fontSize: 24))),
        ),
        body: ListView(padding: EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
          Form(
            key: _formStateKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  inputFormatters: [LengthLimitingTextInputFormatter(199)],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Required field';
                    }
                    if (value.length < 3) {
                      return 'Search text too short.';
                    }
                    return null;
                  },
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintStyle: muteFS16W500,
                      hintText: "Type to search...",
                      border: UnderlineInputBorder()),
                ),
                SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        if (!_formStateKey.currentState!.validate()) {
                          return;
                        }
                        _search();
                      },
                      icon: Icon(Icons.search),
                      label: Text("Search"))
                ]),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Search Options",
            style: primaryFS17W500,
          ),
          SizedBox(height: 16),
          Divider(thickness: 1.2, height: 0),
       CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: _matchExactPhrase,
            title: Row(
              children: [
                Expanded(
                    child: Text("Match Exact Phrase", style: darkFS15W600)),
              ],
            ),
            onChanged: (bool? value) {
              setState(() {
                if (_matchExactPhrase == false) {
                  _matchExactPhrase = true;
                } else {
                  _matchExactPhrase = false;
                }
              });
            },
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: _searchOT,
            title: Row(
              children: [
                Expanded(
                    child: Text("Search Old Testament", style: darkFS15W600)),
              ],
            ),
            onChanged: (bool? value) {
              setState(() {
                if (_searchOT == false) {
                  _searchOT = true;
                } else {
                  _searchOT = false;
                }
              });
            },
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: _searchNT,
            title: Row(
              children: [
                Expanded(
                    child: Text("Search New Testament", style: darkFS15W600)),
              ],
            ),
            onChanged: (bool? value) {
              setState(() {
                if (_searchNT == false) {
                  _searchNT = true;
                } else {
                  _searchNT = false;
                }
              });
            },
          ),
        ]),
      ),
    );
  }

  _search() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    late AwesomeDialog dialog;
    dialog = await showWaitingDialogAsync(context, message: "Searching...")
      ..show();

    _results.clear();
    if (_searchNT == false && _searchOT == false) {
      dialog.dismiss();
      await showErrorDialogAsync(context,
          message: "No results found. Please, adjust your search options.")
        ..show();
    } else {
      dialog.dismiss();
      _results = await Provider.of<BibleProvider>(context, listen: false).search(_searchController.text, matchExactPhrase: _matchExactPhrase, searchNT: _searchNT, searchOT: _searchOT);
      if (_results.isEmpty) {
        await showErrorDialogAsync(context, message: "No results found.")
          ..show();
      } else {
        SearchParameters searchParameters = SearchParameters.fromMap({
          "search": _searchController.text,
          "results": _results,
          "matchExactPhrase": _matchExactPhrase,
          "searchOT": _searchOT,
          "searchNT": _searchNT,
        });
        Navigator.of(context).pushNamed(SearchResultsScreenRoute,
            arguments: {"searchParameters": searchParameters});
      }
    }
  }

}
