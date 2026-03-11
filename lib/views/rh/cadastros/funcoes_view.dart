import 'package:flutter/material.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CadastroFuncoes extends StatefulWidget {
  const CadastroFuncoes({super.key});

  @override
  State<CadastroFuncoes> createState() => _CadastroFuncoesState();
}

class _CadastroFuncoesState extends State<CadastroFuncoes> {
  final _nomeController = TextEditingController();
  final _valorHoraController = TextEditingController();

  bool _formAberto = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FuncaoProvider>().fetchFuncoes());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorHoraController.dispose();
    super.dispose();
  }

  Future<void> _salvar(FuncaoProvider provider) async {
    final nome = _nomeController.text.trim();

    final valor =
        double.tryParse(
          _valorHoraController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;

    if (nome.isEmpty || valor <= 0) return;

    /// ajuste conforme seu provider
    await provider.addFuncao(nome, valor);

    if (provider.erro == null) {
      _nomeController.clear();
      _valorHoraController.clear();

      setState(() {
        _formAberto = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FuncaoProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        onPressed: () {
          setState(() {
            _formAberto = !_formAberto;
          });
        },
        child: Icon(_formAberto ? Icons.close : Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Funções',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          /// FORMULÁRIO
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _formAberto
                ? Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NOVA FUNÇÃO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),

                          /// NOME
                          TextField(
                            controller: _nomeController,
                            decoration: const InputDecoration(
                              labelText: 'Nome da função',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// VALOR
                          TextField(
                            controller: _valorHoraController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Valor por hora',
                              prefixText: 'R\$ ',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (provider.erro != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.danger,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      provider.erro!,
                                      style: const TextStyle(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: provider.loading
                                  ? null
                                  : () => _salvar(provider),
                              child: provider.loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.background,
                                      ),
                                    )
                                  : const Text('Salvar'),
                            ),
                          ),
                        ],
                      ),
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
                  'FUNÇÕES CADASTRADAS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Text(
                  '${provider.funcoes.length}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          /// LISTA
          Expanded(
            child: provider.loading && provider.funcoes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.funcoes.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: provider.funcoes.length,
                    itemBuilder: (context, index) {
                      final funcao = provider.funcoes[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentDim,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            funcao.nomeFuncao,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: funcao.valorHora != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'R\$ ${funcao.valorHora!.toStringAsFixed(2)}/h',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                            ),
                            onPressed: () {
                              provider.removeFuncao(funcao.funcaoId);
                            },
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

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 56, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Nenhuma função cadastrada',
            style: TextStyle(color: AppColors.textMuted),
          ),
          SizedBox(height: 6),
          Text(
            'Toque em + para adicionar',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
