#!/bin/bash
set -e

create_pid_dir() {
  mkdir -p /run/apt-cacher-ng
  chmod -R 0755 /run/apt-cacher-ng
  chown ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} /run/apt-cacher-ng
}

create_cache_dir() {
  mkdir -p ${APT_CACHER_NG_CACHE_DIR}
  chmod -R 0755 ${APT_CACHER_NG_CACHE_DIR}
  chown -R ${APT_CACHER_NG_USER}:root ${APT_CACHER_NG_CACHE_DIR}
}

create_log_dir() {
  mkdir -p ${APT_CACHER_NG_LOG_DIR}
  chmod -R 0755 ${APT_CACHER_NG_LOG_DIR}
  chown -R ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} ${APT_CACHER_NG_LOG_DIR}
}

create_config_dir() {
  if [ ! -d ${APT_CACHER_NG_CONFIG_DIR} ]
  then
    mkdir -p ${APT_CACHER_NG_CONFIG_DIR}
    chmod -R 0755 ${APT_CACHER_NG_CONFIG_DIR}
    chown -R ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} ${APT_CACHER_NG_CONFIG_DIR}
    # Copy missing files in the configuraiton directory
    cp -Rvu /etc/apt-cacher-ng/acng.conf ${APT_CACHER_NG_CONFIG_DIR}
    cp -Rvu /etc/apt-cacher-ng/backends_* ${APT_CACHER_NG_CONFIG_DIR}
  fi
}

create_pid_dir
create_cache_dir
create_log_dir
create_config_dir

# allow arguments to be passed to apt-cacher-ng
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == apt-cacher-ng || ${1} == $(command -v apt-cacher-ng) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch apt-cacher-ng
if [[ -z ${1} ]]; then
  exec start-stop-daemon --start --chuid ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} \
    --exec "$(command -v apt-cacher-ng)" -- -c ${APT_CACHER_NG_CONFIG_DIR} ${EXTRA_ARGS}
else
  exec "$@"
fi
