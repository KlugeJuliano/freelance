import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PedidoProvider>().fetchPedidos();
      context.read<FuncaoProvider>().fetchFuncoes();
    });
  }

  Drawer _buildDrawer(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                AccentBadge('RH'),
                SizedBox(height: 8),
                Text(
                  'Menu',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          _drawerItem(
            icon: Icons.work_outline,
            label: 'Cadastro de Funções',
            onTap: () {
              Navigator.pop(context);
              context.push('/rh/cadastros/cadastro_funcoes');
            },
          ),
          _drawerItem(
            icon: Icons.people_outline,
            label: 'Cadastro de Colaboradores',
            onTap: () {
              Navigator.pop(context);
              context.push('/rh/cadastros/cadastro_colaboradores');
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(),
          ),

          _drawerItem(
            icon: Icons.logout,
            label: 'Sair',
            danger: true,
            onTap: () async {
              await auth.signOut();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return ListTile(
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

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();

    final pedidosPendentes = pedidoProvider.pedidos
        .where((p) => p.status == 'solicitado' || p.status == 'recusado')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fila de Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PedidoProvider>().fetchPedidos(),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: pedidoProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : pedidosPendentes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 56,
                    color: AppColors.textMuted.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum pedido pendente',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Novos pedidos aparecerão aqui',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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

                return GestureDetector(
                  onTap: () => context.push(
                    '/rh/escala_pedidos/${pedido.id}',
                    extra: pedido,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
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

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatarData(pedido.dataInicio)}  →  ${_formatarData(pedido.dataFim)}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
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
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${pedido.quantidade} vaga${pedido.quantidade > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              if (pedido.observacoes != null &&
                                  pedido.observacoes!.isNotEmpty) ...[
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.notes,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    pedido.observacoes!,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
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
                                  color: AppColors.accent.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: AppColors.accent.withOpacity(0.8),
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
    );
  }
}
