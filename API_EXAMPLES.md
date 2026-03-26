# 🔗 EXEMPLOS DE INTEGRAÇÃO E DOCUMENTAÇÃO DE API

## 📡 Exemplos cURL

### 1. Criar Evento

```bash
curl -X POST http://192.168.1.100:8000/events \
  -H "Content-Type: application/json" \
  -d '{
    "id": "EVT001",
    "name": "Conferência Tech Angola 2026",
    "date": "2026-03-24",
    "location": "Luanda"
  }'
```

**Resposta:**
```json
{
  "id": "EVT001",
  "name": "Conferência Tech Angola 2026",
  "date": "2026-03-24",
  "location": "Luanda"
}
```

---

### 2. Sincronizar Tickets

```bash
curl -X POST http://192.168.1.100:8000/sync-tickets \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": "EVT001",
    "tickets": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "ticket_type": "VIP",
        "attendee_name": "João Silva"
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "ticket_type": "Normal",
        "attendee_name": "Maria Santos"
      }
    ]
  }'
```

**Resposta:**
```json
{
  "synced": 2,
  "total": 2,
  "errors": []
}
```

---

### 3. Validar Ticket (Principal)

```bash
curl -X POST http://192.168.1.100:8000/validate-ticket \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
    "event_id": "EVT001",
    "timestamp": 1710000000,
    "signature": "a1b2c3d4e5f6...",
    "device_id": "scanner-porta-1"
  }'
```

**Resposta Sucesso:**
```json
{
  "status": "valid",
  "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
  "attendee_name": "João Silva",
  "ticket_type": "VIP"
}
```

**Resposta Erro - Já Usado:**
```json
{
  "status": "already_used",
  "used_at": "2026-03-24 10:30:15"
}
```

**Resposta Erro - Inválido:**
```json
{
  "status": "invalid",
  "reason": "ticket_not_found"
}
```

---

### 4. Obter Estatísticas

```bash
curl http://192.168.1.100:8000/events/EVT001/stats
```

**Resposta:**
```json
{
  "event_id": "EVT001",
  "total_tickets": 100,
  "used_tickets": 45,
  "valid_tickets": 55
}
```

---

### 5. Listar Eventos

```bash
curl http://192.168.1.100:8000/events
```

**Resposta:**
```json
[
  {
    "id": "EVT001",
    "name": "Conferência Tech Angola 2026",
    "date": "2026-03-24",
    "location": "Luanda",
    "status": "active"
  },
  {
    "id": "EVT002",
    "name": "Summit Startups",
    "date": "2026-04-15",
    "location": "Namibe",
    "status": "active"
  }
]
```

---

### 6. Obter Logs de Validação

```bash
curl "http://192.168.1.100:8000/validation-logs/EVT001?limit=50"
```

**Resposta:**
```json
[
  {
    "id": 1,
    "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
    "event_id": "EVT001",
    "validation_status": "valid",
    "device_id": "scanner-porta-1",
    "timestamp": "2026-03-24 10:30:15"
  },
  {
    "id": 2,
    "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
    "event_id": "EVT001",
    "validation_status": "already_used",
    "device_id": "scanner-porta-2",
    "timestamp": "2026-03-24 10:31:30"
  }
]
```

---

### 7. Health Check

```bash
curl http://192.168.1.100:8000/health
```

**Resposta:**
```json
{
  "status": "ok",
  "timestamp": "2026-03-24T10:30:15.000Z",
  "database": "connected"
}
```

---

## 🐍 Exemplos Python

### Integração com Django

```python
# views.py
import requests
import json
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

VAMOS_LA_API = "http://192.168.1.100:8000"

@require_http_methods(["POST"])
def validate_ticket(request):
    """Validar ticket via VAMOS LÁ"""
    try:
        data = json.loads(request.body)
        
        response = requests.post(
            f"{VAMOS_LA_API}/validate-ticket",
            json=data,
            timeout=5
        )
        
        return JsonResponse(response.json())
    except requests.exceptions.Timeout:
        return JsonResponse({
            "status": "error",
            "reason": "server_timeout"
        }, status=504)
    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        }, status=500)

@require_http_methods(["GET"])
def get_stats(request):
    """Obter estatísticas"""
    event_id = request.GET.get('event_id')
    
    response = requests.get(
        f"{VAMOS_LA_API}/events/{event_id}/stats"
    )
    
    return JsonResponse(response.json())
```

---

## 🟦 Exemplos JavaScript

### Integração com Node.js

```javascript
// api-client.js
const axios = require('axios');

const VAMOS_LA_API = 'http://192.168.1.100:8000';

class VamosLaClient {
  constructor(apiUrl = VAMOS_LA_API) {
    this.apiUrl = apiUrl;
    this.client = axios.create({
      baseURL: apiUrl,
      timeout: 5000,
    });
  }

  async validateTicket(ticketId, eventId, timestamp, signature, deviceId) {
    try {
      const response = await this.client.post('/validate-ticket', {
        ticket_id: ticketId,
        event_id: eventId,
        timestamp,
        signature,
        device_id: deviceId,
      });
      return response.data;
    } catch (error) {
      return {
        status: 'error',
        reason: error.code,
      };
    }
  }

  async getStats(eventId) {
    try {
      const response = await this.client.get(`/events/${eventId}/stats`);
      return response.data;
    } catch (error) {
      return null;
    }
  }

  async syncTickets(eventId, tickets) {
    try {
      const response = await this.client.post('/sync-tickets', {
        event_id: eventId,
        tickets,
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = VamosLaClient;
```

**Uso:**
```javascript
const VamosLaClient = require('./api-client');

const client = new VamosLaClient();

// Validar ticket
const result = await client.validateTicket(
  '550e8400-e29b-41d4-a716-446655440000',
  'EVT001',
  1710000000,
  'a1b2c3d4e5f6...',
  'scanner-1'
);

console.log(result); // { status: 'valid', ... }
```

---

## 🔄 Exemplo: Integração com Google Sheets

```python
# export_to_sheets.py
import sqlite3
import gspread
from google.oauth2.service_account import Credentials

# Conectar ao SQLite
conn = sqlite3.connect('database/tickets.db')
cursor = conn.cursor()

# Obter dados
cursor.execute('''
  SELECT ticket_id, attendee_name, ticket_type, status, used_at
  FROM tickets
  WHERE event_id = ?
  ORDER BY used_at DESC
''', ('EVT001',))

tickets = cursor.fetchall()

# Conectar ao Google Sheets
scopes = ['https://www.googleapis.com/auth/spreadsheets']
creds = Credentials.from_service_account_file('credentials.json', scopes=scopes)
client = gspread.authorize(creds)

# Abrir planilha
sheet = client.open('VAMOS LÁ - Resultados').sheet1

# Adicionar cabeçalhos
sheet.append_row(['Ticket ID', 'Participante', 'Tipo', 'Status', 'Validado em'])

# Adicionar dados
for ticket in tickets:
    sheet.append_row(ticket)

print(f"✅ Exportados {len(tickets)} tickets para Google Sheets")
```

---

## 📊 Exemplo: Dashboard em Tempo Real

```html
<!-- dashboard.html -->
<!DOCTYPE html>
<html>
<head>
  <title>VAMOS LÁ - Dashboard</title>
  <style>
    body { font-family: Arial; }
    .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
    .stat-card { padding: 20px; border: 1px solid #ccc; border-radius: 8px; }
    .stat-number { font-size: 32px; font-weight: bold; color: #007bff; }
    .stat-label { color: #666; font-size: 14px; }
    #chart { margin-top: 30px; }
  </style>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <h1>🎫 Dashboard VAMOS LÁ</h1>
  
  <div class="stats">
    <div class="stat-card">
      <div class="stat-label">Total de Tickets</div>
      <div class="stat-number" id="total">-</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Usados</div>
      <div class="stat-number" id="used">-</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Válidos</div>
      <div class="stat-number" id="valid">-</div>
    </div>
  </div>

  <canvas id="chart"></canvas>

  <script>
    const API = 'http://192.168.1.100:8000';
    const EVENT_ID = 'EVT001';

    async function updateStats() {
      try {
        const response = await fetch(`${API}/events/${EVENT_ID}/stats`);
        const data = await response.json();
        
        document.getElementById('total').textContent = data.total_tickets;
        document.getElementById('used').textContent = data.used_tickets;
        document.getElementById('valid').textContent = data.valid_tickets;
        
        // Atualizar gráfico
        updateChart(data);
      } catch (error) {
        console.error('Erro ao buscar stats:', error);
      }
    }

    function updateChart(data) {
      const ctx = document.getElementById('chart').getContext('2d');
      
      new Chart(ctx, {
        type: 'doughnut',
        data: {
          labels: ['Usados', 'Válidos'],
          datasets: [{
            data: [data.used_tickets, data.valid_tickets],
            backgroundColor: ['#28a745', '#ffc107'],
          }]
        },
        options: {
          responsive: true,
          plugins: {
            title: {
              display: true,
              text: 'Status de Validação'
            }
          }
        }
      });
    }

    // Atualizar a cada 5 segundos
    updateStats();
    setInterval(updateStats, 5000);
  </script>
</body>
</html>
```

---

## 🔌 Webhook para Cloud Backend

```javascript
// Após cada validação, enviar para backend

app.post('/validate-ticket', async (req, res) => {
  // ... validação normal ...
  
  if (result.status === 'valid') {
    // Enviar webhook para cloud backend
    try {
      await fetch('https://backend.com/webhooks/ticket-validated', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ticket_id: req.body.ticket_id,
          event_id: req.body.event_id,
          device_id: req.body.device_id,
          timestamp: new Date().toISOString(),
        }),
      });
    } catch (error) {
      console.error('Webhook error:', error);
      // Não impedir validação se webhook falhar
    }
  }
  
  res.json(result);
});
```

---

## 🧪 Teste de Carga (Artillery)

```yaml
# load-test.yml
config:
  target: 'http://192.168.1.100:8000'
  phases:
    - duration: 60
      arrivalRate: 10
      name: 'Ramp up'

scenarios:
  - name: 'Validar Ticket'
    flow:
      - post:
          url: '/validate-ticket'
          json:
            ticket_id: '{{ ticketId }}'
            event_id: 'EVT001'
            timestamp: '{{ timestamp }}'
            signature: '{{ signature }}'
            device_id: 'load-test'
```

**Rodar:**
```bash
artillery run load-test.yml
```

---

**Próximas Integrações:**
- [ ] Integração com Eventbrite
- [ ] Integração com payment gateways
- [ ] Sincronização com sistemas de gestão de eventos
- [ ] Mobile app nativa (Swift/Kotlin)

---

Versão: 1.0.0  
Status: ✅ Pronto para integração
