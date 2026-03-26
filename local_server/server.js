const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const crypto = require('crypto');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ========================================
// CONFIGURAÇÕES
// ========================================
const PORT = process.env.PORT || 8000;
const SECRET_KEY = process.env.SECRET_KEY || 'your-secret-key-change-in-production';
const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../database/tickets.db');

// ========================================
// INICIALIZAR BANCO DE DADOS
// ========================================
const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('❌ Erro ao conectar ao banco:', err.message);
    process.exit(1);
  }
  console.log('✅ Conectado ao SQLite em:', DB_PATH);
});

// Habilitar modo thread-safe
db.configure('busyTimeout', 5000);

// ========================================
// CRIAR TABELAS
// ========================================
const initDatabase = () => {
  db.serialize(() => {
    // Tabela de eventos
    db.run(`
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        status TEXT DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tabela de tickets
    db.run(`
      CREATE TABLE IF NOT EXISTS tickets (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        ticket_type TEXT,
        attendee_name TEXT,
        status TEXT DEFAULT 'valid',
        used_at DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(event_id) REFERENCES events(id)
      )
    `);

    // Tabela de logs de validação
    db.run(`
      CREATE TABLE IF NOT EXISTS validation_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_id TEXT NOT NULL,
        event_id TEXT NOT NULL,
        validation_status TEXT,
        device_id TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(ticket_id) REFERENCES tickets(id),
        FOREIGN KEY(event_id) REFERENCES events(id)
      )
    `);

    console.log('✅ Tabelas inicializadas');
  });
};

initDatabase();

// ========================================
// FUNÇÕES DE CRIPTOGRAFIA
// ========================================

/**
 * Gerar assinatura HMAC-SHA256
 * @param {string} ticket_id
 * @param {string} event_id
 * @param {number} timestamp
 * @returns {string} signature
 */
function generateSignature(ticket_id, event_id, timestamp) {
  const message = `${ticket_id}${event_id}${timestamp}`;
  return crypto
    .createHmac('sha256', SECRET_KEY)
    .update(message)
    .digest('hex');
}

/**
 * Verificar assinatura HMAC
 * @param {string} ticket_id
 * @param {string} event_id
 * @param {number} timestamp
 * @param {string} signature
 * @returns {boolean}
 */
function verifySignature(ticket_id, event_id, timestamp, signature) {
  const expected = generateSignature(ticket_id, event_id, timestamp);
  return crypto.timingSafeEqual(
    Buffer.from(expected),
    Buffer.from(signature)
  );
}

// ========================================
// ENDPOINTS
// ========================================

/**
 * POST /validate-ticket
 * Principal endpoint de validação
 */
app.post('/validate-ticket', (req, res) => {
  const { ticket_id, event_id, timestamp, signature, device_id } = req.body;

  // Validar entrada
  if (!ticket_id || !event_id || !timestamp || !signature) {
    return res.status(400).json({
      status: 'invalid',
      reason: 'missing_fields',
      message: 'Campos obrigatórios: ticket_id, event_id, timestamp, signature',
    });
  }

  try {
    // ✅ PASSO 1: Verificar assinatura HMAC
    if (!verifySignature(ticket_id, event_id, parseInt(timestamp), signature)) {
      console.log(`❌ Assinatura inválida para ticket: ${ticket_id}`);
      logValidation(ticket_id, event_id, 'invalid_signature', device_id);
      return res.status(200).json({
        status: 'invalid',
        reason: 'invalid_signature',
      });
    }

    // ✅ PASSO 2: Buscar ticket no banco
    db.get(
      'SELECT * FROM tickets WHERE id = ? AND event_id = ?',
      [ticket_id, event_id],
      (err, row) => {
        if (err) {
          console.error('❌ Erro ao consultar ticket:', err.message);
          return res.status(500).json({
            status: 'error',
            reason: 'database_error',
          });
        }

        // Ticket não encontrado
        if (!row) {
          console.log(`❌ Ticket não encontrado: ${ticket_id}`);
          logValidation(ticket_id, event_id, 'not_found', device_id);
          return res.status(200).json({
            status: 'invalid',
            reason: 'ticket_not_found',
          });
        }

        // ✅ PASSO 3: Verificar status
        if (row.status === 'used') {
          console.log(`⚠️  Ticket já usado: ${ticket_id}`);
          logValidation(ticket_id, event_id, 'already_used', device_id);
          return res.status(200).json({
            status: 'already_used',
            used_at: row.used_at,
          });
        }

        // ✅ PASSO 4: Marcar como usado com LOCK ATÔMICO
        const now = new Date().toISOString();
        db.run(
          `UPDATE tickets SET status = 'used', used_at = ? WHERE id = ? AND status = 'valid'`,
          [now, ticket_id],
          function (err) {
            if (err) {
              console.error('❌ Erro ao atualizar ticket:', err.message);
              return res.status(500).json({
                status: 'error',
                reason: 'database_error',
              });
            }

            // Verificar se foi atualizado (lock atômico funcionou)
            if (this.changes === 0) {
              console.log(`⚠️  Ticket já foi marcado como usado (race condition): ${ticket_id}`);
              logValidation(ticket_id, event_id, 'already_used', device_id);
              return res.status(200).json({
                status: 'already_used',
              });
            }

            console.log(`✅ Ticket validado com sucesso: ${ticket_id}`);
            logValidation(ticket_id, event_id, 'valid', device_id);
            res.status(200).json({
              status: 'valid',
              ticket_id,
              attendee_name: row.attendee_name,
              ticket_type: row.ticket_type,
            });
          }
        );
      }
    );
  } catch (error) {
    console.error('❌ Erro na validação:', error.message);
    res.status(500).json({
      status: 'error',
      reason: 'validation_error',
      message: error.message,
    });
  }
});

/**
 * POST /sync-tickets
 * Sincronizar tickets (bulk insert)
 */
app.post('/sync-tickets', (req, res) => {
  const { event_id, tickets } = req.body;

  if (!event_id || !Array.isArray(tickets)) {
    return res.status(400).json({
      error: 'event_id e tickets array são obrigatórios',
    });
  }

  db.serialize(() => {
    db.run('BEGIN TRANSACTION');

    let inserted = 0;
    let errors = [];

    tickets.forEach((ticket) => {
      db.run(
        `INSERT OR IGNORE INTO tickets (id, event_id, ticket_type, attendee_name, status)
         VALUES (?, ?, ?, ?, 'valid')`,
        [ticket.id, event_id, ticket.ticket_type, ticket.attendee_name],
        function (err) {
          if (err) {
            errors.push({ ticket_id: ticket.id, error: err.message });
          } else {
            inserted++;
          }
        }
      );
    });

    db.run('COMMIT', (err) => {
      if (err) {
        console.error('❌ Erro ao sincronizar:', err.message);
        return res.status(500).json({ error: err.message });
      }

      console.log(`✅ Sincronizados ${inserted}/${tickets.length} tickets`);
      res.status(200).json({
        synced: inserted,
        total: tickets.length,
        errors,
      });
    });
  });
});

/**
 * POST /events
 * Criar novo evento
 */
app.post('/events', (req, res) => {
  const { id, name, date, location } = req.body;

  if (!id || !name || !date) {
    return res.status(400).json({
      error: 'id, name e date são obrigatórios',
    });
  }

  db.run(
    `INSERT INTO events (id, name, date, location, status)
     VALUES (?, ?, ?, ?, 'active')`,
    [id, name, date, location || ''],
    function (err) {
      if (err) {
        if (err.message.includes('UNIQUE')) {
          return res.status(409).json({ error: 'Evento já existe' });
        }
        return res.status(500).json({ error: err.message });
      }

      res.status(201).json({
        id,
        name,
        date,
        location,
      });
    }
  );
});

/**
 * GET /events
 * Listar eventos
 */
app.get('/events', (req, res) => {
  db.all(`SELECT * FROM events ORDER BY date DESC`, (err, rows) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json(rows);
  });
});

/**
 * GET /events/:event_id/stats
 * Estatísticas de validação
 */
app.get('/events/:event_id/stats', (req, res) => {
  const { event_id } = req.params;

  db.get(
    `SELECT
      COUNT(*) as total_tickets,
      SUM(CASE WHEN status = 'used' THEN 1 ELSE 0 END) as used_tickets,
      SUM(CASE WHEN status = 'valid' THEN 1 ELSE 0 END) as valid_tickets
     FROM tickets
     WHERE event_id = ?`,
    [event_id],
    (err, row) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.status(200).json({
        event_id,
        ...row,
      });
    }
  );
});

/**
 * GET /validation-logs/:event_id
 * Logs de validação
 */
app.get('/validation-logs/:event_id', (req, res) => {
  const { event_id } = req.params;
  const limit = parseInt(req.query.limit) || 100;

  db.all(
    `SELECT * FROM validation_logs
     WHERE event_id = ?
     ORDER BY timestamp DESC
     LIMIT ?`,
    [event_id, limit],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.status(200).json(rows);
    }
  );
});

/**
 * GET /health
 * Health check
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    database: 'connected',
  });
});

// ========================================
// FUNÇÕES AUXILIARES
// ========================================

/**
 * Log de validação
 */
function logValidation(ticket_id, event_id, validation_status, device_id) {
  db.run(
    `INSERT INTO validation_logs (ticket_id, event_id, validation_status, device_id)
     VALUES (?, ?, ?, ?)`,
    [ticket_id, event_id, validation_status, device_id || 'unknown']
  );
}

// ========================================
// INICIAR SERVIDOR
// ========================================
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔════════════════════════════════════════════╗
║   🎫 VAMOS LÁ TICKETS - SERVIDOR LOCAL    ║
╚════════════════════════════════════════════╝
  
📡 API rodando em:     http://0.0.0.0:${PORT}
🗄️  Banco de dados:    ${DB_PATH}
🔑 SECRET_KEY:         ${SECRET_KEY.substring(0, 10)}...

✅ Pronto para receber validações!
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Encerrando servidor...');
  server.close(() => {
    db.close();
    console.log('✅ Servidor encerrado');
    process.exit(0);
  });
});

module.exports = { app, db };
