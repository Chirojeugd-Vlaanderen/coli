#!/bin/bash

# Opgelet! Dit gaat enkel werken als pandoc en texlive-latex-bin
# geinstalleerd  zijn.
# Verder heb je nog een hele nest latex-pakketten nodig, zie
# files/preamble-chiro.tex

# standaardwaarden

VERGADERING="COMMISSIE LINUX"
DATUM=`date +%d/%m/%Y`
DOC_ID=''
DOC_NR=''
INFILE=''
OUTFILE=''

function show_help {
cat << EOF

Creert pdf-verslagen van een markdown inputfile

USAGE: 
  $0 [OPTIONS]... -o OUTPUTFILE INPUTFILE

OPTONS:
  -v VERGADERINGNAAM
  -d VERGADERDATUM
  -i DOCUMENT-ID
  -n DOCUMENT-NR

EXAMPLE:
  $0 -v "COMMISSIE LINUX" -d "29/10/2013" -o out.pdf in.md
EOF
}

while getopts "h?v:d:i:n:o:" opt; do
	case $opt in
		h|\?)
			show_help
			exit 0
			;;
		v)
			VERGADERING=$OPTARG
			;;
		d)
			DATUM=$OPTARG
			;;
		i)
			DOC_ID=$OPTARG
			;;
		n)
			DOC_NR=$OPTARG
			;;
		o)
			OUTFILE=$OPTARG
			;;
	esac
done

# TODO: Als er wat exotische symbolen in vergadering, datum,... zitten,
# dan zijn we de pineut.
# Slashes in datums vangen we wel op.


if [ -z "$OUTFILE" ]; then
	# output file is verplicht
	show_help
	exit 0
fi;

shift $((OPTIND-1))
INFILE=$1

if [ ! -z "$INFILE" ]; then
	INFILE=`realpath "$INFILE"`
fi;

# We gaan ervanuit dat de bestanden die we nodig hebben in een
# subfolder 'files' van de folder van het script staan. Wat niet
# echt proper is. Maar voorlopig werkt het wel.

# Bepaal dus eerst de folder waarin dit script staat:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Maak nu een tijdelijke folder aan, waar we het echte werk
# zullen doen.

WORKINGDIR=`mktemp -d`
pushd $WORKINGDIR
cp $DIR/files/chiro.png .

# door pipes (|) te gebruiken in de sed-expressie ipv forward
# slashes (/) vermijd ik problemen met datums.

sed -e "s|__VERGADERING__|$VERGADERING|;s|__DATUM__|$DATUM|;s|__DOC_ID__|$DOC_ID|;s|__DOC_NR__|$DOC_NR|" $DIR/files/preamble-chiro.txt > ./tmp.tex

pandoc -t latex "$INFILE" >> ./tmp.tex
echo '\end{document}' >> ./tmp.tex

pdflatex tmp.tex

popd

cp -i $WORKINGDIR/tmp.pdf "$OUTFILE"

rm -rf $WORKINGDIR

