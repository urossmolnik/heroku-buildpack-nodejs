#!/usr/bin/env bash

kv_create() {
  local f=$1
  mkdir -p "$(dirname "$f")"
  touch "$f"
}

kv_clear() {
  local f=$1
  echo "" > "$f"
}

kv_set() {
  if [[ $# -eq 3 ]]; then
    local f=$1
    if [[ -f $f ]]; then
      echo "$2=$3" >> "$f"
    fi
  fi
}

kv_get() {
  if [[ $# -eq 2 ]]; then
    local f=$1
    if [[ -f $f ]]; then
      grep "^$2=" "$f" | sed -e "s/^$2=//" | tail -n 1
    fi
  fi
}

# get the value, but wrap it in quotes if it contains a space
kv_get_escaped() {
  local value
  value=$(kv_get "$1" "$2")
  if [[ $value =~ [[:space:]]+ ]]; then
    echo "\"$value\""
  else
    echo "$value"
  fi
}

kv_keys() {
  local f=$1
  local keys=()

  if [[ -f $f ]]; then
    # get list of keys
    while IFS="=" read -r key value; do
      keys+=("$key")
    done < "$f"

    echo "${keys[@]}" | tr ' ' '\n' | sort -u
  fi
}

kv_list() {
  local f=$1

  kv_keys "$f" | tr ' ' '\n' | while read -r key; do
    if [[ -n $key ]]; then
      echo "$key=$(kv_get_escaped "$f" "$key")"
    fi
  done
}
