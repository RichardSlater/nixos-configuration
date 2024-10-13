#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "use sudo and retry"
  exit
fi

echo "Reading environment."
source ./.env

if [[ -z "${USER_HASHED_PASSWORD}" ]]; then
    echo "USER_HASHED_PASSWORD not in environment, set it and retry"
    exit
fi

export USER_HASHED_PASSWORD
export HOST

echo "Substituting variables"
envsubst '$USER_HASHED_PASSWORD' < ./configuration.nix > ./configuration_merged.nix
diff configuration_merged.nix configuration.nix

cp ./configuration_merged.nix /etc/nixos/configuration.nix
cp ./${HOST}/hardware-configuration.nix /etc/nixos/hardware-configuration.nix

rm configuration_merged.nix

sudo nixos-rebuild switch
