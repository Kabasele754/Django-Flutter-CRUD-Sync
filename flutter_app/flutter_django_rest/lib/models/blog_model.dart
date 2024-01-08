class Blog {
  final int? localId; // Ajout de localId
  final int? id;
  late final String title;
  late final String content;
  DateTime? createdAt;
  DateTime? updatedAt;
  final int? synced;

  Blog({
    this.localId, // Ajout de localId
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
    this.synced,
  });

  // Autres membres de la classe...

  // Méthode pour créer une copie mise à jour avec des valeurs facultatives
  Blog copyWith({
    int? localId, // Ajout de localId
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? synced,
  }) {
    return Blog(
      localId: localId ?? this.localId, // Ajout de localId
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  // Méthode pour convertir un objet Map en instance de Blog
  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      localId: map['localId'], // Ajout de localId
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      synced: map['synced'],
    );
  }

  // Méthode pour convertir une instance de Blog en objet Map
  Map<String, dynamic> toMap() {
    return {
      'localId': localId, // Ajout de localId
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt!.toIso8601String(), // Convertit DateTime en format ISO 8601
      'updatedAt': updatedAt!.toIso8601String(),
      'synced': synced,
    };
  }
}
