import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/api_bloc.dart';
import '../bloc/api_event.dart';
import '../bloc/api_state.dart';
import '../models/student.dart';

class ScreenApi extends StatefulWidget {
  @override
  _ScreenApiState createState() => _ScreenApiState();
}

class _ScreenApiState extends State<ScreenApi> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gestión de Estudiantes",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepPurple[600],
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              BlocProvider.of<ApiBloc>(context).add(FetchStudents());
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => ApiBloc()..add(FetchStudents()),
        child: BlocBuilder<ApiBloc, ApiState>(
          builder: (context, state) {
            if (state is ApiLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              );
            } else if (state is ApiLoaded || state is ApiSearchResult) {
              final students = state is ApiLoaded
                  ? state.students
                  : (state as ApiSearchResult).searchResults;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar estudiante',
                        prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                      onSubmitted: (value) {
                        BlocProvider.of<ApiBloc>(context).add(
                          SearchStudent(searchController.text.trim())
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            onTap: () {
                              _showStudentDetailsDialog(context, student);
                            },
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, 
                              vertical: 8
                            ),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(student.imagen),
                              backgroundColor: Colors.deepPurple[100],
                              onBackgroundImageError: (exception, stackTrace) {
                                return;
                              },
                            ),
                            title: Text(
                              student.nombre + ' ' + student.lastName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                            subtitle: Text(
                              'Teléfono: ${student.phoneNumber}',
                              style: TextStyle(color: Colors.deepPurple[600]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditStudentDialog(context, student);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context, student);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is ApiError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.red, 
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            }
            return Center(
              child: Text(
                'No hay estudiantes',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 18,
                ),
              )
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple[600],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddStudentDialog(context);
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmar Eliminación", 
          style: TextStyle(color: Colors.deepPurple),
        ),
        content: Text(
          "¿Estás seguro de que quieres eliminar a ${student.nombre} ${student.lastName}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              BlocProvider.of<ApiBloc>(context).add(DeleteStudent(student.id));
              Navigator.pop(context);
            },
            child: Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final lastNameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            "Agregar Estudiante",
            style: TextStyle(color: Colors.deepPurple),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Nombre", setState),
                _buildTextField(lastNameController, "Apellido", setState),
                _buildTextField(phoneController, "Teléfono", setState),
                _buildTextField(imageController, "URL Imagen", setState),
                
                if (imageController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.network(
                      imageController.text,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {
                if (_validateInputs(
                  nameController.text, 
                  lastNameController.text, 
                  phoneController.text, 
                  imageController.text
                )) {
                  final newStudent = Student(
                    id: '',
                    nombre: nameController.text,
                    lastName: lastNameController.text,
                    phoneNumber: phoneController.text,
                    imagen: imageController.text,
                  );
                  BlocProvider.of<ApiBloc>(context).add(AddStudent(newStudent));
                  Navigator.pop(context);
                } else {
                  _showErrorDialog(context, "Todos los campos son obligatorios");
                }
              },
              child: Text("Agregar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.nombre);
    final phoneController = TextEditingController(text: student.phoneNumber);
    final lastNameController = TextEditingController(text: student.lastName);
    final imageController = TextEditingController(text: student.imagen);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            "Editar Estudiante",
            style: TextStyle(color: Colors.deepPurple),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Nombre", setState),
                _buildTextField(lastNameController, "Apellido", setState),
                _buildTextField(phoneController, "Teléfono", setState),
                _buildTextField(imageController, "URL Imagen", setState),
                
                if (imageController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.network(
                      imageController.text,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                if (_validateInputs(
                  nameController.text, 
                  lastNameController.text, 
                  phoneController.text, 
                  imageController.text
                )) {
                  final updatedStudent = Student(
                    id: student.id,
                    nombre: nameController.text,
                    lastName: lastNameController.text,
                    phoneNumber: phoneController.text,
                    imagen: imageController.text,
                  );
                  BlocProvider.of<ApiBloc>(context).add(UpdateStudent(updatedStudent));
                  Navigator.pop(context);
                } else {
                  _showErrorDialog(context, "Todos los campos son obligatorios");
                }
              },
              child: Text("Actualizar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetailsDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Detalles del Estudiante",
          style: TextStyle(
            color: Colors.deepPurple, 
            fontWeight: FontWeight.bold
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(student.imagen),
              backgroundColor: Colors.deepPurple[100],
              onBackgroundImageError: (exception, stackTrace) {
                return;
              },
            ),
            SizedBox(height: 16),
            _buildDetailRow("Nombre", student.nombre),
            _buildDetailRow("Apellido", student.lastName),
            _buildDetailRow("Teléfono", student.phoneNumber),
            SizedBox(height: 8),
            Text(
              "URL de Imagen:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              student.imagen,
              style: TextStyle(color: Colors.blue),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cerrar", 
              style: TextStyle(color: Colors.deepPurple)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String labelText,
    StateSetter setState
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Error", 
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  bool _validateInputs(
    String name, 
    String lastName, 
    String phone, 
    String image
  ) {
    return name.isNotEmpty && 
           lastName.isNotEmpty && 
           phone.isNotEmpty && 
           image.isNotEmpty;
  }
}