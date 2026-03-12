import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _senhaVisivel = false;

  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final sucesso = await auth.login(
      _emailController.text.trim(),
      _senhaController.text,
    );

    if (!mounted) return;
    if (sucesso) _redirecionarPorRole(auth.role);
  }

  void _redirecionarPorRole(String? role) {
    switch (role) {
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
        context.go('/');
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      fillColor: AppColors.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.people_alt_outlined,
                          color: AppColors.accent,
                          size: 36,
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
                        'Entre com sua conta',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Card do formulário
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration(
                                'E-mail',
                                Icons.email_outlined,
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Informe o e-mail'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _senhaController,
                              obscureText: !_senhaVisivel,
                              decoration:
                                  _inputDecoration(
                                    'Senha',
                                    Icons.lock_outline,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _senhaVisivel
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _senhaVisivel = !_senhaVisivel,
                                      ),
                                    ),
                                  ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Informe a senha'
                                  : null,
                              onFieldSubmitted: (_) =>
                                  auth.loading ? null : _login(),
                            ),

                            // Erro
                            if (auth.erro != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.danger.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.danger,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        auth.erro!,
                                        style: const TextStyle(
                                          color: AppColors.danger,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                              ),
                              onPressed: auth.loading ? null : _login,
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.background,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
