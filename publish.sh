#!/bin/sh
set -e

# Baut und überträgt beide Auslieferungen nacheinander.
#
# Die Adressen unterscheiden sich nur in Untertitel und Kontaktadresse; alles
# Weitere steht einmal in config/_default/ (siehe dort). Weil canonifyURLs
# gesetzt ist, steckt die baseURL in nahezu jeder erzeugten Datei -- es sind
# also wirklich zwei Bauten, nicht einer, der zweimal hochgeladen wird.
#
# Argumente gehen an rsync durch. Vor einem Lauf mit Löschungen lohnt sich:
#   ./publish.sh --dry-run

host=serverprofis

# Beide Ziele liegen auf demselben Server. Ohne das Folgende baut jeder
# rsync-Aufruf seine eigene SSH-Verbindung auf -- und weil die Schlüssel in
# Secretive liegen (~/.ssh/config: IdentityAgent, Secure Enclave), verlangt
# jede Verbindung eine eigene Freigabe per Touch ID.
#
# ControlMaster hält die erste Verbindung offen; der zweite rsync-Aufruf
# hängt sich an dieselbe Sitzung und authentifiziert sich nicht neu. Eine
# Freigabe statt zwei, und der zweite Verbindungsaufbau entfällt ganz.
#
# %C ist ein Kürzel aus Host, Port und Benutzer -- ssh setzt es selbst ein,
# deshalb steht es hier in Anführungszeichen und nicht in der Shell.
ssh_control='/tmp/ssh-publish-%C'
ssh_opts="-o ControlMaster=auto -o ControlPath=$ssh_control -o ControlPersist=60"

# Verbindung am Ende schließen, auch bei Abbruch -- sonst bliebe sie noch
# ControlPersist-Sekunden offen.
cleanup() {
	ssh -O exit -o ControlPath="$ssh_control" "$host" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

publish() {
	environment=$1
	path=$2
	shift 2

	echo "==> $environment -> $host:$path"

	# public/ vorher leeren: Hugo räumt dort nichts weg, und zwischen den
	# beiden Bauten ändert sich wegen canonifyURLs jede einzelne Datei.
	rm -rf public

	# --gc räumt unbenutzte Bildfassungen aus resources/_gen, --minify
	# verkleinert zusätzlich das HTML (CSS und JS laufen schon über die
	# Asset-Pipeline).
	hugo --gc --minify --environment "$environment"

	# --delete: ohne das bleibt auf dem Server alles liegen, was dort einmal
	# existiert hat. Bis September 2026 waren das rund 40 MB unbenutzter
	# Bilder samt privater Fotos unter /images/me/ und Seiten, die es längst
	# nicht mehr gibt. Beide Zielverzeichnisse enthalten ausschließlich
	# diese Website.
	rsync -av --delete -e "ssh $ssh_opts" "$@" public/ "$host:$path"
}

publish beruehrungen sites/xn--berhrungen-ceb.com/ "$@"
publish innenreise   sites/innenreisebegleitung.de/ "$@"
