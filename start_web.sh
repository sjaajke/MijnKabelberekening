#!/bin/bash
# Start de Kabelberekening web-app en open in Safari
cd "$(dirname "$0")"

# Kies een vrije poort (standaard 8080)
PORT=8080

echo "Kabelberekening starten op http://localhost:$PORT"
echo "Druk op Ctrl+C om te stoppen."

# Open Safari na een korte vertraging zodat de server klaar is
(sleep 1 && open -a Safari "http://localhost:$PORT") &

# Serveer de build/web map
cd build/web && python3 -m http.server $PORT
