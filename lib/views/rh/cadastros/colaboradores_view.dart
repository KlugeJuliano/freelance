import 'package:flutter/material.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pessoa_funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:provider/provider.dart';

class CadastroColaboradores extends StatefulWidget {
  const CadastroColaboradores({super.key});

  @override
  State<CadastroColaboradores> createState() => _CadastroColaboradoresState();
}

class _CadastroColaboradoresState extends State<CadastroColaboradores> {
  final _nomeController = TextEditingController();
  final Set<String> _funcoesSelecionadas = {};

  @override
  Widget build(BuildContext context) {
    final pesssoaProvider = context.watch<PessoaProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();
    final pessoaFuncaoProvider = context.read<PessoaFuncaoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Colaboradores'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),

              const SizedBox(height: 20),

              const Text(
                'Funções',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...funcaoProvider.funcoes.map((funcao) {
                return CheckboxListTile(
                  title: Text(funcao.nomeFuncao),
                  value: _funcoesSelecionadas.contains(funcao.funcaoId),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _funcoesSelecionadas.add(funcao.funcaoId);
                      } else {
                        _funcoesSelecionadas.remove(funcao.funcaoId);
                      }
                    });
                  },
                );
              }),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  final nome = _nomeController.text;

                  if (nome.isEmpty) return;

                  final pessoaId = DateTime.now().toString();

                  pesssoaProvider.adicionarPessoa(
                    PessoaModel(pessoaId: pessoaId, nome: nome),
                  );

                  for (final funcaoId in _funcoesSelecionadas) {
                    pessoaFuncaoProvider.vincularPessoaFuncao(
                      pessoaId,
                      funcaoId,
                    );
                  }

                  _nomeController.clear();

                  setState(() {
                    _funcoesSelecionadas.clear();
                  });
                },
                child: const Text('Salvar'),
              ),

              const SizedBox(height: 30),

              const Text(
                'Pessoas cadastradas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: pesssoaProvider.pessoas.length,
                  itemBuilder: (context, index) {
                    final pessoa = pesssoaProvider.pessoas[index];

                    final funcoesIds = pessoaFuncaoProvider
                        .buscarFuncoesPorPessoa(pessoa.pessoaId);

                    final nomesFuncoes = funcaoProvider.funcoes
                        .where((f) => funcoesIds.contains(f.funcaoId))
                        .map((f) => f.nomeFuncao)
                        .join(', ');

                    return ListTile(
                      title: Text(pessoa.nome),
                      subtitle: Text(nomesFuncoes),
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
