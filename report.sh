cat << EOF

==================================================
NETWORK PERFORMANCE REPORT
==================================================

ANALYZED PERIOD
---------------
Start Date        : ${inicio}
End Date          : ${fim}
Duration          : ${dias}d ${horas}h ${minutos}m
Average Interval  : ${intervalo_min}m ${intervalo_seg}s

DOWNLOAD
---------
Average Speed     : ${media_download} Mbps
Minimum Speed     : ${min_download} Mbps
Maximum Speed     : ${max_download} Mbps

UPLOAD
-------
Average Speed     : ${media_upload} Mbps
Minimum Speed     : ${min_upload} Mbps
Maximum Speed     : ${max_upload} Mbps

LATENCY
-------
Average Ping      : ${media_ping} ms
Minimum Ping      : ${min_ping} ms
Maximum Ping      : ${max_ping} ms

AVAILABILITY
------------
Valid Tests       : ${total_medicoes}
Failed Tests      : ${sem_resposta}
Success Rate      : ${taxa_sucesso}%

==================================================

EOF
