#!/bin/bash

# fail if anything errors
set -e
# fail if a function call is missing an argument
set -u

# load properties to be able to use them in here
source nexus-book.properties

echo "nexus_version set to $nexus_version"

if [ $publish_master == "true" ]; then
    echo "Preparing for master deployment"
    
    rm -rf target/site/reference
    rm -rf target/site/pdf
    rm -rf target/site/other
    mkdir -p target/site/reference
    mkdir -p target/site/pdf
    mkdir -p target/site/other
fi

echo "Preparing for version $nexus_version deployment"
rm -rf target/site/$nexus_version/reference
rm -rf target/site/$nexus_version/pdf
rm -rf target/site/$nexus_version/other
mkdir -p target/site/$nexus_version/reference
mkdir -p target/site/$nexus_version/pdf
mkdir -p target/site/$nexus_version/other

if [ $publish_master == "true" ]; then
    echo "Copying for master deployment"
    cp -r target/book-nexus.chunked/*  target/site/reference
    cp target/book-nexus.pdf target/site/pdf/nxbook-pdf.pdf
    cp target/sonatype-nexus-eval-guide.pdf target/site/pdf/sonatype-nexus-eval-guide.pdf
    cp target/book-nexus.epub target/site/other/nexus-book.epub
fi

echo "Copying for version $nexus_version deployment"

# NOT copying the overall index into version specific directories since links would be broken and 
# it is an overall index
cp -r target/book-nexus.chunked/* target/site/$nexus_version/reference
cp target/book-nexus.pdf target/site/$nexus_version/pdf/nxbook-pdf.pdf
cp target/sonatype-nexus-eval-guide.pdf target/site/$nexus_version/pdf/sonatype-nexus-eval-guide.pdf
cp target/book-nexus.epub target/site/$nexus_version/other/nexus-book.epub
echo "Copying redirector"
cp -v site/global/index.html target/site/$nexus_version/


if [ $publish_master == "true" ]; then
echo "Invoking templating process for master"

../nexus-documentation-wrapper/apply-template.sh ../nexus-book/target/site/reference "Nexus Documentation" "searchID" "block" "$nexus_version" "../"
fi

echo "Invoking templating process for $nexus_version "
../nexus-documentation-wrapper/apply-template.sh ../nexus-book/target/site/$nexus_version/reference "Nexus Documentation" "searchID" "block" "$nexus_version" "../../"

#if [ $publish_index == "true" ]; then
#    echo "Preparing root index for deployment"
#    echo "  Copying content and resources"
#    cp target/index.html target/site
#    cp -r site/css target/site
#    cp -r site/js target/site
#    cp -r site/images target/site
#    python template.py -p 'target/site/' -b '<body class="article">' -t "./" -v "$nexus_version"
#    cp -rv site/global/sitemap*.xml target/site
#    echo "... done"
#fi
