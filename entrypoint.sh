#!/bin/bash

# Set work directory
if [ -n "${WORK_DIR}" ]; then
  cd $WORK_DIR
fi

if [ -z "$GITHUB_TOKEN" ]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

if [ -z "$GITHUB_REPOSITORY" ]; then
	echo "Set the GITHUB_REPOSITORY env variable."
	exit 1
fi

# config
URI=https://api.github.com
API_VERSION=v3
API_HEADER="Accept: application/vnd.github.${API_VERSION}+json; application/vnd.github.antiope-preview+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
TITLE="Composer Vulnerability Report(`date "+%Y/%m/%d"`)"

PHP_AUDIT_MESSAG=$(php `which composer` audit -f json --locked)
PAYLOAD="`php /opt/message-composer-audit.php "${PHP_AUDIT_MESSAG}"`"

# exits error
if [ $? != 0 ]; then
  echo $PAYLOAD
  exit 1
fi

# LABEL setting
ARR=(${ISSUE_LABELS//,/ })
LABEL_ARRAY="["
for STR in "${ARR[@]}";
do
 LABEL_ARRAY="${LABEL_ARRAY}\"${STR}\","
done
LABEL_ARRAY="${LABEL_ARRAY%,}]"

JSON='{"title":"'"${TITLE}"'","body":"'"${PAYLOAD}"'","labels":'${LABEL_ARRAY}'}'

curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" -d "${JSON}" -H "Content-Type: application/json" -X POST "${URI}/repos/${GITHUB_REPOSITORY}/issues"

TITLE="NPM Vulnerability Report(`date "+%Y/%m/%d"`)"

NODE_VERSION="20.3.0"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
rm -rf "$NVM_DIR/versions/node/v$NODE_VERSION/"
nvm install ${NODE_VERSION}
nvm use ${NODE_VERSION}
NPM_AUDIT_MESSAG=$(npm audit --json --package-lock-only)
PAYLOAD="`php /opt/message-npm-audit.php "${NPM_AUDIT_MESSAG}"`"

# exits error
if [ $? != 0 ]; then
  echo $PAYLOAD
  exit 1
fi
JSON='{"title":"'"${TITLE}"'","body":"'"${PAYLOAD}"'","labels":'${LABEL_ARRAY}'}'

curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" -d "${JSON}" -H "Content-Type: application/json" -X POST "${URI}/repos/${GITHUB_REPOSITORY}/issues"