import 'package:flutter_api_student/models/student.dart';

abstract class ApiState {}

class ApiInitial extends ApiState {}

class ApiLoading extends ApiState {}

class ApiLoaded extends ApiState {
  final List<Student> students;
  ApiLoaded(this.students);
}

class ApiError extends ApiState {
  final String message;
  ApiError(this.message);
}

class ApiSearchResult extends ApiState {
  final List<Student> searchResults;
  ApiSearchResult(this.searchResults);
}