// lib/views/direcao/relatorios_view.dart

import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/services/relatorio_service.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RelatoriosView extends StatefulWidget {
  const RelatoriosView({super.key});

  @override
  State<RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends State<RelatoriosView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<Map<String, dynamic>> _porLoja = [];
  List<Map<String, dynamic>> _porFuncao = [];
  List<Map<String, dynamic>> _custoLoja = [];
  List<Map<String, dynamic>> _custoFuncao = [];
  List<Map<String, dynamic>> _evolucao = [];

  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final results = await Future.wait([
        RelatorioService.pedidosPorLoja(),
        RelatorioService.pedidosPorFuncao(),
        RelatorioService.custosPorLoja(),
        RelatorioService.custosPorFuncao(),
        RelatorioService.evolucaoMensal(),
      ]);
      setState(() {
        _porLoja = results[0];
        _porFuncao = results[1];
        _custoLoja = results[2];
        _custoFuncao = results[3];
        _evolucao = results[4];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar relatórios';
        _loading = false;
      });
    }
  }

  // ─── helpers de layout ───────────────────────────────────────────

  Widget _secao(String titulo) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
    child: Text(
      titulo,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    ),
  );

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _linha(String label, String valor, {bool destaque = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: destaque ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 14,
              fontWeight: destaque ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            color: destaque ? AppColors.accent : AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // Barra horizontal proporcional
  Widget _barra(double valor, double maxValor) {
    final pct = maxValor > 0 ? (valor / maxValor).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: LayoutBuilder(
        builder: (_, constraints) => Stack(
          children: [
            Container(
              height: 6,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 6,
              width: constraints.maxWidth * pct,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── abas ────────────────────────────────────────────────────────

  Widget _tabPedidosPorLoja() {
    if (_porLoja.isEmpty) return _vazio();
    final max = (_porLoja.first['total_pedidos'] as int).toDouble();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        _secao('PEDIDOS POR LOJA'),
        ..._porLoja.map(
          (item) => _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linha(
                  item['nome'] as String,
                  '${item['total_pedidos']} pedidos',
                  destaque: true,
                ),
                _barra((item['total_pedidos'] as int).toDouble(), max),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabPedidosPorFuncao() {
    if (_porFuncao.isEmpty) return _vazio();
    final max = (_porFuncao.first['total_pedidos'] as int).toDouble();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        _secao('PEDIDOS POR FUNÇÃO'),
        ..._porFuncao.map(
          (item) => _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linha(
                  item['nome'] as String,
                  '${item['total_pedidos']} pedidos',
                  destaque: true,
                ),
                _barra((item['total_pedidos'] as int).toDouble(), max),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabCustos() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        // Por loja
        _secao('CUSTOS POR LOJA'),
        if (_custoLoja.isEmpty)
          _card(
            const Center(
              child: Text(
                'Sem dados',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ..._custoLoja.map((item) {
            final maxLoja = (_custoLoja.first['total_valor'] as double);
            return _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _linha(
                    item['nome'] as String,
                    _currency.format(item['total_valor']),
                    destaque: true,
                  ),
                  _linha(
                    'Horas trabalhadas',
                    '${(item['total_horas'] as double).toStringAsFixed(1)}h',
                  ),
                  _barra(item['total_valor'] as double, maxLoja),
                ],
              ),
            );
          }),

        // Por função
        _secao('CUSTOS POR FUNÇÃO'),
        if (_custoFuncao.isEmpty)
          _card(
            const Center(
              child: Text(
                'Sem dados',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ..._custoFuncao.map((item) {
            final maxFunc = (_custoFuncao.first['total_valor'] as double);
            return _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _linha(
                    item['nome'] as String,
                    _currency.format(item['total_valor']),
                    destaque: true,
                  ),
                  _linha(
                    'Horas trabalhadas',
                    '${(item['total_horas'] as double).toStringAsFixed(1)}h',
                  ),
                  _barra(item['total_valor'] as double, maxFunc),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _tabEvolucao() {
    if (_evolucao.isEmpty) return _vazio();

    // Total acumulado para referência
    final total = _evolucao.fold<double>(
      0,
      (sum, e) => sum + (e['total_valor'] as double),
    );
    final max = _evolucao
        .map((e) => e['total_valor'] as double)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        _secao('EVOLUÇÃO MENSAL'),

        // Card de total
        _card(
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Total no período',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const Spacer(),
              Text(
                _currency.format(total),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Um card por mês
        ..._evolucao.map(
          (item) => _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linha(
                  item['mes'] as String,
                  _currency.format(item['total_valor']),
                  destaque: true,
                ),
                _barra(item['total_valor'] as double, max),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _vazio() => const Center(
    child: Text(
      'Nenhum dado encontrado',
      style: TextStyle(color: AppColors.textMuted),
    ),
  );

  // ─── build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Relatórios',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: _carregar,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Pedidos / Loja'),
            Tab(text: 'Pedidos / Função'),
            Tab(text: 'Custos'),
            Tab(text: 'Evolução'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _erro != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _erro!,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _tabPedidosPorLoja(),
                _tabPedidosPorFuncao(),
                _tabCustos(),
                _tabEvolucao(),
              ],
            ),
    );
  }
}
