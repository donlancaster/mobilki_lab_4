import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:notes/colors.dart';
import 'package:notes/dimens.dart';
import 'package:notes/repository/note_repository.dart';
import 'package:notes/widgets/action_button.dart';

import '../entity/note.dart';

class NotePage extends StatefulWidget {
  final Note? note;
  final VoidCallback onDBedited;

  const NotePage({Key? key, this.note, required this.onDBedited}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final NoteRepository _repository = NoteRepository();
  bool editing = false;

  @override
  void initState() {
    super.initState();
    editing = widget.note == null;
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        elevation: 0,
        leadingWidth: AppDimens.appBarButtonHeight + AppDimens.marginDefault,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppDimens.marginDefault),
          child: Center(
            child: CustomActionButton(
              onTap: () => Navigator.of(context).pop(),
              icon: Icons.arrow_back_ios_rounded,
            ),
          ),
        ),
        actions: [
          Center(
            child: editing ? _saveButton() : _editButton(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.marginDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleField(),
              if (widget.note != null) _date(),
              _descriptionField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _date() {
    return Row(
      children: [
        Text(
          DateFormat('MMM dd, yyyy').format(widget.note!.dateCreated),
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.lightText,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(width: AppDimens.marginDefault),
        GestureDetector(
          onTap: _onDelete,
          child: const Text(
            'Delete',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: () {
        _onSave();
      },
      child: Container(
        height: AppDimens.appBarButtonHeight,
        width: 75,
        margin: const EdgeInsets.only(right: AppDimens.marginDefault),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: AppColors.button,
        ),
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _editButton() {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.marginDefault),
      child: CustomActionButton(
        onTap: () => setState(() => editing = true),
        icon: Icons.edit,
      ),
    );
  }

  Widget _titleField() {
    return TextField(
      enabled: editing,
      textAlign: TextAlign.start,
      controller: _titleController,
      style: const TextStyle(
        fontSize: 35,
        color: Colors.white,
        decoration: null,
      ),
      decoration: const InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 35,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }

  Widget _descriptionField() {
    return TextField(
      maxLines: 23,
      enabled: editing,
      textAlign: TextAlign.start,
      controller: _descriptionController,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        decoration: null,
      ),
      decoration: const InputDecoration(
        hintText: 'Type something...',
        hintStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }

  void _onSave() async {
    if (_titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Title is empty');
      return;
    }
    if (widget.note == null) {
      Navigator.of(context).pop();
      await _repository.saveNote(
        title: _titleController.text,
        description: _descriptionController.text,
      );
      widget.onDBedited();
    } else {
      setState(() => editing = false);
      await _repository.updateNote(
        updatedNote: widget.note!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
        ),
      );
      widget.onDBedited();
    }
  }

  void _onDelete() async {
    Navigator.of(context).pop();
    await _repository.deleteNote(deletedNote: widget.note!);
    widget.onDBedited();
  }
}
