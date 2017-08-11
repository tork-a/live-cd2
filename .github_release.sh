#!/bin/bash

set -e

# install latest hub 2017.08.04
git clone -b v2.3.0-pre10 https://github.com/github/hub.git
(cd hub; ./script/build; sudo cp bin/hub /usr/local/bin/)

mkdir -p ~/.config/
echo "github.com:" > ~/.config/hub
echo "- user: k-okada" >> ~/.config/hub
echo "  oauth_token: $GITHUB_ACCESS_TOKEN" >> ~/.config/hub

set -x
csplit CHANGELOG.rst '/^------------/' '{*}'
aws_files=""
for iso in release/*.iso ; do
    filename=`basename $iso .iso`-${CIRCLE_TAG//./_}.iso
    aws_files="$aws_files"$'\n'"[Custom LIVE-CD $filename](https://s3-ap-northeast-1.amazonaws.com/live-cd2/$filename)"$'\n'
    aws s3 cp $iso s3://live-cd2/$filename  --acl public-read
done
hub release; sleep 10
hub release create -p -m "$CIRCLE_TAG"$'\n\n'"$aws_files"$'\n\n'"`sed '$d' xx01`"$'\n\n'"Released on `date '+%Y/%m/%d %H:%M:%S'`" $CIRCLE_TAG

