#!/bin/bash
set -eu
if ! command -v python3 >/dev/null; then echo 'Python 3 is required.' >&2; exit 1; fi
if ! command -v codex >/dev/null; then echo 'Install Codex CLI first: https://developers.openai.com/codex/cli' >&2; exit 1; fi
read -r -p 'Windows Tailscale IPv4 address: ' BRIDGE_IP
python3 - "$BRIDGE_IP" <<'PY'
import ipaddress, os, pathlib, sys
try:
    ip = ipaddress.ip_address(sys.argv[1])
    if ip.version != 4 or ip not in ipaddress.ip_network('100.64.0.0/10'):
        raise ValueError()
except ValueError:
    sys.exit('Enter a valid Tailscale IPv4 address (100.64.0.0/10).')
path = pathlib.Path.home() / '.codex' / 'config.toml'
path.parent.mkdir(parents=True, exist_ok=True)
old = path.read_text(encoding='utf-8') if path.exists() else ''
try:
    import tomllib
except ImportError:
    sys.exit('Python 3.11 or newer is required to validate the existing TOML safely.')
try:
    config = tomllib.loads(old)
except tomllib.TOMLDecodeError as exc:
    sys.exit(f'Existing config is not valid TOML: {exc}')
if 'school' in config.get('mcp_servers', {}):
    sys.exit('A school MCP already exists. Inspect it before making changes.')
new = old.rstrip() + f'\n\n[mcp_servers.school]\nurl = "http://{ip}:8000/mcp"\nbearer_token_env_var = "SCHOOL_MCP_TOKEN"\ntool_timeout_sec = 120\n'
tomllib.loads(new)
temp = path.with_name('config.toml.school-tmp')
try:
    with temp.open('x', encoding='utf-8') as f: f.write(new)
    if path.exists(): os.chmod(temp, path.stat().st_mode & 0o777)
    else: os.chmod(temp, 0o600)
    os.replace(temp, path)
finally:
    if temp.exists(): temp.unlink()
print(f'Configured school MCP in {path}')
PY
mkdir -p "$HOME/.local/bin"
LAUNCHER="$HOME/.local/bin/school-codex"
if [ -e "$LAUNCHER" ]; then echo "Launcher already exists: $LAUNCHER; leaving it unchanged."; exit 0; fi
umask 077
cat > "$LAUNCHER" <<'EOF'
#!/bin/bash
read -r -s -p 'MCP password: ' SCHOOL_MCP_TOKEN
echo
export SCHOOL_MCP_TOKEN
exec codex "$@"
EOF
chmod 700 "$LAUNCHER"
echo "Run $LAUNCHER to start Codex."

