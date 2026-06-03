#!/bin/bash

ARQUIVO="internet_log.txt"

if [ ! -f "$ARQUIVO" ]; then
    echo "Arquivo não encontrado: $ARQUIVO"
    exit 1
fi

# Datas de início e fim
inicio=$(grep -m1 '^\[' "$ARQUIVO" | tr -d '[]')
fim=$(grep '^\[' "$ARQUIVO" | tail -1 | tr -d '[]')

# Converte para timestamp
inicio_ts=$(date -d "$inicio" +%s 2>/dev/null)
fim_ts=$(date -d "$fim" +%s 2>/dev/null)

# Duração total
duracao_seg=$((fim_ts - inicio_ts))

dias=$((duracao_seg / 86400))
horas=$(((duracao_seg % 86400) / 3600))
minutos=$(((duracao_seg % 3600) / 60))

# Coleta dados
downloads=$(grep "Download:" "$ARQUIVO" | awk '{print $2}')
uploads=$(grep "Upload:" "$ARQUIVO" | awk '{print $2}')
pings=$(grep "Ping:" "$ARQUIVO" | awk '{print $2}')

total_medicoes=$(echo "$downloads" | wc -l | tr -d ' ')

if [ "$total_medicoes" -eq 0 ]; then
    echo "Nenhuma medição encontrada."
    exit 1
fi

# Médias
media_download=$(echo "$downloads" | awk '{s+=$1} END {printf "%.2f", s/NR}')
media_upload=$(echo "$uploads" | awk '{s+=$1} END {printf "%.2f", s/NR}')
media_ping=$(echo "$pings" | awk '{s+=$1} END {printf "%.3f", s/NR}')

# Mínimos e máximos
min_download=$(echo "$downloads" | sort -n | head -1)
max_download=$(echo "$downloads" | sort -n | tail -1)

min_upload=$(echo "$uploads" | sort -n | head -1)
max_upload=$(echo "$uploads" | sort -n | tail -1)

min_ping=$(echo "$pings" | sort -n | head -1)
max_ping=$(echo "$pings" | sort -n | tail -1)

# Intervalo médio entre medições
if [ "$total_medicoes" -gt 1 ]; then
    intervalo_medio=$((duracao_seg / (total_medicoes - 1)))
    intervalo_min=$((intervalo_medio / 60))
    intervalo_seg=$((intervalo_medio % 60))
else
    intervalo_min=0
    intervalo_seg=0
fi

# Conta medições sem resposta
sem_resposta=0

while IFS= read -r linha; do
    if [[ "$linha" =~ ^\[.*\]$ ]]; then

        read -r linha1 || true
        read -r linha2 || true
        read -r linha3 || true

        if [[ ! "$linha1" =~ Download: ]] || \
           [[ ! "$linha2" =~ Upload: ]] || \
           [[ ! "$linha3" =~ Ping: ]]; then
            ((sem_resposta++))
        fi
    fi
done < "$ARQUIVO"

# Taxa de sucesso
total_tentativas=$((total_medicoes + sem_resposta))

if [ "$total_tentativas" -gt 0 ]; then
    taxa_sucesso=$(awk -v ok="$total_medicoes" -v total="$total_tentativas" \
        'BEGIN { printf "%.2f", (ok/total)*100 }')
else
    taxa_sucesso="0.00"
fi

cat << EOF

==================================================
RELATÓRIO DE DESEMPENHO DA REDE
==================================================

PERÍODO ANALISADO
-----------------
Início             : ${inicio}
Fim                : ${fim}
Duração            : ${dias}d ${horas}h ${minutos}min
Intervalo médio    : ${intervalo_min}min ${intervalo_seg}s

DOWNLOAD
---------
Velocidade média   : ${media_download} Mbps
Menor velocidade   : ${min_download} Mbps
Maior velocidade   : ${max_download} Mbps

UPLOAD
-------
Velocidade média   : ${media_upload} Mbps
Menor velocidade   : ${min_upload} Mbps
Maior velocidade   : ${max_upload} Mbps

PING
-----
Ping médio         : ${media_ping} ms
Menor ping         : ${min_ping} ms
Maior ping         : ${max_ping} ms

DISPONIBILIDADE
---------------
Medições válidas   : ${total_medicoes}
Sem resposta       : ${sem_resposta}
Taxa de sucesso    : ${taxa_sucesso}%

==================================================

EOF
