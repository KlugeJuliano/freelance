import 'package:flutter/material.dart';
import 'package:freelance/models/funcao_model.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:provider/provider.dart';

class CadastroFuncoes extends StatefulWidget {
  const CadastroFuncoes({super.key});

  @override
  State<CadastroFuncoes> createState() => _CadastroFuncoesState();
}

class _CadastroFuncoesState extends State<CadastroFuncoes> {
  final _nomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final funcaoProvider = context.watch<FuncaoProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Funções'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome da função'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  final nome = _nomeController.text;

                  if (nome.isEmpty) return;

                  funcaoProvider.addFuncao(
                    FuncaoModel(
                      funcaoId: DateTime.now().toString(),
                      nomeFuncao: nome,
                    ),
                  );

                  _nomeController.clear();
                },
                child: const Text('Salvar'),
              ),

              const SizedBox(height: 30),

              const Text(
                'Funções cadastradas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: funcaoProvider.funcoes.length,
                  itemBuilder: (context, index) {
                    final funcao = funcaoProvider.funcoes[index];

                    return ListTile(
                      title: Text(funcao.nomeFuncao),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          funcaoProvider.removeFuncao(funcao.funcaoId);
                        },
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
