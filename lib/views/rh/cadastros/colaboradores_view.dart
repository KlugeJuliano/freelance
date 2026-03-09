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
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _pixController = TextEditingController();
  final Set<String> _funcoesSelecionadas = {};

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

  @override
  Widget build(BuildContext context) {
    final pessoaProvider = context.watch<PessoaProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Colaboradores'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pixController,
                  decoration: const InputDecoration(
                    labelText: 'Chave Pix',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Funções',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ...funcaoProvider.funcoes.map((funcao) {
                  return CheckboxListTile(
                    dense: true,
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

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                                telefone: _telefoneController.text.trim(),
                                email: _emailController.text.trim(),
                                chavePix: _pixController.text.trim(),
                                funcaoIds: _funcoesSelecionadas.toList(),
                              ),
                            );

                            _nomeController.clear();
                            _cpfController.clear();
                            _telefoneController.clear();
                            _emailController.clear();
                            _pixController.clear();
                            setState(() => _funcoesSelecionadas.clear());
                          },
                    child: pessoaProvider.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar'),
                  ),
                ),

                if (pessoaProvider.erro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      pessoaProvider.erro!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 24),

                const Text(
                  'Colaboradores cadastrados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (pessoaProvider.loading && pessoaProvider.pessoas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (pessoaProvider.pessoas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Nenhum colaborador cadastrado')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true, // <-- lista ocupa só o espaço necessário
                    physics:
                        const NeverScrollableScrollPhysics(), // <-- scroll quem controla é o SingleChildScrollView pai
                    itemCount: pessoaProvider.pessoas.length,
                    itemBuilder: (context, index) {
                      // ... mesmo código de antes
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
