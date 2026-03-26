#!/usr/bin/env python3
import subprocess
import json

# Pegar informações dos workflows
result = subprocess.run([
    'gh', 'run', 'list',
    '--repo', 'ter-er1/vamos-la-tickets',
    '--branch', 'main',
    '--limit', '5',
    '--json', 'databaseId,name,conclusion,status'
], capture_output=True, text=True)

if result.returncode != 0:
    print("❌ Erro ao acessar GitHub CLI")
    print("Erro:", result.stderr)
    exit(1)

runs = json.loads(result.stdout)
print("📋 Últimos Workflows:\n")

for i, run in enumerate(runs, 1):
    print(f"{i}. {run['name']}")
    print(f"   ID: {run['databaseId']}")
    print(f"   Status: {run['status']}")
    print(f"   Conclusão: {run['conclusion']}")
    print()

# Pegar o primeiro run
if runs:
    run_id = runs[0]['databaseId']
    print(f"\n📥 Baixando logs do workflow #{run_id}...\n")
    
    # Pegar os logs
    result = subprocess.run([
        'gh', 'run', 'view', str(run_id),
        '--repo', 'ter-er1/vamos-la-tickets',
        '--log'
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        logs = result.stdout
        # Mostrar apenas as últimas linhas com erro
        lines = logs.split('\n')
        
        # Procurar por erros (linhas com error, failed, ❌, etc)
        print("🔴 Linhas com ERROS:\n")
        error_found = False
        for i, line in enumerate(lines):
            if any(keyword in line.lower() for keyword in ['error', 'failed', 'fatal', '❌', 'exception', 'gradle', 'groovy']):
                # Mostrar contexto (linhas anteriores e posteriores)
                start = max(0, i-2)
                end = min(len(lines), i+3)
                for j in range(start, end):
                    if j == i:
                        print(f">>> {lines[j]}")
                    else:
                        print(f"    {lines[j]}")
                print()
                error_found = True
        
        if not error_found:
            print("Nenhum erro óbvio encontrado. Últimas 30 linhas dos logs:\n")
            for line in lines[-30:]:
                if line.strip():
                    print(line)
    else:
        print("❌ Erro ao baixar logs:", result.stderr)
