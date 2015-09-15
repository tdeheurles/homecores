# ====================== CERTIFICATES ======================
# ==========================================================

# INFO: this script is an implementation of that page :
#   https://coreos.com/kubernetes/docs/latest/openssl.html



# control usage
if [[ ! -f config.sh ]]; then
	echo "you need to fill the config.sh file first"
	echo "open config.sh"
	cp templates/template.config.sh config.sh
	exit 1
fi

# some declaration
CERTIFICATE_PATH="certificates"
mkdir -p $CERTIFICATE_PATH

testfile() {
	if [[ -e $1 ]]; then 
		echo -e " \e[92m==>\e[39m $1 generated"
	else 
		echo -e "\e[91merror with $1\e[39m"
		exit 1
	fi
}

# import configuration
. ./config.sh


# ========== ARCHIVE PREVIOUS STUFF ============
# ==============================================
echo -e "\e[92m\n\nClean previous certificates\e[39m"
rm $CERTIFICATE_PATH/*


# ========== Create a Cluster Root CA ==========
# ==============================================
echo -e "\e[92m\n\nCreate cluster Root CA\e[39m"
echo -e "\e[92m$CA_KEY_PEM\e[39m"
CA_KEY_PEM="$CERTIFICATE_PATH/ca-key.pem"
openssl genrsa -out $CA_KEY_PEM 2048
testfile $CA_KEY_PEM

echo -e "\e[92m$CA_PEM\e[39m"
CA_PEM="$CERTIFICATE_PATH/ca.pem"
openssl req -x509 -new -nodes -key $CA_KEY_PEM \
    -days 10000 -out $CA_PEM -subj "/CN=kube-ca"
testfile $CA_PEM



# ======= Generate the API Server Keypair ======
# ==============================================
echo -e "\e[92m\n\nGenerate the API Server Keypair\e[39m"
echo -e "\e[92mopenssl.cnf\e[39m"
OPENSSL_CNF="$CERTIFICATE_PATH/openssl.cnf"
cat <<EOF > $OPENSSL_CNF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
IP.1 = ${K8S_SERVICE_IP}
IP.2 = ${MASTER_IP}
EOF
testfile $OPENSSL_CNF


echo -e "\e[92m$APISERVER_KEY_PEM\e[39m"
APISERVER_KEY_PEM="$CERTIFICATE_PATH/apiserver-key.pem"
openssl genrsa -out $APISERVER_KEY_PEM 2048
testfile $APISERVER_KEY_PEM

echo -e "\e[92m$APISERVER_CSR\e[39m"
APISERVER_CSR="$CERTIFICATE_PATH/apiserver.csr"
openssl req -new -key $APISERVER_KEY_PEM         \
  -out $APISERVER_CSR -subj "/CN=kube-apiserver" \
  -config $OPENSSL_CNF
testfile $APISERVER_CSR

echo -e "\e[92m$APISERVER_PEM\e[39m"
APISERVER_PEM="$CERTIFICATE_PATH/apiserver.pem"
openssl x509 -req -in $APISERVER_CSR               \
  -CA $CA_PEM -CAkey $CA_KEY_PEM -CAcreateserial   \
  -out $APISERVER_PEM -days 365 -extensions v3_req \
  -extfile $OPENSSL_CNF
testfile $APISERVER_PEM




# ======= Generate the Kubernetes Worker Keypair ======
# =====================================================
echo -e "\e[92m\n\nGenerate the API Server Keypair\e[39m"
echo -e "\e[92m$WORKER_KEY_PEM\e[39m"
WORKER_KEY_PEM="$CERTIFICATE_PATH/worker-key.pem"
openssl genrsa -out $WORKER_KEY_PEM 2048
testfile $WORKER_KEY_PEM

echo -e "\e[92m$WORKER_CSR\e[39m"
WORKER_CSR="$CERTIFICATE_PATH/worker.csr"
openssl req -new -key $WORKER_KEY_PEM      \
  -out $WORKER_CSR -subj "/CN=kube-worker"
testfile $WORKER_CSR

echo -e "\e[92m$WORKER_PEM\e[39m"
WORKER_PEM="$CERTIFICATE_PATH/worker.pem"
openssl x509 -req -in $WORKER_CSR                \
  -CA $CA_PEM -CAkey $CA_KEY_PEM -CAcreateserial \
  -out $WORKER_PEM -days 365
testfile $WORKER_PEM




# ==== Generate the Cluster Administrator Keypair ====
# ====================================================
echo -e "\e[92m\n\nGenerate the Cluster Administrator Keypair\e[39m"
echo -e "\e[92m$ADMIN_KEY_PEM\e[39m"
ADMIN_KEY_PEM="$CERTIFICATE_PATH/admin-key.pem"
openssl genrsa -out $ADMIN_KEY_PEM 2048
testfile $ADMIN_KEY_PEM

echo -e "\e[92m$ADMIN_CSR\e[39m"
ADMIN_CSR="$CERTIFICATE_PATH/admin.csr"
openssl req -new -key $ADMIN_KEY_PEM     \
  -out $ADMIN_CSR -subj "/CN=kube-admin"
testfile $ADMIN_CSR

echo -e "\e[92m$ADMIN_PEM\e[39m"
ADMIN_PEM="$CERTIFICATE_PATH/admin.pem"
openssl x509 -req -in $ADMIN_CSR                 \
  -CA $CA_PEM -CAkey $CA_KEY_PEM -CAcreateserial \
  -out $ADMIN_PEM -days 365
testfile $ADMIN_PEM
