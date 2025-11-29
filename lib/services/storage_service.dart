import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('$path/$name');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadStudentDocument({
    required File file,
    required String studentId,
  }) async {
    return uploadFile(
      file: file,
      path: 'students/$studentId/documents',
    );
  }

  Future<String> uploadStudentPhoto({
    required File file,
    required String studentId,
  }) async {
    return uploadFile(
      file: file,
      path: 'students/$studentId/photo',
      fileName: 'profile.jpg',
    );
  }

  Future<String> uploadComplaintImage({
    required File file,
    required String complaintId,
  }) async {
    return uploadFile(
      file: file,
      path: 'complaints/$complaintId',
    );
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
