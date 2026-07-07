import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/escalacao_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/loja_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/services/status_service.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JornadaView extends StatefulWidget {
  final String pedidoId;
  const JornadaView({super.key, required this.pedidoId});

  @override
  State<JornadaView> createState() => _JornadaViewState();
}

class _JornadaViewState extends State<JornadaView> {
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _statusService = StatusService();
  PedidoModel? _pedido;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _carregar());
  }

  Future<void> _carregar() async {
    final pedidoProvider = context.read<PedidoProvider>();
    final escalacaoProvider = context.read<EscalacaoProvider>();
    final funcaoProvider = context.read<FuncaoProvider>();
    final lojaProvider = context.read<LojaProvider>();

    await Future.wait([
      pedidoProvider.fetchPedidos(),
      funcaoProvider.fetchFuncoes(),
      lojaProvider.fetchLojas(),
    ]);

    final pedido = pedidoProvider.pedidos
        .where((p) => p.id == widget.pedidoId)
        .firstOrNull;

    if (pedido != null) {
      setState(() => _pedido = pedido);
      await escalacaoProvider.carregarEscalados(pedido.id);
    }
  }

  Future<void> _executarAcao(
    BuildContext context,
    String titulo,
    String mensagem,
    Future<PedidoModel> Function(PedidoModel) acao,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titulo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          mensagem,
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

    if (confirmar != true || _pedido == null) return;

    try {
      final pedidoAtualizado = await acao(_pedido!);
      setState(() => _pedido = pedidoAtualizado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$titulo realizado com sucesso'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  List<_AcaoConfig> _acoesDisponiveis() {
    if (_pedido == null) return [];
    final status = _pedido!.status;

    return [
      if (status == 'solicitado')
        _AcaoConfig(
          label: 'Cancelar Pedido',
          icon: Icons.cancel_outlined,
          danger: true,
          onTap: () => _executarAcao(
            context,
            'Cancelar Pedido',
            'Deseja cancelar este pedido?',
            (p) => _statusService.cancelarPedido(p),
          ),
        ),
      if (status == 'escalado')
        _AcaoConfig(
          label: 'Aprovar Escalação',
          icon: Icons.check_circle_outline,
          onTap: () => _executarAcao(
            context,
            'Aprovar Escalação',
            'Deseja aprovar a escalação do RH?',
            (p) => _statusService.aprovarPedido(p),
          ),
        ),
      if (status == 'escalado')
        _AcaoConfig(
          label: 'Recusar Escalação',
          icon: Icons.thumb_down_outlined,
          danger: true,
          onTap: () => _executarAcao(
            context,
            'Recusar Escalação',
            'Deseja recusar a escalação e devolver ao RH?',
            (p) => _statusService.recusarPedido(p),
          ),
        ),
      if (status == 'aprovado')
        _AcaoConfig(
          label: 'Confirmar Início',
          icon: Icons.play_circle_outline,
          onTap: () => _executarAcao(
            context,
            'Confirmar Início da Jornada',
            'Confirmar que a jornada foi iniciada?',
            (p) => _statusService.iniciarJornada(p),
          ),
        ),
      if (status == 'em_andamento')
        _AcaoConfig(
          label: 'Finalizar Jornada',
          icon: Icons.stop_circle_outlined,
          onTap: () => _executarAcao(
            context,
            'Finalizar Jornada',
            'Confirmar que a jornada foi concluída?',
            (p) => _statusService.finalizarPedido(p),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final escalacaoProvider = context.watch<EscalacaoProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();
    final lojaProvider = context.watch<LojaProvider>();

    if (_pedido == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Jornada')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pedido = _pedido!;
    final nomeFuncao =
        funcaoProvider.buscarPorId(pedido.funcaoId)?.nomeFuncao ?? '—';
    final nomeLoja = lojaProvider.buscarPorId(pedido.lojaId)?.nomeLoja ?? '—';
    final acoes = _acoesDisponiveis();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Jornada'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // Card de detalhes do pedido
            Container(
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
                      StatusBadge(pedido.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.store_outlined, nomeLoja),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.calendar_today,
                    '${_dateFormat.format(pedido.dataInicio)}  →  ${_dateFormat.format(pedido.dataFim)}',
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.people_outline,
                    '${pedido.quantidade} vaga${pedido.quantidade > 1 ? 's' : ''}',
                  ),
                  if (pedido.observacoes != null &&
                      pedido.observacoes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _infoRow(Icons.notes, pedido.observacoes!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Escalados
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
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

            if (escalacaoProvider.loading)
              const Center(child: CircularProgressIndicator())
            else if (escalacaoProvider.escalados.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Nenhum freelancer escalado ainda',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              )
            else
              ...escalacaoProvider.escalados.map(
                (escalado) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
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
                    subtitle: escalado.status != "pendente"
                        ? StatusBadge(escalado.status)
                        : null,
                  ),
                ),
              ),

            // Ações
            if (acoes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'AÇÕES',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              ...acoes.map(
                (acao) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acao.danger
                            ? AppColors.danger.withOpacity(0.15)
                            : AppColors.accentDim,
                        foregroundColor: acao.danger
                            ? AppColors.danger
                            : AppColors.accent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: acao.danger
                                ? AppColors.danger.withOpacity(0.3)
                                : AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                      ),
                      icon: Icon(acao.icon),
                      label: Text(
                        acao.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: acao.onTap,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _AcaoConfig {
  final String label;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  _AcaoConfig({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });
}
