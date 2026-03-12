import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/loja_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PedidoProvider>().fetchPedidos();
      context.read<FuncaoProvider>().fetchFuncoes();
      context.read<LojaProvider>().fetchLojas();
    });
  }

  Future<void> _recarregar() async {
    await context.read<PedidoProvider>().fetchPedidos();
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final funcaoProvider = context.watch<FuncaoProvider>();
    final lojaProvider = context.watch<LojaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _recarregar),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: pedidoProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : pedidoProvider.pedidos.isEmpty
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
                    'Nenhum pedido criado ainda',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toque em Solicitar para criar um pedido',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _recarregar,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: pedidoProvider.pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidoProvider.pedidos[index];
                  final nomeFuncao =
                      funcaoProvider.buscarPorId(pedido.funcaoId)?.nomeFuncao ??
                      '—';
                  final nomeLoja =
                      lojaProvider.buscarPorId(pedido.lojaId)?.nomeLoja ?? '—';

                  return GestureDetector(
                    onTap: () =>
                        context.push('/manager/jornada_view/${pedido.id}'),
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
                            // Função + status
                            Row(
                              children: [
                                AccentBadge(nomeFuncao),
                                const Spacer(),
                                StatusBadge(pedido.status),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Loja
                            Row(
                              children: [
                                const Icon(
                                  Icons.store_outlined,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  nomeLoja,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Período
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_dateFormat.format(pedido.dataInicio)}  →  ${_dateFormat.format(pedido.dataFim)}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Quantidade
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
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Ver detalhes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Ver detalhes',
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
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        onPressed: () => context.push('/manager/new_request'),
        icon: const Icon(Icons.add),
        label: const Text(
          'Solicitar pessoas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
