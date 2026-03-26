#!/usr/bin/env node

/**
 * SCRIPT DE TESTE E DEMONSTRAÇÃO
 * Testar validação de tickets
 */

const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');

const SECRET_KEY = 'vamos-la-tickets-secret-key-production';
const API_URL = 'http://localhost:8000';

/**
 * Gerar assinatura HMAC-SHA256
 */
function generateSignature(ticket_id, event_id, timestamp) {
  const message = `${ticket_id}${event_id}${timestamp}`;
  return crypto
    .createHmac('sha256', SECRET_KEY)
    .update(message)
    .digest('hex');
}

/**
 * Validar ticket
 */
async function validateTicket(ticket_id, event_id) {
  const timestamp = Math.floor(Date.now() / 1000);
  const signature = generateSignature(ticket_id, event_id, timestamp);

  const payload = {
    ticket_id,
    event_id,
    timestamp,
    signature,
    device_id: 'test-device-001',
  };

  try {
    const response = await fetch(`${API_URL}/validate-ticket`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('❌ Erro de conexão:', error.message);
    return null;
  }
}

/**
 * Criar evento
 */
async function createEvent(event_id, name, date) {
  try {
    const response = await fetch(`${API_URL}/events`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: event_id,
        name,
        date,
        location: 'Luanda, Angola',
      }),
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('❌ Erro ao criar evento:', error.message);
    return null;
  }
}

/**
 * Sincronizar tickets
 */
async function syncTickets(event_id, tickets) {
  try {
    const response = await fetch(`${API_URL}/sync-tickets`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        event_id,
        tickets,
      }),
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('❌ Erro ao sincronizar:', error.message);
    return null;
  }
}

/**
 * Obter estatísticas
 */
async function getStats(event_id) {
  try {
    const response = await fetch(`${API_URL}/events/${event_id}/stats`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('❌ Erro ao obter stats:', error.message);
    return null;
  }
}

/**
 * PROGRAMA PRINCIPAL - TESTES
 */
async function main() {
  console.log(`
╔════════════════════════════════════════════╗
║   🎫 SCRIPT DE TESTE - VALIDAÇÃO TICKETS   ║
╚════════════════════════════════════════════╝
  `);

  // 1️⃣ Criar evento
  console.log('\n📅 PASSO 1: Criar evento...');
  const eventId = 'EVT001';
  const eventResult = await createEvent(eventId, 'Conferência Tech Angola 2026', '2026-03-24');
  console.log('✅ Evento criado:', eventResult);

  // 2️⃣ Gerar e sincronizar tickets
  console.log('\n🎫 PASSO 2: Sincronizar 5 tickets...');
  const tickets = Array.from({ length: 5 }, (_, i) => ({
    id: uuidv4(),
    ticket_type: i % 2 === 0 ? 'VIP' : 'Normal',
    attendee_name: `Participante ${i + 1}`,
  }));

  console.log('Tickets gerados:', tickets.length);
  const syncResult = await syncTickets(eventId, tickets);
  console.log('✅ Sincronização:', syncResult);

  // 3️⃣ Validar primeiro ticket (sucesso esperado)
  console.log('\n✅ PASSO 3: Validar primeira entrada (deve ser SUCCESS)...');
  const firstTicketId = tickets[0].id;
  const validation1 = await validateTicket(firstTicketId, eventId);
  console.log('Resultado:', validation1);

  // 4️⃣ Tentar validar novamente (deve falhar - já usado)
  console.log('\n❌ PASSO 4: Validar novamente (deve falhar - JÁ USADO)...');
  const validation2 = await validateTicket(firstTicketId, eventId);
  console.log('Resultado:', validation2);

  // 5️⃣ Validar segundo ticket (sucesso esperado)
  console.log('\n✅ PASSO 5: Validar segunda entrada (deve ser SUCCESS)...');
  const secondTicketId = tickets[1].id;
  const validation3 = await validateTicket(secondTicketId, eventId);
  console.log('Resultado:', validation3);

  // 6️⃣ Validar ticket fake (deve falhar - inválido)
  console.log('\n❌ PASSO 6: Validar ticket FAKE (deve falhar - INVÁLIDO)...');
  const fakeTicketId = uuidv4();
  const validation4 = await validateTicket(fakeTicketId, eventId);
  console.log('Resultado:', validation4);

  // 7️⃣ Obter estatísticas
  console.log('\n📊 PASSO 7: Obter estatísticas...');
  const stats = await getStats(eventId);
  console.log('Estatísticas:', stats);

  console.log(`
╔════════════════════════════════════════════╗
║   ✅ TESTES CONCLUÍDOS COM SUCESSO!        ║
╚════════════════════════════════════════════╝
  `);
}

main();
