#!/bin/sh
set -e

cp $DOC_BASE_FOLDER/index.html.md /usr/src/app/source

cd /usr/src/app/source
bundle exec middleman build --clean
#Getting back to home folder to allow relative doc_base_folder
cd $GITHUB_WORKSPACE
mv /usr/src/app/build $DOC_BASE_FOLDER

if [[ "$ZIP_BUILD" == "true" ]]; then
    echo "Zipping Slate documentation"
    zip -r $DOC_BASE_FOLDER/documentation.zip $DOC_BASE_FOLDER/build
fi