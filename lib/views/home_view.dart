import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Selecione o perfil'),
              const SizedBox(height: 20),

              // Exibe o cargo selecionado
              Text(
                _selectedRole == null
                    ? 'Nenhum perfil selecionado'
                    : 'Perfil: $_selectedRole',
              ),
              const SizedBox(height: 10),

              // PopupMenuButton para selecionar o cargo
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() => _selectedRole = value);
                },
                itemBuilder: (BuildContext context) => const [
                  PopupMenuItem(
                    value: 'gerente',
                    child: Text('Gerente'),
                  ),
                  PopupMenuItem(
                    value: 'rh',
                    child: Text('Recursos Humanos'),
                  ),
                  PopupMenuItem(
                    value: 'diretoria',
                    child: Text('Diretoria'),
                  ),
                ],
                child: const Icon(Icons.arrow_drop_down_circle),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _selectedRole == null
                    ? null
                    : () {
                  // Atualiza o AuthProvider
                  context.read<AuthProvider>().login(_selectedRole!);

                  // Redireciona conforme o cargo
                  if (_selectedRole == 'gerente') {
                    context.go('/manager/gerente');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ainda não há tela para "$_selectedRole"',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  'ENTRAR',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
