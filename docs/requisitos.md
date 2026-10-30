# Requisitos de Software — Dropod

> Plataforma de automação de vendas no WhatsApp com pagamento via PIX e logística automatizada pelo Uber Flash.

**Versão:** 1.0  
**Data:** Outubro de 2026  
**Status:** Em revisão

---

## 1. Atendimento e Bot no WhatsApp

|ID|Descrição|
|---|---|
|RF01|O sistema deve cumprimentar o cliente, reconhecer clientes recorrentes e apresentar o menu principal ao receber a primeira mensagem no WhatsApp. (MH)|
|RF02|O sistema deve apresentar catálogo com produtos ativos, descrições, preços e disponibilidades atualizados em tempo real, ocultando itens sem estoque. (MH)|
|RF03|O sistema deve permitir que o cliente adicione, remova e altere quantidades do carrinho, confirmando o resumo a cada alteração. (MH)|
|RF04|O sistema deve impedir a seleção de quantidades superiores ao estoque disponível e informar o limite máximo ao cliente. (MH)|
|RF05|O sistema deve tratar mensagens fora do fluxo orientando o cliente e oferecendo o menu ou atendimento humano após tentativas consecutivas. (SH)|
|RF06|O sistema deve permitir a transferência da conversa para um atendente humano a qualquer momento, pausando a automação. (SH)|

---

## 2. Coleta e Validação de Endereço

|ID|Descrição|
|---|---|
|RF07|O sistema deve solicitar o endereço completo de entrega e aceitar o compartilhamento de localização do WhatsApp como apoio. (MH)|
|RF08|O sistema deve geocodificar e validar o endereço, solicitar confirmação explícita do cliente e rejeitar endereços fora da área de cobertura. (MH)|
|RF09|O sistema deve coletar o nome e telefone do destinatário antes de realizar a cotação da entrega. (MH)|

---

## 3. Cotação de Frete e Reserva do Pedido

|ID|Descrição|
|---|---|
|RF10|O sistema deve solicitar a cotação de frete à API do Uber Direct com base nos endereços de origem e destino e armazenar id, valor e validade. (MH)|
|RF11|O sistema deve calcular o total do pedido (produtos + frete cotado + margem de segurança) e exibir os valores discriminados. (MH)|
|RF12|O sistema deve criar o pedido com status `AGUARDANDO_PAGAMENTO` e tempo limite de validade alinhado à cotação (padrão 5 minutos). (MH)|
|RF13|O sistema deve realizar a reserva temporária do estoque dos produtos pelo mesmo prazo de validade da cotação. (MH)|
|RF14|O sistema deve permitir a reabertura de pedido expirado, realizando nova cotação de frete e atualizando a reserva de estoque e o total. (MH)|
|RF15|O sistema deve informar o cliente caso a Uber não retorne cotação de entrega (fora de área/sem cobertura) e oferecer alternativas. (MH)|

---

## 4. Pagamento via PIX e Webhooks

|ID|Descrição|
|---|---|
|RF16|O sistema deve gerar cobrança PIX dinâmica no gateway com valor exato, identificador único (txid) e tempo de expiração vinculado ao pedido. (MH)|
|RF17|O sistema deve enviar ao cliente o código PIX Copia e Cola, a imagem do QR Code, o valor e o horário limite de pagamento. (MH)|
|RF18|O sistema deve enviar um lembrete de expiração de pagamento próximo ao fim do prazo caso o PIX permaneça pendente. (SH)|
|RF19|O sistema deve disponibilizar endpoint seguro para recebimento de Webhooks do gateway de pagamento, validando autenticidade e enfileirando o evento. (MH)|
|RF20|O sistema deve garantir idempotência no processamento de notificações de pagamento, impedindo cobranças ou despachos duplicados. (MH)|
|RF21|O sistema deve validar se o valor e o identificador do PIX pago correspondem exatamente ao pedido esperado. (MH)|
|RF22|O sistema deve executar rotina de reconciliação ativa (consulta periódica ao gateway) para recuperar pagamentos cujos Webhooks falharam. (SH)|
|RF23|O sistema deve expirar o pedido, cancelar a cobrança no gateway e liberar a reserva de estoque ao fim do prazo sem confirmação de pagamento. (MH)|
|RF24|O sistema deve permitir a execução de estornos totais ou parciais via API do gateway, registrando comprovante e notificando o cliente. (MH)|
|RF25|O sistema deve permitir a geração de PIX complementar vinculado ao pedido original para os casos de ajuste ou flutuação do valor do frete. (SH)|

---

## 5. Integração Uber Flash (Uber Direct)

|ID|Descrição|
|---|---|
|RF26|O sistema deve solicitar automaticamente a entrega no Uber Direct assim que o Webhook confirmar o recebimento do PIX. (MH)|
|RF27|O sistema deve realizar a reconferência pré-despacho de estoque e do valor do frete imediatamente antes de acionar a API da Uber. (MH)|
|RF28|O sistema deve processar Webhooks de status da Uber (designado, coletado, em rota, entregue, cancelado) e atualizar a linha do tempo do pedido. (MH)|
|RF29|O sistema deve realizar retentativas automáticas de solicitação de entrega em caso de falha inicial de conexão ou ausência momentânea de entregadores. (MH)|
|RF30|O sistema deve permitir o cancelamento manual da corrida de entrega pelo painel quando permitido pela Uber. (SH)|
|RF31|O sistema deve registrar ocorrências e acionar o cliente e o lojista em casos de falha na entrega, endereço não localizado ou devolução. (SH)|

---

## 6. Notificações, Rastreamento e Pós-Venda

|ID|Descrição|
|---|---|
|RF32|O sistema deve enviar o link de rastreamento em tempo real e o código/PIN de verificação ao cliente no WhatsApp após o despacho da corrida. (MH)|
|RF33|O sistema deve enviar notificações automáticas de mudança de status da entrega (coletado, a caminho, entregue). (SH)|
|RF34|O sistema deve alterar o status para `CONCLUIDO` ao receber a confirmação de entregue e enviar mensagem de encerramento. (MH)|
|RF35|O sistema deve permitir que o cliente consulte o status atual do pedido e o link de rastreio digitando "meu pedido". (SH)|
|RF36|O sistema deve permitir que o cliente abra chamados ou ocorrências pós-entrega sobre o pedido. (CH)|

---

## 7. Painel Administrativo do Lojista

|ID|Descrição|
|---|---|
|RF37|O sistema deve exigir autenticação segura e controle de acesso por perfil (administrador e operador) para acesso ao painel web. (MH)|
|RF38|O sistema deve permitir a gestão de catálogo e estoque (cadastro, edição, desativação, preços, fotos e quantidades). (MH)|
|RF39|O sistema deve exibir a listagem de pedidos com filtros e histórico em linha do tempo (atendimento, cotação, PIX, entrega). (MH)|
|RF40|O sistema deve permitir a configuração de parâmetros operacionais (tempo de validade do pedido, margem de segurança, tolerância de absorção e horários). (MH)|
|RF41|O sistema deve exibir relatórios financeiros e de conciliação (PIX recebidos, fretes pagos à Uber, margens retidas, custos absorvidos e estornos). (SH)|
|RF42|O sistema deve emitir alertas operacionais sobre falhas de integração, pagamentos sem entrega, divergências de valor ou estornos pendentes. (SH)|
|RF43|O sistema deve manter registro imutável de auditoria de eventos operacionais e financeiros. (SH)|

---

## Requisitos Não Funcionais

|ID|Descrição|
|---|---|
|RNF01|O endpoint de recebimento de Webhook deve validar, gravar e responder ao gateway em no máximo 1 segundo. (MH)|
|RNF02|O tempo decorrido do recebimento do Webhook de pagamento até o envio da solicitação de entrega à Uber deve ser inferior a 10 segundos (p95). (SH)|
|RNF03|As respostas automáticas do bot no WhatsApp devem ser entregues em até 3 segundos (p95). (SH)|
|RNF04|O sistema deve suportar no mínimo 100 conversas simultâneas e 20 pedidos por minuto com arquitetura escalável horizontalmente. (CH)|
|RNF05|O sistema deve manter disponibilidade mínima de 99,5% no backend e 99,9% no endpoint de Webhook. (SH)|
|RNF06|O sistema deve garantir que nenhum evento de pagamento seja perdido, persistindo dados em banco antes do reconhecimento (ACK). (MH)|
|RNF07|Todas as operações com impacto financeiro ou logístico (criação de PIX, estorno, solicitação de corrida) devem ser estritamente idempotentes. (MH)|
|RNF08|O sistema deve utilizar mensageria/filas com retentativa exponencial e Dead Letter Queue (DLQ) monitorada. (MH)|
|RNF09|O sistema deve possuir política de backup automático com RTO de no máximo 30 minutos e RPO de no máximo 5 minutos. (SH)|
|RNF10|As mensagens críticas do WhatsApp (PIX, código de entrega e link de rastreio) devem ser enfileiradas com prioridade alta. (SH)|
|RNF11|O sistema deve aplicar circuit breaker, timeouts curtos e retentativas controladas para todas as integrações de APIs externas. (MH)|
|RNF12|O sistema deve entrar em modo degradado em caso de indisponibilidade da API da Uber, interrompendo novas cotações e preservando pedidos já pagos. (MH)|
|RNF13|Toda comunicação externa e interna deve ser realizada exclusivamente via HTTPS/TLS. (MH)|
|RNF14|Segredos e chaves de API devem ser armazenados em cofre de segredos com rotação periódica. (MH)|
|RNF15|O sistema deve estar em conformidade com a LGPD (minimização de dados, mascaramento em logs e exclusão a pedido). (MH)|
|RNF16|O painel administrativo deve ter controle de acesso baseado em perfis, proteção contra força bruta e auditoria de acessos. (MH)|
|RNF17|O sistema deve aplicar limitação de taxa (rate limiting) por número de telefone para evitar abuso e spam na geração de PIX. (SH)|
|RNF18|Logs do sistema devem ser estruturados e conter ID de correlação único em toda a cadeia de execução (pedido, txid, id da corrida). (MH)|
|RNF19|As configurações operacionais (prazos, margens, tolerâncias) devem ser externalizadas e alteráveis em tempo de execução sem novo deploy. (MH)|