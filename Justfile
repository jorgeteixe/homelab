default:
  @just --list

flash DEVICE:
  ./cloud-init/flash.sh {{DEVICE}}

encrypt-all: encrypt-user-data encrypt-dotenv
decrypt-all: decrypt-user-data decrypt-dotenv

encrypt-user-data:
  sops --encrypt --input-type yaml --output-type yaml --encrypted-comment-regex 'sops-encrypt' cloud-init/user-data > cloud-init/user-data.enc

decrypt-user-data:
  sops --decrypt --input-type yaml --output-type yaml cloud-init/user-data.enc > cloud-init/user-data

encrypt-dotenv:
  sops --encrypt --input-type dotenv docker/.env > docker/.env.enc

decrypt-dotenv:
  sops --decrypt --input-type dotenv --output-type dotenv docker/.env.enc > docker/.env
