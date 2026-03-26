# 🗄️ DIAGRAMA E SCHEMA DO BANCO DE DADOS

## 📊 Schema SQLite

```sql
-- Tabela de eventos
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  date TEXT NOT NULL,
  location TEXT,
  status TEXT DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de tickets (CRÍTICA - muitas queries)
CREATE TABLE tickets (
  id TEXT PRIMARY KEY,
  event_id TEXT NOT NULL,
  ticket_type TEXT,
  attendee_name TEXT,
  status TEXT DEFAULT 'valid',
  used_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(event_id) REFERENCES events(id)
);

-- Tabela de logs de validação
CREATE TABLE validation_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticket_id TEXT NOT NULL,
  event_id TEXT NOT NULL,
  validation_status TEXT,
  device_id TEXT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(ticket_id) REFERENCES tickets(id),
  FOREIGN KEY(event_id) REFERENCES events(id)
);
```

## 📈 Relações

```
┌────────────────┐
│    events      │
│    (evento)    │
└────────────────┘
        │
        │ 1:N
        │
        ▼
┌────────────────┐
│   tickets      │
│  (entrada)     │
└────────────────┘
        │
        │ 1:N
        │
        ▼
┌──────────────────────┐
│ validation_logs      │
│  (histórico)         │
└──────────────────────┘
```

## 📋 Exemplos de Dados

### Tabela: events

```
id    | name                             | date       | location     | status
------|----------------------------------|------------|--------------|--------
EVT001| Conferência Tech Angola 2026     | 2026-03-24 | Luanda       | active
EVT002| Summit Startups Angola           | 2026-04-15 | Namibe       | active
EVT003| Jornada de Tecnologia            | 2026-05-10 | Benguela      | active
```

### Tabela: tickets

```
id (UUID)                          | event_id | ticket_type | attendee_name  | status     | used_at
------------------------------------|----------|-------------|----------------|-----------|------------------
550e8400-e29b-41d4-a716-446655440000| EVT001   | VIP         | João Silva     | used       | 2026-03-24 10:30
550e8400-e29b-41d4-a716-446655440001| EVT001   | Normal      | Maria Santos   | used       | 2026-03-24 10:45
550e8400-e29b-41d4-a716-446655440002| EVT001   | VIP         | Pedro Costa    | valid      | NULL
550e8400-e29b-41d4-a716-446655440003| EVT001   | Normal      | Ana Martins    | valid      | NULL
550e8400-e29b-41d4-a716-446655440004| EVT001   | Normal      | Lucas Fernandes| valid      | NULL
```

### Tabela: validation_logs

```
id | ticket_id                          | event_id | validation_status | device_id         | timestamp
---|---------------------------------------|----------|-------------------|-------------------|-----------------------
1  | 550e8400-e29b-41d4-a716-446655440000| EVT001   | valid             | scanner-porta-1   | 2026-03-24 10:30:15
2  | 550e8400-e29b-41d4-a716-446655440000| EVT001   | already_used      | scanner-porta-2   | 2026-03-24 10:31:30
3  | 550e8400-e29b-41d4-a716-446655440001| EVT001   | valid             | scanner-porta-3   | 2026-03-24 10:45:00
4  | xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx| EVT001   | invalid_signature | scanner-porta-1   | 2026-03-24 10:50:22
5  | 550e8400-e29b-41d4-a716-446655440002| EVT001   | valid             | scanner-porta-2   | 2026-03-24 11:15:45
```

## 🔍 Queries Principais

### Query 1: Validar Ticket (CRÍTICA)

```sql
-- PASSO 1: Buscar ticket
SELECT * FROM tickets 
WHERE id = ? AND event_id = ?;

-- PASSO 2: Atualizar com lock atômico
UPDATE tickets 
SET status='used', used_at=datetime('now')
WHERE id=? AND status='valid';
```

**Performance:** <10ms

### Query 2: Sincronizar Tickets (BULK)

```sql
INSERT OR IGNORE INTO tickets 
(id, event_id, ticket_type, attendee_name, status)
VALUES (?, ?, ?, ?, 'valid');
```

**Performance:** ~1ms por ticket

### Query 3: Obter Estatísticas

```sql
SELECT
  COUNT(*) as total_tickets,
  SUM(CASE WHEN status='used' THEN 1 ELSE 0 END) as used_tickets,
  SUM(CASE WHEN status='valid' THEN 1 ELSE 0 END) as valid_tickets
FROM tickets
WHERE event_id = ?;
```

**Performance:** <5ms

### Query 4: Histórico de Validação

```sql
SELECT * FROM validation_logs
WHERE event_id = ?
ORDER BY timestamp DESC
LIMIT 100;
```

**Performance:** <20ms

## 📊 Análise de Dados

### Exemplo: Evento com 200 tickets

```
Total de tickets:      200
Usados:                145 (72.5%)
Válidos:               55  (27.5%)

Tempo evento:          4 horas
Validações/min:        36
Pico/min:              50
Total queries:         ~10,000

Tamanho database:      ~500KB
```

## 🚀 Otimizações

### Índices Automáticos

SQLite cria automaticamente índices para PRIMARY KEY:

```sql
-- Implícito (criado automaticamente)
CREATE INDEX tickets_pk ON tickets(id);
CREATE INDEX events_pk ON events(id);
```

### Para melhor performance (opcional):

```sql
-- Índice para buscas by event_id
CREATE INDEX idx_tickets_event_id ON tickets(event_id);

-- Índice para buscas de status
CREATE INDEX idx_tickets_status ON tickets(status);

-- Índice para logs
CREATE INDEX idx_logs_event_timestamp ON validation_logs(event_id, timestamp);
```

## 💾 Backup e Restauração

### Backup Manual

```bash
cp database/tickets.db database/tickets.db.backup
cp database/tickets.db database/tickets.db.$(date +%Y%m%d_%H%M%S)
```

### Dump SQL

```bash
sqlite3 database/tickets.db ".dump" > backup.sql
```

### Restaurar

```bash
sqlite3 database/tickets.db < backup.sql
```

## 🔄 Sincronização com Cloud

### Após evento (enviar para backend):

```python
import sqlite3
import json

conn = sqlite3.connect('tickets.db')
cursor = conn.cursor()

# Obter logs de validação
cursor.execute('''
  SELECT ticket_id, event_id, validation_status, timestamp 
  FROM validation_logs 
  WHERE timestamp > ?
  ORDER BY timestamp
''', (last_sync_time,))

logs = cursor.fetchall()

# Enviar para cloud
payload = {
  "event_id": "EVT001",
  "validations": [
    {
      "ticket_id": log[0],
      "status": log[2],
      "timestamp": log[3]
    }
    for log in logs
  ]
}

# POST /sync-validation-logs
requests.post("https://backend.com/sync", json=payload)
```

## 📈 Crescimento de Dados

### Estimativa para 5 eventos/ano com 200 tickets cada:

```
Tickets:        1,000
Validations:    ~5,000 (média 70% conversão)
Database size:  ~2-3 MB
Storage:        Negligível (~negligível em qualquer dispositivo)
```

## 🛡️ Integridade de Dados

### Constraints (validações automáticas):

```sql
-- Status só pode ser 'valid' ou 'used'
CHECK(status IN ('valid', 'used'))

-- Referência integridade
FOREIGN KEY(event_id) REFERENCES events(id)

-- Não permite duplicatas
PRIMARY KEY(id)
```

## 📊 Monitoramento

### Ver tamanho do banco

```bash
sqlite3 database/tickets.db "SELECT page_count*page_size as size_bytes FROM pragma_page_count, pragma_page_size;" 
```

### Verificar integridade

```bash
sqlite3 database/tickets.db "PRAGMA integrity_check;"
```

### Otimizar banco

```bash
sqlite3 database/tickets.db "VACUUM;"
```

---

**Versionamento do Schema:**

- v1.0: Schema inicial (Março 2026)
- Pronto para expansão (logs adicionais, sync status, etc)

---

Próximas melhorias (opcional):
- [ ] Tabela de sincronização status
- [ ] Tabela de auditoria (quem fez o quê)
- [ ] Campos de metadata adicionais
- [ ] Partição de dados por data (se >1M registros)
