# certificates

## SSH key
The homecores project run inside a VM. We use SSH to connect to that virtual machine. So a SSH certificate is a good way to go.

The project came with an SSH certificate to simplify first try.

For current utilisation, using your own is a better idea.

### Importing an SSH key
If you already have your own certificate (without passphrase): 
- copy the private key to the main folder and name it `id_rsa`
- open the public key with an editor (or just `cat publicKeyName`) and copy paste it to the `config.sh file` :

```
# security
public_id_rsa='AAAAB3NzaC1yc2EA....87YUYOi4nAw== homecores@example.com'
```
do not copy the `ssh-rsa ` part of the file.

### Generating an SSH key
It's really easy to generate ssh public and private keys.
- Start your `git bash`
- run the command `ssh-keygen -t rsa -b 4096 -C "email@youwant.com"`
- choose `./id_rsa` as the name of your key (the `./` will generate it in your current folder)
- hit enter on each other questions (do not add a passphrase)
- that will generate 2 files:
  - id_rsa (the private key)
  - id_rsa.pub (the public key)
- follow the `importing an SSH key` just above

## Project certificates

### Under work
This part is not working as the `generate_new_cluster_certificates.sh` need the master IP at encryption time. So it need to be run after the `vagrant up`

---

This project propose a script to generate the certificate for everything. It's located in `bootstrap_scripts/helpers/generate_new_cluster_certificates.sh`. Run it from the homecores folder (don't change your directory to `bootstrap_scripts/helpers/`).

After the script as run, you should have a `certificates` folder generated with the same files as in the `demo_certificates` folder:
- admin-key.pem
- admin.csr
- admin.pem
- apiserver-key.pem
- apiserver.csr
- apiserver.pem
- ca-key.pem
- ca.csr
- ca.pem
- openssl.cnf
- worker-key.pem
- worker.csr
- worker.pem

only the pem files are usefull for the project (.csr and .cnf are intermediate files).
