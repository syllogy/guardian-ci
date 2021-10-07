#!/usr/bin/env bash
set -euo pipefail


VERSION=$(cat VERSION)
if [[ -z $VERSION ]]; then
    echo "no VERSION file present"
    exit 1
fi

if [[ -z $IMAGE_NAME ]]; then
    CONTAINER="bishopfox/$RELEASE_NAME"
else
    CONTAINER="bishopfox/$IMAGE_NAME"
fi

VERSIONED_TAG="$VERSION"
NAMED_TAG="stable"
if [[ -n $CANDIDATE ]]; then
    VERSIONED_TAG="$VERSIONED_TAG-$CIRCLE_SHA1"
    NAMED_TAG="latest"
fi

build() {
    docker build --pull --no-cache -t "$CONTAINER" "$DOCKERFILE_PATH"
}

buildx() {
    docker buildx build \
      --platform "$PLATFORMS" \
      --no-cache \
      --tag "$CONTAINER:$VERSIONED_TAG" \
      --tag "$CONTAINER:$NAMED_TAG" \
      --build-arg AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
      --build-arg AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
      --build-arg AWS_REGION="$AWS_REGION" \
      --push \
      .
}

push_version() {
    local TAG="$1"

    docker tag "$CONTAINER:latest" "$TAG"

    docker push "$TAG"
}

build_migration() {
    docker build -t "$CONTAINER:migrate" ./migrations/
}

push_migration() {
    local TAG="$1"

    docker tag "$CONTAINER:migrate" "$TAG"

    docker push "$TAG"
}


echo "$DOCKER_PASS" | docker login --username "$DOCKER_USER" --password-stdin

if [[ -n "$DOCKER_BUILDX" ]]; then
    buildx
else
    build
    push_version "$CONTAINER:$VERSIONED_TAG"
    push_version "$CONTAINER:$NAMED_TAG"
fi

if [[ -f migrations/Dockerfile ]]; then
    build_migration
    push_migration "$CONTAINER:migrate-$VERSIONED_TAG"
    push_migration "$CONTAINER:migrate-$NAMED_TAG"
fi
