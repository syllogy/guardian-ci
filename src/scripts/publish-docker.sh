VERSION=$(cat VERSION)
if [[ -z $VERSION ]]; then
  echo "no VERSION file present"
  exit 1
fi

CONTAINER="bishopfox/$RELEASE_NAME"

DOCKER_TAG="$VERSION"
if [[ -n $CANDIDATE ]]; then
  DOCKER_TAG="$DOCKER_TAG-$CIRCLE_SHA1"
fi

build() {
  docker build --pull --no-cache -t "$CONTAINER" .
}

push_version() {
  local TAG=$1
  docker tag "$CONTAINER:latest" "$TAG"
	docker push "$TAG"
}

push_latest() {
  docker push "$CONTAINER:latest"
}

push_migration() {
  local TAG=$1

  docker build -t "$CONTAINER:migrate" ./migrations/

  docker tag "$CONTAINER:migrate" "$TAG"
	docker push "$TAG"
}


echo "$DOCKER_PASS" | docker login --username "$DOCKER_USER" --password-stdin

build

push_version "$CONTAINER:$DOCKER_TAG"

push_latest

if [[ -f migrations/Dockerfile ]]; then
  push_migration "$CONTAINER:migrate:$DOCKER_TAG"
fi
