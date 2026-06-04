import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme.dart';
import '../../models/aluno.dart';
import '../../repositories/aluno_repository.dart';
import '../../utils/bjj_utils.dart';

class MeuCadastroScreen extends StatefulWidget {
  final bool editar;
  const MeuCadastroScreen({super.key, this.editar = false});

  @override
  State<MeuCadastroScreen> createState() => _MeuCadastroScreenState();
}

class _MeuCadastroScreenState extends State<MeuCadastroScreen> {
  final _repo = AlunoRepository();
  bool _loading = false;

  late final _nomeCtrl = TextEditingController();
  late final _emailCtrl = TextEditingController();
  late final _telefoneCtrl = TextEditingController();
  late final _respNomeCtrl = TextEditingController();
  late final _respTelCtrl = TextEditingController();
  late final _enderecoCtrl = TextEditingController();
  late final _cidadeCtrl = TextEditingController();
  late final _estadoCtrl = TextEditingController();
  late final _cepCtrl = TextEditingController();
  late final _pesoCtrl = TextEditingController();
  late final _nascCtrl = TextEditingController();

  String _sexo = 'masculino';
  Aluno? _existente;

  @override
  void initState() {
    super.initState();
    _preencher();
  }

  void _preencher() {
    final auth = context.read<AuthProvider>();
    final user = auth.usuario;
    final aluno = auth.alunoVinculado;
    _existente = aluno;
    _nomeCtrl.text = aluno?.nome ?? user?.nome ?? '';
    _emailCtrl.text = aluno?.email ?? user?.email ?? '';
    _telefoneCtrl.text = aluno?.telefone ?? '';
    _respNomeCtrl.text = aluno?.nomeResponsavel ?? '';
    _respTelCtrl.text = aluno?.telefoneResponsavel ?? '';
    _enderecoCtrl.text = aluno?.endereco ?? '';
    _cidadeCtrl.text = aluno?.cidade ?? '';
    _estadoCtrl.text = aluno?.estado ?? '';
    _cepCtrl.text = aluno?.cep ?? '';
    _pesoCtrl.text = aluno?.peso?.toString() ?? '';
    _nascCtrl.text = aluno?.dataNascimento ?? '';
    if (aluno != null) _sexo = aluno.sexo;
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl, _emailCtrl, _telefoneCtrl, _respNomeCtrl, _respTelCtrl,
      _enderecoCtrl, _cidadeCtrl, _estadoCtrl, _cepCtrl, _pesoCtrl, _nascCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeCtrl.text.trim().isEmpty ||
        _nascCtrl.text.isEmpty ||
        _telefoneCtrl.text.trim().isEmpty ||
        _cidadeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, nascimento, telefone e cidade.')),
      );
      return;
    }

    final idade = calcularIdadeCBJJ(_nascCtrl.text);
    if (idade != null && idade < 18) {
      if (_respNomeCtrl.text.trim().isEmpty || _respTelCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menores de 18 anos: informe o responsável.')),
        );
        return;
      }
    }

    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final user = auth.usuario!;

    final dados = Aluno(
      id: _existente?.id ?? '',
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? user.email : _emailCtrl.text.trim(),
      dataNascimento: _nascCtrl.text,
      sexo: _sexo,
      telefone: _telefoneCtrl.text.trim(),
      nomeResponsavel: _respNomeCtrl.text.trim().isEmpty ? null : _respNomeCtrl.text.trim(),
      telefoneResponsavel: _respTelCtrl.text.trim().isEmpty ? null : _respTelCtrl.text.trim(),
      endereco: _enderecoCtrl.text.trim().isEmpty ? null : _enderecoCtrl.text.trim(),
      cidade: _cidadeCtrl.text.trim(),
      estado: _estadoCtrl.text.trim().isEmpty ? null : _estadoCtrl.text.trim().toUpperCase(),
      cep: _cepCtrl.text.trim().isEmpty ? null : _cepCtrl.text.trim(),
      peso: _pesoCtrl.text.isEmpty ? null : double.tryParse(_pesoCtrl.text),
      faixa: _existente?.faixa ?? 'branca',
      grau: _existente?.grau ?? 0,
      ativo: false,
      cadastroValidado: false,
      createdAt: _existente?.createdAt,
    );

    Aluno salvo;
    if (_existente != null) {
      await _repo.atualizar(dados);
      salvo = dados;
    } else {
      salvo = await _repo.criar(dados);
    }

    await auth.vincularAlunoSalvo(salvo);

    if (mounted) {
      setState(() => _loading = false);
      if (!widget.editar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro enviado! Aguarde a validação do professor.'),
            backgroundColor: verdeEscuro,
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro atualizado.'), backgroundColor: verdeEscuro),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoria = _nascCtrl.text.isEmpty ? null : getCategoriaEtaria(_nascCtrl.text);
    final podeVoltar = widget.editar;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editar ? 'Meu Cadastro' : 'Complete seu Cadastro'),
        automaticallyImplyLeading: podeVoltar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.editar)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Text(
                  'Bem-vindo ao SM BJJ! Preencha seus dados para o professor validar e definir sua turma.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            if (categoria != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Categoria: $categoria', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            _campo(_nomeCtrl, 'Nome Completo *'),
            _campo(_emailCtrl, 'Email', type: TextInputType.emailAddress, readOnly: true),
            Row(children: [
              Expanded(child: _campo(_nascCtrl, 'Nascimento *', hint: 'AAAA-MM-DD', onChanged: (_) => setState(() {}))),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sexo,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                  ],
                  onChanged: (v) => setState(() => _sexo = v!),
                ),
              ),
            ]),
            _campo(_telefoneCtrl, 'Telefone *', type: TextInputType.phone),
            _campo(_pesoCtrl, 'Peso (kg)', type: TextInputType.number),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text('Responsável (obrigatório se menor de 18)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            _campo(_respNomeCtrl, 'Nome do Responsável'),
            _campo(_respTelCtrl, 'Telefone do Responsável', type: TextInputType.phone),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text('Endereço', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            _campo(_enderecoCtrl, 'Rua, Número, Bairro'),
            Row(children: [
              Expanded(flex: 3, child: _campo(_cidadeCtrl, 'Cidade *')),
              const SizedBox(width: 10),
              Expanded(child: _campo(_estadoCtrl, 'UF', maxLength: 2)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _campo(_cepCtrl, 'CEP')),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _salvar,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(widget.editar ? 'Salvar alterações' : 'Enviar cadastro'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController ctrl,
    String label, {
    TextInputType? type,
    String? hint,
    int? maxLength,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: ctrl,
          readOnly: readOnly,
          decoration: InputDecoration(labelText: label, hintText: hint),
          keyboardType: type,
          maxLength: maxLength,
          onChanged: onChanged,
        ),
      );
}
