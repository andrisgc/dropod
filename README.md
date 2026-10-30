<div align="center">
  <img src="docs/assets/concept-2-capsule-cut/svg/dropod-c2-lockup-white-transparent.svg" alt="Dropod" height="100" />
  <br/>
  <br/>

  [![Status](https://img.shields.io/badge/status-in%20development-yellow?style=flat-square&labelColor=1a1a1a)](.)
  [![License](https://img.shields.io/badge/license-BSL%201.1-blue?style=flat-square&labelColor=1a1a1a)](LICENSE)
  [![Java](https://img.shields.io/badge/Java-21-orange?style=flat-square&labelColor=1a1a1a&logo=openjdk&logoColor=white)](https://openjdk.org/projects/jdk/21/)
  [![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?style=flat-square&labelColor=1a1a1a&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&labelColor=1a1a1a&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
  [![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&labelColor=1a1a1a&logo=react&logoColor=black)](https://react.dev/)

</div>

---

O **Dropod** é uma plataforma SaaS de automação comercial e logística que conecta o atendimento no WhatsApp à liquidação instantânea por PIX e ao despacho automático de corridas pelo **Uber Flash (Uber Direct)**. O sistema elimina o trabalho operacional do lojista, gerenciando desde a cotação dinâmica com trava de preço até o envio do PIN e rastreamento em tempo real para o cliente final.

> Desenvolvido para comércios locais e lojistas que realizam vendas diretas pelas redes sociais e perdem tempo precioso cotando fretes, conferindo comprovantes e solicitando entregadores manualmente.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [API Reference](#api-reference)
- [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [License](#license)

---

## Overview

### O problema

Lojistas que vendem diretamente pelo WhatsApp enfrentam gargalos operacionais constantes que reduzem a conversão e geram prejuízos:

- **Atrito no atendimento:** Demora para responder cotações e apresentar o catálogo de produtos atualizado.
- **Flutuação de tarifa da Uber:** Riscos de variação do valor do frete entre o momento do orçamento e o despacho da entrega.
- **Conferência manual de pagamentos:** Ineficiência no recebimento e validação de comprovantes de PIX.
- **Logística descentralizada:** Necessidade de digitar manualmente endereços e dados do destinatário no aplicativo de entregas.
- **Falta de visibilidade do cliente:** Ausência de acompanhamento transparente do pedido e do link de rastreamento do entregador.

### O que o Dropod faz

- **Atendimento Guia & Catálogo:** Apresenta catálogo e estoque em tempo real diretamente na conversa do WhatsApp.
- **Cotação Dinâmica com Trava de Preço:** Calcula frete via Uber Direct + margem de segurança configurável e gera pedido com tempo de expiração estrito (5 a 10 minutos).
- **Cobrança PIX Automática:** Gera PIX dinâmico (Copia e Cola + QR Code) sincronizado com a validade do pedido e processa confirmações via Webhooks assíncronos.
- **Despacho Automático:** Solicita o motorista no Uber Flash em até 10 segundos após a confirmação do pagamento.
- **Acompanhamento Transparente:** Envia PIN de confirmação de entrega e link de rastreamento ao cliente em tempo real.
- **Gestão de Exceções:** Trata casos de pagamento atrasado, estouro de tolerância de frete, PIX complementar e estornos automáticos com total rastreabilidade.

---

## Architecture

O backend do Dropod adota a **Clean Architecture** combinada com **Domain-Driven Design (DDD)** e **Event-Driven Architecture (EDA)**. A troca de estado da aplicação é desacoplada através de mensagens e filas com o padrão **Outbox Transacional**, garantindo resiliência e idempotência no processamento de Webhooks financeiros e logísticos.

```
┌────────────────────────────────────────────────────────┐
│                      interfaces/                       │  REST Controllers, Webhooks, DTOs
│  ┌──────────────────────────────────────────────────┐  │
│  │                  application/                    │  │  Use Cases, Sagas, Ports (In/Out)
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │                  domain/                   │  │  │  Entities, Value Objects, Domain Rules
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                     infrastructure/                    │  JPA, Webhooks, RabbitMQ, Uber/PIX/WhatsApp Clients
└────────────────────────────────────────────────────────┘
```

### Máquina de Estados do Pedido

`CARRINHO` ➔ `AGUARDANDO_PAGAMENTO` ➔ `PAGO` ➔ `DESPACHANDO` ➔ `EM_ENTREGA` ➔ `CONCLUIDO`  
*(Estados de Exceção: `EXPIRADO`, `PAGO_PENDENTE_DECISAO`, `FALHA_ENTREGA`, `ESTORNADO`)*

Decisões de arquitetura e Registros de Decisão Arquitetural serão mantidos em [`docs/adr/`](docs/adr/).

---

## Tech Stack

| Layer | Technology | Reason                                                           |
|-------|-----------|------------------------------------------------------------------|
| Language | Java 21 | LTS, Virtual Threads para alta concorrência, Records             |
| Build Tool | Apache Maven | Gerenciamento de dependências padronizado e reprodutível         |
| Framework | Spring Boot 3.x | Ecossistema maduro, Spring Security, Spring Data JPA             |
| Security | Spring Security + JWT | Autenticação stateless no painel e validação de Webhooks         |
| Database | PostgreSQL 16 | ACID, suporte a JSONB para auditoria de payloads                 |
| Cache & Lock | Redis | Distributed Lock (Redlock), controle de taxa e cache de catálogo |
| Messaging | RabbitMQ | Filas duráveis para Webhooks, DLQ, retentativas e eventos        |
| Frontend | React 18 + TypeScript + Vite | Tipagem forte, builds rápidos e alta performance                 |
| UI Componentry | TailwindCSS / shadcn/ui | Interface limpa e minimalista para o painel do lojista           |
| WhatsApp API | WhatsApp Cloud API (Meta) | API Oficial com botões, listas e webhooks estáveis               |
| Logistics API | Uber Direct API | Cotação dinâmica e despacho automatizado do Uber Flash           |
| Payment API | Efí Bank / Asaas / Mercado Pago | Pix dinâmico com Webhook e suporte a estornos via API            |
| Testing | JUnit 5 + Mockito + Testcontainers | Cobertura unitária e de integração com containers reais          |
| Infra | Docker + Railway → AWS | Início simples, caminho de migração claro |


---

## API Reference

Documentação da API REST interativa disponível via Swagger UI no ambiente de desenvolvimento:
`http://localhost:8080/swagger-ui.html`

Endpoints Principais:

```text
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh

GET    /api/v1/produtos
POST   /api/v1/produtos
PUT    /api/v1/produtos/{id}
GET    /api/v1/configuracoes
PUT    /api/v1/configuracoes

GET    /api/v1/pedidos
GET    /api/v1/pedidos/{id}
POST   /api/v1/pedidos/{id}/estorno
GET    /api/v1/relatorios/financeiro

POST   /api/v1/webhooks/whatsapp
POST   /api/v1/webhooks/pix/{provedor}
POST   /api/v1/webhooks/uber
```

---

## Project Structure

```text
dropod/
├── dropod-api/                        # Backend Spring Boot (Java 21)
|   ├── pom.xml
│   ├── mvnw
│   ├── mvnw.cmd
│   └── src/main/java/br/com/dropod/
│       ├── domain/                  # Entidades, Value Objects e Regras de Negócio
│       │   ├── model/               # Pedido, Produto, Cotacao, Pagamento...
│       │   ├── valueobject/         # Endereco, Cnpj, Telefone, Money...
│       │   └── repository/          # Interfaces de Repositório
│       ├── application/             # Casos de Uso, Sagas e Portas
│       │   ├── usecase/             # ProcessarPagamentoUseCase, DespacharEntregaUseCase...
│       │   └── port/                # Inbound/Outbound Ports
│       ├── infrastructure/          # Adaptadores Técnicos e Integrações
│       │   ├── persistence/         # Repositórios JPA e Mapeadores
│       │   ├── messaging/           # Consumers e Publishers RabbitMQ
│       │   ├── pix/                 # Integrador Gateway PIX
│       │   ├── uber/                # Integrador Uber Direct API
│       │   └── whatsapp/            # Client WhatsApp Cloud API
│       └── interfaces/              # Controladores REST e Webhooks
│           ├── rest/                # Controllers Admin
│           ├── webhook/             # Endpoints de recepção de Webhooks
│           └── dto/                 # Data Transfer Objects
├── dropod-web/                        # Frontend React + TypeScript (Painel Lojista)
│   └── src/
│       ├── components/              # UI Components
│       ├── pages/                   # Pedidos, Catálogo, Configurações, Relatórios
│       ├── hooks/                   # Custom Hooks / TanStack Query
│       └── services/                # Clients API REST
├── docs/                            # Documentação do Projeto
│   ├── adr/                         # Architecture Decision Records
│   └── uml/                         # Diagramas de Sequência e Atividades
├── docker-compose.yml               # Postgres, Redis e RabbitMQ locais
├── .env.example
└── README.md
```

---

## Roadmap

### v1.0 — MVP Core
- [ ] Bot interativo no WhatsApp para seleção de produtos e carrinho
- [ ] Validação e geocodificação de endereço
- [ ] Cotação dinâmica Uber Direct com margem de segurança configurável
- [ ] Geração de PIX dinâmico com tempo de expiração vinculado ao pedido
- [ ] Endpoint de Webhook assíncrono para confirmação de PIX
- [ ] Despacho automático da corrida no Uber Flash
- [ ] Envio de PIN e link de rastreamento em tempo real para o cliente
- [ ] Painel Administrativo para gestão de produtos, estoque, pedidos e configurações de margem

### v1.1.0 — Gestão Avançada de Exceções & Tolerância
- [ ] Tratamento automatizado de pagamentos atrasados (fora do prazo)
- [ ] Geração de PIX complementar para diferenças de frete
- [ ] Módulo de estorno automático e manual via API do gateway
- [ ] Painel financeiro de conciliação (PIX recebidos vs. Fretes pagos à Uber)

### v1.2.0 — Resiliência & Reconciliação
- [ ] Job de reconciliação ativa para recuperação de Webhooks perdidos
- [ ] Dashboard com alertas operacionais e métricas de desempenho
- [ ] Suporte a atendimento humano com pausa automática da automação

### v2.0.0 — Escala & Multi-tenant (SaaS)
- [ ] Arquitetura multi-tenant para atendimento a múltiplos lojistas
- [ ] Suporte a múltiplos gateways de pagamento e transportadoras alternativas
- [ ] Aplicativo mobile em React Native para acompanhamento em tempo real pelo lojista

---

## License

Distributed under the [Business Source License 1.1](LICENSE).  
Commercial use requires explicit permission from the author.  
See `LICENSE` for the full terms.

---