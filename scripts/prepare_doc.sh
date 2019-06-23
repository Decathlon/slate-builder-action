#!/bin/sh
set -e

if [ ! -z "$TEMPLATE_REPO" ]; then
    echo "Overriding default slate template with the provided ones";
    mkdir /usr/src/template || echo "Template folder already exists"
    cd /usr/src/template
    git init
    git pull https://${GH_PAT}@github.com/$TEMPLATE_REPO
    rm -rf /usr/src/app/source/*
    cp -R /usr/src/template/* /usr/src/app/source
    cp index.html.md /usr/src/index.html.md || echo "No custom index file detected using default one."
    cd $GITHUB_WORKSPACE
fi

cat /usr/src/index.html.md > $DOC_BASE_FOLDER/index.html.md.tmp

# Grab all .md files and build them
# Exception: REAMDE file

for i in $(ls $DOC_BASE_FOLDER/*.md); do
    if [ "$i" != $DOC_BASE_FOLDER/README.md ]; then
        echo "Building $i..."
        cat $i >> $DOC_BASE_FOLDER/index.html.md.tmp;
        echo -e "\n" >> $DOC_BASE_FOLDER/index.html.md.tmp;
    fi
done;

mv $DOC_BASE_FOLDER/index.html.md.tmp $DOC_BASE_FOLDER/index.html.md
exec "$@"