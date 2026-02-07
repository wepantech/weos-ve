#!/bin/bash

# Konfiguration
IMAGE="/encrypted/encrypted_disk.img"
KEYFILE="/var/roothome/key.keyfile"
MAPPER="fsimg_crypt"
MOUNTPOINT="/encrypted/mountpoint"
NAME="decrypted_space"

# Prüfe Root-Rechte
if [[ $EUID -ne 0 ]]; then
   echo "Dieses Skript muss als root ausgeführt werden (sudo)."
   exit 1
fi

# Prüfe Dateien
if [[ ! -f "$IMAGE" ]]; then
    echo "Fehler: $IMAGE nicht gefunden."
    exit 1
fi

if [[ ! -f "$KEYFILE" ]]; then
    echo "Fehler: $KEYFILE nicht gefunden."
    exit 1
fi

# Erstelle Mountpoint falls nicht vorhanden
mkdir -p "$MOUNTPOINT"

# Prüfe ob bereits gemountet/entschlüsselt
if [[ -e /dev/mapper/$MAPPER ]]; then
    echo "Warnung: $MAPPER ist bereits geöffnet. Schließe es zuerst."
    exit 1
fi

if mountpoint -q "$MOUNTPOINT"; then
    echo "Warnung: $MOUNTPOINT ist bereits gemountet."
    exit 1
fi

# Entschlüssele LUKS-Container mit Keyfile
echo "Entschlüssele $IMAGE..."
if ! cryptsetup luksOpen "$IMAGE" "$MAPPER" --key-file "$KEYFILE"; then
    echo "Fehler: Entschlüsselung fehlgeschlagen."
    exit 1
fi

# Formatiere/Mount ext4 (angenommen Partition 1 im Image)
echo "Mounting /dev/mapper/$MAPPER auf $MOUNTPOINT..."
if ! mount /dev/mapper/"$MAPPER" "$MOUNTPOINT"; then
    echo "Fehler: Mount fehlgeschlagen."
    cryptsetup luksClose "$MAPPER"
    exit 1
fi

echo "Erfolg! Dateisystem ist unter $MOUNTPOINT gemountet."
echo "Inhalt:"
ls -la "$MOUNTPOINT"
