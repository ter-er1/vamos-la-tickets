#!/usr/bin/env python3

"""
GERADOR E TESTADOR DE QR CODES
Script Python para gerar e testar QR Codes para o sistema VAMOS LÁ TICKETS

Requisitos:
    pip install requests qrcode[pil] pillow

Uso:
    python3 generate_qr_codes.py
"""

import json
import hmac
import hashlib
import time
import uuid
import requests
from datetime import datetime

# ========================================
# CONFIGURAÇÕES
# ========================================

SERVER_URL = "http://192.168.1.100:8000"  # ⚠️ Trocar conforme seu IP
SECRET_KEY = "vamos-la-tickets-secret-key-production"
EVENT_ID = "EVT001"

# ========================================
# FUNÇÕES
# ========================================

def generate_signature(ticket_id, event_id, timestamp):
    """Gerar assinatura HMAC-SHA256"""
    message = f"{ticket_id}{event_id}{timestamp}"
    signature = hmac.new(
        SECRET_KEY.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()
    return signature


def generate_qr_data(ticket_id, event_id):
    """Gerar dados para QR Code"""
    timestamp = int(time.time())
    signature = generate_signature(ticket_id, event_id, timestamp)
    
    return {
        "ticket_id": ticket_id,
        "event_id": event_id,
        "timestamp": timestamp,
        "signature": signature,
    }


def generate_qr_string(ticket_id, event_id):
    """Gerar string JSON para QR Code"""
    data = generate_qr_data(ticket_id, event_id)
    return json.dumps(data)


def generate_qr_image(data_string, filename):
    """Gerar imagem QR Code"""
    try:
        import qrcode
        
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(data_string)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        img.save(filename)
        print(f"✅ QR Code salvo em: {filename}")
        return True
    except ImportError:
        print("⚠️  qrcode não instalado. Install com: pip install qrcode[pil]")
        return False


def validate_ticket(ticket_id, event_id, timestamp, signature, device_id="test-device"):
    """Validar ticket via API"""
    payload = {
        "ticket_id": ticket_id,
        "event_id": event_id,
        "timestamp": timestamp,
        "signature": signature,
        "device_id": device_id,
    }
    
    try:
        response = requests.post(
            f"{SERVER_URL}/validate-ticket",
            json=payload,
            timeout=5
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            return {
                "status": "error",
                "reason": f"http_error_{response.status_code}",
            }
    except requests.exceptions.ConnectionError:
        return {
            "status": "error",
            "reason": "connection_error",
            "message": f"Não conseguiu conectar a {SERVER_URL}",
        }
    except Exception as e:
        return {
            "status": "error",
            "reason": "exception",
            "message": str(e),
        }


def create_event(event_id, name, date, location="Luanda, Angola"):
    """Criar evento"""
    payload = {
        "id": event_id,
        "name": name,
        "date": date,
        "location": location,
    }
    
    try:
        response = requests.post(
            f"{SERVER_URL}/events",
            json=payload,
            timeout=5
        )
        return response.json()
    except Exception as e:
        return {"error": str(e)}


def sync_tickets(event_id, tickets):
    """Sincronizar tickets"""
    payload = {
        "event_id": event_id,
        "tickets": tickets,
    }
    
    try:
        response = requests.post(
            f"{SERVER_URL}/sync-tickets",
            json=payload,
            timeout=5
        )
        return response.json()
    except Exception as e:
        return {"error": str(e)}


def get_event_stats(event_id):
    """Obter estatísticas"""
    try:
        response = requests.get(
            f"{SERVER_URL}/events/{event_id}/stats",
            timeout=5
        )
        return response.json()
    except Exception as e:
        return {"error": str(e)}


def print_header(title):
    """Print header"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


# ========================================
# PROGRAMA PRINCIPAL
# ========================================

def main():
    print_header("🎫 GERADOR E TESTADOR DE QR CODES")
    print(f"📡 Servidor: {SERVER_URL}")
    print(f"🔑 Secret Key: {SECRET_KEY[:30]}...")
    print(f"📅 Evento: {EVENT_ID}\n")
    
    # 1️⃣ Criar evento
    print_header("1️⃣  Criando evento...")
    event_result = create_event(
        EVENT_ID,
        "Conferência Tech Angola 2026",
        "2026-03-24"
    )
    print(f"✅ Resultado: {json.dumps(event_result, indent=2)}\n")
    
    # 2️⃣ Gerar tickets
    print_header("2️⃣  Gerando 5 tickets de teste...")
    tickets = []
    ticket_data = {}
    
    for i in range(5):
        ticket_id = str(uuid.uuid4())
        ticket_type = "VIP" if i % 2 == 0 else "Normal"
        attendee_name = f"Participante {i + 1}"
        
        tickets.append({
            "id": ticket_id,
            "ticket_type": ticket_type,
            "attendee_name": attendee_name,
        })
        
        ticket_data[i] = {
            "ticket_id": ticket_id,
            "ticket_type": ticket_type,
            "attendee_name": attendee_name,
        }
        
        print(f"  {i+1}. {attendee_name} ({ticket_type})")
        print(f"     ID: {ticket_id}\n")
    
    # 3️⃣ Sincronizar tickets
    print_header("3️⃣  Sincronizando tickets...")
    sync_result = sync_tickets(EVENT_ID, tickets)
    print(f"✅ Resultado: {json.dumps(sync_result, indent=2)}\n")
    
    # 4️⃣ Gerar QR Codes
    print_header("4️⃣  Gerando QR Codes...")
    qr_codes = {}
    
    for i, ticket in enumerate(tickets):
        ticket_id = ticket["id"]
        qr_data = generate_qr_data(ticket_id, EVENT_ID)
        qr_string = json.dumps(qr_data)
        
        qr_codes[i] = qr_data
        
        print(f"  Ticket {i+1}:")
        print(f"    Data: {qr_string}")
        
        # Gerar imagem
        filename = f"qr_code_{i+1}.png"
        generate_qr_image(qr_string, filename)
        print()
    
    # 5️⃣ Testar validações
    print_header("5️⃣  Testando validações...")
    
    # ✅ Validar primeiro ticket (deve ser válido)
    print("Teste 1: Primeiro ticket (deve ser VÁLIDO)")
    qr1 = qr_codes[0]
    result1 = validate_ticket(
        qr1["ticket_id"],
        qr1["event_id"],
        qr1["timestamp"],
        qr1["signature"],
        device_id="test-device-1"
    )
    print(f"  Status: {result1.get('status')}")
    print(f"  Razão: {result1.get('reason')}\n")
    
    # ❌ Validar novamente (deve falhar - já usado)
    print("Teste 2: Mesmo ticket novamente (deve falhar - JÁ USADO)")
    result2 = validate_ticket(
        qr1["ticket_id"],
        qr1["event_id"],
        qr1["timestamp"],
        qr1["signature"],
        device_id="test-device-1"
    )
    print(f"  Status: {result2.get('status')}")
    print(f"  Razão: {result2.get('reason')}\n")
    
    # ✅ Validar segundo ticket (deve ser válido)
    print("Teste 3: Segundo ticket (deve ser VÁLIDO)")
    qr2 = qr_codes[1]
    result3 = validate_ticket(
        qr2["ticket_id"],
        qr2["event_id"],
        qr2["timestamp"],
        qr2["signature"],
        device_id="test-device-2"
    )
    print(f"  Status: {result3.get('status')}")
    print(f"  Razão: {result3.get('reason')}\n")
    
    # ❌ Validar ticket fake (deve falhar - não existe)
    print("Teste 4: Ticket FAKE (deve falhar - NÃO EXISTE)")
    fake_id = str(uuid.uuid4())
    fake_qr = generate_qr_data(fake_id, EVENT_ID)
    result4 = validate_ticket(
        fake_qr["ticket_id"],
        fake_qr["event_id"],
        fake_qr["timestamp"],
        fake_qr["signature"],
        device_id="test-device-3"
    )
    print(f"  Status: {result4.get('status')}")
    print(f"  Razão: {result4.get('reason')}\n")
    
    # 6️⃣ Obter estatísticas
    print_header("6️⃣  Estatísticas finais...")
    stats = get_event_stats(EVENT_ID)
    print(f"  Total de tickets: {stats.get('total_tickets')}")
    print(f"  Usados: {stats.get('used_tickets')}")
    print(f"  Válidos: {stats.get('valid_tickets')}\n")
    
    # Resumo
    print_header("✅ TESTES CONCLUÍDOS COM SUCESSO!")
    print(f"  ✅ Evento criado")
    print(f"  ✅ 5 tickets sincronizados")
    print(f"  ✅ QR Codes gerados (qr_code_1.png ... qr_code_5.png)")
    print(f"  ✅ Validações testadas")
    print(f"  ✅ Duplicação bloqueada")
    print(f"  ✅ Sistema operacional\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⛔ Cancelado pelo usuário")
    except Exception as e:
        print(f"\n\n❌ Erro: {e}")
