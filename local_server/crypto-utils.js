const crypto = require('crypto');

/**
 * UTILITÁRIOS DE CRIPTOGRAFIA
 * Funções para gerar QR Codes e assinaturas
 */

const SECRET_KEY = 'vamos-la-tickets-secret-key-production';

/**
 * Gerar assinatura HMAC-SHA256
 * @param {string} ticket_id - UUID do ticket
 * @param {string} event_id - ID do evento
 * @param {number} timestamp - Timestamp Unix
 * @returns {string} - Assinatura em hexadecimal
 */
function generateSignature(ticket_id, event_id, timestamp) {
  const message = `${ticket_id}${event_id}${timestamp}`;
  return crypto
    .createHmac('sha256', SECRET_KEY)
    .update(message)
    .digest('hex');
}

/**
 * Gerar dados para QR Code
 * @param {string} ticket_id
 * @param {string} event_id
 * @returns {object} - Objeto para codificar no QR
 */
function generateQRData(ticket_id, event_id) {
  const timestamp = Math.floor(Date.now() / 1000);
  const signature = generateSignature(ticket_id, event_id, timestamp);

  return {
    ticket_id,
    event_id,
    timestamp,
    signature,
  };
}

/**
 * Gerar QR Code como string JSON
 * @param {string} ticket_id
 * @param {string} event_id
 * @returns {string} - JSON stringificado para QR Code
 */
function generateQRString(ticket_id, event_id) {
  const data = generateQRData(ticket_id, event_id);
  return JSON.stringify(data);
}

module.exports = {
  generateSignature,
  generateQRData,
  generateQRString,
};
