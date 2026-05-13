# Freelance Manager

Aplicativo Flutter para gestao de freelancers, pedidos de mao de obra, escalacao, jornada, pagamentos e relatorios por empresa.

## Visao Geral

O **Freelance Manager** organiza o fluxo operacional entre tres perfis principais:

| Perfil | Responsabilidades |
|---|---|
| **Diretoria** | Cadastrar a empresa, criar usuarios, acompanhar relatorios e indicadores |
| **RH** | Cadastrar funcoes, cadastrar colaboradores/freelancers e escalar pessoas nos pedidos |
| **Gerente** | Criar pedidos, acompanhar solicitacoes e controlar o ciclo da jornada |

O backend atual do app e o **Supabase**, usando Supabase Auth, tabelas PostgreSQL, RPCs e queries diretas pelo cliente Dart.

## Arquitetura

```text
Flutter
  -> Views
  -> Providers
  -> Services
  -> Supabase Auth / PostgreSQL / RPC
```

### Stack

| Camada | Tecnologia |
|---|---|
| App | Flutter / Dart |
| Estado | Provider |
| Navegacao | GoRouter |
| Backend | Supabase |
| Autenticacao | Supabase Auth |
| Banco de dados | PostgreSQL via Supabase |
| Variaveis de ambiente | flutter_dotenv |
| Graficos | fl_chart |
| Internacionalizacao de datas | intl |

## Funcionalidades

### Autenticacao e empresa

- Login com e-mail e senha via Supabase Auth.
- Cadastro inicial de empresa em `/cadastro_empresa`.
- Identificacao de perfil por empresa administradora ou tabela `usuarios`.
- Redirecionamento por perfil:
  - `diretoria` -> `/direcao/home`
  - `rh` -> `/rh/fila_pedidos`
  - `gerente` -> `/manager/gerente`
- Logout via Supabase Auth.

### Diretoria

- Tela inicial com dados da empresa.
- Cadastro e remocao de usuarios da empresa.
- Perfis de usuario: `diretoria`, `rh` e `gerente`.
- Relatorios com KPIs, filtros por periodo e abas de analise.
- Consultas por pedidos, loja, funcao, custos e evolucao mensal.

### RH

- Cadastro de funcoes com valor/hora.
- Cadastro de colaboradores/freelancers com CPF, telefone, e-mail, chave Pix e funcoes.
- Fila de pedidos pendentes.
- Escalacao de pessoas em pedidos.
- Finalizacao da escalacao, alterando o pedido para `escalado`.

### Gerente

- Listagem dos pedidos da empresa.
- Criacao de novo pedido por loja, funcao, periodo e quantidade.
- Visualizacao da jornada/detalhes do pedido.
- Acoes por status:
  - `solicitado` -> cancelar
  - `escalado` -> aprovar ou recusar
  - `aprovado` -> confirmar inicio
  - `em_andamento` -> finalizar

### Pagamentos e horas

- Servico para registrar entrada e saida real.
- Calculo de horas trabalhadas e valor total.
- Upsert em `pagamentos`.
- Marcacao de pagamentos como `fechado` ou `pago`.

## Status dos modulos

| Modulo | Status |
|---|---|
| Autenticacao | Implementado |
| Cadastro de empresa | Implementado |
| Diretoria - usuarios | Implementado |
| Diretoria - relatorios | Implementado |
| RH - funcoes | Implementado |
| RH - colaboradores | Implementado |
| RH - escalacao | Implementado |
| Gerente - pedidos | Implementado |
| Gerente - jornada/status | Implementado |
| Pagamentos/horas | Servico implementado; depende do fluxo de tela e schema |

## Como Rodar

### Pre-requisitos

- Flutter instalado.
- Um projeto Supabase configurado.
- Arquivo `.env` na raiz do projeto com as chaves do Supabase.

### Variaveis de ambiente

Crie um arquivo `.env` na raiz:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon
```

O arquivo `.env` esta registrado como asset no `pubspec.yaml`.

### Instalar dependencias

```bash
flutter pub get
```

### Executar o app

```bash
flutter run
```

### Verificar analise estatica

```bash
flutter analyze
```

## Rotas Principais

| Rota | Tela |
|---|---|
| `/` | Splash |
| `/login` | Login |
| `/cadastro_empresa` | Cadastro de empresa |
| `/direcao/home` | Home da diretoria |
| `/direcao/relatorios` | Relatorios |
| `/manager/gerente` | Pedidos do gerente |
| `/manager/new_request` | Novo pedido |
| `/manager/jornada_view/:pedidoId` | Detalhes da jornada |
| `/rh/fila_pedidos` | Fila de pedidos do RH |
| `/rh/escala_pedidos/:id` | Escalacao |
| `/rh/cadastros/cadastro_funcoes` | Cadastro de funcoes |
| `/rh/cadastros/cadastro_colaboradores` | Cadastro de colaboradores |

## Estrutura do Projeto

```text
lib/
  main.dart
  helpers/
    datetime_helper.dart
  models/
    empresa_model.dart
    freelancer_escalado_model.dart
    funcao_model.dart
    pagamento_model.dart
    pedido_model.dart
    pessoa_model.dart
    pessoa_no_pedido.dart
    unitystore.dart
    usuario_model.dart
  providers/
    auth_provider.dart
    escalacao_provider.dart
    funcao_provider.dart
    loja_provider.dart
    pedido_provider.dart
    pessoa_funcao_provider.dart
    pessoa_provider.dart
    usuario_provider.dart
  services/
    escalacao_service.dart
    pagamento_service.dart
    relatorio_service.dart
    status_service.dart
    supabase_client.dart
    supabase_service.dart
  theme/
    app_theme.dart
  views/
    cadastro_empresa_view.dart
    login_view.dart
    relatorios_view.dart
    splash_view.dart
    direcao/
      diretoria_home_view.dart
    manager/
      jornada_view.dart
      new_request_view.dart
      requests_view.dart
    rh/
      escalacao_view.dart
      fila_pedidos_view.dart
      cadastros/
        colaboradores_view.dart
        funcoes_view.dart
```

## Entidades e Tabelas Esperadas

O app consulta ou atualiza as seguintes tabelas/relacionamentos no Supabase:

| Tabela/RPC | Uso |
|---|---|
| `empresas` | Dados da empresa administradora |
| `usuarios` | Usuarios vinculados a empresa e seus perfis |
| `lojas` | Lojas disponiveis para pedidos |
| `funcoes` | Funcoes e valores por hora |
| `pessoas` | Colaboradores/freelancers |
| `pessoa_funcao` | Relacao entre pessoas e funcoes |
| `pedidos` | Solicitacoes de mao de obra |
| `pedido_escalacao` | Pessoas escaladas e jornada real |
| `pagamentos` | Horas, valores e status de pagamento |
| `cadastrar_empresa` | RPC usada no cadastro inicial da empresa |
| `criar_usuario` | RPC usada para criar usuario da empresa |

## Status de Pedido

```text
solicitado
escalado
aprovado
recusado
em_andamento
finalizado
cancelado
```

## Tema

O app usa um tema escuro centralizado em `lib/theme/app_theme.dart`, com cores em `AppColors` para background, cards, acentos, texto, bordas, sucesso e perigo.

## Autor

Desenvolvido por **Juliano** - 2026
