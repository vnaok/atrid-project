
class UserProfile {
  final String idUsuario;
  final String nombre;
  final String? apellido;
  final String rol;


  UserProfile({
    required this.idUsuario,
    required this.nombre,
    this.apellido,
    required this.rol,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      idUsuario: map['id_usuario'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      rol: map['rol'],
    );
  }
}