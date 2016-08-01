#!/bin/bash

set -e

git clone -b v2.2.2 https://github.com/github/hub.git;
(cd hub; ./script/build; sudo cp hub /usr/local/bin/)

mkdir -p ~/.config/
echo "github.com:" > ~/.config/hub
echo "- user: k-okada" >> ~/.config/hub
echo "  oauth_token: $GITHUB_ACCESS_TOKEN" >> ~/.config/hub

set -x
csplit CHANGELOG.rst '/^------------/' '{*}'
for iso in $CIRCLE_ARTIFACTS/*.iso ; do
    filename=`basename $iso .iso`-${CIRCLE_TAG//./_}.iso
    aws s3 cp $iso s3://live-cd2/$filename  --acl public-read
    hub releaes create -p $CIRCLE_TAG ; echo "ok"; sleep 10;
    hub releaes
    hub release create -p -m "$CIRCLE_TAG"$'\n'"[Custom LIVE-CD $filename](https://s3-ap-northeast-1.amazonaws.com/live-cd2/$filename)"$'\n\n'"`sed '$d' xx01`"$'\n\n'"Released on `date '+%Y/%m/%d %H:%M:%S'`" $CIRCLE_TAG
done

