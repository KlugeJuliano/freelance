import 'package:flutter/material.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:provider/provider.dart';

class CadastroFuncoes extends StatefulWidget {
  const CadastroFuncoes({super.key});

  @override
  State<CadastroFuncoes> createState() => _CadastroFuncoesState();
}

class _CadastroFuncoesState extends State<CadastroFuncoes> {
  final _nomeController = TextEditingController();
  final _valorHoraController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final funcaoProvider = context.watch<FuncaoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Funções'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da função',
                  border: OutlineInputBorder(),
                ),
              ),

              TextField(
                controller: _valorHoraController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor por hora (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: funcaoProvider.loading
                      ? null
                      : () async {
                          final nome = _nomeController.text.trim();
                          final valor =
                              double.tryParse(
                                _valorHoraController.text.replaceAll(',', '.'),
                              ) ??
                              0.0;
                          if (nome.isEmpty) return;
                          await funcaoProvider.addFuncao(nome, valor);
                          _nomeController.clear();
                          _valorHoraController.clear();
                        },
                  child: funcaoProvider.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar'),
                ),
              ),

              if (funcaoProvider.erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    funcaoProvider.erro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 30),

              const Text(
                'Funções cadastradas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: funcaoProvider.loading && funcaoProvider.funcoes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : funcaoProvider.funcoes.isEmpty
                    ? const Center(child: Text('Nenhuma função cadastrada'))
                    : ListView.builder(
                        itemCount: funcaoProvider.funcoes.length,
                        itemBuilder: (context, index) {
                          final funcao = funcaoProvider.funcoes[index];
                          return ListTile(
                            title: Text(funcao.nomeFuncao),
                            subtitle: funcao.valorHora != null
                                ? Text(
                                    'R\$ ${funcao.valorHora!.toStringAsFixed(2)}/h',
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  funcaoProvider.removeFuncao(funcao.funcaoId),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
