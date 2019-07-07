set -ex
ls
DOCKER_BUILD_FOLDER=/srv/export/${bamboo.buildNumber}
BUILD_FOLDER=/home/ec2-user/export/${bamboo.buildNumber}
alias wp="wp --allow-root --path=/srv/www/wp"
WP="wp --allow-root --path=/srv/www/wp"

main() {
  # Get all blogs
  BLOGS=$(sudo /usr/local/bin/docker-compose -f /srv/docker-compose.yml exec -T webapp /bin/bash -c "${WP} site list --format=csv")
  while read -r line; do
    if [[ $line == *"blog_id"* ]]; then continue; fi
    line=${line/,*//}
    line=${line#/#}
    line=$(echo $line | sed 's!/!!') 
    blog_ids+=($line)
  done <<< "$BLOGS"

  for blog_id in "${blog_ids[@]}"; do
    if [[ $blog_id == 1 ]]; then continue; fi
    #if [[ $blog_id != 3 ]]; then continue; fi
    FILENAME="${blog_id}.sql.gz"
    FILE="${BUILD_FOLDER}/${FILENAME}"
    DOCKER_FILE="${DOCKER_BUILD_FOLDER}/${FILENAME}"
    echo "DOING $blog_id into $FILE (a.k.a docker's ${DOCKER_FILE})"
    db_tables="--tables=wp_${blog_id}_commentmeta,wp_${blog_id}_comments,wp_${blog_id}_links,wp_${blog_id}_options,wp_${blog_id}_postmeta,wp_${blog_id}_posts,wp_${blog_id}_term_relationships,wp_${blog_id}_term_taxonomy,wp_${blog_id}_termmeta,wp_${blog_id}_terms";
    sudo /usr/local/bin/docker-compose -f /srv/docker-compose.yml exec -T webapp /bin/bash -c "set -ex; mkdir -p ${DOCKER_BUILD_FOLDER}; ${WP} db export - ${db_tables} | gzip > '${DOCKER_FILE}'"
    echo "CURRENT LS: ${BUILD_FOLDER}"
    ls "${BUILD_FOLDER}"
    
    upload_aws "${FILE}"
    sudo rm -f "${FILE}"
  done
}


upload_aws() {
  if [[ $# != 1 ]]; then
    echo "Usage: upload_aws source_file"
    exit 1
  fi
  local_file="$1"
  b=$(basename "$local_file")
  remote_file="spp-uat-dbdumps/${bamboo.buildNumber}/$b"
  echo "Uploading $local_file ==> $remote_file"

  export https_proxy=http://proxy-uat.cp1.news.com.au:8080
  aws s3 cp "$local_file" "s3://$remote_file"
  echo "AWS S3 REMOTE CONTENTS:"
  aws s3 ls s3://spp-uat-dbdumps
  unset https_proxy
}

main