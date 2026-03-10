import 'package:flutter/material.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:provider/provider.dart';

class CadastroColaboradores extends StatefulWidget {
  const CadastroColaboradores({super.key});

  @override
  State<CadastroColaboradores> createState() => _CadastroColaboradoresState();
}

class _CadastroColaboradoresState extends State<CadastroColaboradores> {
  static const _dark = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1D27);
  static const _accent = Color(0xFF00E5A0);
  static const _accentDim = Color(0x2200E5A0);
  static const _danger = Color(0xFFFF4D6A);
  static const _textPrimary = Color(0xFFEEEEF5);
  static const _textMuted = Color(0xFF6B7280);

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _pixController = TextEditingController();
  final Set<String> _funcoesSelecionadas = {};
  bool _formAberto = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PessoaProvider>().carregarFreelancers();
      context.read<FuncaoProvider>().carregarFuncoes();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _pixController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      filled: true,
      fillColor: _dark,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accent),
      ),
    );
  }

  void _limparForm() {
    _nomeController.clear();
    _cpfController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _pixController.clear();
    setState(() => _funcoesSelecionadas.clear());
  }

  @override
  Widget build(BuildContext context) {
    final pessoaProvider = context.watch<PessoaProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: _dark,
        appBar: AppBar(
          backgroundColor: _dark,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Colaboradores',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: _accent,
          foregroundColor: _dark,
          onPressed: () => setState(() => _formAberto = !_formAberto),
          child: Icon(_formAberto ? Icons.close : Icons.person_add),
        ),

        body: Column(
          children: [
            // Formulário expansível
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _formAberto
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NOVO COLABORADOR',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nomeController,
                            style: const TextStyle(color: _textPrimary),
                            decoration: _inputDecoration(
                              'Nome completo',
                              Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cpfController,
                            style: const TextStyle(color: _textPrimary),
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'CPF',
                              Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _telefoneController,
                            style: const TextStyle(color: _textPrimary),
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              'Telefone',
                              Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: _textPrimary),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'E-mail',
                              Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _pixController,
                            style: const TextStyle(color: _textPrimary),
                            decoration: _inputDecoration(
                              'Chave Pix',
                              Icons.qr_code,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Funções
                          const Text(
                            'FUNÇÕES',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          funcaoProvider.funcoes.isEmpty
                              ? const Text(
                                  'Nenhuma função cadastrada',
                                  style: TextStyle(
                                    color: _textMuted,
                                    fontSize: 13,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: funcaoProvider.funcoes.map((
                                    funcao,
                                  ) {
                                    final selecionada = _funcoesSelecionadas
                                        .contains(funcao.funcaoId);
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        if (selecionada) {
                                          _funcoesSelecionadas.remove(
                                            funcao.funcaoId,
                                          );
                                        } else {
                                          _funcoesSelecionadas.add(
                                            funcao.funcaoId,
                                          );
                                        }
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selecionada
                                              ? _accentDim
                                              : _dark,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: selecionada
                                                ? _accent
                                                : Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Text(
                                          funcao.nomeFuncao,
                                          style: TextStyle(
                                            color: selecionada
                                                ? _accent
                                                : _textMuted,
                                            fontWeight: selecionada
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                          const SizedBox(height: 20),

                          // Erro
                          if (pessoaProvider.erro != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _danger.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: _danger,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pessoaProvider.erro!,
                                      style: const TextStyle(
                                        color: _danger,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: _dark,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: pessoaProvider.loading
                                  ? null
                                  : () async {
                                      final nome = _nomeController.text.trim();
                                      if (nome.isEmpty) return;
                                      await pessoaProvider.adicionarPessoa(
                                        PessoaModel(
                                          pessoaId: '',
                                          nome: nome,
                                          cpf: _cpfController.text.trim(),
                                          telefone: _telefoneController.text
                                              .trim(),
                                          email: _emailController.text.trim(),
                                          chavePix: _pixController.text.trim(),
                                          funcaoIds: _funcoesSelecionadas
                                              .toList(),
                                        ),
                                      );
                                      if (pessoaProvider.erro == null) {
                                        _limparForm();
                                        setState(() => _formAberto = false);
                                      }
                                    },
                              child: pessoaProvider.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: _dark,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Salvar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Label da lista
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'COLABORADORES',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${pessoaProvider.pessoas.length}',
                    style: const TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: pessoaProvider.loading && pessoaProvider.pessoas.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : pessoaProvider.pessoas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 56,
                            color: _textMuted.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum colaborador cadastrado',
                            style: TextStyle(color: _textMuted),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Toque em + para adicionar',
                            style: TextStyle(color: _textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: pessoaProvider.pessoas.length,
                      itemBuilder: (context, index) {
                        final pessoa = pessoaProvider.pessoas[index];
                        final nomesFuncoes = funcaoProvider.funcoes
                            .where((f) => pessoa.funcaoIds.contains(f.funcaoId))
                            .map((f) => f.nomeFuncao)
                            .toList();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _accentDim,
                              child: Text(
                                pessoa.nome[0].toUpperCase(),
                                style: const TextStyle(
                                  color: _accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              pessoa.nome,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (pessoa.cpf != null &&
                                    pessoa.cpf!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      pessoa.cpf!,
                                      style: const TextStyle(
                                        color: _textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (nomesFuncoes.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Wrap(
                                      spacing: 6,
                                      children: nomesFuncoes.map((nome) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _accentDim,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            nome,
                                            style: const TextStyle(
                                              color: _accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: _danger,
                                  size: 18,
                                ),
                              ),
                              onPressed: () =>
                                  pessoaProvider.removerPessoa(pessoa.pessoaId),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
