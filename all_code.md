
# Arquivos da pasta `lib`

## `lib/database/config_database.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqflite.dart';

class ConfigDatabase {
  static Future<Database> getDatabase() async {
    final String pathDatabase = await getDatabasesPath();
    final String path = '$pathDatabase/app_rh.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE requests(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gerente TEXT,
            data_solicitacao TEXT,
            data_limite TEXT,
            pessoas_necessarias INTEGER,
            departamento TEXT,
            descricao TEXT,
            status TEXT
          )
        ''');
      },
    );
  }
}
```

## `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/views/direcao/relatorios_consolidados_view.dart';
import 'package:freelance/views/home_view.dart';
import 'package:freelance/views/manager/jornada_view.dart';
import 'package:freelance/views/manager/new_request_view.dart';
import 'package:freelance/views/manager/requests_view.dart';
import 'package:freelance/views/rh/escalacao_view.dart';
import 'package:freelance/views/rh/fila_pedidos_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => PessoaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/manager/gerente',
      builder: (context, state) => GerenteView(),
    ),
    GoRoute(
      path: '/manager/new_request',
      builder: (context, state) => NovaSolicitacao(),
    ),
    GoRoute(
      path: '/manager/jornada_view/:pedidoId',
      builder: (context, state) {
        final pedidoId = state.pathParameters['pedidoId']!;
        return DetalhesPedido(pedidoId: pedidoId);
      },
    ),
    GoRoute(
      path: '/rh/fila_pedidos',
      builder: (context, state) => const FilaPedidosView(),
    ),
    GoRoute(
      path: '/rh/escala_pedidos',
      builder: (context, state) => const EscalacaoView(),
    ),
    GoRoute(
      path: '/direcao/diretoria',
      builder: (context, state) => const RelatoriosConsolidadosView(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Freelance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
```

## `lib/models/confirmacao_loja.dart`

```dart
class ConfirmacaoLojaModel{
  String id;
  String pedidoId;
  String userId;
  String confirmacao;
  DateTime dataEnvio;

  ConfirmacaoLojaModel({
    required this.id,
    required this.pedidoId,
    required this.userId,
    required this.confirmacao,
    required this.dataEnvio
});

}
```

## `lib/models/escala.dart`

```dart
class EscalaModel {
  String id;
  String pedidoId;
  String rhId;
  DateTime dataCriacao;
  String status;

  EscalaModel({
    required this.id,
    required this.pedidoId,
    required this.rhId,
    required this.dataCriacao,
    required this.status,
  });
}
```

## `lib/models/escala_freelance.dart`

```dart
class EscalaFreelanceModel {
  String id;
  String escalaId;
  String freelanceId;
  String status;
  DateTime horaEntrada;
  DateTime horaSaida;
  String observacoes;

  EscalaFreelanceModel({
    required this.id,
    required this.escalaId,
    required this.freelanceId,
    required this.status,
    required this.horaEntrada,
    required this.horaSaida,
    required this.observacoes,
  });
}
```

## `lib/models/relatorio.dart`

```dart
class RelatorioModel{
  String id;
  String pedidoId;
  String totalHoras;
  int totalFreelancers;
  int custoEstimado;
  DateTime dataCriacao;

  RelatorioModel({
    required this.id,
    required this.pedidoId,
    required this.totalHoras,
    required this.totalFreelancers,
    required this.custoEstimado,
    required this.dataCriacao
});
}
```

## `lib/models/request.dart`

```dart
import 'package:freelance/models/pessoa_no_pedido.dart';

class PedidoModel {
  String id;
  String lojaId;
  String gerenteId;
  DateTime dataInicio;
  DateTime dataFim;
  String funcao;
  int quantidade;
  String observacoes;
  String status;
  DateTime dataCriacao;
  List<PessoaNoPedidoModel> pessoas;

  PedidoModel({
    required this.id,
    required this.lojaId,
    required this.gerenteId,
    required this.dataInicio,
    required this.dataFim,
    required this.funcao,
    required this.quantidade,
    required this.observacoes,
    required this.status,
    required this.dataCriacao,
    List<PessoaNoPedidoModel>? pessoas,
  }) : pessoas = pessoas ?? [];
}
```

## `lib/models/unitystore.dart`

```dart
class LojaModel{
  String id;
  String nomeLoja;
  String gerenteId;

  LojaModel({
    required this.id,
    required this.nomeLoja,
    required this.gerenteId
});
}
```

## `lib/models/users.dart`

```dart
class UserModel {
  String id;
  String name;
  String email;
  String cargo;
  String lojaId;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.cargo,
    required this.lojaId,
  });
}
```

## `lib/models/pessoa_no_pedido.dart`

```dart
class PessoaNoPedidoModel {
  String pessoaId;
  String funcao;

  PessoaNoPedidoModel({required this.funcao, required this.pessoaId});
}
```

## `lib/models/pessoa_model.dart`

```dart
class PessoaModel {
  String pessoaId;
  String nome;

  PessoaModel({required this.nome, required this.pessoaId});
}
```

## `lib/providers/auth_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:freelance/models/users.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  String? get cargo => user?.cargo;

  void login(UserModel user) {
    _user = user;

    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
```

## `lib/providers/escala_provider.dart`

```dart
```

## `lib/providers/pedido_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:freelance/models/pessoa_no_pedido.dart';
import 'package:freelance/models/request.dart';

class PedidoProvider extends ChangeNotifier {
  final List<PedidoModel> _pedidos = [];

  List<PedidoModel> get pedidos => _pedidos;

  adicionarPedido(PedidoModel pedidos) {
    _pedidos.add(pedidos);

    notifyListeners();
  }

  buscarPorId(String id) {
    return pedidos.firstWhere((pedido) => pedido.id == id);
  }

  adicionarPessoaPedido({
    required String pedidoId,
    required String pessoaId,
    required String funcao,
  }) {
    final pedido = buscarPorId(pedidoId);

    pedido.pessoas.add(PessoaNoPedidoModel(funcao: funcao, pessoaId: pessoaId));

    notifyListeners();
  }
}
```

## `lib/providers/pessoa_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:freelance/models/pessoa_model.dart';

class PessoaProvider extends ChangeNotifier {
  final List<PessoaModel> _pessoas = [];

  List<PessoaModel> get pessoas => _pessoas;

  adicionarPessoa(PessoaModel pessoa) {
    _pessoas.add(pessoa);
    notifyListeners();
  }

  buscarPessoaPorId(String id) {
    return _pessoas.firstWhere(
      (p) => p.pessoaId == id,
      orElse: () =>
          PessoaModel(nome: 'Pessoa não encontrada', pessoaId: 'invalid'),
    );
  }

  removerPessoa(String id) {
    _pessoas.removeWhere((p) => p.pessoaId == id);

    notifyListeners();
  }

  alterarPessoa(String id, String novoNome) {
    final pessoa = _pessoas.firstWhere((p) => p.pessoaId == id);
    pessoa.nome = novoNome;

    notifyListeners();
  }
}
```

## `lib/views/direcao/relatorios_consolidados_view.dart`

```dart
import 'package:flutter/material.dart';

class RelatoriosConsolidadosView extends StatefulWidget {
  const RelatoriosConsolidadosView({super.key});

  @override
  State<RelatoriosConsolidadosView> createState() => _RelatoriosConsolidadosViewState();
}

class _RelatoriosConsolidadosViewState extends State<RelatoriosConsolidadosView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Consolidados'),
      ),
      body: const Center(
        child: Text('Conteúdo dos Relatórios Consolidados'),
      ),
    );
  }
}
```

## `lib/views/home_view.dart`

```dart
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
```

## `lib/views/manager/jornada_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:provider/provider.dart';

class DetalhesPedido extends StatelessWidget {
  final String pedidoId;

  const DetalhesPedido({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final pessoaProvider = context.watch<PessoaProvider>();

    final pedido = pedidoProvider.buscarPorId(pedidoId);
    final pessoasNoPedido = pedido.pessoas;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Detalhes do pedido')),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        child: Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text('Cancelar')),
            ElevatedButton(onPressed: () {}, child: Text('Finalizar')),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Card(
          child: Column(
            children: [
              Text(
                'Pedido id: ${pedido.id} para ${pedido.dataInicio} status: ${pedido.status}',
              ),
              const SizedBox(height: 4),
              Text('Relação das pessoas selecionadas:'),
              const SizedBox(height: 4),
              SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Expanded(child: Text('Nome'))),
                    DataColumn(label: Expanded(child: Text('Função'))),
                  ],
                  rows:
                      pessoasNoPedido.map((pessoasNoPedido) {
                        final pessoa = pessoaProvider.buscarPessoaPorId(
                          pessoasNoPedido.pessoaId,
                        );
                      })[DataRow(
                        cells: [
                          DataCell(Text(pessoasNoPedido.nome)),
                          DataCell(Text(pessoasNoPedido.funcao)),
                        ],
                      )],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## `lib/views/manager/new_request_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:freelance/helpers/datetime_helper.dart';
import 'package:freelance/models/request.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const List<String> setores = [
  'Reposição',
  'Limpeza',
  'Açougue',
  'Segurança',
  'Cozinha',
  'Frios',
  'Operador de Caixa',
  'Fiscal de Loja',
  'Fiscal de caixa',
  'Motorista',
  'Estoquista',
  'Ajudante de Carga e Descarga',
  'CPD',
  'Padaria',
  'Salgados',
];

class NovaSolicitacao extends StatefulWidget {
  NovaSolicitacao({super.key});
  DateTime? dataInicio;
  DateTime? dataFim;

  @override
  State<NovaSolicitacao> createState() => _NovaSolicitacaoState();
}

class _NovaSolicitacaoState extends State<NovaSolicitacao> {
  final _formKey = GlobalKey<FormState>();

  String valuedropDonw = setores[0];

  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  String setorSelecionado = setores[0];

  @override
  void dispose() {
    quantidadeController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  void _submeter() {
    if (!_formKey.currentState!.validate()) return;

    if (dataInicio == null || dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data de início e fim')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final pedidoProvider = context.read<PedidoProvider>();

    if (auth.user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      return;
    }

    final novoPedido = PedidoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lojaId: auth.user!.lojaId,
      gerenteId: auth.user!.id,
      dataInicio: dataInicio!,
      dataFim: dataFim!,
      funcao: valuedropDonw,
      quantidade: int.parse(quantidadeController.text),
      observacoes: observacaoController.text,
      status: 'pendente',
      dataCriacao: DateTime.now(),
    );

    pedidoProvider.adicionarPedido(novoPedido);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitação enviada ao RH')));

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Solicitação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // volta para a tela anterior
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Criar Pedido de Pessoal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Card principal do formulário
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Função
                        DropdownButton<String>(
                          hint: Text('Selecione a Função'),
                          isExpanded: true,
                          value: valuedropDonw,
                          items: setores.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              valuedropDonw = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quantidade
                        TextFormField(
                          controller: quantidadeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obrigatorio";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de Pessoas',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Data/hora início
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data/Horario de inicio',
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) =>
                              dataInicio == null ? 'Campo obrigatório' : null,
                          onTap: () async {
                            final result = await selecionarDataHora(context);
                            if (result != null) {
                              setState(() {
                                dataInicio = result;
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: dataInicio == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(dataInicio!),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Data/hora fim
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data/Hora fim',
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) =>
                              dataFim == null ? 'Campo obrigatório' : null,
                          onTap: () async {
                            final result = await selecionarDataHora(context);
                            if (result != null) {
                              setState(() {
                                dataFim = result;
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: dataFim == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(dataFim!),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Observações
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obrigatorio";
                            }
                            return null;
                          },
                          controller: observacaoController,
                          decoration: const InputDecoration(
                            labelText: 'Observações',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botão principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Enviar para RH',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _submeter();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## `lib/views/manager/requests_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GerenteView extends StatelessWidget {
  const GerenteView({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>().pedidos;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Pedidos - Gerente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: pedidoProvider.length,
          itemBuilder: (context, index) {
            final pedido = pedidoProvider[index];
            return Card(
              child: ListTile(
                title: Text(
                  'Solicitação para ${pedido.dataInicio.day}/${pedido.dataInicio.month}/${pedido.dataInicio.year}',
                ),

                subtitle: Text(
                  'Solicitação de ${pedido.quantidade} pessoas para o setor de ${pedido.funcao}.',
                ),
                onTap: () {
                  context.go('/manager/jornada_view/${pedido.id}');
                },
                trailing: ElevatedButton(
                  onPressed: () {},

                  child: Text("Aprovar"),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/manager/new_request');
        },
        label: Text('solicitar pessoas'),
      ),
    );
  }
}
```

## `lib/views/rh/conferencia_view.dart`

```dart
```

## `lib/views/rh/escalacao_view.dart`

```dart
import 'package:flutter/material.dart';

class EscalacaoView extends StatefulWidget {
  const EscalacaoView({super.key});

  @override
  State<EscalacaoView> createState() => _EscalacaoViewState();
}

class _EscalacaoViewState extends State<EscalacaoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escalação de pedidos'), centerTitle: true),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOLICITAÇÃO: 123456',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Gerente Responsável: João Silva',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Data da Solicitação: 01/01/2024',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('Data Limite: 15/01/2024', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Pessoas Necessárias: 5', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Departamento: Vendas', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Descrição: Necessidade de contratação de novos funcionários para o setor de vendas.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Ação ao pressionar o botão
              },
              child: Text('Escalar Pessoas'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## `lib/views/rh/fila_pedidos_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fila de pedidos'),
      centerTitle: true,),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solicitação #12345', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text('Loja: Loja Central'),
                    Text('Gerente: João Silva'),
                    Text('Data: 25/06/2024'),
                    Text('Pessoas solicitadas: 3'),
                    Text('Status: Em andamento'),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Ação ao pressionar o botão
                        context.push('/rh/escala_pedidos');
                      },
                      child: Text('Ver detalhes do pedido'),
                    ),
                  ],
                ),
              ),
             ),
              Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitação #12346', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.0),
                      Text('Loja: Loja Norte'),
                      Text('Gerente: Maria Oliveira'),
                      Text('Data: 26/06/2024'),
                      Text('Pessoas solicitadas: 2'),
                      Text('Status: Pendente'),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Ação ao pressionar o botão
                        },
                        child: Text('Ver detalhes do pedido'),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitação #12347', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.0),
                      Text('Loja: Loja Sul'),
                      Text('Gerente: Carlos Pereira'),
                      Text('Data: 27/06/2024'),
                      Text('Pessoas solicitadas: 4'),
                      Text('Status: Aprovado'),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Ação ao pressionar o botão
                        },
                        child: Text('Ver detalhes do pedido'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
```

## `lib/views/rh/relatorio_view.dart`

```dart
```

## `lib/widgets/confirm_dialog.dart`

```dart
```

## `lib/widgets/freelancer_list_item.dart`

```dart
```

## `lib/widgets/pedido_card.dart`

```dart
```

## `lib/helpers/datetime_helper.dart`

```dart
import 'package:flutter/material.dart';

DateTime? dataInicio;
DateTime? dataFim;

Future<DateTime?> selecionarDataHora(BuildContext context) async {
  final data = await showDatePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );

  if (data == null) return null;

  final hora = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (hora == null) return null;

  return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
}
```

## `lib/services/status_service.dart`

```dart
import 'package:freelance/models/request.dart';

enum StatusPedido { solicitado, aprovado, cancelado, recusado, finalizado }

class StatusService {
  PedidoModel aprovarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.solicitado) {
      throw Exception("Pedido não pode ser aprovado");
    }

    pedido.status = StatusPedido.aprovado.name;

    return pedido;
  }

  PedidoModel cancelarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.solicitado) {
      throw Exception('Este pedido não pode ser cancelado');
    }

    pedido.status = StatusPedido.cancelado.name;

    return pedido;
  }

  //Pedido só pode ser recusado depois que foi aprovado pelo RH
  PedidoModel recusarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.aprovado) {
      throw Exception('Este pedido não pode ser recusado');
    }

    pedido.status = StatusPedido.recusado.name;
    return pedido;
  }

  PedidoModel finalizarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.aprovado) {
      throw Exception('Este pedido não pode ser finalizado ');
    }
    pedido.status = StatusPedido.finalizado.name;
    return pedido;
  }
}
```
