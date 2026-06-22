# Play Console — Data Safety (pré-preenchido)

> Revisar com jurídico/negócio antes do envio final.

## Coleta/compartilhamento de dados

- Coleta dados pessoais? **Sim**
- Compartilha dados com terceiros? **Sim** (operadores essenciais)
- Dados criptografados em trânsito? **Sim**
- Permite solicitar exclusão de dados? **Sim** (ver `legal/exclusao-de-dados.md`)

## Tipos de dados (prováveis)

1. **Informações pessoais**
   - Nome, e-mail, telefone
   - Finalidade: funcionalidade do app e gestão da academia
2. **Atividade no app**
   - Presença, turmas, interações internas
   - Finalidade: recursos centrais da plataforma
3. **Informações financeiras**
   - Status de pagamento/mensalidade, pedidos
   - Finalidade: cobrança e gestão de compras
4. **IDs do dispositivo/sessão**
   - Sessão técnica e segurança
   - Finalidade: autenticação e prevenção a abuso

## Serviços envolvidos

- Supabase (auth + banco)
- Google Sign-In (OAuth)
- Mercado Pago / PIX (pagamentos)
- WhatsApp (contato de suporte iniciado pelo usuário)

## Não coletado como dado remoto sensível

- Biometria bruta (digital/rosto): **não enviada ao servidor**; uso apenas local via API nativa.
