import 'package:flutter_api_student/models/student.dart';

abstract class ApiEvent {}

class FetchStudents extends ApiEvent {}

class AddStudent extends ApiEvent {
  final Student student;
  AddStudent(this.student);
}

class UpdateStudent extends ApiEvent {
  final Student student;
  UpdateStudent(this.student);
}

class DeleteStudent extends ApiEvent {
  final String id;
  DeleteStudent(this.id);
}

class SearchStudent extends ApiEvent {
  final String query;
  SearchStudent(this.query);
}