# Vertente - Customizacoes sobre o Chatwoot

Este documento lista TODAS as modificacoes feitas sobre o Chatwoot upstream.
Quando atualizar o upstream, consulte este arquivo para re-aplicar as mudancas.

## Estrategia de Atualizacao

```bash
# 1. Adicionar upstream como remote (apenas na primeira vez)
git remote add upstream https://github.com/chatwoot/chatwoot.git

# 2. Buscar atualizacoes
git fetch upstream

# 3. Fazer merge ou rebase da branch desejada
git merge upstream/develop
# OU
git rebase upstream/develop
```

### Resolucao de Conflitos

Os conflitos mais provaveis serao nos **arquivos modificados** listados abaixo.
Cada modificacao e marcada com um comentario `# Custom:` no codigo para facilitar a identificacao.

---

## Feature 1: Administracao de Templates WhatsApp

### Arquivos NOVOS (sem risco de conflito)
- `db/migrate/20260308200001_create_whatsapp_template_visibilities.rb`
- `app/models/whatsapp_template_visibility.rb`
- `app/models/concerns/whatsapp_template_visible.rb`
- `app/models/concerns/template_visibility_assignable.rb`
- `app/controllers/api/v1/accounts/whatsapp_templates_controller.rb`
- `app/javascript/dashboard/api/whatsappTemplates.js`
- `app/javascript/dashboard/store/modules/whatsappTemplates.js`
- `app/javascript/dashboard/routes/dashboard/settings/whatsappTemplates/` (toda a pasta)
- `app/javascript/dashboard/i18n/locale/en/whatsappTemplates.json`

### Arquivos MODIFICADOS (precisam ser re-aplicados em conflito)

| Arquivo | Mudanca | Como re-aplicar |
|---------|---------|-----------------|
| `app/models/channel/whatsapp.rb` | Adicionado `include WhatsappTemplateVisible` | Adicionar 1 linha apos `include Reauthorizable` |
| `app/models/inbox.rb` | Adicionado `include TemplateVisibilityAssignable` | Adicionar 1 linha apos `include InboxAgentAvailability` |
| `app/models/team.rb` | Adicionado `include TemplateVisibilityAssignable` | Adicionar 1 linha apos `include AccountCacheRevalidator` |
| `config/routes.rb` | Adicionado `draw :custom` | Adicionar 1 linha no bloco `scope module: :accounts` |
| `config/routes/custom.rb` | Arquivo de rotas customizadas | Arquivo novo, sem conflito |
| `app/javascript/dashboard/store/index.js` | Adicionado import `whatsappTemplates` | Adicionar 2 linhas (import + modulo) |
| `app/javascript/dashboard/store/mutation-types.js` | Adicionado 2 constantes | Adicionar no final do arquivo |
| `app/javascript/dashboard/routes/dashboard/settings/settings.routes.js` | Adicionado import + spread | Adicionar 2 linhas |
| `app/javascript/dashboard/components-next/sidebar/Sidebar.vue` | Adicionado menu item "WhatsApp Templates" | Adicionar bloco no array `menuItems` |
| `app/javascript/dashboard/i18n/locale/en/settings.json` | Adicionado `WHATSAPP_TEMPLATES` key | Adicionar 1 linha no `SIDEBAR` |

---

## Feature 2: Kanban Board

### Arquivos NOVOS (sem risco de conflito)
- `db/migrate/20260308200002_add_kanban_enabled_to_inboxes.rb`
- `db/migrate/20260308200003_create_kanban_stages.rb`
- `db/migrate/20260308200004_add_kanban_stage_id_to_conversations.rb`
- `app/models/kanban_stage.rb`
- `app/models/concerns/kanban_stageable.rb`
- `app/models/concerns/kanban_inbox.rb`
- `app/controllers/api/v1/accounts/kanban_stages_controller.rb`
- `app/controllers/api/v1/accounts/kanban_controller.rb`
- `app/javascript/dashboard/api/kanban.js`
- `app/javascript/dashboard/store/modules/kanban.js`
- `app/javascript/dashboard/routes/dashboard/kanban/` (toda a pasta)
- `app/javascript/dashboard/i18n/locale/en/kanban.json`

### Arquivos MODIFICADOS (precisam ser re-aplicados em conflito)

| Arquivo | Mudanca | Como re-aplicar |
|---------|---------|-----------------|
| `app/models/conversation.rb` | Adicionado `include KanbanStageable` | Adicionar 1 linha apos `include ConversationMuteHelpers` |
| `app/models/inbox.rb` | Adicionado `include KanbanInbox` | Adicionar 1 linha apos `include InboxAgentAvailability` |
| `config/routes.rb` | (ja incluso no `draw :custom`) | Sem mudanca adicional |
| `config/routes/custom.rb` | Rotas do kanban | Arquivo novo, sem conflito |
| `app/controllers/api/v1/accounts/inboxes_controller.rb` | Adicionado `:kanban_enabled` + setup call | 2 mudancas: params + callback |
| `app/views/api/v1/models/_inbox.json.jbuilder` | Adicionado `json.kanban_enabled` | Adicionar 1 linha |
| `app/views/api/v1/conversations/partials/_conversation.json.jbuilder` | Adicionado `json.kanban_stage_id` | Adicionar 1 linha |
| `app/javascript/dashboard/store/index.js` | Adicionado import `kanban` | (ja incluso acima) |
| `app/javascript/dashboard/store/mutation-types.js` | Adicionado 8 constantes | (ja incluso acima) |
| `app/javascript/dashboard/routes/dashboard/dashboard.routes.js` | Adicionado import + spread | Adicionar 2 linhas |
| `app/javascript/dashboard/i18n/locale/en/index.js` | Adicionado import `kanban` | Adicionar 2 linhas |

---

## Resumo de Impacto por Arquivo Upstream

### Risco BAIXO (1 linha adicionada, marcada com `# Custom:`)
- `app/models/conversation.rb` - 1 include
- `app/models/inbox.rb` - 2 includes
- `app/models/team.rb` - 1 include
- `app/models/channel/whatsapp.rb` - 1 include
- `config/routes.rb` - 1 linha `draw :custom`
- `app/views/api/v1/models/_inbox.json.jbuilder` - 1 linha
- `app/views/api/v1/conversations/partials/_conversation.json.jbuilder` - 1 linha

### Risco MEDIO (2-5 linhas adicionadas)
- `app/controllers/api/v1/accounts/inboxes_controller.rb` - 2 mudancas
- `app/javascript/dashboard/store/index.js` - 2 imports + 2 modulos
- `app/javascript/dashboard/store/mutation-types.js` - 10 constantes no final
- `app/javascript/dashboard/routes/dashboard/settings/settings.routes.js` - 2 linhas
- `app/javascript/dashboard/routes/dashboard/dashboard.routes.js` - 2 linhas
- `app/javascript/dashboard/i18n/locale/en/index.js` - 2 linhas
- `app/javascript/dashboard/i18n/locale/en/settings.json` - 1 linha

### Risco ALTO (bloco de codigo adicionado)
- `app/javascript/dashboard/components-next/sidebar/Sidebar.vue` - bloco de menu item (~7 linhas)

---

## Dica: Busca Rapida

Para encontrar todas as customizacoes no codigo, busque por:
```bash
grep -r "# Custom:" app/ config/
```

Todas as modificacoes em arquivos existentes estao marcadas com este comentario.
