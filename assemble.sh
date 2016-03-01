#!/bin/bash

# fail if anything errors
set -e
# fail if a function call is missing an argument
set -u

# load properties to be able to use them in here
source nexus-book.properties

echo "version set to $version"

if [ $publish_master == "true" ]; then
    echo "Preparing for master deployment"
    
    rm -rf target/site/reference
    rm -rf target/site/pdf
    rm -rf target/site/other
    mkdir -p target/site/reference
    mkdir -p target/site/pdf
    mkdir -p target/site/other
fi

echo "Preparing for version $version deployment"
rm -rf target/site/$version/reference
rm -rf target/site/$version/pdf
rm -rf target/site/$version/other
mkdir -p target/site/$version/reference
mkdir -p target/site/$version/pdf
mkdir -p target/site/$version/other

if [ $publish_master == "true" ]; then
    echo "Copying for master deployment"
    cp -r target/book-nexus.chunked/*  target/site/reference
    cp target/book-nexus.pdf target/site/pdf/nxbook-pdf.pdf
    cp target/sonatype-nexus-eval-guide.pdf target/site/pdf/sonatype-nexus-eval-guide.pdf
    cp target/book-nexus.epub target/site/other/nexus-book.epub
fi

echo "Copying for version $version deployment"

# NOT copying the overall index into version specific directories since links would be broken and 
# it is an overall index
cp -r target/book-nexus.chunked/* target/site/$version/reference
cp target/book-nexus.pdf target/site/$version/pdf/nxbook-pdf.pdf
cp target/sonatype-nexus-eval-guide.pdf target/site/$version/pdf/sonatype-nexus-eval-guide.pdf
cp target/book-nexus.epub target/site/$version/other/nexus-book.epub
echo "Copying redirector"
cp -v site/global/index.html target/site/$version/


if [ $publish_master == "true" ]; then
echo "Invoking templating process for master"
../nexus-documentation-wrapper/apply-template.sh ../nexus-book/target/site/reference ../nexus-book/nexus-book.properties "block" "../../" "book"
fi

echo "Invoking templating process for $version "
../nexus-documentation-wrapper/apply-template.sh ../nexus-book/target/site/$version/reference ../nexus-book/nexus-book.properties "block" "../../../" "book"

if [ $publish_index == "true" ]; then
    echo "Preparing root index for deployment"
    echo "  Copying content and resources"
    cp target/index.html target/site

../nexus-documentation-wrapper/apply-template.sh ../nexus-book/target/site/ ../nexus-book/nexus-book.properties "none" "../../" "article"
#    python template.py -p 'target/site/' -b '<body class="article">' -t "./" -v "$version"
    cp -rv site/global/sitemap*.xml target/site
    echo "... done"
fi
