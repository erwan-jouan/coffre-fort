IMAGE   := coffre-fort
IMAGE_VERSION   := 1.0.1
ENC     ?= secrets.yml.enc
SRC     ?= secrets.yml
PORT    ?= 9371

SHELL   := /bin/bash

.PHONY: build encrypt decrypt serve keychain-store help

## build: build the Docker image
build:
	docker build -t $(IMAGE):$(IMAGE_VERSION) .

## encrypt: encrypt SRC into ENC  (make encrypt SRC=secrets.yml ENC=secrets.yml.enc)
encrypt: build
	@COFFRE_FORT_PASSWORD="$$(security find-generic-password -s coffre-fort -a coffre-fort -w)" \
	docker run --rm \
	  --user "$$(id -u):$$(id -g)" \
	  -e COFFRE_FORT_PASSWORD \
	  -v "$$(pwd):/data" \
	  $(IMAGE) encrypt /data/$(SRC) /data/$(ENC)

## decrypt: decrypt ENC to stdout  (make decrypt ENC=secrets.yml.enc)
decrypt: build
	@COFFRE_FORT_PASSWORD="$$(security find-generic-password -s coffre-fort -a coffre-fort -w)" \
	docker run --rm \
	  -e COFFRE_FORT_PASSWORD \
	  -v "$$(pwd):/data" \
	  $(IMAGE) decrypt /data/$(ENC) /data/$(SRC)

## serve: decrypt via Keychain, then start with Docker Compose  (make serve ENC=secrets.yml.enc PORT=9371)
serve: build
	@COFFRE_FORT_PASSWORD="$$(security find-generic-password -s coffre-fort -a coffre-fort -w)" \
	PORT=$(PORT) ENC=$(ENC) docker compose up coffre-fort

## keychain-store: save master password in Keychain (one-time setup)
keychain-store:
	@read -s -p "Master password: " pw && echo && \
	  security delete-generic-password -s coffre-fort -a coffre-fort 2>/dev/null; \
	  security add-generic-password -s coffre-fort -a coffre-fort -w "$$pw" && \
	  echo "Password stored in Keychain."

## help: show usage
help: build
	@docker run --rm --entrypoint python3 $(IMAGE) main.py