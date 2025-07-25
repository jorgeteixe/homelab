default:
  @just --list

flash DEVICE:
  ./cloud-init/flash.sh {{DEVICE}}

encrypt-user-data:
  sops --encrypt --input-type yaml --output-type yaml --encrypted-comment-regex 'sops-encrypt' cloud-init/user-data > cloud-init/user-data.enc

decrypt-user-data:
  sops --decrypt --input-type yaml --output-type yaml cloud-init/user-data.enc > cloud-init/user-data
