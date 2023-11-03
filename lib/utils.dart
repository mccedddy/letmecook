import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:image_picker/image_picker.dart';

String? fileName;

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    fileName = _file.name;
    return await _file.readAsBytes();
  }
}