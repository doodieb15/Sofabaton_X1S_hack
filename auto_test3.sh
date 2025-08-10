#!/bin/bash

HOST="192.168.2.168"
PORT="8102"


send_and_check() {
    local input="$1"
    local buffer=""
    local start_time timeout=1

    # Verbindung neu öffnen
    exec 3<>/dev/tcp/$HOST/$PORT || {
        echo "Fehler: Verbindung zu $HOST:$PORT fehlgeschlagen."
        exit 1
    }

    printf -v to_send "%s" "$input"

    # Daten senden (ohne Debug-Ausgabe)
    printf "%s" "$to_send" >&3

    start_time=$(date +%s)

    while true; do
        now=$(date +%s)
        (( now - start_time >= timeout )) && break

        if read -t 0.1 -u 3 -n 500 chunk; then
            buffer+="$chunk"
        else
            break
        fi
    done

    # Verbindung schließen
    exec 3<&-
    exec 3>&-

    # Prüfen auf BAD REQUEST
    if [[ "${buffer,,}" == *"bad request"* ]]; then
        return 1
    else
        return 0
    fi
}

output_file="words_ending_with_space.txt"
> "$output_file"  # Datei leeren am Anfang

chars=(' ' {A..Z})

# Schritt 1: Einzelne Zeichen testen (inkl. Leerzeichen)
accepted=()

for char in "${chars[@]}"; do
    if send_and_check "$char"; then
        echo "✅ '$( [[ $char == ' ' ]] && echo '<SPACE>' || echo $char )' akzeptiert"
        accepted+=("$char")
    fi
done

max_length=10

for (( len=2; len<=max_length; len++ )); do
    echo "Teste Kombinationen der Länge $len..."

    new_accepted=()

    for prefix in "${accepted[@]}"; do
        for char in "${chars[@]}"; do
            combo="${prefix}${char}"
            if send_and_check "$combo"; then
                display_combo="${combo// /<SPACE>}"
                echo "✅ $display_combo akzeptiert"
                new_accepted+=("$combo")

                # Wenn combo mit Leerzeichen endet, in Datei schreiben
                if [[ $combo == *" " ]]; then
                    echo "$combo" >> "$output_file"
                fi
            fi
        done
    done

    if [ ${#new_accepted[@]} -eq 0 ]; then
        echo "Keine neuen akzeptierten Kombinationen der Länge $len gefunden. Abbruch."
        break
    fi

    accepted=("${new_accepted[@]}")
done

echo "Fertig. Wörter mit Leerzeichen am Ende sind in $output_file gespeichert."
