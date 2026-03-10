import 'package:flutter/material.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:provider/provider.dart';

class CadastroFuncoes extends StatefulWidget {
  const CadastroFuncoes({super.key});

  @override
  State<CadastroFuncoes> createState() => _CadastroFuncoesState();
}

class _CadastroFuncoesState extends State<CadastroFuncoes> {
  static const _dark = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1D27);
  static const _accent = Color(0xFF00E5A0);
  static const _accentDim = Color(0x2200E5A0);
  static const _danger = Color(0xFFFF4D6A);
  static const _textPrimary = Color(0xFFEEEEF5);
  static const _textMuted = Color(0xFF6B7280);

  final _nomeController = TextEditingController();
  final _valorHoraController = TextEditingController();
  bool _formAberto = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FuncaoProvider>().carregarFuncoes());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorHoraController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
            'Funções',
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
          child: Icon(_formAberto ? Icons.close : Icons.add),
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
                            'NOVA FUNÇÃO',
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
                              'Nome da função',
                              Icons.work_outline,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _valorHoraController,
                            style: const TextStyle(color: _textPrimary),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              'Valor por hora (R\$)',
                              Icons.attach_money,
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (funcaoProvider.erro != null)
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
                                      funcaoProvider.erro!,
                                      style: const TextStyle(
                                        color: _danger,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _dark,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: funcaoProvider.loading
                                ? null
                                : () async {
                                    final nome = _nomeController.text.trim();
                                    final valor =
                                        double.tryParse(
                                          _valorHoraController.text
                                              .trim()
                                              .replaceAll(',', '.'),
                                        ) ??
                                        0.0;
                                    if (nome.isEmpty || valor <= 0) return;
                                    await funcaoProvider.addFuncao(nome, valor);
                                    if (funcaoProvider.erro == null) {
                                      _nomeController.clear();
                                      _valorHoraController.clear();
                                      setState(() => _formAberto = false);
                                    }
                                  },
                            child: funcaoProvider.loading
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
                    'FUNÇÕES CADASTRADAS',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${funcaoProvider.funcoes.length}',
                    style: const TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: funcaoProvider.loading && funcaoProvider.funcoes.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : funcaoProvider.funcoes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 56,
                            color: _textMuted.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma função cadastrada',
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
                      itemCount: funcaoProvider.funcoes.length,
                      itemBuilder: (context, index) {
                        final funcao = funcaoProvider.funcoes[index];
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
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _accentDim,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.work_outline,
                                color: _accent,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              funcao.nomeFuncao,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: funcao.valorHora != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'R\$ ${funcao.valorHora!.toStringAsFixed(2)}/h',
                                      style: const TextStyle(
                                        color: _accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : null,
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
                                  funcaoProvider.removeFuncao(funcao.funcaoId),
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
