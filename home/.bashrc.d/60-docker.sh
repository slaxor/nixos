docker_clean() {
  set -x
  CONTAINERS=$(docker ps -qf status=exited)
  [ -z "${CONTAINERS}" ] || ( echo ${CONTAINERS}| xargs docker rm )
  IMAGES=$(docker images -qf dangling=true)
  [ -z "${IMAGES}" ] || ( echo ${IMAGES} | xargs docker rmi )
  VOLUMES=$(docker volume ls -qf dangling=true)
  [ -z "${VOLUMES}" ] || ( echo ${VOLUMES} | xargs docker volume rm )
  set +x
}

docker_find() {
  sudo find $(docker inspect $(docker volume ls|awk '/local/{print $2}')|jq --raw-output '.[].Mountpoint') -iname "*${1}*"
}

