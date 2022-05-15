import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes/colors.dart';
import 'package:notes/dimens.dart';
import 'package:notes/pages/note.dart';
import 'package:notes/repository/note_repository.dart';
import 'package:intl/intl.dart';
import 'package:notes/widgets/action_button.dart';

import '../entity/note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> _items = [];
  List<Note> _searchItems = [];
  final NoteRepository _repository = NoteRepository();
  bool searching = false;
  final TextEditingController _searchController = TextEditingController();

  List<Note> get itemList => searching ? _searchItems : _items;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() => setState(() {
          if (_searchController.text.isEmpty) {
            _searchItems = _items;
          } else {
            _searchItems =
                _items.where((item) => item.title.contains(_searchController.text)).toList();
          }
        }));
  }

  void _loadData() async {
    final items = await _repository.getNotes();
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        elevation: 0,
        leadingWidth: 80 + AppDimens.marginDefault,
        leading: searching
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: AppDimens.marginDefault),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: AppDimens.marginSmall / 2),
                      child: Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        flexibleSpace: searching ? _searchRow() : null,
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.marginSmall / 3),
                child: searching ? _cancelSearchButton() : _searchButton(),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppDimens.marginSmall),
            Expanded(
              child: _grid(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (newContext) => NotePage(
                onDBedited: _loadData,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: AppColors.button,
      ),
    );
  }

  Widget _searchButton() {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.marginDefault),
      child: CustomActionButton(
        onTap: () {
          _searchItems = _items;
          setState(() => searching = true);
        },
        icon: Icons.search,
      ),
    );
  }

  Widget _searchRow() {
    return Row(
      children: [
        const SizedBox(width: AppDimens.marginDefault),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.marginSmall),
            margin: const EdgeInsets.only(top: 1.5 * AppDimens.marginDefault),
            height: AppDimens.appBarButtonHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: AppColors.button, width: 2),
              color: AppColors.primaryBg,
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Type here',
                hintStyle: TextStyle(color: AppColors.lightText),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.appBarButtonHeight + 2 * AppDimens.marginDefault),
      ],
    );
  }

  Widget _cancelSearchButton() {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.marginDefault),
      child: CustomActionButton(
        onTap: () {
          _searchController.text = '';
          _searchItems = [];
          setState(() => searching = false);
        },
        icon: Icons.close,
      ),
    );
  }

  Widget _grid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.marginDefault),
      child: itemList.isNotEmpty
          ? GridView.custom(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(2, 4),
                  const QuiltedGridTile(4, 2),
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(2, 2),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) => _gridCard(itemList[index]),
                childCount: itemList.length,
              ),
            )
          : Container(),
    );
  }

  Widget _gridCard(Note note) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => NotePage(
              note: note,
              onDBedited: _loadData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: note.color,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        padding: const EdgeInsets.all(AppDimens.marginSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AutoSizeText(
                note.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                ),
                wrapWords: true,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(note.dateCreated),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
