#!/bin/bash -e

USER="your_atlas_account"
ATLAS_TOKEN="your_atlas_tokens"
ATLAS_URL="https://atlas.hashicorp.com/api/v1"

function usage {
    echo "$0 - Upload or remote your box on https://atlas.hashicorp.com"
    echo ""
    echo "Usage: $0 [--upload|--remove|--version|--help] <BOX_FILE_NAME>"
    exit 1
}

create_box() {
  if wget -O /dev/null "${ATLAS_URL}/box/$USER/$BOX_NAME" 2>&1 | grep -q 'ERROR 404'; then
    #Create box, because it doesn't exists
    echo "*** Creating box: ${BOX_NAME}, Short Description: $SHORT_DESCRIPTION"
    curl -s ${ATLAS_URL}/boxes -X POST -d box[name]="$BOX_NAME" -d box[short_description]="${SHORT_DESCRIPTION}" \
      -d box[is_private]=false -d access_token="$ATLAS_TOKEN" > /dev/null
  fi
}

remove_box() {
  BOX_NAME=$(echo $BOX_FILE | cut -d'.' -f 1)
  echo "*** Removing box: $USER/$BOX_NAME"
  curl -s ${ATLAS_URL}/box/$USER/$BOX_NAME -X DELETE -d access_token="$ATLAS_TOKEN"

  #Remove previous version (always keep just one - latest version - recently uploaded)
  # if [ "$CURRENT_VERSION" != "null" ]; then
  #   echo "*** Removing previous version: ${ATLAS_BOX_URL}/version/$CURRENT_VERSION"
  #   curl -s ${ATLAS_BOX_URL}/version/$CURRENT_VERSION -X DELETE -d access_token="$ATLAS_TOKEN" > /dev/null
  # fi
}

upload_box() {
  BOX_NAME=$(echo $BOX_FILE | cut -d'.' -f 1)
  DESCRIPTION=$BOX_NAME
  SHORT_DESCRIPTION=$BOX_NAME
  MAIN_VERSION="$(date +%Y%m%d)"

  create_box

  echo "*** Getting current version of the box (if exists)"
  CURRENT_VERSION=$(curl -s ${ATLAS_URL}/box/$USER/$BOX_NAME -X GET -d access_token="$ATLAS_TOKEN" | jq -r ".current_version.version")

  VERSION=${MAIN_VERSION}.0
  if [ "$CURRENT_VERSION" != "null" ]; then
    SUB_VERSION=$(echo $CURRENT_VERSION | cut -d'.' -f 2)
    SUB_VERSION=$((SUB_VERSION + 1))
    VERSION=${MAIN_VERSION}.${SUB_VERSION}
  fi

  echo "*** Cureent version of the box: $CURRENT_VERSION"
  ATLAS_BOX_URL=${ATLAS_URL}/box/$USER/$BOX_NAME/
  curl -sS ${ATLAS_BOX_URL}/versions -X POST -d version[version]="$VERSION" -d access_token="$ATLAS_TOKEN" > /dev/null
  curl -sS ${ATLAS_BOX_URL}/version/$VERSION -X PUT -d version[description]="$DESCRIPTION" -d access_token="$ATLAS_TOKEN" > /dev/null
  curl -sS ${ATLAS_BOX_URL}/version/$VERSION/providers -X POST -d provider[name]='virtualbox' -d access_token="$ATLAS_TOKEN" > /dev/null
  UPLOAD_PATH=$(curl -sS ${ATLAS_BOX_URL}/version/$VERSION/provider/virtualbox/upload?access_token=$ATLAS_TOKEN | jq -r '.upload_path')

  echo "*** Uploading \"${BOX_FILE}\" to $UPLOAD_PATH as version [$VERSION]"
  curl -s -X PUT --upload-file $BOX_FILE $UPLOAD_PATH
  curl -s ${ATLAS_BOX_URL}/version/$VERSION/release -X PUT -d access_token="$ATLAS_TOKEN" > /dev/null
}

list_box() {
  BOX_NAME=$(echo $BOX_FILE | cut -d'.' -f 1)
  OUTPUT=$(curl -s ${ATLAS_URL}/box/$USER/$BOX_NAME -X GET -d access_token="$ATLAS_TOKEN")
  echo "tag     : "$(echo $OUTPUT | jq -r ".tag")
  echo "name    : "$(echo $OUTPUT | jq -r ".name")
  echo "version : "$(echo $OUTPUT | jq -r ".current_version.version")
  echo "created : "$(echo $OUTPUT | jq -r ".created_at")
  echo "updated : "$(echo $OUTPUT | jq -r ".updated_at")
}

if [ $# -lt 1 ] || [ "$1" = "-h" ]; then
    usage
fi

while [ $# -gt 0 ]; do
    case "$1" in
    -h|--help) usage; exit 0 ;;
    --upload) export BOX_FILE=$2; upload_box; shift ;;
    --remove) export BOX_FILE=$2; remove_box; shift ;;
    --version) export BOX_FILE=$2; list_box; shift ;;
    --debug) set -o xtrace ;;
    (-*) usage; exit 1 ;;
    (*)  usage; exit 1 ;;
    esac
    shift
done
