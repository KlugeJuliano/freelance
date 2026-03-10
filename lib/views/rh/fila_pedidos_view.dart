import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  static const _dark = Color(0xFF0F1117);
  static const _card = Color(0xFF1A1D27);
  static const _accent = Color(0xFF00E5A0);
  static const _accentDim = Color(0x2200E5A0);
  static const _textPrimary = Color(0xFFEEEEF5);
  static const _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PedidoProvider>().carregarPedidos();
      context.read<FuncaoProvider>().carregarFuncoes();
    });
  }

  Drawer _buildDrawer(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Drawer(
      backgroundColor: _card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: BoxDecoration(
              color: _dark,
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
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
                  child: const Text(
                    'RH',
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          _drawerItem(
            context,
            icon: Icons.work_outline,
            label: 'Cadastro de Funções',
            onTap: () {
              Navigator.pop(context);
              context.push('/rh/cadastros/cadastro_funcoes');
            },
          ),

          _drawerItem(
            context,
            icon: Icons.people_outline,
            label: 'Cadastro de Colaboradores',
            onTap: () {
              Navigator.pop(context);
              context.push('/rh/cadastros/cadastro_colaboradores');
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.white.withOpacity(0.06)),
          ),

          _drawerItem(
            context,
            icon: Icons.logout,
            label: 'Sair',
            danger: true,
            onTap: () async {
              await auth.logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFFF4D6A) : _textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      onTap: onTap,
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'solicitado':
        return const Color(0xFFFFB347);
      case 'em_selecao':
        return const Color(0xFF00E5A0);
      case 'finalizado':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    final pedidosPendentes = pedidoProvider.pedidos
        .where((p) => p.status == 'solicitado')
        .toList();

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: _dark,
        appBar: AppBar(
          backgroundColor: _dark,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Fila de Pedidos',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: _textMuted),
              onPressed: () => context.read<PedidoProvider>().carregarPedidos(),
            ),
          ],
        ),

        drawer: _buildDrawer(context),

        body: pedidoProvider.loading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : pedidosPendentes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 56,
                      color: _textMuted.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum pedido pendente',
                      style: TextStyle(color: _textMuted, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Novos pedidos aparecerão aqui',
                      style: TextStyle(color: _textMuted, fontSize: 13),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: pedidosPendentes.length,
                itemBuilder: (context, index) {
                  final pedido = pedidosPendentes[index];
                  final nomeFuncao =
                      funcaoProvider.buscarPorId(pedido.funcaoId)?.nomeFuncao ??
                      pedido.funcaoId;
                  final statusColor = _statusColor(pedido.status);

                  return GestureDetector(
                    onTap: () => context.push(
                      '/rh/escala_pedidos/${pedido.id}',
                      extra: pedido,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
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
                                      fontSize: 12,
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
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    pedido.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
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
                                  size: 13,
                                  color: _textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_formatarData(pedido.dataInicio)}  →  ${_formatarData(pedido.dataFim)}',
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 13,
                                  color: _textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${pedido.quantidade} vaga${pedido.quantidade > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                if (pedido.observacoes.isNotEmpty) ...[
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.notes,
                                    size: 13,
                                    color: _textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      pedido.observacoes,
                                      style: const TextStyle(
                                        color: _textMuted,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Ver escalação',
                                  style: TextStyle(
                                    color: _accent.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: _accent.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
