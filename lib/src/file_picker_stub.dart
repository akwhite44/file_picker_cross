import 'dart:typed_data';

import '../file_picker_cross.dart';

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<Map<String, Uint8List>> selectSingleFileAsBytes(
    {FileTypeCross type, String fileExtension}) async {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<Map<String, Uint8List>> selectMultipleFilesAsBytes(
    {FileTypeCross type, String fileExtension}) async {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<String> pickSingleFileAsPath(
    {FileTypeCross type, String fileExtension}) async {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<Uint8List> internalFileByPath({String path}) {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<bool> saveInternalBytes({Uint8List bytes, String path}) {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<String> exportToExternalStorage({Uint8List bytes, String fileName}) {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<bool> deleteInternalPath({String path}) {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<List<String>> listFiles({Pattern at, Pattern name}) async {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<FileQuotaCross> getInternalQuota() async {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}
