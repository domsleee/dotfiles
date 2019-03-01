ssh_r() {
  if [[ $# != 1 ]]; then echo "ssh_r ip"; return; fi
  ssh -i ~/.ssh/id_rsa_uat.pem ec2-user@$1
}

ssh_webapp() {
  if [[ $# != 1 ]]; then echo "ssh_webapp ip" && return; fi
  ssh -i ~/.ssh/id_rsa_uat.pem ec2-user@$1 -t "cd /srv && sudo /usr/local/bin/docker-compose exec webapp bash"
}

scp_r() {
  if [[ $# != 2 ]]; then echo "ssh_webapp a b" && return; fi
  scp -i ~/.ssh/id_rsa_uat.pem $1 $2
}