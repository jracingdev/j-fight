class Usuario {
  final String id;
  final String nome;
  final String email;
  final String role; // admin | aluno
  final String? fotoUrl;
  final String? googleId;
  final String? senhaHash;
  final String? alunoId;
  final String? createdAt;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.role = 'aluno',
    this.fotoUrl,
    this.googleId,
    this.senhaHash,
    this.alunoId,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        id: m['id'],
        nome: m['nome'],
        email: m['email'],
        role: m['role'] ?? 'aluno',
        fotoUrl: m['foto_url'],
        googleId: m['google_id'],
        senhaHash: m['senha_hash'],
        alunoId: m['aluno_id'],
        createdAt: m['created_at'],
      );

  Usuario copyWith({String? alunoId, String? nome, String? fotoUrl}) => Usuario(
        id: id,
        nome: nome ?? this.nome,
        email: email,
        role: role,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        googleId: googleId,
        senhaHash: senhaHash,
        alunoId: alunoId ?? this.alunoId,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'email': email,
        'role': role,
        'foto_url': fotoUrl,
        'google_id': googleId,
        'senha_hash': senhaHash,
        'aluno_id': alunoId,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };
}
