#!/bin/bash
set -euo pipefail

VERBOSE=0

# parse args
for arg in "$@"; do
  case "$arg" in
    -v|--verbose)
      VERBOSE=1
      # remove this flag from $@ so it doesn't get treated as the device
      shift
      ;;
  esac
done

# now $1 should be the device
DEVICE="${1:-}"

if [[ $VERBOSE -eq 1 ]]; then
  set -x
fi

BASE_URL="https://cdimage.ubuntu.com/releases/24.04/release"
IMG_NAME="ubuntu-24.04.2-preinstalled-server-arm64+raspi.img.xz"
SHA_FILE="SHA256SUMS"
CLOUD_INIT_DIR="cloud-init"

echo "[DEBUG] starting script with DEVICE=$DEVICE"

if [[ -z "$DEVICE" ]]; then
  echo "[ERROR] usage: $0 /dev/sdX"
  exit 1
fi
if [[ ! -b "$DEVICE" ]]; then
  echo "[ERROR] $DEVICE is not a block device"
  exit 1
fi

echo "[DEBUG] downloading SHA256SUMS from $BASE_URL/$SHA_FILE"
curl --fail --location --progress-bar "$BASE_URL/$SHA_FILE" -o "$SHA_FILE"
echo "[DEBUG] SHA256SUMS downloaded"

echo "[DEBUG] extracting hash for $IMG_NAME"
EXPECTED_HASH=$(grep "\*$IMG_NAME" "$SHA_FILE" | awk '{print $1}')
echo "[DEBUG] expected hash: $EXPECTED_HASH"
if [[ -z "$EXPECTED_HASH" ]]; then
  echo "[ERROR] could not find hash for $IMG_NAME in $SHA_FILE"
  exit 1
fi

if [[ ! -f "$IMG_NAME" ]]; then
  echo "[DEBUG] image not found, downloading from $BASE_URL/$IMG_NAME"
  wget --show-progress -O "$IMG_NAME" "$BASE_URL/$IMG_NAME"
else
  echo "[DEBUG] image $IMG_NAME already exists"
fi

echo "[DEBUG] verifying sha256 for $IMG_NAME"
DOWNLOADED_HASH=$(sha256sum "$IMG_NAME" | awk '{print $1}')
echo "[DEBUG] got hash: $DOWNLOADED_HASH"
if [[ "$DOWNLOADED_HASH" != "$EXPECTED_HASH" ]]; then
  echo "[ERROR] checksum mismatch!"
  exit 1
fi
echo "[DEBUG] checksum OK"

echo "[DEBUG] will write image to $DEVICE"
read -p ">>> this will erase $DEVICE and flash $IMG_NAME. continue? (yes/[no]) " ans
[[ "$ans" == "yes" ]] || { echo "[DEBUG] aborted by user"; exit 1; }

echo "[DEBUG] flashing image with dd bs=32M"
xzcat "$IMG_NAME" | sudo dd of="$DEVICE" bs=32M status=progress conv=fsync

sync
sleep 2

BOOT_PART="${DEVICE}1"
[[ -b "$BOOT_PART" ]] || BOOT_PART="${DEVICE}p1"
echo "[DEBUG] using boot partition $BOOT_PART"
if [[ ! -b "$BOOT_PART" ]]; then
  echo "[ERROR] could not find boot partition"
  exit 1
fi

TMPMNT=$(mktemp -d)
echo "[DEBUG] mounting $BOOT_PART to $TMPMNT"
sudo mount "$BOOT_PART" "$TMPMNT"

echo "[DEBUG] copying cloud-init files from $CLOUD_INIT_DIR"
if [[ -f "$CLOUD_INIT_DIR/user-data" ]]; then
  echo "[DEBUG] copying user-data"
  sudo cp "$CLOUD_INIT_DIR/user-data" "$TMPMNT/user-data"
else
  echo "[WARN] user-data not found in $CLOUD_INIT_DIR"
fi
if [[ -f "$CLOUD_INIT_DIR/network-config" ]]; then
  echo "[DEBUG] copying network-config"
  sudo cp "$CLOUD_INIT_DIR/network-config" "$TMPMNT/network-config"
else
  echo "[WARN] network-config not found in $CLOUD_INIT_DIR"
fi

sync
echo "[DEBUG] unmounting $TMPMNT"
sudo umount "$TMPMNT"
rmdir "$TMPMNT"

echo "[DEBUG] done!"
