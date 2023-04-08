#! bin/bash

# Display Quarto's edge and latest release
# 
# Usage
#   sh latest.sh [ edge | latest ]
#   sh latest.sh    -> displays edge

OWNER="quarto-dev"
REPO="quarto-cli"
RELEASE="edge"
ARCH="arm64"
OS="linux"
EXT="deb"
CONTAINS=${OS}-${ARCH}.$EXT

# uncomment to show all
# CONTAINS=quarto

# curl: -s for silent, -L to follow redirects
# jq: -r for raw string output

if [ ${RELEASE} = "edge" ]; then
    QUERY="?per_page=1"
    FILTER='.[0]' 
else
    QUERY="/${RELEASE}"
    FILTER='.' 
fi

echo "Version name"
curl -sL https://api.github.com/repos/${OWNER}/${REPO}/releases${QUERY} \
   | jq -r $FILTER \
   | jq -r '.name'

echo "Download URL"
curl -sL https://api.github.com/repos/${OWNER}/${REPO}/releases${QUERY} \
   | jq -r $FILTER \
   | jq --arg STR ${CONTAINS} \
        -r '.assets[] | select(.browser_download_url | contains($STR)) | .browser_download_url'

# uncomment to see the whole JSON
# curl -sL https://api.github.com/repos/${OWNER}/${REPO}/releases${QUERY} \
#    | jq .