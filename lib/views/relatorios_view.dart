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
  final _mesFormatter = DateFormat('MMMM yyyy', 'pt_BR');
  final _dateDisplay = DateFormat('dd/MM/yyyy', 'pt_BR');

  // ─── dados ───────────────────────────────────────────────────────
  List<Map<String, dynamic>> _porLoja = [];
  List<Map<String, dynamic>> _porFuncao = [];
  List<Map<String, dynamic>> _custoLoja = [];
  List<Map<String, dynamic>> _custoFuncao = [];
  List<Map<String, dynamic>> _evolucao = [];

  // ─── KPIs ────────────────────────────────────────────────────────
  int _totalPedidos = 0;
  double _custoTotal = 0;
  double _horasTotal = 0;

  // ─── filtro de período ───────────────────────────────────────────
  DateTime? _dataInicio;
  DateTime? _dataFim;

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

  String? get _inicioStr => _dataInicio?.toIso8601String();
  String? get _fimStr => _dataFim?.toIso8601String();

  Future<void> _carregar() async {
    final empresaId = context.read<AuthProvider>().empresaId;
    if (empresaId == null) {
      setState(() {
        _loading = false;
        _erro = 'Empresa não identificada.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final results = await Future.wait([
        RelatorioService.pedidosPorLoja(
          empresaId: empresaId,
          dataInicio: _inicioStr,
          dataFim: _fimStr,
        ),
        RelatorioService.pedidosPorFuncao(
          empresaId: empresaId,
          dataInicio: _inicioStr,
          dataFim: _fimStr,
        ),
        RelatorioService.custosPorLoja(
          empresaId: empresaId,
          dataInicio: _inicioStr,
          dataFim: _fimStr,
        ),
        RelatorioService.custosPorFuncao(
          empresaId: empresaId,
          dataInicio: _inicioStr,
          dataFim: _fimStr,
        ),
        RelatorioService.evolucaoMensal(
          empresaId: empresaId,
          dataInicio: _inicioStr,
          dataFim: _fimStr,
        ),
      ]);

      final custoLoja = results[2];
      final evolucao = results[4];

      final custoTotal = custoLoja.fold<double>(
        0,
        (sum, e) => sum + (e['total_valor'] as double),
      );
      final horasTotal = custoLoja.fold<double>(
        0,
        (sum, e) => sum + (e['total_horas'] as double),
      );
      final totalPedidos = (results[0]).fold<int>(
        0,
        (sum, e) => sum + (e['total_pedidos'] as int),
      );

      setState(() {
        _porLoja = results[0];
        _porFuncao = results[1];
        _custoLoja = custoLoja;
        _custoFuncao = results[3];
        _evolucao = evolucao;
        _custoTotal = custoTotal;
        _horasTotal = horasTotal;
        _totalPedidos = totalPedidos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar relatórios: $e';
        _loading = false;
      });
    }
  }

  // ─── seletor de período ──────────────────────────────────────────
  Future<void> _selecionarPeriodo() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dataInicio != null && _dataFim != null
          ? DateTimeRange(start: _dataInicio!, end: _dataFim!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.background,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.card),
        ),
        child: child!,
      ),
    );

    if (range != null) {
      setState(() {
        _dataInicio = range.start;
        _dataFim = range.end;
      });
      _carregar();
    }
  }

  void _limparFiltro() {
    setState(() {
      _dataInicio = null;
      _dataFim = null;
    });
    _carregar();
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

  Widget _barra(double valor, double maxValor, {String? percentualLabel}) {
    final pct = maxValor > 0 ? (valor / maxValor).clamp(0.0, 1.0) : 0.0;
    final pctStr = '${(pct * 100).toStringAsFixed(0)}%';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 10),
          Text(
            percentualLabel ?? pctStr,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── KPIs ────────────────────────────────────────────────────────
  Widget _kpis() {
    final ticketMedio = _totalPedidos > 0 ? _custoTotal / _totalPedidos : 0.0;
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _kpiCard(Icons.receipt_long_outlined, 'Pedidos', '$_totalPedidos'),
          const SizedBox(width: 10),
          _kpiCard(
            Icons.attach_money,
            'Custo total',
            _currency.format(_custoTotal),
          ),
          const SizedBox(width: 10),
          _kpiCard(
            Icons.schedule_outlined,
            'Horas',
            '${_horasTotal.toStringAsFixed(0)}h',
          ),
          const SizedBox(width: 10),
          _kpiCard(
            Icons.trending_up,
            'Ticket médio',
            _currency.format(ticketMedio),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(IconData icon, String label, String valor) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    ),
  );

  // ─── chip de filtro ativo ─────────────────────────────────────────
  Widget? _filtroBanner() {
    if (_dataInicio == null && _dataFim == null) return null;
    final texto =
        '${_dateDisplay.format(_dataInicio!)} → ${_dateDisplay.format(_dataFim!)}';
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range, color: AppColors.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  texto,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _limparFiltro,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.accent,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        ..._porLoja.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final item = entry.value;
          final total = item['total_pedidos'] as int;
          return _card(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: rank == 1 ? AppColors.accentDim : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rank == 1 ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: rank == 1 ? AppColors.accent : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _linha(
                        item['nome'] as String,
                        '$total pedidos',
                        destaque: true,
                      ),
                      _barra(total.toDouble(), max),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
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
        ..._porFuncao.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final item = entry.value;
          final total = item['total_pedidos'] as int;
          return _card(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: rank == 1 ? AppColors.accentDim : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rank == 1 ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: rank == 1 ? AppColors.accent : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _linha(
                        item['nome'] as String,
                        '$total pedidos',
                        destaque: true,
                      ),
                      _barra(total.toDouble(), max),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _tabCustos() {
    // fix: calcular max uma vez fora do map
    final maxLoja = _custoLoja.isEmpty
        ? 0.0
        : (_custoLoja.first['total_valor'] as double);
    final maxFunc = _custoFuncao.isEmpty
        ? 0.0
        : (_custoFuncao.first['total_valor'] as double);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        _secao('CUSTOS POR LOJA'),
        if (_custoLoja.isEmpty)
          _card(_semDados())
        else
          ..._custoLoja.map(
            (item) => _card(
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
            ),
          ),

        _secao('CUSTOS POR FUNÇÃO'),
        if (_custoFuncao.isEmpty)
          _card(_semDados())
        else
          ..._custoFuncao.map(
            (item) => _card(
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
            ),
          ),
      ],
    );
  }

  Widget _tabEvolucao() {
    if (_evolucao.isEmpty) return _vazio();

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

        ..._evolucao.map((item) {
          // formata "2025-03" → "Março 2025"
          final mesStr = item['mes'] as String;
          String mesLabel = mesStr;
          try {
            final parts = mesStr.split('-');
            final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
            mesLabel = _mesFormatter.format(dt);
            mesLabel = mesLabel[0].toUpperCase() + mesLabel.substring(1);
          } catch (_) {}

          return _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linha(
                  mesLabel,
                  _currency.format(item['total_valor']),
                  destaque: true,
                ),
                _barra(item['total_valor'] as double, max),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _vazio() => const Center(
    child: Padding(
      padding: EdgeInsets.all(40),
      child: Text(
        'Nenhum dado encontrado',
        style: TextStyle(color: AppColors.textMuted),
      ),
    ),
  );

  Widget _semDados() => const Center(
    child: Text('Sem dados', style: TextStyle(color: AppColors.textMuted)),
  );

  // ─── build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final banner = _filtroBanner();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Relatórios'),
        actions: [
          // Botão de filtro de período
          IconButton(
            tooltip: 'Filtrar período',
            icon: Icon(
              Icons.date_range,
              color: _dataInicio != null
                  ? AppColors.accent
                  : AppColors.textMuted,
            ),
            onPressed: _selecionarPeriodo,
          ),
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // KPIs sempre visíveis
                _kpis(),
                const SizedBox(height: 8),
                // Chip de filtro ativo (só aparece quando há filtro)
                if (banner != null) banner,
                // Conteúdo das abas
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _tabPedidosPorLoja(),
                      _tabPedidosPorFuncao(),
                      _tabCustos(),
                      _tabEvolucao(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
