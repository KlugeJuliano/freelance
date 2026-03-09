import 'package:flutter/material.dart';
import 'package:freelance/models/freelancer_escalado_model.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/services/escalacao_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EscalacaoView extends StatefulWidget {
  final PedidoModel pedido; // <-- recebe o pedido inteiro, não só o id
  const EscalacaoView({super.key, required this.pedido});

  @override
  State<EscalacaoView> createState() => _EscalacaoViewState();
}

class _EscalacaoViewState extends State<EscalacaoView> {
  List<FreelancerEscaladoModel> _escalados = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PessoaProvider>().carregarFreelancers();
      context.read<FuncaoProvider>().carregarFuncoes();
    });
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final escalados = await EscalacaoService.buscarEscalados(
        widget.pedido.id,
      );
      setState(() {
        _escalados = escalados;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar escalação: $e';
        _loading = false;
      });
    }
  }

  Future<void> _escalarFreelancer(String freelancerId) async {
    try {
      await EscalacaoService.escalarFreelancer(widget.pedido.id, freelancerId);
      await _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao escalar: $e')));
    }
  }

  Future<void> _removerEscalado(String freelancerId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover freelancer'),
        content: const Text('Deseja remover da escalação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await EscalacaoService.removerEscalado(widget.pedido.id, freelancerId);
      await _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
    }
  }

  Future<void> _finalizar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finalizar escalação'),
        content: Text(
          'Escalados: ${_escalados.length}/${widget.pedido.quantidade}\n'
          'Deseja finalizar esta escalação?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await EscalacaoService.finalizar(widget.pedido.id);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao finalizar: $e')));
    }
  }

  void _abrirDialogEscalar(List<PessoaModel> freelancers, String nomeFuncao) {
    final escaladosIds = _escalados.map((e) => e.freelancerId).toSet();

    // Filtra apenas quem tem a função compatível e ainda não foi escalado
    final compativeis = freelancers
        .where(
          (f) =>
              f.funcaoIds.contains(widget.pedido.funcaoId) &&
              !escaladosIds.contains(f.pessoaId),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (compativeis.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Nenhum freelancer disponível para a função "$nomeFuncao"',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Freelancers — $nomeFuncao',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: compativeis.length,
                itemBuilder: (context, index) {
                  final f = compativeis[index];
                  return ListTile(
                    title: Text(f.nome),
                    subtitle: Text(f.cpf ?? ''),
                    trailing: const Icon(Icons.add_circle, color: Colors.green),
                    onTap: () {
                      Navigator.pop(context);
                      Future.microtask(() => _escalarFreelancer(f.pessoaId));
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pessoaProvider = context.watch<PessoaProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    final nomeFuncao =
        funcaoProvider.buscarPorId(widget.pedido.funcaoId)?.nomeFuncao ??
        widget.pedido.funcaoId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalação'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _escalados.length >= widget.pedido.quantidade
            ? null // desabilita se já atingiu a quantidade
            : () => _abrirDialogEscalar(pessoaProvider.pessoas, nomeFuncao),
        icon: const Icon(Icons.person_add),
        label: Text(
          'Escalar (${_escalados.length}/${widget.pedido.quantidade})',
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Finalizar Escalação'),
          onPressed: _escalados.isEmpty ? null : _finalizar,
        ),
      ),

      body: Column(
        children: [
          // Cabeçalho com info do pedido
          Container(
            width: double.infinity,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Função: $nomeFuncao',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Período: ${_formatarData(widget.pedido.dataInicio)} → ${_formatarData(widget.pedido.dataFim)}',
                ),
                Text('Vagas: ${_escalados.length}/${widget.pedido.quantidade}'),
              ],
            ),
          ),

          // Lista de escalados
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_erro!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _carregarDados,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : _escalados.isEmpty
                ? const Center(child: Text('Nenhum freelancer escalado ainda'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _escalados.length,
                    itemBuilder: (context, index) {
                      final escalado = _escalados[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(escalado.nome),
                          subtitle: Text(escalado.status),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _removerEscalado(escalado.freelancerId),
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

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }
}
