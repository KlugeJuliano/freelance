# 📋 Freelance Manager

Sistema mobile de gestão de freelancers para alocação em pedidos de lojas, desenvolvido em Flutter com backend Laravel.

---

## 🧩 Visão Geral

O **Freelance Manager** é uma plataforma que conecta três perfis de usuário — **RH**, **Gerente** e **Diretoria** — para gerenciar o ciclo completo de alocação de freelancers: desde o cadastro de colaboradores e funções, passando pela criação de pedidos de mão-de-obra, até a escalação, registro de horas e pagamento.

---

## 🏗️ Arquitetura

```
Mobile (Flutter)
    └── View
        └── Provider (estado e regras de apresentação)
            └── Service (chamadas HTTP via Dio)
                └── API REST (Laravel + PostgreSQL)
```

### Stack

| Camada | Tecnologia |
|---|---|
| Mobile | Flutter (Dart) |
| Gerenciamento de estado | Provider |
| Navegação | GoRouter |
| HTTP Client | Dio |
| Backend | Laravel 11 |
| Banco de dados | PostgreSQL 16 |
| Cache | Redis |
| Infraestrutura | Docker |

---

## 👥 Perfis de Usuário

| Perfil | Responsabilidades |
|---|---|
| **RH** | Cadastrar funções, cadastrar freelancers, escalar colaboradores nos pedidos |
| **Gerente** | Criar pedidos de mão-de-obra para sua loja |
| **Diretoria** | Visualizar relatórios consolidados de custos e alocações |

---

## 📱 Módulos

### ✅ Autenticação
- Login com e-mail e senha
- Controle de acesso por perfil (role-based)
- Logout com invalidação de token (Laravel Sanctum)

### ✅ RH — Cadastros
- Cadastro de funções com valor/hora
- Cadastro de freelancers com CPF, telefone, e-mail e chave Pix
- Vínculo de freelancers a múltiplas funções (N:N)
- Soft delete de freelancers (campo `ativo`) para preservar histórico

### ✅ RH — Escalação
- Fila de pedidos com status `solicitado`
- Filtro automático de freelancers compatíveis com a função do pedido
- Controle de vagas preenchidas vs. total solicitado
- Finalização da escalação com confirmação
- Remoção de escalados com confirmação

### 🔄 Gerente — Pedidos *(em desenvolvimento)*
- Criação de pedidos por loja, função, período e quantidade
- Visualização do histórico de pedidos

### ⏳ Pagamentos / Horas *(pendente)*
- Registro de entrada e saída real
- Cálculo de horas trabalhadas
- Geração de pagamentos com snapshot de valor/hora

### ⏳ Diretoria — Relatórios *(pendente)*
- Gastos por loja, função, gerente e freelancer
- Evolução de custos por período

---

## 🚀 Como rodar

### Pré-requisitos
- Docker e Docker Compose instalados

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd docker
```

### 2. Suba os containers

```bash
docker compose up -d
```

### 3. Execute as migrations

```bash
docker exec -it freelance-app php artisan migrate
```

### 4. Crie os usuários iniciais

```bash
docker exec -it freelance-app php artisan tinker
```

```php
$rh       = App\Models\Role::where('nome', 'rh')->first();
$gerente  = App\Models\Role::where('nome', 'gerente')->first();
$diretoria = App\Models\Role::where('nome', 'diretoria')->first();

App\Models\User::create(['nome' => 'RH',        'email' => 'rh@admin.com',        'password' => bcrypt('password'), 'role_id' => $rh->id]);
App\Models\User::create(['nome' => 'Gerente',   'email' => 'gerente@teste.com',   'password' => bcrypt('password'), 'role_id' => $gerente->id]);
App\Models\User::create(['nome' => 'Diretoria', 'email' => 'diretoria@teste.com', 'password' => bcrypt('password'), 'role_id' => $diretoria->id]);
```

### 5. Rode o app Flutter

```bash
cd app-flutter
flutter pub get
flutter run
```

---

## 🌐 Serviços

| Serviço | URL |
|---|---|
| API | http://localhost:8000 |
| pgAdmin | http://localhost:5050 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

**Credenciais pgAdmin:**
- E-mail: `admin@admin.com`
- Senha: `admin`

---

## 🗂️ Estrutura do projeto Flutter

```
lib/
├── main.dart                  # Rotas e providers globais
├── models/                    # Modelos de dados
│   ├── pedido_model.dart
│   ├── pessoa_model.dart
│   ├── funcao_model.dart
│   ├── pessoa_no_pedido.dart
│   └── colaborador_funcao_model.dart
├── providers/                 # Gerenciamento de estado
│   ├── auth_provider.dart
│   ├── pedido_provider.dart
│   ├── pessoa_provider.dart
│   ├── funcao_provider.dart
│   └── escalacao_provider.dart
├── services/                  # Comunicação com a API
│   ├── api_services.dart
│   └── escalacao_service.dart
└── views/                     # Telas
    ├── home_view.dart
    ├── rh/
    │   ├── fila_pedidos_view.dart
    │   ├── escalacao_view.dart
    │   └── cadastros/
    │       ├── funcoes_view.dart
    │       └── colaboradores_view.dart
    ├── manager/
    │   ├── requests_view.dart
    │   ├── new_request_view.dart
    │   └── jornada_view.dart
    └── direcao/
        └── relatorios_consolidados_view.dart
```

---

## 🔌 Endpoints principais da API

| Método | Rota | Descrição |
|---|---|---|
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/logout` | Logout |
| GET | `/api/freelancers` | Listar freelancers |
| POST | `/api/freelancers` | Cadastrar freelancer |
| PATCH | `/api/freelancers/{id}` | Atualizar (soft delete via `ativo: false`) |
| GET | `/api/funcoes` | Listar funções |
| POST | `/api/funcoes` | Cadastrar função |
| GET | `/api/pedidos` | Listar pedidos |
| POST | `/api/pedidos` | Criar pedido |
| GET | `/api/pedidos/{id}/escalacao` | Buscar escalados de um pedido |
| POST | `/api/pedidos/{id}/escalacao` | Escalar freelancer |
| DELETE | `/api/pedidos/{id}/escalacao/{freelancer}` | Remover escalado |
| POST | `/api/pedidos/{id}/escalacao/finalizar` | Finalizar escalação |
| POST | `/api/pedidos/{id}/horas` | Registrar horas |
| GET | `/api/relatorios/gastos-por-loja` | Relatório por loja |

---

## 🎨 Design System

Todas as telas seguem um tema escuro unificado:

| Token | Valor | Uso |
|---|---|---|
| `_dark` | `#0F1117` | Background principal |
| `_card` | `#1A1D27` | Cards e superfícies |
| `_accent` | `#00E5A0` | Ações, badges, progresso |
| `_danger` | `#FF4D6A` | Erros, remoção |
| `_textPrimary` | `#EEEEF5` | Texto principal |
| `_textMuted` | `#6B7280` | Texto secundário, labels |

---

## 📊 Status do projeto

| Módulo | Status | Progresso |
|---|---|---|
| Autenticação | ✅ Concluído | 100% |
| RH — Cadastros | ✅ Concluído | 90% |
| RH — Escalação | ✅ Concluído | 85% |
| Gerente — Pedidos | 🔄 Em desenvolvimento | 20% |
| Pagamentos / Horas | ⏳ Pendente | 5% |
| Diretoria — Relatórios | ⏳ Pendente | 10% |

**Progresso geral: ~45%**

---

## 👨‍💻 Autor

Desenvolvido por **Juliano** — 2026