# CS 1.6 Server Installer 🎮

Kompletny instalator serwera Counter-Strike 1.6 z najnowszymi modyfikacjami, gotowy do wdrożenia na VPS lub lokalnym WSL za pomocą jednej komendy.

## 🚀 Szybka instalacja (jedna komenda)

> ⚠️ **Uwaga bezpieczeństwa:** Zawsze zalecamy przejrzenie skryptu przed jego uruchomieniem. Możesz to zrobić pobierając skrypt lokalnie lub przeglądając go na GitHubie.

```bash
curl -sSL https://raw.githubusercontent.com/PtakuPL/ks16/main/install.sh | bash
```

Lub jeśli wolisz najpierw przejrzeć skrypt (zalecane):

```bash
wget https://raw.githubusercontent.com/PtakuPL/ks16/main/install.sh
chmod +x install.sh
./install.sh
```

### Instalacja w niestandardowej lokalizacji

```bash
./install.sh /sciezka/do/instalacji
```

## 📦 Co zawiera?

Instalator automatycznie pobiera i konfiguruje:

| Komponent | Opis |
|-----------|------|
| **HLDS (CS 1.6)** | Bazowy serwer Counter-Strike 1.6 via SteamCMD |
| **ReHLDS** | Reverse-Engineered HLDS - poprawiona wydajność i stabilność |
| **Metamod-r** | Metamod-r - system pluginów dla HLDS |
| **ReGameDLL_CS** | Ulepszona logika gry z bugfixami |
| **ReAPI** | Zaawansowane API dla pluginów AMX Mod X |
| **AMX Mod X** | System administracji i pluginów |
| **YaPB** | Yet another POD Bot - inteligentne boty AI |

## 🖥️ Wymagania systemowe

- **System operacyjny:** Linux (Debian/Ubuntu, CentOS/RHEL, Arch Linux) lub WSL
- **RAM:** Minimum 512 MB (zalecane 1 GB+)
- **Dysk:** Minimum 2 GB wolnego miejsca
- **Sieć:** Port 27015 UDP (należy otworzyć w firewallu)

## 🛠️ Zarządzanie serwerem

Po instalacji dostępne są następujące skrypty:

```bash
# Uruchomienie serwera
~/cs16_server/start.sh

# Zatrzymanie serwera
~/cs16_server/stop.sh

# Restart serwera
~/cs16_server/restart.sh

# Sprawdzenie statusu
~/cs16_server/status.sh

# Aktualizacja serwera
~/cs16_server/update.sh
```

### Dostęp do konsoli serwera

```bash
screen -r cs16        # Podłączenie do konsoli
# Ctrl+A, D           # Odłączenie od konsoli (serwer działa dalej)
```

## ⚙️ Konfiguracja

### Główne pliki konfiguracyjne

| Plik | Opis |
|------|------|
| `server/cstrike/server.cfg` | Główna konfiguracja serwera |
| `server/cstrike/mapcycle.txt` | Lista map w rotacji |
| `server/cstrike/motd.txt` | Wiadomość powitalna |
| `server/cstrike/addons/amxmodx/configs/users.ini` | Lista adminów AMX |
| `server/cstrike/addons/amxmodx/configs/plugins.ini` | Lista aktywnych pluginów |
| `server/cstrike/addons/yapb/conf/yapb.cfg` | Konfiguracja botów YaPB |

### Ważne ustawienia w server.cfg

```cfg
hostname "Nazwa Twojego Serwera"     # Nazwa serwera
sv_password ""                         # Hasło serwera (puste = brak)
rcon_password "twoje_haslo"           # Hasło RCON (ZMIEŃ TO!)
```

### Dodawanie adminów AMX Mod X

Edytuj plik `users.ini` i dodaj swoje Steam ID:

```ini
"STEAM_0:0:123456" "" "abcdefghijklmnopqrstu" "ce"
```

## 🤖 Zarządzanie Botami (YaPB)

YaPB (Yet another POD Bot) to nowoczesny system botów dla CS 1.6.

### Podstawowe komendy konsolowe

```bash
yb add              # Dodaj bota
yb add [nazwa]      # Dodaj bota o konkretnej nazwie
yb kick             # Wyrzuć losowego bota
yb kickall          # Wyrzuć wszystkie boty
yb fill             # Wypełnij serwer botami
yb menu             # Otwórz menu botów
yb killbots         # Zabij wszystkie boty
```

### Konfiguracja botów w server.cfg

```cfg
yb_quota 10                    # Liczba botów na serwerze
yb_quota_mode fill             # Tryb: fill (dopełnianie), normal (stała liczba)
yb_difficulty 2                # Poziom trudności: 0-4
yb_autovacate 1                # Usuń bota gdy gracz dołącza
```

### Poziomy trudności botów

| Poziom | Opis |
|--------|------|
| 0 | Newbie - bardzo łatwy |
| 1 | Average - łatwy |
| 2 | Normal - normalny |
| 3 | Professional - trudny |
| 4 | Godlike - bardzo trudny |

Więcej informacji: [YaPB Wiki](https://yapb.jeefo.net/wiki/)

## 🔧 Otwieranie portów

### Ubuntu/Debian (UFW)

```bash
sudo ufw allow 27015/udp
```

### CentOS/RHEL (firewalld)

```bash
sudo firewall-cmd --permanent --add-port=27015/udp
sudo firewall-cmd --reload
```

## 🔒 Bezpieczeństwo

⚠️ **WAŻNE:** Przed uruchomieniem serwera:

1. Zmień hasło RCON w `server.cfg`
2. Skonfiguruj listę adminów w `users.ini`
3. Otwórz tylko niezbędne porty w firewallu

## 📋 Struktura katalogów

```
cs16_server/
├── server/             # Pliki serwera HLDS
│   └── cstrike/        # Pliki gry Counter-Strike
│       ├── addons/     # Metamod, AMX Mod X, YaPB
│       │   ├── metamod/    # Metamod-r
│       │   ├── amxmodx/    # AMX Mod X
│       │   ├── regamedll/  # ReGameDLL_CS
│       │   └── yapb/       # YaPB Boty
│       ├── dlls/       # Biblioteki gry
│       └── *.cfg       # Pliki konfiguracyjne
├── steamcmd/           # SteamCMD
├── start.sh            # Skrypt startowy
├── stop.sh             # Skrypt zatrzymania
├── restart.sh          # Skrypt restartu
├── status.sh           # Skrypt statusu
└── update.sh           # Skrypt aktualizacji
```

## 🐛 Rozwiązywanie problemów

### Serwer nie startuje

1. Sprawdź logi: `cat server/cstrike/qconsole.log`
2. Upewnij się, że masz zainstalowane biblioteki 32-bit
3. Sprawdź czy port 27015 nie jest zajęty: `netstat -tulpn | grep 27015`

### Błędy bibliotek 32-bit

```bash
# Debian/Ubuntu
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install lib32gcc-s1 lib32stdc++6

# CentOS/RHEL
sudo yum install glibc.i686 libstdc++.i686
```

### Problemy z screen

```bash
# Sprawdź sesje screen
screen -ls

# Zabij wszystkie sesje cs16
killall -9 hlds_linux
```

## 📚 Przydatne linki

- [ReHLDS - GitHub](https://github.com/dreamstalker/rehlds)
- [ReGameDLL_CS - GitHub](https://github.com/s1lentq/ReGameDLL_CS)
- [ReAPI - GitHub](https://github.com/s1lentq/reapi)
- [Metamod-r - GitHub](https://github.com/theAsmodai/metamod-r)
- [AMX Mod X - Oficjalna strona](https://www.amxmodx.org/)
- [YaPB - GitHub](https://github.com/yapb/yapb)
- [YaPB Wiki](https://yapb.jeefo.net/wiki/)

## 📄 Licencja

MIT License - możesz swobodnie używać i modyfikować ten projekt.

---

**Miłej gry! 🎮**