import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:disk_space/disk_space.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'file_picker_desktop.dart';
import 'file_picker_mobile.dart';

/// Implementation of file selection dialog delegating to platform-specific implementations
Future<Map<String, Uint8List>> selectSingleFileAsBytes(
    {FileTypeCross type, String fileExtension}) async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
    return await selectFilesMobile(type: type, fileExtension: fileExtension);
  } else {
    return await selectFilesDesktop(type: type, fileExtension: fileExtension);
  }
}

/// Implementation of file selection dialog delegating to platform-specific implementations
Future<Map<String, Uint8List>> selectMultipleFilesAsBytes(
    {FileTypeCross type, String fileExtension}) async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
    return await selectMultipleFilesMobile(
        type: type, fileExtension: fileExtension);
  } else {
    return await selectMultipleFilesDesktop(
        type: type, fileExtension: fileExtension);
  }
}

/// Implementation of file selection dialog delegating to platform-specific implementations
Future<String> pickSingleFileAsPath(
    {FileTypeCross type, String fileExtension}) async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
    return await saveFileMobile(type: type, fileExtension: fileExtension);
  } else {
    return await saveFileDesktop(fileExtension: fileExtension);
  }
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<Uint8List> internalFileByPath({String path}) async {
  return fileByPath(await normalizedApplicationDocumentsPath() + path)
      .readAsBytes();
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<bool> saveInternalBytes({Uint8List bytes, String path}) async {
  File file = fileByPath(await normalizedApplicationDocumentsPath() + path);
  file.createSync(recursive: true);
  return file
      .writeAsBytes(bytes)
      .then((value) => true)
      .catchError((e) => false);
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<String> exportToExternalStorage(
    {Uint8List bytes, String fileName}) async {
  String extension;
  if (fileName.contains('.'))
    extension = fileName.substring(fileName.lastIndexOf('.'));
  if (Platform.isAndroid || Platform.isIOS) {
    final String path = (await getTemporaryDirectory()).path + '/' + fileName;
    await File(path).writeAsBytes(bytes);
    Share.shareFiles([path]);
    return fileName;
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    String path = await saveFileDesktop(
        fileExtension: extension, suggestedFileName: fileName);
    File file = await File(path).create(recursive: true);
    file = await file.writeAsBytes(bytes);
    return file.path;
  } else {
    throw UnimplementedError(
        'Exporting files is not implemented on your platform.');
  }
}

Future<bool> deleteInternalPath({String path}) async {
  if (await fileByPath(path).exists())
    return fileByPath(path)
        .delete()
        .then((value) => true)
        .catchError((e) => false);
  else
    return true;
}

Future<FileQuotaCross> getInternalQuota() async {
  double freeSpace = (await DiskSpace.getFreeDiskSpace) * 1e6;
  double totalSpace = (await DiskSpace.getTotalDiskSpace) * 1e6;
  print(totalSpace);
  print(freeSpace);
  return (FileQuotaCross(
      quota: totalSpace.round(), usage: (totalSpace - freeSpace).round()));
}

/// Dummy implementation throwing an error. Should be overwritten by conditional imports.
Future<List<String>> listFiles({Pattern at, Pattern name}) async {
  final String appPath = await normalizedApplicationDocumentsPath();
  List<String> files =
      await Directory(await normalizedApplicationDocumentsPath())
          .list(recursive: true)
          .map((event) => '/' + event.path.replaceFirst(appPath, ''))
          .toList();
  if (at != null) files = files.where((element) => element.startsWith(at));
  if (name != null) files = files.where((element) => element.endsWith(name));
  return files;
}

/// Parsing various valid HTML/JS file type declarations into valid ones for file_picker
dynamic parseExtension(String fileExtension) {
  return (fileExtension != null &&
          fileExtension.replaceAll(',', '').trim().isNotEmpty)
      ? fileExtension.split(',').map<String>((e) => e.trim()).toList()
      : null;
}

FileType fileTypeCrossParse(FileTypeCross type) {
  FileType accept;
  switch (type) {
    case FileTypeCross.any:
      accept = FileType.any;
      break;
    case FileTypeCross.audio:
      accept = FileType.audio;
      break;
    case FileTypeCross.image:
      accept = FileType.image;
      break;
    case FileTypeCross.video:
      accept = FileType.video;
      break;
    case FileTypeCross.custom:
      accept = FileType.custom;
      break;
  }
  return accept;
}

/// Returns a [String] containing the path of a directory which is both readable and writable. If it was not created yet, it is created.
Future<String> normalizedApplicationDocumentsPath() async {
  String directoryPath;

  String appName;
  try {
    appName = (await PackageInfo.fromPlatform()).appName;
  } catch (e) {
    appName = 'file_picker_cross';
  }

  /// unfortunately, Windows is not yet supported by [path_provider]. See https://github.com/flutter/flutter/issues/41715 for more details.
  if (Platform.isWindows) {
    directoryPath = Directory(r'%LOCALAPPDATA%\' + appName).path;
  } else
    directoryPath = (await getApplicationDocumentsDirectory()).path;
  String path = (directoryPath.replaceAll(r'\', r'/') + '/$appName/')
      .replaceAll(r'//', '/');
  if (!await Directory(path).exists())
    Directory(path).createSync(recursive: true);
  return path;
}

File fileByPath(String path) => File.fromUri(Uri.file(path));
