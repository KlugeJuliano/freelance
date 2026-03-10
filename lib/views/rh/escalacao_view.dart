import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/escalacao_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EscalacaoView extends StatefulWidget {
  final PedidoModel pedido;
  const EscalacaoView({super.key, required this.pedido});

  @override
  State<EscalacaoView> createState() => _EscalacaoViewState();
}

class _EscalacaoViewState extends State<EscalacaoView> {
  static const _dark = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1D27);
  static const _accent = Color(0xFF00E5A0);
  static const _accentDim = Color(0x2200E5A0);
  static const _danger = Color(0xFFFF4D6A);
  static const _textPrimary = Color(0xFFEEEEF5);
  static const _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EscalacaoProvider>().carregarEscalados(widget.pedido.id);
      context.read<PessoaProvider>().carregarFreelancers();
      context.read<FuncaoProvider>().carregarFuncoes();
    });
  }

  void _abrirDialogEscalar(BuildContext context) {
    final escalacaoProvider = context.read<EscalacaoProvider>();
    final pessoaProvider = context.read<PessoaProvider>();
    final funcaoProvider = context.read<FuncaoProvider>();

    final nomeFuncao = // <-- adicionar
        funcaoProvider.buscarPorId(widget.pedido.funcaoId)?.nomeFuncao ??
        widget.pedido.funcaoId;

    // DEBUG
    print('=== funcaoId do pedido: ${widget.pedido.funcaoId}');
    for (final p in pessoaProvider.pessoas) {
      print('Freelancer: ${p.nome} | funcaoIds: ${p.funcaoIds}');
    }

    print('=== funcoes cadastradas:');
    for (final f in funcaoProvider.funcoes) {
      print('  ${f.funcaoId} | ${f.nomeFuncao}');
    }

    final escaladosIds = escalacaoProvider.escalados
        .map((e) => e.pessoaId)
        .toSet();
    final compativeis = pessoaProvider.pessoas
        .where(
          (f) =>
              f.funcaoIds.contains(widget.pedido.funcaoId) &&
              !escaladosIds.contains(f.pessoaId),
        )
        .toList();

    print('Compatíveis encontrados: ${compativeis.length}');

    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        if (compativeis.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off, color: _textMuted, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Nenhum freelancer disponível\npara "$nomeFuncao"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textMuted, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _accentDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      nomeFuncao,
                      style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${compativeis.length} disponíveis',
                    style: const TextStyle(color: _textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: compativeis.length,
                itemBuilder: (_, index) {
                  final f = compativeis[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: _dark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _accentDim,
                        child: Text(
                          f.nome[0].toUpperCase(),
                          style: const TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        f.nome,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        f.cpf ?? '',
                        style: const TextStyle(color: _textMuted, fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _accentDim,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: _accent, size: 20),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        escalacaoProvider.escalarFreelancer(
                          widget.pedido.id,
                          f.pessoaId,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalizar(BuildContext context) async {
    final escalacaoProvider = context.read<EscalacaoProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Finalizar escalação',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Escalados: ${escalacaoProvider.escalados.length}/${widget.pedido.quantidade}\nDeseja confirmar?',
          style: const TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _dark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    final sucesso = await escalacaoProvider.finalizar(widget.pedido.id);
    if (sucesso && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final escalacaoProvider = context.watch<EscalacaoProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    final nomeFuncao =
        funcaoProvider.buscarPorId(widget.pedido.funcaoId)?.nomeFuncao ??
        widget.pedido.funcaoId;

    final vagas = widget.pedido.quantidade;
    final escalados = escalacaoProvider.escalados.length;
    final progresso = vagas > 0 ? escalados / vagas : 0.0;

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: _dark,
        appBar: AppBar(
          backgroundColor: _dark,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Escalação',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: _textMuted),
              onPressed: () =>
                  escalacaoProvider.carregarEscalados(widget.pedido.id),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: _textMuted),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!mounted) return;
                context.go('/login');
              },
            ),
          ],
        ),

        body: Column(
          children: [
            // Header card com info do pedido
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accentDim,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          nomeFuncao,
                          style: const TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.pedido.status,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatarData(widget.pedido.dataInicio)}  →  ${_formatarData(widget.pedido.dataFim)}',
                        style: const TextStyle(color: _textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de progresso de vagas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vagas preenchidas',
                        style: TextStyle(color: _textMuted, fontSize: 12),
                      ),
                      Text(
                        '$escalados / $vagas',
                        style: TextStyle(
                          color: escalados >= vagas ? _accent : _textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progresso.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        escalados >= vagas ? _accent : _accent.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Erro
            if (escalacaoProvider.erro != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: _danger, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        escalacaoProvider.erro!,
                        style: const TextStyle(color: _danger, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Título da lista
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'ESCALADOS',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: escalacaoProvider.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : escalacaoProvider.escalados.isEmpty
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
                            'Nenhum freelancer escalado',
                            style: TextStyle(color: _textMuted, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Toque em Escalar para adicionar',
                            style: TextStyle(color: _textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: escalacaoProvider.escalados.length,
                      itemBuilder: (context, index) {
                        final escalado = escalacaoProvider.escalados[index];
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
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _accentDim,
                              child: Text(
                                escalado.nome[0].toUpperCase(),
                                style: const TextStyle(
                                  color: _accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              escalado.nome,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: escalado.status != null
                                ? Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accentDim,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      escalado.status!,
                                      style: const TextStyle(
                                        color: _accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
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
                                  Icons.remove,
                                  color: _danger,
                                  size: 18,
                                ),
                              ),
                              onPressed: () =>
                                  escalacaoProvider.removerEscalado(
                                    widget.pedido.id,
                                    escalado.pessoaId,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),

        floatingActionButton: escalados >= vagas
            ? null
            : FloatingActionButton.extended(
                backgroundColor: _accent,
                foregroundColor: _dark,
                onPressed: () => _abrirDialogEscalar(context),
                icon: const Icon(Icons.person_add),
                label: Text(
                  'Escalar ($escalados/$vagas)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

        bottomNavigationBar: escalacaoProvider.escalados.isEmpty
            ? null
            : Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: _dark,
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: _dark,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Finalizar Escalação',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () => _finalizar(context),
                ),
              ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }
}
