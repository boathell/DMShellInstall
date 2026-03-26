#!/bin/bash
#==============================================================#
# 脚本名     :   create_parted.sh
# 创建时间   :   2023-05-09 20:02:09
# 更新时间   :   2024-04-26 19:52:18
# 描述      :   创建普通分区脚本
# 路径      :   /soft/create_parted.sh
# 版本      :   1.0.0
# 作者      :   yuanzijian(yzj@dameng.com)
# Copyright (C) 2023-2023 Zijian yuan
#==============================================================#
# 定义磁盘
typeset -l disk
# 定义是否格式化磁盘
typeset -u dd_disk
dd_disk=N
# 定义磁盘分区数组
declare -a partition_names=()
# 定义磁盘分区开始标记
part_start=0
# 定义磁盘分区结束标记
part_end=0
# 定义 run_command 函数
function run_command() {
  "$@" >/dev/null 2>&1       # 执行传入的命令和参数
  local status=$?            # 获取命令的退出状态
  if [ $status -eq 0 ]; then # 如果命令执行成功
    echo -e "\n命令\033[32m \"$*\" \033[0m执行成功。"
    return 0 # 返回 0，使得当前命令退出
  else       # 如果命令执行失败
    echo -e "\n命令\033[31m \"$*\" \033[0m执行失败，退出码为 $status。"
    return $status # 返回命令的退出状态，使得当前命令继续执行
  fi
}
#判断校验卷组名字是否只包含字母和数字
function check_alphanumeric() {
  # 循环遍历字符串中的每个字符
  for ((i = 0; i < ${#1}; i++)); do
    char="${1:$i:1}"
    # 如果字符不是字母或数字，返回1
    if [[ ! "$char" =~ [[:alnum:]] ]]; then
      return 1
    fi
  done
  # 判断字符串是否全部由数字组成
  if [[ -z "$1" ]]; then
    return 1
  elif [[ "$1" =~ ^[0-9]*$ ]]; then
    return 1
  else
    return 0
  fi
}
# 校验目录是否已经挂载
function check_mount_dir() {
  mount_dir=$1
  while true; do
    if [[ "${mount_dir}" =~ ^/ ]]; then
      if [[ "$mount_dir" == "/" ]] || grep -qs "$mount_dir " /proc/mounts; then
        echo
        read -rep "$(echo -e "目录\033[31m 已被挂载 \E[0m，请重新输入要挂载的目录名: ")" mount_dir
        continue
      else
        echo -e "\n要挂载的目录名：\033[32m $mount_dir \033[0m"
        break
      fi
    else
      echo
      read -rep "$(echo -e "目录名不是以\033[31m / \E[0m开头，请重新输入要挂载的目录名: ")" mount_dir
      continue
    fi
  done
}
# 校验数值是否为正整数
function check_disk_size() {
  input_size=$1
  while true; do
    if ! [[ $input_size =~ ^[0-9]+$ ]]; then
      read -rep "$(echo -e "\033[31m无效的输入，请输入一个正整数: \E[0m")" input_size
      echo
      continue
    else
      echo -e "\n输入的数据大小为：\033[32m $input_size \033[0m\n"
      return 0
    fi
  done
  return 1
}
# 校验磁盘是否存在
function check_disk() {
  echo
  # 校验磁盘
  while true; do
    # 获取用户输入的磁盘名
    read -rep "$(echo -e "请输入磁盘名（\033[32m例如 sdb或者 vdb\E[0m）：")" disk
    # 判断函数执行结果
    if [[ -b /dev/$disk ]]; then
      echo -e "\n\033[32m校验磁盘成功\033[0m\n"
      break
    else
      echo -e "\n\033[31m校验磁盘失败，请重新输入\033[0m\n"
      continue
    fi
  done
}
# 格式化磁盘
function dd_disk() {
  while true; do
    # 继续循环确认清盘
    read -rep "是否使用dd清盘？[Y/N]: " choice
    case "$choice" in
    [Yy])
      echo -e "\n您选择了dd清盘。\n"
      dd_disk=Y
      break
      ;;
    [Nn])
      echo -e "\n您选择了直接创建分区。\n"
      break
      ;;
    *)
      echo -e "\n\033[31m输入有误，请重新输入。\033[0m\n"
      ;;
    esac
  done
  if [[ $dd_disk == "Y" ]]; then
    # 格式化磁盘
    dd if=/dev/zero of=/dev/"$disk" bs=100M count=10
    wait $!
    echo
  fi
}
function create_partition_table() {
  # 修改磁盘分区表
  parted /dev/"${disk}" >/dev/null 2>&1 <<EOF
mklabel gpt
q
EOF
}
# 创建分区
function create_partition() {
  # 判断是否需要继续创建分区
  if [[ "$flag" == "exit" ]]; then
    # 退出整个函数
    return
  fi
  # 指定分区名字
  # 校验传入的磁盘分区名字
  while true; do
    # 获取用户输入的分区名称
    read -rep "请输入分区名称(可以包含数字)：" partition_name
    check_alphanumeric "$partition_name"
    # 判断函数执行结果
    if [[ $? -eq 0 ]]; then
      echo -e "\n输入分区名称符合要求\n"
      break
    else
      echo -e "\n\033[31m输入分区名称不符合要求，请重新输入。\033[0m\n"
      continue
    fi
  done
  # 指定分区大小
  # 校验传入的磁盘大小
  while true; do
    # 获取用户输入的数据大小
    read -rep "请输入磁盘百分比（例如 10）：" part_end
    check_disk_size "$part_end"
    # 判断函数执行结果
    if [[ $? -eq 0 ]]; then
      echo -e "校验数值大小成功\n"
      break
    else
      echo -e "\033[31m校验数值大小失败，请重新输入\033[0m\n"
      continue
    fi
  done
  # 3.确认分区大小
  while true; do
    # 用户决定是否创建
    read -rep "请确认是否创建，确认输入[Y]/重新配置输入[N]，退出输入[Q]: " choice
    case "$choice" in
    [Yy])
      # 定义分区结束点
      part_end=$((part_start + part_end))
      if [ $part_end -gt 100 ]; then
        part_end=100
      fi
      # 执行命令
      run_command parted /dev/"${disk}" <<EOF
mkpart $partition_name ${part_start}% ${part_end}%
q
EOF
      break
      ;;
    [Nn])
      echo
      return 4
      ;;
    [Qq])
      flag="exit"
      break
      ;;
    *)
      echo -e "\n请输入 Y、N 或者 Q.\n"
      ;;
    esac
  done
  # 4.添加分区创建数组
  # 如果分区创建成功，创建的分区加到数组里面
  if parted /dev/"${disk}" print | grep "${partition_name}" >/dev/null; then
    # 判断磁盘分区是否已经存在于数组中
    exists=0
    for i in "${partition_names[@]}"; do
      if [ "$i" == "$partition_name" ]; then
        exists=1
        break
      fi
    done
    if [[ "$exists" -eq 0 ]]; then
      # 将分区名称添加到数组中
      partition_names+=("$partition_name")
    fi
  fi
  while true; do
    # 继续循环创建分区
    echo
    read -rep "是否继续创建分区？[Y/N] " choice
    case "$choice" in
    [Yy])
      echo -e "\n您选择了继续创建。\n"
      return 4
      ;;
    [Nn])
      echo -e "\n您选择了退出创建。"
      flag="exit"
      break
      ;;
    *)
      echo -e "\n\033[31m输入有误，请重新输入。\033[0m"
      ;;
    esac
  done
}
# 格式化分区，并挂盘
function format_and_mount() {
  # 获取磁盘的uuid
  local uuid=
  # 挂载点路径
  local mount_dir=
  # 格式化文件类型
  for ((x = 1; x <= "${#partition_names[@]}"; x++)); do
    run_command mkfs.ext4 -T largefile /dev/"${disk}"$x
  done
  # 创建挂载点，挂载目录
  while true; do
    # 获取用户输入的挂载点目录
    local mount_dir=""
    declare -A mount_point=()
    for partition_name in "${partition_names[@]}"; do
      echo
      read -rep "$(echo -e "请输入磁盘分区\033[32m $partition_name \033[0m 挂载目录（默认：\033[32m /$partition_name \033[0m）：")" mount_dir
      # 如果用户未输入挂载目录，则使用默认挂载目录 /$partition_name
      if [[ -z "$mount_dir" ]]; then
        # shellcheck disable=SC2154
        mount_dir="/$partition_name"
      fi
      # 校验挂载目录
      if check_mount_dir "$mount_dir"; then
        run_command mkdir -p $mount_dir
        mount_point+=([$partition_name]=${mount_dir%/})
      fi
    done
    # 创建挂载点并挂载分区
    for partition_name in "${partition_names[@]}"; do
      # 编写fstab文件
      uuid=$(blkid | grep "$partition_name" | cut -d '"' -f 2)
      fstab_entry="UUID=$uuid   ${mount_point[$partition_name]}  ext4   defaults   0   0"
      if grep -qF "UUID=$uuid" /etc/fstab; then
        sed -i "/^UUID=$uuid/c$fstab_entry"/etc/fstab
      else
        echo "$fstab_entry" >>/etc/fstab
      fi
      mount -a
      echo -e "\n已成功挂载分区\033[32m $partition_name \033[0m 到\033[32m ${mount_point[$partition_name]} \033[0m 目录下。"
    done
    if [[ $? -eq 0 ]]; then
      echo -e "\n磁盘分区创建成功，请查验：\n"
      break
    else
      echo -e "\n\033[31m磁盘分区创建失败，请卸载分区，删除fstab新增信息，重新配置\033[0m"
      continue
    fi
  done
  df -Th
  echo
}
# 确认磁盘分区创建
function confirm_partition() {
  # 检查parted是否已安装
  if ! command -v parted &>/dev/null; then
    echo -e "\n\033[31mparted 未安装，请先安装parted。\033[0m\n"
    exit 1
  fi
  # 校验磁盘格式
  check_disk
  # 是否格式化磁盘
  dd_disk
  # 创建磁盘分区表
  create_partition_table
  # 创建磁盘分区
  create_partition
  while [ "$?" -eq "4" ]; do
    # 重新定义新分区的起始点
    part_start=$part_end
    create_partition
    #如果返回值是4，就一直执行create_lvs函数
  done
  # 格式化分区并挂载分区
  format_and_mount
}
confirm_partition
