// Modelo de autor (antes era author.model.ts con interface).
// En Dart no hay interfaces para JSON, así que hacemos una clase con fromJson.
class Author {
  final String id; // en la API se llama _id
  final String name;
  final String email;
  final String? nationality;
  final String? biography;
  final String? birthDate;
  final String? website;
  final String? photoUrl;
  final bool? active;
  final String? role; // 'author' o 'admin'

  Author({
    required this.id,
    required this.name,
    required this.email,
    this.nationality,
    this.biography,
    this.birthDate,
    this.website,
    this.photoUrl,
    this.active,
    this.role,
  });

  // Convierte el JSON de la API en un objeto Author
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      nationality: json['nationality'] as String?,
      biography: json['biography'] as String?,
      birthDate: json['birthDate'] as String?,
      website: json['website'] as String?,
      photoUrl: json['photoUrl'] as String?,
      active: json['active'] as bool?,
      role: json['role'] as String?,
    );
  }
}

// Roles que acepta la API
const List<String> authorRoles = ['author', 'admin'];
