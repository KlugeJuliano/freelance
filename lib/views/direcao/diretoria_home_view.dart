import 'package:flutter/material.dart';
import 'package:freelance/models/usuario_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/usuario_provider.dart';
import 'package:freelance/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DiretoriaHomeView extends StatefulWidget {
  const DiretoriaHomeView({super.key});

  @override
  State<DiretoriaHomeView> createState() => _DiretoriaHomeViewState();
}

class _DiretoriaHomeViewState extends State<DiretoriaHomeView> {
  void _abrirCadastroUsuario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FormularioUsuario(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuarioProvider = context.watch<UsuarioProvider>();
    final empresa = auth.empresa;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diretoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Relatórios',
            onPressed: () => context.push('/direcao/relatorios'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da empresa
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empresa?.nome ?? '—',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        empresa?.cnpj ?? '',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                AccentBadge('Admin'),
              ],
            ),
          ),

          // Header lista
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              children: [
                const Text(
                  'USUÁRIOS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.accentDim,
                  child: Text(
                    '${usuarioProvider.usuarios.length}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: usuarioProvider.loading && usuarioProvider.usuarios.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : usuarioProvider.usuarios.isEmpty
                ? _emptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: usuarioProvider.usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarioProvider.usuarios[index];
                return _UsuarioCard(
                  usuario: usuario,
                  onRemover: () =>
                      usuarioProvider.removerUsuario(usuario.id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        onPressed: _abrirCadastroUsuario,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(
          'Novo usuário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
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
          'Nenhum usuário cadastrado',
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'Toque em Novo usuário para começar',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    ),
  );
}

// ── Card de usuário ──────────────────────────────────────────────────────────

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onRemover;

  const _UsuarioCard({required this.usuario, required this.onRemover});

  @override
  Widget build(BuildContext context) {
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
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.accentDim,
          child: Text(
            usuario.nome[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          usuario.nome,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              usuario.email,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            AccentBadge(usuario.roleLabel),
          ],
        ),
        trailing: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.danger,
              size: 18,
            ),
          ),
          onPressed: () async {
            final confirmar = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Remover usuário',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Deseja remover ${usuario.nome}?',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Remover'),
                  ),
                ],
              ),
            );
            if (confirmar == true) onRemover();
          },
        ),
      ),
    );
  }
}

// ── Formulário de cadastro (bottom sheet) ────────────────────────────────────

class _FormularioUsuario extends StatefulWidget {
  const _FormularioUsuario();

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _roleSelecionada = 'rh';
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UsuarioProvider>();

    await provider.criarUsuario(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      role: _roleSelecionada,
    );

    if (!mounted) return;

    if (provider.erro == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário criado com sucesso!'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuarioProvider>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'NOVO USUÁRIO',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Nome completo', Icons.person_outline),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('E-mail', Icons.email_outlined),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe o e-mail' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _senhaController,
              obscureText: !_senhaVisivel,
              decoration: _inputDecoration('Senha', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _senhaVisivel = !_senhaVisivel),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a senha';
                if (v.length < 6) return 'Mínimo de 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Seleção de role
            const Text(
              'PERFIL DE ACESSO',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _RoleChip(
                  label: 'RH',
                  role: 'rh',
                  selecionada: _roleSelecionada,
                  onTap: () => setState(() => _roleSelecionada = 'rh'),
                ),
                const SizedBox(width: 10),
                _RoleChip(
                  label: 'Gerente',
                  role: 'gerente',
                  selecionada: _roleSelecionada,
                  onTap: () => setState(() => _roleSelecionada = 'gerente'),
                ),
                const SizedBox(width: 10),
                _RoleChip(
                  label: 'Diretoria',
                  role: 'diretoria',
                  selecionada: _roleSelecionada,
                  onTap: () => setState(() => _roleSelecionada = 'diretoria'),
                ),
              ],
            ),

            // Erro
            if (provider.erro != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.erro!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.loading ? null : _salvar,
                child: provider.loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.background,
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Criar usuário'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final String selecionada;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.role,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = role == selecionada;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ativo ? AppColors.accentDim : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ativo ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? AppColors.accent : AppColors.textMuted,
            fontWeight: ativo ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}