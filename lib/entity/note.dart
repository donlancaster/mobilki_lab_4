import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Note {
  static const idField = 'id';
  static const titleField = 'title';
  static const descriptionField = 'description';
  static const dateCreatedField = 'date_created';
  static const colorField = 'color';

  final int id;
  final String title;
  final String? description;
  final DateTime dateCreated;
  late final Color color;

  Note({
    required this.id,
    required this.title,
    required this.dateCreated,
    this.description,
    Color? color,
  }) {
    this.color = color ?? _availableColors[_random.nextInt(_availableColors.length)];
  }

  Map<String, dynamic> toJson() {
    return {
      idField: id,
      titleField: title,
      descriptionField: description,
      dateCreatedField: dateCreated.millisecondsSinceEpoch,
      colorField: color.value,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json[idField],
      title: json[titleField],
      description: json[descriptionField],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(json[dateCreatedField]),
      color: Color(json[colorField]),
    );
  }

  Note copyWith({String? title, String? description}) {
    return Note(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateCreated: dateCreated,
      color: color,
    );
  }
}

Random _random = Random();

List<Color> _availableColors = [
  Colors.red.shade300,
  Colors.orange.shade300,
  Colors.lightGreenAccent,
  Colors.tealAccent,
  Colors.lightBlueAccent,
  Colors.purpleAccent.shade100,
];
