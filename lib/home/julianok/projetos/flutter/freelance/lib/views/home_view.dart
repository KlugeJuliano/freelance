import 'package:flutter/material.dart';
import 'package:freelance/models/users.dart';
import 'package:provider/provider.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _selectedUser;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final fakeUsers = [
      UserModel(
        id: '1',
        name: 'Gerente Loja',
        email: 'gerente@loja.com',
        cargo: 'Gerente',
        lojaId: '1',
      ),
      UserModel(
        id: "2",
        name: 'RH Central',
        email: 'rh@empresa.com',
        cargo: 'Recursos Humanos',
        lojaId: '0', // RH não pertence a uma loja específica
      ),
      UserModel(
        id: "3",
        name: 'Diretoria',
        email: 'diretoria@empresa.com',
        cargo: 'Diretor',
        lojaId: "0",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Selecione o perfil',
                  style: TextStyle(fontFamily: 'ROBOTO', fontSize: 32),
                ),
                const SizedBox(height: 20),

                // Exibe o cargo selecionado
                Text(
                  _selectedUser?.cargo ?? "Nenhum perfil selecionado",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),

                // PopupMenuButton para selecionar o cargo
                PopupMenuButton<UserModel>(
                  onSelected: (user) {
                    setState(() => _selectedUser = user);
                  },
                  itemBuilder: (context) => fakeUsers
                      .map(
                        (user) => PopupMenuItem<UserModel>(
                          value: user,
                          child: Text(user.name),
                        ),
                      )
                      .toList(),
                  child: const Icon(Icons.arrow_drop_down_circle),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _selectedUser == null
                      ? null
                      : () {
                          context.read<AuthProvider>().login(_selectedUser!);

                          switch (_selectedUser!.id) {
                            case '1':
                              context.push('/manager/gerente');
                              break;
                            case '2':
                              context.push('/rh/fila_pedidos');
                              break;
                            case '3':
                              context.push('/direcao/diretoria');
                              break;
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
      ),
    );
  }
}
