import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillswap/Datas/userdata.dart';
import 'package:skillswap/firebase/firebase.dart';
import 'package:skillswap/homepageCandidate/Search/usersearch.dart';

class SearchUser_Screen extends StatefulWidget {
  SearchUser_Screen({super.key});

  @override
  State<SearchUser_Screen> createState() => _SearchUser_ScreenState();
}

class _SearchUser_ScreenState extends State<SearchUser_Screen> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final UserController userController = Get.find();

  List _allUser = [];
  List _searchResult = [];
  bool _isLoading = false;

  allUser() {
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore.instance
        .collection('Users')
        .orderBy('First')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _allUser = snapshot.docs;
        _allUser.removeWhere((doc) => doc.id == userController.userid);
        searchResult(); // Move this inside setState
      });
    });
  }

  searchResult() {
    setState(() {
      _isLoading = true; // Set isLoading to true before performing search
    });
    var showResult = [];
    if (_search.text.isNotEmpty) {
      List<String> searchthis = _search.text
          .split(" ")
          .where((word) => word.isNotEmpty)
          .map((word) => word.trim())
          .toList();

      for (var u in _allUser) {
        List<Map<String, dynamic>> skills =
            List<Map<String, dynamic>>.from(u['Skills'] ?? []);
        List<String> skillNames = [];

        for (var skill in skills) {
          skillNames.add(skill['skill'].toLowerCase());
        }

        if (searchthis
            .every((skill) => skillNames.contains(skill.toLowerCase()))) {
          showResult.add(u);
          break;
        }
      }
      showResult = List.from(_allUser);
    }else {
      // Reset search result based on current search mode
      showResult =
           List.from(_allUser);
    }
    setState(() {
      _searchResult = showResult;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearch);
    _searchFocusNode.requestFocus();
    allUser();
  }

  _onSearch() {
    if (_search.text.isNotEmpty && _search.text.trim() != "") {
      searchResult();
    }
  }

  @override
  void dispose() {
    _search.removeListener(_onSearch);
    _search.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SizedBox(
          height: height * 0.06,
          child: CupertinoSearchTextField(
              controller: _search, focusNode: _searchFocusNode),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searchResult.isEmpty
                      ? Center(
                          child: Text("No results found"),
                        )
                      : ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userdata = _searchResult[index]
                                .data() as Map<String, dynamic>;
                            String userid = _searchResult[index].id;
                            // Check if userdata is null
                            if (userdata['First'] == null) {
                              // Show a loading indicator
                              if (_isLoading == true) {
                                return Container();
                              } else {
                                _isLoading = true;
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }
                            return Column(
                              children: [
                                UserSearch(userdata, userid),
                                Divider()
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
