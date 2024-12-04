class Student {
  final String id;
  final String nombre;
  final String imagen;
  final String phoneNumber;
  final String lastName;

  Student({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.phoneNumber,
    required this.lastName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      nombre: json['nombre'],
      imagen: json['imagen'],
      phoneNumber: json['phoneNumber'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'imagen': imagen,
      'phoneNumber': phoneNumber,
      'lastName': lastName,
    };
  }
}