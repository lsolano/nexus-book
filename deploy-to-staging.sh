#!/bin/bash

# fail if anything errors
set -e
# fail if a function call is missing an argument
set -u

# load properties to be able to use them in here
source nexus-book.properties

echo "version set to $version"

# can we get rid of this? 
./assemble.sh

function rsyncToDest {
    source=$1
    target=/var/www/domains/sonatype.com/www/shared/books/nexus-book/$2
    options=$3
    connection=deployer@marketing02.int.sonatype.com
    echo "Uploading $1 to $2 on $connection"
    ssh $connection mkdir -pv $target
    rsync -e ssh $options -av target/$source $connection:$target
}

if [ $publish_master == "true" ]; then
    rsyncToDest site/reference/ reference --delete
    rsyncToDest site/pdf/ pdf --delete
    rsyncToDest site/other/ other --delete
fi

rsyncToDest site/$version/reference/ $version/reference --delete
rsyncToDest site/$version/pdf/ $version/pdf --delete
rsyncToDest site/$version/other/ $version/other --delete
rsyncToDest site/$version/index.html $version --delete

if [ $publish_index == "true" ]; then
    rsyncToDest site/index.html  "" --delete
    rsyncToDest site/sitemap.xml "" --delete
    rsyncToDest site/sitemap-nexus-2.xml  "" --delete
    rsyncToDest site/sitemap-nexus-3.xml  "" --delete
    rsyncToDest site/js/ js --delete
    rsyncToDest site/images/ images --delete
    rsyncToDest site/css/ css --delete
    rsyncToDest site/sitemap.xml "" --delete
fi

# Important to use separate rsync run WITHOUT --delete since its an archive! and we do NOT want old archives to be deleted
#rsyncToStage archive/ archive

