# Backlog — dropod

> Plataforma de automação de vendas no WhatsApp com pagamento via PIX e logística automatizada pelo Uber Flash.

**Versão:** 1.0  
**Data:** Outubro de 2026  
**Metodologia:** Kanban  
**Status:** Em refinamento

---

## Fase 1 — Atendimento e Catálogo no WhatsApp

> Objetivo: o cliente consegue interagir com o bot no WhatsApp, visualizar os produtos disponíveis e montar seu carrinho de compras.

| ID | Nome | Tipo de Requisito | Prioridade | Descrição | US |
| --- | --- | --- | --- | --- | --- |
| RF01 | Início de conversa | Funcional | Must | O sistema deve cumprimentar o cliente, reconhecer clientes recorrentes e apresentar o menu principal ao receber a primeira mensagem no WhatsApp. | US01 |
| RF02 | Catálogo em tempo real | Funcional | Must | O sistema deve apresentar catálogo com produtos ativos, descrições, preços e disponibilidades atualizados em tempo real, ocultando itens sem estoque. | US02 |
| RF03 | Seleção e carrinho | Funcional | Must | O sistema deve permitir que o cliente adicione, remova e altere quantidades do carrinho, confirmando o resumo a cada alteração. | US03 |
| RF04 | Limites de quantidade | Funcional | Must | O sistema deve impedir a seleção de quantidades superiores ao estoque disponível e informar o limite máximo ao cliente. | US03 |
| RF05 | Mensagens fora do fluxo | Funcional | Should | O sistema deve tratar mensagens fora do fluxo orientando o cliente e oferecendo o menu ou atendimento humano após tentativas consecutivas. | US01 |
| RF06 | Transfêrencia para atendente | Funcional | Should | O sistema deve permitir a transferência da conversa para um atendente humano a qualquer momento, pausando a automação. | US04 |
| RNF13 | Comunicação HTTPS | Não Funcional | Must | Toda comunicação externa e interna deve ser realizada exclusivamente via HTTPS/TLS. | — |
| RNF17 | Proteção contra spam/abuse | Não Funcional | Should | O sistema deve aplicar limitação de taxa (rate limiting) por número de telefone para evitar abuso e spam na geração de PIX. | — |

---

## Fase 2 — Coleta de Endereço, Cotação e Reserva

> Objetivo: o cliente informa o endereço validado, o sistema calcula o frete via Uber Direct com margem de segurança e reserva o estoque temporariamente.

| ID | Nome | Tipo de Requisito | Prioridade | Descrição | US |
| --- | --- | --- | --- | --- | --- |
| RF07 | Coleta de endereço | Funcional | Must | O sistema deve solicitar o endereço completo de entrega e aceitar o compartilhamento de localização do WhatsApp como apoio. | US05 |
| RF08 | Validação de endereço | Funcional | Must | O sistema deve geocodificar e validar o endereço, solicitar confirmação explícita do cliente e rejeitar endereços fora da área de cobertura. | US05 |
| RF09 | Dados do destinatário | Funcional | Must | O sistema deve coletar o nome e telefone do destinatário antes de realizar a cotação da entrega. | US05 |
| RF10 | Cotação Uber Direct | Funcional | Must | O sistema deve solicitar a cotação de frete à API do Uber Direct com base nos endereços de origem e destino e armazenar id, valor e validade. | US06 |
| RF11 | Cálculo do total | Funcional | Must | O sistema deve calcular o total do pedido (produtos + frete cotado + margem de segurança) e exibir os valores discriminados. | US06 |
| RF12 | Tempo limite do pedido | Funcional | Must | O sistema deve criar o pedido com status `AGUARDANDO_PAGAMENTO` e tempo limite de validade alinhado à cotação (padrão 5 minutos). | US07 |
| RF13 | Reserva de estoque | Funcional | Must | O sistema deve realizar a reserva temporária do estoque dos produtos pelo mesmo prazo de validade da cotação. | US07 |
| RF14 | Reabertura por expiração | Funcional | Must | O sistema deve permitir a reabertura de pedido expirado, realizando nova cotação de frete e atualizando a reserva de estoque e o total. | US08 |
| RF15 | Indisponibilidade de entrega | Funcional | Must | O sistema deve informar o cliente caso a Uber não retorne cotação de entrega (fora de área/sem cobertura) e oferecer alternativas. | US06 |
| RNF03 | Tempo de resposta do bot | Não Funcional | Should | As respostas automáticas do bot no WhatsApp devem ser entregues em até 3 segundos (p95). | — |
| RNF19 | Parametrização externalizada | Não Funcional | Must | As configurações operacionais (prazos, margens, tolerâncias) devem ser externalizadas e alteráveis em tempo de execução sem novo deploy. | — |

---

## Fase 3 — Pagamento PIX e Webhooks (Core Financeiro)

> Objetivo: o cliente recebe a chave PIX, paga no app bancário e o sistema valida a notificação de forma assíncrona, idempotente e segura.

| ID | Nome | Tipo de Requisito | Prioridade | Descrição | US |
| --- | --- | --- | --- | --- | --- |
| RF16 | Geração de PIX dinâmico | Funcional | Must | O sistema deve gerar cobrança PIX dinâmica no gateway com valor exato, identificador único (txid) e tempo de expiração vinculado ao pedido. | US09 |
| RF17 | Envio do PIX | Funcional | Must | O sistema deve enviar ao cliente o código PIX Copia e Cola, a imagem do QR Code, o valor e o horário limite de pagamento. | US09 |
| RF18 | Lembrete de expiração | Funcional | Should | O sistema deve enviar um lembrete de expiração de pagamento próximo ao fim do prazo caso o PIX permaneça pendente. | US09 |
| RF19 | Recebimento de Webhook | Funcional | Must | O sistema deve disponibilizar endpoint seguro para recebimento de Webhooks do gateway de pagamento, validando autenticidade e enfileirando o evento. | US10 |
| RF20 | Idempotência de pagamento | Funcional | Must | O sistema deve garantir idempotência no processamento de notificações de pagamento, impedindo cobranças ou despachos duplicados. | US10 |
| RF21 | Conferência do valor | Funcional | Must | O sistema deve validar se o valor e o identificador do PIX pago correspondem exatamente ao pedido esperado. | US11 |
| RF22 | Reconciliação ativa | Funcional | Should | O sistema deve executar rotina de reconciliação ativa (consulta periódica ao gateway) para recuperar pagamentos cujos Webhooks falharam. | US11 |
| RF23 | Expiração de cobrança | Funcional | Must | O sistema deve expirar o pedido, cancelar a cobrança no gateway e liberar a reserva de estoque ao fim do prazo sem confirmação de pagamento. | US12 |
| RF24 | Estornos automatizados | Funcional | Must | O sistema deve permitir a execução de estornos totais ou parciais via API do gateway, registrando comprovante e notificando o cliente. | US13 |
| RF25 | Cobrança complementar | Funcional | Should | O sistema deve permitir a geração de PIX complementar vinculado ao pedido original para os casos de ajuste ou flutuação do valor do frete. | US13 |
| RNF01 | Resposta rápida do Webhook | Não Funcional | Must | O endpoint de recebimento de Webhook deve validar, gravar e responder ao gateway em no máximo 1 segundo. | — |
| RNF06 | Persistência do evento | Não Funcional | Must | O sistema deve garantir que nenhum evento de pagamento seja perdido, persistindo dados em banco antes do reconhecimento (ACK). | — |
| RNF07 | Idempotência técnica | Não Funcional | Must | Todas as operações com impacto financeiro ou logístico (criação de PIX, estorno, solicitação de corrida) devem ser estritamente idempotentes. | — |
| RNF08 | Mensageria e DLQ | Não Funcional | Must | O sistema deve utilizar mensageria/filas com retentativa exponencial e Dead Letter Queue (DLQ) monitorada. | — |
| RNF14 | Cofre de segredos | Não Funcional | Must | Segredos e chaves de API devem ser armazenados em cofre de segredos com rotação periódica. | — |

---

## Fase 4 — Integração Uber Flash e Despacho Logístico (Core Logístico)

> Objetivo: assim que o pagamento é confirmado, a corrida é solicitada automaticamente no Uber Direct com tratamento resiliente a falhas e flutuação de frete.

| ID | Nome | Tipo de Requisito | Prioridade | Descrição | US |
| --- | --- | --- | --- | --- | --- |
| RF26 | Criação automática da corrida | Funcional | Must | O sistema deve solicitar automaticamente a entrega no Uber Direct assim que o Webhook confirmar o recebimento do PIX. | US14 |
| RF27 | Reconferência pré-despacho | Funcional | Must | O sistema deve realizar a reconferência pré-despacho de estoque e do valor do frete imediatamente antes de acionar a API da Uber. | US14 |
| RF28 | Controle de status da entrega | Funcional | Must | O sistema deve processar Webhooks de status da Uber (designado, coletado, em rota, entregue, cancelado) e atualizar a linha do tempo do pedido. | US15 |
| RF29 | Retentativas automáticas | Funcional | Must | O sistema deve realizar retentativas automáticas de solicitação de entrega em caso de falha inicial de conexão ou ausência momentânea de entregadores. | US15 |
| RF30 | Cancelamento de corrida | Funcional | Should | O sistema deve permitir o cancelamento manual da corrida de entrega pelo painel quando permitido pela Uber. | US16 |
| RF31 | Tratamento de falha na entrega | Funcional | Should | O sistema deve registrar ocorrências e acionar o cliente e o lojista em casos de falha na entrega, endereço não localizado ou devolução. | US16 |
| RNF02 | Tempo do despacho | Não Funcional | Should | O tempo decorrido do recebimento do Webhook de pagamento até o envio da solicitação de entrega à Uber deve ser inferior a 10 segundos (p95). | — |
| RNF11 | Resiliência de APIs | Não Funcional | Must | O sistema deve aplicar circuit breaker, timeouts curtos e retentativas controladas para todas as integrações de APIs externas. | — |
| RNF12 | Modo degradado | Não Funcional | Must | O sistema deve entrar em modo degradado em caso de indisponibilidade da API da Uber, interrompendo novas cotações e preservando pedidos já pagos. | — |

---

## Fase 5 — Notificações, Rastreamento e Pós-Venda

> Objetivo: o cliente recebe o código/PIN de entrega e o link de rastreamento em tempo real no WhatsApp, com avisos de status até a conclusão.

| ID | Nome | Tipo de Requisito | Prioridade | Descrição | US |
| --- | --- | --- | --- | --- | --- |
| RF32 | Envio de PIN e rastreio | Funcional | Must | O sistema deve enviar o link de rastreamento em tempo real e o código/PIN de verificação ao cliente no WhatsApp após o despacho da corrida. | US17 |
| RF33 | Notificações de mudança de status | Funcional | Should | O sistema deve enviar notificações automáticas de mudança de status da entrega (coletado, a caminho, entregue). | US17 |
| RF34 | Conclusão do pedido | Funcional | Must | O sistema deve alterar o status para `CONCLUIDO` ao receber a confirmação de entregue e enviar mensagem de encerramento. | US18 |
| RF35 | Consulta de status ("meu pedido") | Funcional | Should | O sistema deve permitir que o cliente consulte o status atual do pedido e o link de rastreio digitando "meu pedido". | US18 |
| RF36 | Abertura de ocorrências | Funcional | Could | O sistema deve permitir que o cliente abra chamados ou ocorrências pós-entrega sobre o pedido. | US18 |
| RNF10 | Prioridade de mensagens críticas | Não Funcional | Should | As mensagens críticas do WhatsApp (PIX, código de entrega e link de rastreio) devem ser enfileiradas com prioridade alta. | — |

---

## Fase 6 — Painel Administrativo, Alertas e Conformidade

> Objetivo: o lojista gerencia produtos, estoque, configurações de frete/margem e visualiza relatórios financeiros com total segurança e auditoria.

| ID | Nome | Tipo de Requisito | Prioridade | Descrição | US |
| --- | --- | --- | --- | --- | --- |
| RF37 | Autenticação no painel | Funcional | Must | O sistema deve exigir autenticação segura e controle de acesso por perfil (administrador e operador) para acesso ao painel web. | US19 |
| RF38 | Gestão de catálogo e estoque | Funcional | Must | O sistema deve permitir a gestão de catálogo e estoque (cadastro, edição, desativação, preços, fotos e quantidades). | US20 |
| RF39 | Gestão e filtro de pedidos | Funcional | Must | O sistema deve exibir a listagem de pedidos com filtros e histórico em linha do tempo (atendimento, cotação, PIX, entrega). | US21 |
| RF40 | Configurações operacionais | Funcional | Must | O sistema deve permitir a configuração de parâmetros operacionais (tempo de validade do pedido, margem de segurança, tolerância de absorção e horários). | US22 |
| RF41 | Relatórios e conciliação | Funcional | Should | O sistema deve exibir relatórios financeiros e de conciliação (PIX recebidos, fretes pagos à Uber, margens retidas, custos absorvidos e estornos). | US23 |
| RF42 | Alertas operacionais | Funcional | Should | O sistema deve emitir alertas operacionais sobre falhas de integração, pagamentos sem entrega, divergências de valor ou estornos pendentes. | US24 |
| RF43 | Auditoria imutável | Funcional | Should | O sistema deve manter registro imutável de auditoria de eventos operacionais e financeiros. | US24 |
| RNF04 | Capacidade simultânea | Não Funcional | Could | O sistema deve suportar no mínimo 100 conversas simultâneas e 20 pedidos por minuto com arquitetura escalável horizontalmente. | — |
| RNF05 | Meta de disponibilidade | Não Funcional | Should | O sistema deve manter disponibilidade mínima de 99,5% no backend e 99,9% no endpoint de Webhook. | — |
| RNF09 | Políticas de backup | Não Funcional | Should | O sistema deve possuir política de backup automático com RTO de no máximo 30 minutos e RPO de no máximo 5 minutos. | — |
| RNF15 | Conformidade com LGPD | Não Funcional | Must | O sistema deve estar em conformidade com a LGPD (minimização de dados, mascaramento em logs e exclusão a pedido). | — |
| RNF16 | Segurança do painel | Não Funcional | Must | O painel administrativo deve ter controle de acesso baseado em perfis, proteção contra força bruta e auditoria de acessos. | — |
| RNF18 | Logs com ID de correlação | Não Funcional | Must | Logs do sistema devem ser estruturados e conter ID de correlação único em toda a cadeia de execução (pedido, txid, id da corrida). | — |

---

## User Stories

| ID | Descrição |
| --- | --- |
| US01 | Como cliente, quero ser recebido por um menu interativo no WhatsApp, para que eu possa iniciar minha compra de forma rápida sem atendimento humano. |
| US02 | Como cliente, quero visualizar o catálogo de produtos com fotos, preços e disponibilidade atualizados, para que eu saiba exatamente o que posso comprar. |
| US03 | Como cliente, quero adicionar e remover itens do meu carrinho de compras, para que eu possa montar meu pedido com as quantidades corretas. |
| US04 | Como cliente, quero solicitar a transferência da conversa para um atendente humano a qualquer momento, para tirar dúvidas que o bot não resolva. |
| US05 | Como cliente, quero informar e confirmar meu endereço completo de entrega no WhatsApp, para garantir que o pedido seja enviado ao local correto. |
| US06 | Como cliente, quero visualizar o valor discriminado dos produtos e do frete cotado, para que eu decida a compra com total transparência de custos. |
| US07 | Como lojista, quero que o estoque seja reservado temporariamente durante a janela de pagamento, para evitar vendas duplicadas do mesmo produto. |
| US08 | Como cliente, quero solicitar uma nova cotação quando meu pedido expirar, para que eu possa renovar os valores e finalizar a compra. |
| US09 | Como cliente, quero receber o código PIX Copia e Cola e o QR Code com o valor exato, para realizar o pagamento instantâneo no aplicativo do meu banco. |
| US10 | Como sistema, quero receber e processar as confirmações de pagamento via Webhook de forma assíncrona, para liberar o pedido imediatamente. |
| US11 | Como lojista, quero que o sistema valide o valor recebido e execute rotinas de reconciliação, para evitar despachos sem o pagamento correto. |
| US12 | Como lojista, quero que pedidos não pagos dentro do prazo expirem automaticamente, para liberar o estoque de volta ao catálogo. |
| US13 | Como cliente ou lojista, quero que estornos totais ou parciais de PIX sejam executados via API, para resolver divergências financeiras com agilidade. |
| US14 | Como lojista, quero que a solicitação de entrega no Uber Direct ocorra automaticamente após o pagamento, para agilizar o despacho sem trabalho manual. |
| US15 | Como sistema, quero processar os eventos de status da corrida da Uber, para manter o histórico e a linha do tempo do pedido atualizados. |
| US16 | Como lojista, quero ser alertado e poder gerenciar cancelamentos e falhas de entrega, para tomar decisões sobre reentrega ou devolução. |
| US17 | Como cliente, quero receber o código/PIN de entrega e o link de rastreamento em tempo real no WhatsApp, para acompanhar o entregador até a chegada. |
| US18 | Como cliente, quero consultar o status do meu pedido digitando "meu pedido" e receber a notificação de conclusão quando o produto for entregue. |
| US19 | Como lojista, quero me autenticar com segurança no painel administrativo web, para ter acesso restrito às funcionalidades da minha loja. |
| US20 | Como lojista, quero cadastrar, editar e gerenciar o estoque dos meus produtos no painel, para manter o catálogo do bot sempre atualizado. |
| US21 | Como lojista, quero visualizar a lista de pedidos com filtros e linha do tempo de eventos, para acompanhar a operação em tempo real. |
| US22 | Como lojista, quero parametrizar prazos de expiração, margens de frete e tolerâncias de absorção, para proteger a rentabilidade do meu negócio. |
| US23 | Como lojista, quero visualizar relatórios de vendas, fretes pagos e custos absorvidos, para realizar a conciliação financeira da loja. |
| US24 | Como lojista, quero receber alertas operacionais e ter uma trilha imutável de auditoria, para identificar falhas de integração e garantir a segurança. |

---

_Documento mantido em `/docs/backlog.md` — atualizar a cada nova entrega._