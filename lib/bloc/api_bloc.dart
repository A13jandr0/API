import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../models/student.dart';
import 'api_event.dart';
import 'api_state.dart';

class ApiBloc extends Bloc<ApiEvent, ApiState> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://674869495801f5153590c2a3.mockapi.io/api/v1/',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  List<Student> allStudents = [];

  ApiBloc() : super(ApiInitial()) {
    on<FetchStudents>(_fetchStudents);
    on<AddStudent>(_addStudent);
    on<UpdateStudent>(_updateStudent);
    on<DeleteStudent>(_deleteStudent);
    on<SearchStudent>(_searchStudent);
  }

  Future<void> _fetchStudents(FetchStudents event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final response = await _dio.get('student');
      allStudents = (response.data as List)
          .map((json) => Student.fromJson(json))
          .toList();
      emit(ApiLoaded(allStudents));
    } catch (e) {
      emit(ApiError(_handleError(e)));
    }
  }

  Future<void> _addStudent(AddStudent event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await _dio.post('student', data: event.student.toJson());
      add(FetchStudents());
    } catch (e) {
      emit(ApiError(_handleError(e)));
    }
  }

  Future<void> _updateStudent(UpdateStudent event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await _dio.put('student/${event.student.id}', data: event.student.toJson());
      add(FetchStudents());
    } catch (e) {
      emit(ApiError(_handleError(e)));
    }
  }

  Future<void> _deleteStudent(DeleteStudent event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await _dio.delete('student/${event.id}');
      add(FetchStudents());
    } catch (e) {
      emit(ApiError(_handleError(e)));
    }
  }

  Future<void> _searchStudent(SearchStudent event, Emitter<ApiState> emit) async {
    final query = event.query.toLowerCase();
    final results = allStudents
        .where((student) =>
            student.nombre.toLowerCase().contains(query) ||
            student.lastName.toLowerCase().contains(query) ||
            student.phoneNumber.contains(query))
        .toList();
    
    emit(results.isEmpty ? ApiError('No se encontraron resultados') : ApiSearchResult(results));
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Tiempo de conexión agotado';
        case DioExceptionType.receiveTimeout:
          return 'Tiempo de recepción agotado';
        case DioExceptionType.badResponse:
          return 'Error en el servidor: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Solicitud cancelada';
        default:
          return 'Error de conexión';
      }
    }
    return 'Error desconocido';
  }
}