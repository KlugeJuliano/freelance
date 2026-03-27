import 'package:flutter/material.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CadastroColaboradores extends StatefulWidget {
  const CadastroColaboradores({super.key});

  @override
  State<CadastroColaboradores> createState() => _CadastroColaboradoresState();
}

class _CadastroColaboradoresState extends State<CadastroColaboradores> {
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
      context.read<PessoaProvider>().fetchPessoas();
      context.read<FuncaoProvider>().fetchFuncoes();
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

  void _limparForm() {
    _nomeController.clear();
    _cpfController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _pixController.clear();
    setState(() => _funcoesSelecionadas.clear());
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      filled: true,
      fillColor: AppColors.background,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
    );
  }

  Future<void> _salvar(PessoaProvider provider) async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    final novoColaborador = PessoaModel(
      pessoaId: '', // Gerado pelo Supabase
      nome: nome,
      cpf: _cpfController.text.trim(),
      telefone: _telefoneController.text.trim(),
      email: _emailController.text.trim(),
      chavePix: _pixController.text.trim(),
      funcaoIds: _funcoesSelecionadas.toList(),
      id: '',
      empresaId: '',
    );

    await provider.adicionarPessoa(novoColaborador);

    if (provider.erro == null) {
      _limparForm();
      setState(() => _formAberto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pessoaProvider = context.watch<PessoaProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Colaboradores',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        onPressed: () => setState(() => _formAberto = !_formAberto),
        child: Icon(_formAberto ? Icons.close : Icons.person_add),
      ),
      body: Column(
        children: [
          /// FORMULÁRIO EXPANSÍVEL
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _formAberto
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOVO COLABORADOR',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nomeController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            'Nome completo',
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cpfController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  'CPF',
                                  Icons.badge_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _telefoneController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(
                                  'Telefone',
                                  Icons.phone_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            'E-mail',
                            Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pixController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            'Chave Pix',
                            Icons.qr_code,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// SELEÇÃO DE FUNÇÕES (CHIPS)
                        const Text(
                          'FUNÇÕES',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: funcaoProvider.funcoes.map((funcao) {
                            final selecionada = _funcoesSelecionadas.contains(
                              funcao.funcaoId,
                            );
                            return FilterChip(
                              label: Text(funcao.nomeFuncao),
                              selected: selecionada,
                              onSelected: (val) {
                                setState(() {
                                  val
                                      ? _funcoesSelecionadas.add(
                                          funcao.funcaoId,
                                        )
                                      : _funcoesSelecionadas.remove(
                                          funcao.funcaoId,
                                        );
                                });
                              },
                              backgroundColor: AppColors.background,
                              selectedColor: AppColors.accentDim,
                              checkmarkColor: AppColors.accent,
                              labelStyle: TextStyle(
                                color: selecionada
                                    ? AppColors.accent
                                    : AppColors.textMuted,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide(
                                color: selecionada
                                    ? AppColors.accent
                                    : Colors.white.withOpacity(0.1),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        /// BOTÃO SALVAR
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: pessoaProvider.loading
                                ? null
                                : () => _salvar(pessoaProvider),
                            child: pessoaProvider.loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : const Text(
                                    'SALVAR COLABORADOR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          /// HEADER LISTA
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Text(
                  'COLABORADORES CADASTRADOS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.accentDim,
                  child: Text(
                    '${pessoaProvider.pessoas.length}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// LISTA DE COLABORADORES
          Expanded(
            child: pessoaProvider.loading && pessoaProvider.pessoas.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: pessoaProvider.pessoas.length,
                    itemBuilder: (context, index) {
                      final pessoa = pessoaProvider.pessoas[index];
                      // Pega os nomes das funções filtrando pelo ID
                      final funcoesPessoa = funcaoProvider.funcoes
                          .where((f) => pessoa.funcaoIds.contains(f.funcaoId))
                          .map((f) => f.nomeFuncao)
                          .join(' • ');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.accentDim,
                            child: Text(
                              pessoa.nome[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            pessoa.nome,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (funcoesPessoa.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    funcoesPessoa,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (pessoa.email != null)
                                Text(
                                  pessoa.email!,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
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
    );
  }
}
