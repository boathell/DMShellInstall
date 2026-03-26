#!/bin/bash
#==============================================================#
# 脚本名     :   create_lvm.sh
# 创建时间   :   2023-04-17 10:02:09
# 更新时间   :   2024-04-26 19:52:18
# 描述      :   创建逻辑卷脚本
# 路径      :   /soft/create_lvm.sh
# 版本      :   1.0.0
# 作者      :   yuanzijian(yzj@dameng.com)
# Copyright (C) 2023-2023 Zijian yuan
#==============================================================#
#输入环境变量
export PATH=$PATH:/sbin:/usr/sbin
#获取当前系统版本
os_version=$(grep -oP '(?<=release\s|V)[[:digit:]]+' </etc/system-release)
#传入的磁盘
typeset -l disk_list=
#定义符合要求磁盘数组名称
declare -a valid_disks=()
#卷组名称
typeset -l vg_name=
#逻辑卷名称
typeset -l lv_name=
#定义逻辑卷数组
declare -a lv_names=()
#逻辑卷的大小
input_size=
#是百分比还是具体值
typeset -u is_value_percent=Y
# 定义全局变量，退出函数的标记
flag=""
# 定义磁盘挂载点
typeset -l mount_dir=
# 定义 run_command 函数
function run_command() {
  "$@" >/dev/null 2>&1       # 执行传入的命令和参数
  local status=$?            # 获取命令的退出状态
  if [ $status -eq 0 ]; then # 如果命令执行成功
    echo -e "\n命令\033[32m \"$*\" \033[0m执行成功。"
    return 0 # 返回 0，使得当前命令退出
  else       # 如果命令执行失败
    echo -e "\n命令\033[31m \"$*\" \033[0m执行失败，退出码为 $status。\n"
    return $status # 返回命令的退出状态，使得当前命令继续执行
  fi
}
function confirm_command() {
  local command1=$1
  local command2=$2
  local command3=$3
  local flag=""
  while true; do
    # 用户决定是否创建
    read -rep "请确认是否创建，确认输入[Y]/重新配置输入[N]，退出输入[Q]: " choice
    case "$choice" in
    [Yy])
      # 执行命令
      run_command $command1
      break
      ;;
    [Nn])
      $command2
      break
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
  # 判断是否需要继续创建逻辑卷
  if [[ "$flag" == "exit" ]]; then
    echo
    $command3
  fi
}
# 校验磁盘是否存在
function check_disks() {
  local input_disks="$1"
  #定义不符合要求磁盘数组名称
  local invalid_disks=()
  for disk in ${input_disks// / }; do
    # Check if the disk exists
    if [[ -b "/dev/$disk" ]]; then
      if ! [[ ${valid_disks[*]} =~ "/dev/$disk" ]]; then
        valid_disks+=("/dev/$disk")
      fi
    else
      invalid_disks+=("/dev/$disk")
    fi
  done
  # Check if all disks are valid
  if [[ ${#invalid_disks[@]} -eq 0 ]]; then
    echo -e "\n输入的磁盘列表为：\033[32m ${valid_disks[*]} \033[0m\n"
    return 0
  else
    echo -e "\n磁盘：\033[31m ${invalid_disks[*]} \033[0m名称无效\n"
    return 1
  fi
}
# 格式化磁盘
function dd_disk() {
  while true; do
    # 继续循环确认清盘
    read -rep "是否使用dd清盘？[Y/N] : " choice
    case "$choice" in
    [Yy])
      echo -e "\n您选择了dd清盘。\n"
      dd_disk=Y
      break
      ;;
    [Nn])
      echo -e "\n您选择了直接创建物理卷。\n"
      break
      ;;
    *)
      echo -e "\n\033[31m输入有误，请重新输入。\033[0m\n"
      ;;
    esac
  done
  #清空磁盘
  if [[ $dd_disk = "Y" ]]; then # 是否清空磁盘，如果值是Y，就清空磁盘
    for disk in "${valid_disks[@]}"; do
      dd if=/dev/zero of="$disk" bs=100M count=10 # 使用dd命令写入0以清空磁盘
      wait $!                                     # 如果命令执行成功，跳出循环
      echo
    done
  fi
}
# 校验数值是否为正整数
function check_disk_size() {
  input_size=$1
  while true; do
    if ! [[ $input_size =~ ^[0-9]+$ ]]; then
      read -rep "$(echo -e "\033[31m无效的输入，请输入一个正整数。\E[0m"): " input_size
      continue
    else
      echo -e "输入的数据大小为：\033[32m $input_size \033[0m\n"
      return 0
    fi
  done
  return 1
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
        read -rep "$(echo -e "目录\033[31m 已被挂载 \E[0m，请重新输入要挂载的目录名\E[0m"): " mount_dir
        continue
      else
        echo -e "\n要挂载的目录名：\033[32m $mount_dir \033[0m"
        break
      fi
    else
      echo
      read -rep "$(echo -e "目录名不是以\033[31m / \E[0m开头，请重新输入要挂载的目录名"): " mount_dir
      continue
    fi
  done
}
function create_pvs() {
  echo
  #初始化空字符串
  str=""
  # 校验磁盘
  while true; do
    # 获取用户输入的磁盘名
    read -rep "请输入磁盘名（例如 sdb或者sdb sdc）：" disk_list
    check_disks "$disk_list"
    # 判断函数执行结果
    if [[ $? -eq 0 ]]; then
      echo -e "校验磁盘成功\n"
      break
    else
      echo -e "\033[31m校验磁盘失败，请重新输入\033[0m\n"
      continue
    fi
  done
  # 循环拼接设备路径
  for vd in "${valid_disks[@]}"; do
    str="$str$vd "
  done
  # 删除最后一个空格
  str="${str% }"
  # 是否清盘
  dd_disk
  # 创建物理卷
  confirm_command "pvcreate -y -ff $str" "create_pvs" "exit 0"
}
function create_vgs() {
  #初始化空字符串
  str=""
  while true; do
    # 获取用户输入的卷组名称
    echo
    read -rep "请输入卷组名称(可以包含数字)：" vg_name
    check_alphanumeric "$vg_name"
    # 判断函数执行结果
    if [[ $? -eq 0 ]]; then
      echo -e "\n输入卷组名称符合要求\n"
      break
    else
      echo -e "\n\033[31m输入卷组名称不符合要求，请重新输入\033[0m"
      continue
    fi
  done
  # 循环拼接设备路径
  for vd in "${valid_disks[@]}"; do
    str="$str$vd "
  done
  # 删除最后一个空格
  str="${str% }"
  # 创建卷组
  confirm_command "vgcreate -y $vg_name $str" "create_vgs" "exit 0"
}
function create_lvs() {
  # 建逻辑卷的方法
  local lv_method=
  # 判断是否需要继续创建逻辑卷
  if [[ "$flag" == "exit" ]]; then
    # 退出整个函数
    return
  fi
  # 校验传入的逻辑卷大小
  while true; do
    echo
    # 获取用户输入的逻辑卷名称
    read -rep "请输入逻辑卷名称(可以包含数字)：" lv_name
    check_alphanumeric "$lv_name"
    # 判断函数执行结果
    if [[ $? -eq 0 ]]; then
      echo -e "\n输入逻辑名称符合要求"
      break
    else
      echo -e "\n\033[31m输入逻辑名称不符合要求，请重新输入\033[0m"
      continue
    fi
  done
  # 校验传入的逻辑卷大小
  while true; do
    # 检查卷组剩余空间大小
    free=$(vgs | grep "$vg_name" | awk '{print $7}')
    echo -e "\n该卷组剩余的空间大小为：\033[32m$free\033[0m"
    echo
    # 获取用户输入的数据大小
    read -rep "请输入数据大小（例如 10 ）：" input_size
    echo
    check_disk_size "$input_size"
    # 判断函数执行结果
    if [[ $? -eq 0 ]]; then
      echo -e "校验数据大小成功\n"
      break
    else
      echo -e "\033[31m校验数据大小失败，请重新输入\033[0m\n"
      continue
    fi
  done
  #创建逻辑卷参数方式
  if [[ $is_value_percent == "Y" ]]; then
    lv_method="-l +${input_size}%VG"
  else
    lv_method="-L +${input_size}G"
  fi
  while true; do
    # 用户决定是否创建
    read -rep "请确认是否创建，确认输入[Y]/重新配置输入[N]，退出输入[Q]: " choice
    case "$choice" in
    [Yy])
      # 执行命令
      run_command lvcreate -y $lv_method -n $lv_name $vg_name
      break
      ;;
    [Nn])
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
  # 如果逻辑卷创建成功，创建的逻辑卷加到数组里面
  if lvs --noheadings -o lv_name --select "vg_name=$vg_name" | grep -qw "$lv_name"; then
    # 判断逻辑卷名称是否已经存在于数组中
    exists=0
    for i in "${lv_names[@]}"; do
      if [ "$i" == "$lv_name" ]; then
        exists=1
        break
      fi
    done
    if [[ "$exists" -eq 0 ]]; then
      # 将逻辑卷名称添加到数组中
      lv_names+=("$lv_name")
    fi
  fi
  while true; do
    # 继续循环创建逻辑卷
    echo
    read -rep "是否继续创建逻辑卷？[Y/N] : " choice
    case "$choice" in
    [Yy])
      echo -e "\n您选择了继续创建。"
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
# 格式化逻辑卷，并挂盘
function format_and_mount_lvms() {
  #格式化文件类型
  local fst=
  # 挂载点路径
  local mount_dir=
  # 根据系统选择格式化的文件类型
  case $os_version in
  6)
    fst=ext4
    ;;
  7 | 8 | 9 | 10)
    fst=xfs
    ;;
  *)
    fst=xfs
    ;;
  esac
  echo -e "\n格式化文件系统类型为：\033[32m $fst \033[0m"
  # 格式化文件类型
  for lv_name in "${lv_names[@]}"; do
    run_command mkfs.$fst /dev/mapper/$vg_name-$lv_name
  done
  # 创建挂载点，挂载目录
  while true; do
    # 获取用户输入的挂载点目录
    local mount_dir=""
    declare -A mount_point=()
    for lv_name in "${lv_names[@]}"; do
      echo
      read -rep "$(echo -e "请输入逻辑卷\033[32m /dev/mapper/$vg_name-$lv_name \033[0m 挂载目录（默认：\033[32m /$lv_name \033[0m）"): " mount_dir
      # 如果用户未输入挂载目录，则使用默认挂载目录 /$lv_name
      if [[ -z "$mount_dir" ]]; then
        mount_dir="/$lv_name"
      fi
      # 校验挂载目录
      if check_mount_dir "$mount_dir"; then
        run_command mkdir -p $mount_dir
        mount_point+=([$lv_name]=${mount_dir%/})
      fi
    done
    # 创建挂载点并挂载逻辑卷
    for lv_name in "${lv_names[@]}"; do
      # 编写fstab文件
      fstab_entry="/dev/mapper/$vg_name-$lv_name   ${mount_point[$lv_name]}  $fst   defaults   0      0"
      if grep -qF "/dev/mapper/$vg_name-$lv_name" /etc/fstab; then
        sed -i "/^\/dev\/mapper\/$vg_name-$lv_name/c$fstab_entry"/etc/fstab
      else
        echo "$fstab_entry" >>/etc/fstab
      fi
      mount -a
      echo -e "\n已成功挂载分区\033[32m /dev/mapper/$vg_name-$lv_name \033[0m 到\033[32m ${mount_point[$lv_name]} \033[0m 目录下。"
    done
    if [[ $? -eq 0 ]]; then
      echo -e "\n逻辑卷创建成功，请查验：\n"
      break
    else
      echo -e "\n\033[31m逻辑卷创建失败，请手动删除，重新配置\033[0m"
      continue
    fi
  done
  df -Th
  echo
}
function confirm_lv_configuration() {
  # 检查lvm2工具是否已安装
  if ! command -v lvm &>/dev/null; then
    echo -e "\n\033[31mlvm2 工具未安装，请先安装lvm2工具。\033[0m\n"
    exit 1
  fi
  # 确认创建逻辑卷的方式，是按照百分比还是按照真实值
  cat <<EOF

请确认创建逻辑卷方式：
1 百分比
2 具体值(单位是：G)

EOF
  while true; do
    read -rep "请选择逻辑卷创建方式：" confirm
    case $confirm in
    1)
      is_value_percent=Y
      break
      ;;
    2)
      is_value_percent=N
      break
      ;;
    *)
      echo -e "请输入 1 或者 2 。\n"
      ;;
    esac
  done
  # 创建物理卷
  create_pvs
  # 创建卷组
  create_vgs
  # 创建逻辑卷
  create_lvs
  while [ "$?" -eq "4" ]; do
    create_lvs
    #如果返回值是4，就一直执行create_lvs函数
  done
  # 格式化逻辑卷，并挂盘
  format_and_mount_lvms
}
confirm_lv_configuration
