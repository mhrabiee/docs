#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
ROOT=$SCRIPT_PATH"/bin"
CONTENT_ROOT=$ROOT"/Content"
WWW_ROOT=$ROOT"/site"
NS_DIST_ROOT=$ROOT"/nativescript"
NG_DIST_ROOT=$ROOT"/angular"

DOCS_ROOT=$SCRIPT_PATH"/../../docs"
MODULES_ROOT=$SCRIPT_PATH"/../../NativeScript"
NG_ROOT=$SCRIPT_PATH"/../../nativescript-angular"
SDK_ROOT=$SCRIPT_PATH"/../../nativescript-sdk-examples-ng"
SIDEKICK_ROOT=$SCRIPT_PATH"/../../sidekick-docs"

if [ -d "$ROOT" ]; then
	rm -rf $ROOT
fi

mkdir $ROOT

if [ ! -d "$CONTENT_ROOT" ]; then
	mkdir $CONTENT_ROOT
fi

if [ ! -d "$WWW_ROOT" ]; then
	mkdir $WWW_ROOT
fi

bundle config build.nokogiri --use-system-libraries

cd $SIDEKICK_ROOT
bundle install
jekyll build --config _config.yml

cd $SDK_ROOT
./build-docs.sh

cd $NG_ROOT
./build-doc-snippets.sh

cd $MODULES_ROOT
./build-docs.sh

cp $SCRIPT_PATH"/_config_angular.yml" $SCRIPT_PATH"/_config_nativescript.yml" $SCRIPT_PATH"/_config.yml" $ROOT

cd $DOCS_ROOT"/build"
for JEKYLL_DIR in {_assets,_includes,_layouts,_plugins,fonts,images,web.config}; do
	rsync -a --delete $JEKYLL_DIR $CONTENT_ROOT
done

cp -R $DOCS_ROOT"/docs/./" $MODULES_ROOT"/bin/dist/cookbook" $MODULES_ROOT"/bin/dist/snippets" $NG_ROOT"/bin/dist/snippets" $SDK_ROOT"/dist/code-samples" $CONTENT_ROOT
cp $SCRIPT_PATH"/nginx.conf" $CONTENT_ROOT

cd $ROOT
export JEKYLL_ENV="nativescript"
jekyll build --config _config_nativescript.yml,_config.yml
export JEKYLL_ENV="angular"
jekyll build --config _config_angular.yml,_config.yml

cp -R $MODULES_ROOT"/bin/dist/api-reference" $SIDEKICK_ROOT"/sidekick" $WWW_ROOT
cp -R $NS_DIST_ROOT"/./" $WWW_ROOT
cp -R $NG_DIST_ROOT"/./" $WWW_ROOT"/angular"
