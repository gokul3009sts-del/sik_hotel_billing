import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../database/database_helper.dart';
import '../utils/formatters.dart';

/// Full-data JSON backup/restore. All data stays on-device; the backup file
/// itself can be shared/copied anywhere by the user (Drive, SD card, USB,
/// etc.) but this app never uploads it anywhere on its own.
class BackupService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Directory> _backupDir() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/SIK_Backup');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<File> createBackup() async {
    final data = await _db.exportAllDataAsJson();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await _backupDir();
    final filename = 'SIK_Backup_${Formatters.dateForFile(DateTime.now())}.json';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(jsonStr);
    return file;
  }

  Future<void> shareBackup(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'SIK Data Backup');
  }

  /// Opens the system file picker so the user can choose any .json backup
  /// file on the device, then restores it. Returns null if the user cancels.
  Future<File?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return null;
    return File(result.files.single.path!);
  }

  Future<void> restoreFromFile(File file) async {
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    if (!data.containsKey('dishes') || !data.containsKey('bills')) {
      throw Exception('This file does not look like a valid SIK backup.');
    }
    await _db.restoreAllDataFromJson(data);
  }
}
