#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "use sudo and retry"
  exit
fi

source ./.env

if [[ -z "${USER_HASHED_PASSWORD}" ]]; then
    echo "USER_HASHED_PASSWORD not in environment, set it and retry"
    exit
fi

export USER_HASHED_PASSWORD

cat ./configuration.nix | envsubst > ./configuration_merged.nix
cp ./configuration_merged.nix /etc/nixos/configuration.nix
cp ./${HOST}/hardware-configuration.nix /etc/nixos/configuration.nix

sudo nixos-rebuild switch
