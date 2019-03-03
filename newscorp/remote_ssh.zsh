export nfs_ip=172.29.224.100
export sentry_ip=172.27.131.199

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
  set -x
  sshfs ec2-user@$nfs_ip:/export/SPPAppData $1 -o IdentityFile=~/.ssh/id_rsa_uat.pem
}

ssh_sentry() {
  set -x
  ssh -i ~/.ssh/id_rsa_spp.pem ec2-user@$sentry_ip
}
