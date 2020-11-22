import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FilePickerCross filePickerCross;

  String _fileString = '';
  Set<String> lastFiles;
  FileQuotaCross quota = FileQuotaCross(quota: 0, usage: 0);

  @override
  void initState() {
    FilePickerCross.listInternalFiles()
        .then((value) => setState(() => lastFiles = value.toSet()));
    FilePickerCross.quota().then((value) => setState(() => quota = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.blueGrey, accentColor: Colors.lightGreen),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          padding: EdgeInsets.all(8),
          children: <Widget>[
            Text(
              'Last files',
              style: Theme.of(context).textTheme.headline5,
            ),
            (lastFiles == null)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => ListTile(
                      leading: Text('$index.'),
                      title: Text(lastFiles.toList()[index]),
                      onTap: () async => setFilePicker(
                          await FilePickerCross.fromInternalPath(
                              path: lastFiles.toList()[index])),
                    ),
                    itemCount: lastFiles.length,
                  ),
            Builder(
              builder: (context) => RaisedButton(
                onPressed: () => _selectFile(context),
                child: Text('Open File...'),
              ),
            ),
            (filePickerCross == null)
                ? Text('Open a file first, to save')
                : RaisedButton(
                    onPressed: _selectSaveFile,
                    child: Text('Save as...'),
                  ),
            Text(
              'File system details',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text('Quota: ${(quota.quota / 1e6).round()} MB'),
            Text(
                'Usage: ${(quota.usage / 1e6).round()}; Remaining: ${(quota.remaining / 1e6).round()}'),
            Text('Percentage: ${quota.relative.roundToDouble()}'),
            Text(
              'File details',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
                'File path: ${filePickerCross?.path ?? 'unknown'} (Might cause issues on web)\n'),
            Text('File length: ${filePickerCross?.length ?? 0}\n'),
            Text('File as String: $_fileString\n'),
          ],
        ),
      ),
    );
  }

  void _selectFile(context) {
    FilePickerCross.importMultipleFromStorage().then((filePicker) {
      setFilePicker(filePicker[0]);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You selected ${filePicker.length} file(s).'),
      ));
    });
  }

  void _selectSaveFile() {
    filePickerCross.exportToStorage();
  }

  setFilePicker(FilePickerCross filePicker) => setState(() {
        filePickerCross = filePicker;
        filePickerCross.saveToPath(path: filePickerCross.fileName);
        FilePickerCross.quota().then((value) {
          setState(() => quota = value);
        });
        lastFiles.add(filePickerCross.fileName);
        try {
          _fileString = filePickerCross.toString();
        } catch (e) {
          _fileString = 'Not a text file. Showing base64.\n\n' +
              filePickerCross.toBase64();
        }
      });
}
