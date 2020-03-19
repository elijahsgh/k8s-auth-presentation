#!/usr/bin/env bash
export VAULT_ADDR=http://localhost:8200
export VAULT_SKIP_VERIFY=1
kubectl port-forward service/my-vault 8200:8200 &
PROXY_PID=$!
sleep 3
echo $PROXY_PID
vault status

printf root | vault login -
ENDPOINT=$(terraform output -state=../terraform.tfstate k8s_endpoint)
echo $ENDPOINT
CA_CERT=$(terraform output -state=../terraform.tfstate vault_k8s_auth_ca_crt)
TOKEN=$(terraform output -state=../terraform.tfstate vault_k8s_auth_token)

vault auth enable kubernetes
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN" \
  kubernetes_host="https://$ENDPOINT:443" \
  kubernetes_ca_cert="$CA_CERT"

vault write auth/kubernetes/role/example \
  bound_service_account_names=vault-auth \
  bound_service_account_namespaces=default \
  policies=myapp-kv-ro \
  ttl=24h

vault write auth/kubernetes/role/default_sa \
  bound_service_account_names=default \
  bound_service_account_namespaces=default \
  policies=myapp-kv-ro \
  ttl=24h

kill -HUP $PROXY_PID

# Test from host
# curl --request POST --data '{"jwt": "'"$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"'", "role": "default_sa"}' http://my-vault:8200/v1/auth/kubernetes/login | jq .
