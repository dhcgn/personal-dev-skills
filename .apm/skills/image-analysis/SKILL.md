---
name: image-analysis
description: Analyze image files (JPEG, TIFF, PNG, DNG, RAW, MP4) for corruption, metadata, and structural integrity using local tools. Use when the user wants to check image files for corruption, inspect EXIF/metadata, validate JPEG structure, or understand why an image viewer rejects a file.
---

# Image File Analysis

**UTILITY SKILL** — analyzes image/media files for corruption and metadata using local CLI tools.
USE FOR: "schau dir die Bilder an", "sind die Dateien korrupt", "JPEG Fehler", "Bilder prüfen", "EXIF auslesen", "was stimmt nicht mit den Fotos", "image corruption", "check photos"
DO NOT USE FOR: editing images, converting formats (unless as a repair step), general file management

## Available Tools on this Machine

All tools are located at `C:\tools\`:

| Tool | Binary | Verwendung |
|---|---|---|
| `jpegtran` | `C:\tools\jpegtran.exe` | JPEG-Struktur validieren, lossless transform |
| `ffprobe` | `C:\tools\ffprobe.exe` | Codec, Auflösung, Streams auslesen |
| `ffmpeg` | `C:\tools\ffmpeg.exe` | Dekodierungstest, Fehler-Frames zählen |
| `exiftool` | `C:\tools\exiftool-13.58_64\` | EXIF/IPTC/XMP Metadaten lesen |
| `jpghash` | `C:\tools\jpghash-v0.5.0-windows-amd64.exe` | Perceptual hash für Duplikaterkennung |

Shell-Alias vor jeder Session setzen (PowerShell):
```powershell
Set-Alias rtk "C:\tools\rtk.exe"
```

---

## Workflow

### Schritt 1 — Überblick verschaffen

```powershell
# Dateitypen im Verzeichnis zählen
Get-ChildItem "PFAD" | Group-Object Extension | Sort-Object Count -Descending
```

### Schritt 2 — JPEG-Strukturvalidierung (alle .jpg)

```powershell
# Alle JPGs mit jpegtran prüfen — zeigt nur Fehler
$dir = "PFAD\ZUM\ORDNER"
Get-ChildItem $dir -Filter "*.jpg" | ForEach-Object {
    $r = & "C:\tools\jpegtran.exe" -copy all -outf NUL $_.FullName 2>&1
    if ($LASTEXITCODE -ne 0) {
        [PSCustomObject]@{ File = $_.Name; Error = ($r -join "; ") }
    }
} | Format-Table -AutoSize
```

**Typische jpegtran-Fehler:**

| Meldung | Bedeutung | Schwere |
|---|---|---|
| `Premature end of JPEG file` | EOI-Marker `FF D9` fehlt | ⚠️ Gering — Bilddaten meist vollständig |
| `Corrupt JPEG data: bad Huffman code` | Defekte Huffman-Tabelle / bitflip | 🔴 Hoch — sichtbare Artefakte |
| `Invalid SOS parameters for sequential JPEG` | Ungültiger Stream-Header | ⚠️ Mittel — oft trotzdem dekodierbar |
| `Corrupt JPEG data: premature end of data segment` | Datensegment abgeschnitten | 🔴 Hoch — Bildteile fehlen |

### Schritt 3 — Dekodierungstest mit ffmpeg

```powershell
# Einzelne Datei: Dekodierung auf Fehler prüfen
& "C:\tools\ffmpeg.exe" -v error -i "DATEI.jpg" -frames:v 1 -f null - 2>&1

# Metadaten lesen (Codec, Auflösung)
& "C:\tools\ffprobe.exe" -v error -show_entries stream=width,height,codec_name `
  -of default=nk=1:nw=1 "DATEI.jpg"
```

**ffmpeg-Ausgaben interpretieren:**

| Ausgabe | Bedeutung |
|---|---|
| Keine Ausgabe | Datei vollständig dekodierbar ✅ |
| `overread N` | EOI fehlt, Daten aber vollständig ⚠️ |
| `error count: N` + `error y=… x=…` | Echte Bildartefakte an Position (x,y) 🔴 |
| `error decoding EXIF data` | EXIF-Segment beschädigt (Bild evtl. OK) |

### Schritt 4 — EXIF-Metadaten lesen

```powershell
# Einzelne Datei
& "C:\tools\exiftool-13.58_64\exiftool.exe" "DATEI.jpg"

# Nur wichtige Felder (Kamera, Datum, GPS)
& "C:\tools\exiftool-13.58_64\exiftool.exe" -DateTimeOriginal -Make -Model -GPS* "DATEI.jpg"

# Alle Dateien im Ordner — CSV-Export
& "C:\tools\exiftool-13.58_64\exiftool.exe" -csv "ORDNER\" > metadata.csv
```

### Schritt 5 — EOI-Marker prüfen (PowerShell, kein Tool nötig)

```powershell
# Letzte 2 Bytes einer Datei prüfen — FF D9 = EOI vorhanden
$bytes = [System.IO.File]::ReadAllBytes("DATEI.jpg")
$last2 = $bytes[($bytes.Length-2)..($bytes.Length-1)]
$hasEOI = $last2[0] -eq 0xFF -and $last2[1] -eq 0xD9
Write-Host "EOI vorhanden: $hasEOI"
```

---

## Klassifizierungsschema

```
Für jede Bilddatei:
  ┌─ SOI (FF D8) fehlt? → UNGÜLTIG — kein JPEG
  ├─ EOI (FF D9) fehlt? → REPARIERBAR — FF D9 anhängen
  ├─ jpegtran OK + ffmpeg OK → GESUND
  ├─ jpegtran Fehler + ffmpeg "error count > 0" → BESCHÄDIGT (Artefakte)
  └─ jpegtran Fehler + ffmpeg "overread" only → REPARIERBAR
```

---

## Massen-Analyse (Zusammenfassung)

```powershell
$dir = "PFAD"
$results = Get-ChildItem $dir -Filter "*.jpg" | ForEach-Object {
    $jt = & "C:\tools\jpegtran.exe" -copy all -outf NUL $_.FullName 2>&1
    $ok = $LASTEXITCODE -eq 0
    [PSCustomObject]@{
        File    = $_.Name
        SizeMB  = [math]::Round($_.Length / 1MB, 1)
        Status  = if ($ok) { "OK" } else { ($jt -join "; ") }
    }
}
$results | Group-Object { if ($_.Status -eq "OK") { "OK" } elseif ($_.Status -match "Premature end") { "EOI fehlt" } else { "Beschädigt" } } |
    Select-Object Name, Count | Format-Table
```

---

## Reparatur (Kurzreferenz)

| Problem | Lösung |
|---|---|
| EOI `FF D9` fehlt | `Add-Content -Encoding Byte -Value ([byte[]](0xFF,0xD9)) -Path "DATEI.jpg"` |
| Echte Korruption | Mit Go `image/jpeg` neu dekodieren+enkodieren (EXIF-Verlust) — siehe `how-to-fix.md` |

Detaillierte Go-Implementierung: `.prod-test-data/corrupte-jpgs/how-to-fix.md`
