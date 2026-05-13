import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/escalacao_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EscalacaoView extends StatefulWidget {
  final PedidoModel pedido;
  const EscalacaoView({super.key, required this.pedido});

  @override
  State<EscalacaoView> createState() => _EscalacaoViewState();
}

class _EscalacaoViewState extends State<EscalacaoView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EscalacaoProvider>().carregarEscalados(widget.pedido.id);
      context.read<PessoaProvider>().fetchPessoas();
      context.read<FuncaoProvider>().fetchFuncoes();
    });
  }

  void _abrirDialogEscalar(BuildContext context) {
    final escalacaoProvider = context.read<EscalacaoProvider>();
    final pessoaProvider = context.read<PessoaProvider>();
    final funcaoProvider = context.read<FuncaoProvider>();

    final nomeFuncao =
        funcaoProvider.buscarPorId(widget.pedido.funcaoId)?.nomeFuncao ??
        widget.pedido.funcaoId;

    // IDs já escalados para evitar duplicatas
    final escaladosIds = escalacaoProvider.escalados
        .map((e) => e.pessoaId)
        .toSet();

    final compativeis = pessoaProvider.pessoas
        .where(
          (p) =>
              p.funcaoIds.contains(widget.pedido.funcaoId) &&
              !escaladosIds.contains(p.pessoaId),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
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
                const Icon(
                  Icons.person_off,
                  color: AppColors.textMuted,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum freelancer disponível\npara "$nomeFuncao"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
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
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  AccentBadge(nomeFuncao),
                  const SizedBox(width: 10),
                  Text(
                    '${compativeis.length} disponíveis',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: compativeis.length,
                itemBuilder: (_, index) {
                  final p = compativeis[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accentDim,
                        child: Text(
                          p.nome[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        p.nome,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: p.cpf != null
                          ? Text(
                              p.cpf!,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        escalacaoProvider.escalarFreelancer(
                          widget.pedido.id,
                          p.pessoaId,
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
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Finalizar escalação',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Escalados: ${escalacaoProvider.escalados.length}/${widget.pedido.quantidade}\nDeseja confirmar?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                escalacaoProvider.carregarEscalados(widget.pedido.id),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Header com info do pedido
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentBadge(nomeFuncao),
                    const Spacer(),
                    StatusBadge(widget.pedido.status),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatarData(widget.pedido.dataInicio)}  →  ${_formatarData(widget.pedido.dataFim)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vagas preenchidas',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$escalados / $vagas',
                      style: TextStyle(
                        color: escalados >= vagas
                            ? AppColors.accent
                            : AppColors.textPrimary,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      escalacaoProvider.erro!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Label
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ESCALADOS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),

          // Lista de escalados
          Expanded(
            child: escalacaoProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : escalacaoProvider.escalados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 56,
                          color: AppColors.textMuted.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum freelancer escalado',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Toque em Escalar para adicionar',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
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
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.accentDim,
                            child: Text(
                              escalado.nome[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            escalado.nome,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: StatusBadge(escalado.status),
                          trailing: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: AppColors.danger,
                                size: 18,
                              ),
                            ),
                            onPressed: () => escalacaoProvider.removerEscalado(
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
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
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
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Finalizar Escalação',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () => _finalizar(context),
              ),
            ),
    );
  }
}
