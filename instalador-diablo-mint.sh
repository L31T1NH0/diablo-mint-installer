#!/usr/bin/env bash
set -Eeuo pipefail
trap 'printf "\nFalha na linha %s. Corrija o erro acima e execute novamente.\n" "$LINENO" >&2' ERR

if (( EUID == 0 )); then
    echo 'Execute como usuário normal: bash instalar-diablo-mint.sh' >&2
    exit 1
fi
if [[ $(uname -m) != x86_64 ]] || ! command -v apt-get >/dev/null; then
    echo 'Este instalador requer Linux Mint/Ubuntu de 64 bits (x86_64).' >&2
    exit 1
fi

app="$HOME/.local/share/devilutionx"
data="$HOME/.local/share/diasurgical/devilution"
bin="$HOME/.local/bin"
applications="$HOME/.local/share/applications"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo 'Instalando dependências...'
sudo apt-get update
sudo apt-get install -y ca-certificates curl python3 xz-utils libsdl2-2.0-0 libsdl2-image-2.0-0
mkdir -p "$app" "$data" "$bin" "$applications"

echo 'Baixando DevilutionX oficial...'
curl -fL --retry 3 --connect-timeout 20 \
    https://api.github.com/repos/diasurgical/devilutionx/releases/latest \
    -o "$tmp/release.json"
url=$(python3 - "$tmp/release.json" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    release = json.load(f)
urls = [a['browser_download_url'] for a in release['assets']
        if a['name'] == 'devilutionx-linux-x86_64.tar.xz']
if len(urls) != 1 or not urls[0].startswith('https://github.com/diasurgical/'):
    sys.exit('Não foi possível localizar o pacote oficial Linux x86_64.')
print(urls[0])
PY
)
curl -fL --retry 3 --connect-timeout 20 "$url" -o "$tmp/game.tar.xz"
mkdir "$tmp/game"
tar -xJf "$tmp/game.tar.xz" -C "$tmp/game"
[[ -f "$tmp/game/devilutionx" && -f "$tmp/game/devilutionx.mpq" ]]
cp -a "$tmp/game/." "$app/"

if [[ ! -s "$data/DIABDAT.MPQ" ]]; then
    echo 'Baixando dados de Diablo I (aproximadamente 500 MB)...'
    curl -fL --retry 3 --connect-timeout 20 \
        http://cdn.pvpgn.pro/diablo1/DIABDAT.MPQ -o "$tmp/DIABDAT.MPQ"
    python3 - "$tmp/DIABDAT.MPQ" <<'PY'
import os, sys
p = sys.argv[1]
with open(p, 'rb') as f:
    if f.read(4) != b'MPQ\x1a' or os.path.getsize(p) < 500_000_000:
        sys.exit('Arquivo de dados inválido ou incompleto.')
PY
    mv "$tmp/DIABDAT.MPQ" "$data/DIABDAT.MPQ"
fi
ln -sf "$app/devilutionx.mpq" "$data/devilutionx.mpq"
chmod +x "$app/devilutionx"

# O lançador configura as bibliotecas locais e o diretório dos dados.
python3 - "$app" "$data" "$bin" "$applications" <<'PY'
import pathlib, shlex, sys
app, data, bin_dir, applications = map(pathlib.Path, sys.argv[1:])
launcher = bin_dir / 'devilutionx'
# Substitui apenas o lançador, sem seguir um eventual link antigo.
if launcher.is_symlink():
    launcher.unlink()
launcher.write_text(
    '#!/usr/bin/env bash\nset -e\n'
    + 'export LD_LIBRARY_PATH=' + shlex.quote(str(app)) + '${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\n'
    + 'exec ' + shlex.quote(str(app / 'devilutionx'))
    + ' --data-dir ' + shlex.quote(str(data)) + ' "$@"\n'
)
launcher.chmod(0o755)
def desktop_quote(value):
    return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"').replace('`', '\\`').replace('$', '\\$').replace('%', '%%') + '"'
(applications / 'devilutionx.desktop').write_text(
    '[Desktop Entry]\nType=Application\nName=Diablo (DevilutionX)\n'
    + 'Exec=' + desktop_quote(launcher) + '\n'
    + 'Icon=applications-games\nCategories=Game;RolePlaying;\nTerminal=false\n'
)
PY

"$bin/devilutionx" --version
if command -v update-desktop-database >/dev/null; then
    update-desktop-database "$applications"
fi
echo 'Pronto! Abra Diablo (DevilutionX) pelo menu de aplicativos.'
if [[ -n ${DISPLAY:-}${WAYLAND_DISPLAY:-} ]]; then
    nohup "$bin/devilutionx" > "$data/launch.log" 2>&1 < /dev/null &
fi
