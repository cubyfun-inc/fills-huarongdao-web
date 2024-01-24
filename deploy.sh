#!/bin/bash
set -e

# 设置变量

DOCKER_USERNAME=$1    # 腾讯云镜像空间 登录名
DOCKER_PASSWORD=$2    # 腾讯云镜像空间 密码
DOCKER_DEPLOY_MODE=$3 # 部署模式

DOCKER_CONTAINER_NAME="hrd-web" # 镜像
DOCKER_REMOTE_REPOSITORY="hkccr.ccs.tencentyun.com"
DOCKER_REMOTE_SPACE="software-team" # 腾讯云镜像空间的命名空间

DOCKER_REMOTE_IMAGE_NAME="$DOCKER_REMOTE_REPOSITORY/$DOCKER_REMOTE_SPACE/$DOCKER_CONTAINER_NAME:latest"

echo "DOCKER_CONTAINER_NAME: ${DOCKER_CONTAINER_NAME}"

check_input() {
  if [ -z "$DOCKER_USERNAME" ]; then
    echo "--------- error: arg \$1 to set docker login username. ---------"
    exit 1
  fi

  if [ -z "$DOCKER_PASSWORD" ]; then
    echo "--------- error: arg \$2 to set docker login password. ---------"
    exit 1
  fi

  if [[ "$DOCKER_DEPLOY_MODE" != "revert" && "$DOCKER_DEPLOY_MODE" != "reload" && "$DOCKER_DEPLOY_MODE" != "release" && "$DOCKER_DEPLOY_MODE" != "scale" && "$DOCKER_DEPLOY_MODE" != "stop" ]]; then
    echo "--------- error: arg \$3  revert: 回滚, reload: 重载, scale: 动态扩容 ,release: 部署最新镜像 ---------"

    exit 1
  fi
}

login_to_repository() {
  echo "--------- 登录腾讯云镜像容器服务 ---------"
  echo $DOCKER_PASSWORD | docker login --username=$DOCKER_USERNAME $DOCKER_REMOTE_REPOSITORY --password-stdin
}

echo_docker_container() {
  docker ps --filter "name=^${DOCKER_CONTAINER_NAME}" --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

}

docker_up() {
  docker-compose up -d
  echo_docker_container
}

docker_down() {
  docker-compose down -v
}

deploy_release_do_bkp_if_and_up() {

  # 登录下腾讯镜像空间
  login_to_repository

  if docker inspect $DOCKER_REMOTE_IMAGE_NAME &>/dev/null; then
    echo "--------- 镜像存在，备份并删除当前镜像 ---------"
    docker tag $DOCKER_REMOTE_IMAGE_NAME $DOCKER_REMOTE_IMAGE_NAME-revert

    docker images $DOCKER_REMOTE_IMAGE_NAME-revert

    docker rmi $DOCKER_REMOTE_IMAGE_NAME
  fi

  echo "--------- 拉取远程镜像 ---------"
  docker pull $DOCKER_REMOTE_IMAGE_NAME

  echo "--------- 启动容器 ---------"

  # 将远程仓库的镜像名 tag 为 docker compose 的 image  名, 保持一致
  docker tag $DOCKER_REMOTE_IMAGE_NAME $DOCKER_CONTAINER_NAME

  echo "--------- 启动的镜像 ---------"
  docker images $DOCKER_CONTAINER_NAME

  docker_up
}

deploy_release() {

  # 容器存在
  if docker ps -a --format '{{.Names}}' | grep -q "^$DOCKER_CONTAINER_NAME"; then
    echo "--------- 容器存在 ---------"

    # 获取当前镜像的摘要
    current_digest=$(docker image inspect --format='{{index .RepoDigests 0}}' "$DOCKER_CONTAINER_NAME")

    # 获取远程仓库中的镜像摘要
    remote_digest=$(docker image inspect --format='{{index .RepoDigests 0}}' "$DOCKER_REMOTE_IMAGE_NAME")

    # 镜像摘要一致
    if [[ "$current_digest" == "$remote_digest" ]]; then

      echo "--------- error: 当前镜像的摘要与远程仓库一致, 不处理 ---------"
      docker_up
      exit 0

    fi

    echo "--------- 镜像的摘要与远程仓库不一致, 删除当前容器, 部署最新镜像 ---------"

    docker_down

    deploy_release_do_bkp_if_and_up

  else

    echo "--------- 容器不存在, 部署最新镜像 ---------"

    deploy_release_do_bkp_if_and_up

  fi

}

deploy_stop() {
  echo "--------- 停止容器服务 ---------"

  docker_down
}

deploy_reload() {
  echo "--------- 重载容器服务 ---------"

  docker_down && docker_up
}

deploy_scale() {
  echo "--------- 动态扩容 $DOCKER_CONTAINER_NAME ---------"

  docker_up
}

deploy_revert() {
  echo "--------- 回滚到上一个镜像版本 ---------"

  # 获取当前镜像的摘要
  current_digest=$(docker image inspect --format='{{index .RepoDigests 0}}' "$DOCKER_CONTAINER_NAME")

  # 获取仓库中的 revert 镜像的摘要
  revert_digest=$(docker image inspect --format='{{index .RepoDigests 0}}' "$DOCKER_REMOTE_IMAGE_NAME-revert")

  if [[ "$current_digest" == "$revert_digest" ]]; then

    echo "--------- 当前版本 和 revert 摘要一致, 不处理 ---------"
    docker_up
    exit 0

  else
    echo "--------- 当前版本 和 revert 摘要不一致, 执行回滚 ---------"

    #  tag-revert remote
    docker tag $DOCKER_REMOTE_IMAGE_NAME-revert $DOCKER_REMOTE_IMAGE_NAME

    #  tag-revert DOCKER_CONTAINER_NAME
    docker tag $DOCKER_REMOTE_IMAGE_NAME-revert $DOCKER_CONTAINER_NAME

    echo "--------- 启动的镜像 ---------"
    docker images $DOCKER_CONTAINER_NAME

    docker_down && docker_up

  fi

}

docker_action_image_deploy() {
  echo "--------- 部署模式:${DOCKER_DEPLOY_MODE} ---------"

  case "$DOCKER_DEPLOY_MODE" in

  revert)

    # 回滚
    deploy_revert
    ;;

  reload)
    # 重载
    deploy_reload
    ;;

  stop)
    # 停止
    deploy_stop
    ;;

  scale)
    # 动态扩容
    deploy_scale
    ;;

  release)
    # 部署最新版本
    deploy_release
    ;;

  esac

}

# 主脚本

check_input

docker_action_image_deploy

echo "--------- 执行完毕 ---------"
