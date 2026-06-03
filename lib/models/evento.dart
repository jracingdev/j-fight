class Evento {
  final String id;
  final String titulo;
  final String data; // yyyy-MM-dd
  final String? horaInicio; // HH:mm
  final String? horaFim;   // HH:mm
  final String tipo;
  final String? descricao;
  final String? local;
  final String? organizador;
  final String? linkUrl;
  final String? createdAt;

  const Evento({
    required this.id,
    required this.titulo,
    required this.data,
    this.horaInicio,
    this.horaFim,
    this.tipo = 'campeonato',
    this.descricao,
    this.local,
    this.organizador,
    this.linkUrl,
    this.createdAt,
  });

  String get dataHoraLabel {
    final h = horaInicio != null ? ' às $horaInicio${horaFim != null ? ' – $horaFim' : ''}' : '';
    return '$data$h';
  }

  factory Evento.fromMap(Map<String, dynamic> m) => Evento(
        id: m['id'],
        titulo: m['titulo'],
        data: m['data'],
        horaInicio: m['hora_inicio'],
        horaFim: m['hora_fim'],
        tipo: m['tipo'] ?? 'campeonato',
        descricao: m['descricao'],
        local: m['local'],
        organizador: m['organizador'],
        linkUrl: m['link_url'],
        createdAt: m['created_at'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'data': data,
        'hora_inicio': horaInicio,
        'hora_fim': horaFim,
        'tipo': tipo,
        'descricao': descricao,
        'local': local,
        'organizador': organizador,
        'link_url': linkUrl,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };
}
