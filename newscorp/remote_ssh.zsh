export nfs_ip=172.29.224.100

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

mount_fs() {
  if [[ $# != 1 ]]; then echo "usage: mount_fs folder"; return; fi
  sshfs ec2-user@$nfs_ip $1 -o IdentityFile=~/.ssh/id_rsa_uat.pem
}