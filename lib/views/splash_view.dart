import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _start(); // 👈 usa função async
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return; // 🔥 AQUI resolve o bug

    await _verificar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    final auth = context.read<AuthProvider>();

    await auth.verificarLogin();

    if (!mounted) return;

    print('STATUS: ${auth.status}');
    print('LOGADO: ${auth.isLogado}');
    print('ROLE: ${auth.role}');

    if (auth.isLogado) {
      switch (auth.role) {
        case 'gerente':
          context.go('/manager/gerente');
          break;
        case 'rh':
          context.go('/rh/fila_pedidos');
          break;
        case 'diretoria':
          context.go('/direcao/relatorios');
          break;
        default:
          context.go('/cadastro_empresa');
      }
    } else {
      context.go('/cadastro_empresa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.people_alt_outlined,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Freelance',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gestão de colaboradores',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accent.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
