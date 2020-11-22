import 'dart:typed_data';

import 'package:file_chooser/file_chooser.dart';
import 'package:file_picker_cross/file_picker_cross.dart';

import 'file_picker_io.dart';

/// Implementation of file selection dialog using file_chooser for desktop platforms
Future<Map<String, Uint8List>> selectFilesDesktop(
    {FileTypeCross type, String fileExtension}) async {
  FileChooserResult file = await ((parseExtension(fileExtension) == null)
      ? showOpenPanel()
      : showOpenPanel(allowedFileTypes: [
          FileTypeFilterGroup(
              label: 'files', fileExtensions: parseExtension(fileExtension))
        ]));
  String path = file.paths[0];
  return {path: await fileByPath(path).readAsBytes()};
}

/// Implementation of file selection dialog for multiple files using file_chooser for desktop platforms
Future<Map<String, Uint8List>> selectMultipleFilesDesktop(
    {FileTypeCross type, String fileExtension}) async {
  FileChooserResult chooserResult =
      await ((parseExtension(fileExtension) == null)
          ? showOpenPanel(
              allowsMultipleSelection: true,
            )
          : showOpenPanel(allowsMultipleSelection: true, allowedFileTypes: [
              FileTypeFilterGroup(
                  label: 'files', fileExtensions: parseExtension(fileExtension))
            ]));
  print(chooserResult);
  Map<String, Uint8List> fileBytes = {};
  chooserResult.paths.forEach((path) {
    fileBytes[path] = fileByPath(path).readAsBytesSync();
  });
  return fileBytes;
}

/// Implementation of file selection dialog using file_chooser for desktop platforms
Future<String> saveFileDesktop(
    {String fileExtension, String suggestedFileName}) async {
  FileChooserResult file = await showSavePanel(
      suggestedFileName: suggestedFileName,
      allowedFileTypes: (parseExtension(fileExtension) == null)
          ? null
          : [
              FileTypeFilterGroup(
                  label: 'files', fileExtensions: parseExtension(fileExtension))
            ]);
  String path = file.paths.isEmpty ? "" : file.paths[0];
  return path;
}
