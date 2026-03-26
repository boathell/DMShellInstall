# 更新记录

- `2026/03/26`
  - 修复脚本参数校验变量引用错误（-ar、-dr 参数）
  - 修复 -rs 参数定义格式错误
  - 完善帮助文档参数说明，增加详细解释
  - **将 -cs（大小写敏感）和 -c（字符集）设置为必填参数**
  - 新增安装结果报告功能，自动生成配置文档
  - 新增服务管理命令输出（开机启动、启停命令等）
  - 修复数据守护模式帮助文档中的描述错误
- `2022/11/03`
  - 创建 DMShellInstall 脚本
- `2022/11/12`
  - 补充功能，优化脚本输出
- `2022/11/13`
  - 补充功能，增加传参判断
- `2022/11/20`
  - 修复BUG，增加参数
- `2022/11/22`
  - 增加数据守护模式安装1主1备
- `2022/11/23`
  - 增加数据守护1主2备/3备
- `2022/11/25`
  - 增加数据守护支持1主8备
- `2022/11/26`
  - 兼容 Linux 6 版本
- `2022/12/12`
  - 增加 dsc 部署功能
- `2022/12/13`
  - 增加 dsc 多链路聚合磁盘部署
- `2022/12/15`
  - 增加 dsc 自定义db_name和ep_name
- `2022/12/17`
  - 优化 dsc 脚本参数和逻辑
- `2022/12/21`
  - 内置最新的达梦数据库优化脚本，增加新的参数-sm --sort_mode 参数
- `2022/12/23`
  - 适配复杂密码，除了 & ' " ()  四种字符外，可以输入任意字符
- `2022/12/28`
  - 适配单链路单盘多分区，聚合链路单盘多分区部署dsc（只能在linux7以上版本服务器使用）
- `2023/01/02`
  - 删除"-dhn" "--wc_hostname" 参数，保留"-hn" "--hostname" 参数， 集群时是主机名前缀，例如 -hn db，每个节点主机名是db01,db02..."
- `2023/01/11`
  - 增加dsc部署本地归档模式，本地归档和asm归档混合模式
- `2023/01/12`
  - 更新AutoParaAdj3.1_20230106.sql优化脚本
- `2023/04/15`
  - 重写所有方法函数，更新参数自动优化脚本工具-AutoParaAdj3.5_dm8
- `2023/04/19`
  - 重写create_lvm.sh脚本，修改create_parted.sh脚本
- `2023/04/26`
  - 实现数据守护INSTANCE_NAME自定义
- `2023/05/04`
  - 优化输出日志函数
- `2023/05/20`
  - 添加指定服务器SSH端口
- `2023/05/29`
  - 添加-cm，-bmp参数
- `2023/05/31`
  - 添加-dmp参数
- `2023/06/12`
  - 检测服务器是否已安装数据库，如果安装则跳过安装，如果没有安装则安装
- `2023/10/13`
  - 新增脚本输入参数命令
- `2024/4/16`
  - 删除lenght_in_char参数，新增以ASM镜像方式部署DSC集群，并增加相应的部署参数
- `2024/4/19`
  - 新增数据守护异步备库部署，并增加相应的部署参数
- `2024/4/25`
  - 新增-lci参数，在部署DSC时，添加第三方确认IP地址
- `2024/7/10`
  - 修改创建core_dir目录bug
- `2024/10/15`
  - 优化数据守护参数和修改兼容Oracle部分参数
- `2024/11/03`
  - 新增同步备库和增加部署数据守护参数

# 参数介绍

关于脚本的参数使用可执行 `./DMShellInstall -h` 进行查看。

## 单机参数

单实例数据库无需任何参数即可安装。

|参数缩写|参数用途|参数默认值|是否必填|
|--|--|--|:--:|
|-di |达梦数据库安装镜像名称||√|
|-kp |达梦数据库密钥路径||×|
|-hn |主机名|dmdb|×|
|-dp |系统用户dmdb密码|Dameng@123|×|
|-d  |数据库软件安装目录|/dm|×|
|-dd |数据库文件目录|/dmdata|×|
|-ad |数据库归档目录|/dmarch|×|
|-bd |数据库备份目录|/dmbak|×|
|-dn |数据库名称|DAMENG|×|
|-in |数据库实例名称|DMSERVER|×|
|-es |数据文件簇大小，取值：16/32/64(页)，每次分配新段空间时连续的页数|32|×|
|-ps |数据页大小，取值：4/8/16/32(K)。页大小决定字段最大长度：4K(1900字节)/8K(3900)/16K(8000)/32K(8188)|32|×|
|-cs |字符串大小写敏感，可选值：Y/N 或 1/0。Y/1=敏感(小写需双引号)，N/0=不敏感||√|
|-c  |数据库字符集，0=GB18030(简体中文)/1=UTF-8(Unicode推荐)/2=EUC-KR(韩文)||√|
|-cm |兼容模式：0=原生/1=SQL92/2=ORACLE/3=MS SQL/4=MYSQL/5=DM6/6=TERADATA/7=POSTGRES|0|×|
|-bpm|空格填充模式，0='A'='A '/1='A'≠'A '(Oracle兼容)，Oracle迁移建议设为1|0|×|
|-ls |日志文件大小，单位M|1024|×|
|-er |是否开启归档模式|Y|×|
|-sl |归档空间大小，单位M|102400|×|
|-pn |监听端口号|5236|×|
|-sp |数据库SYSDBA用户密码|(1)指定密码则包含大小写字符、数字、特殊符号、大于9位数的密码，(2)不传 -sp 则随机生成12位数密码(建议使用)|×|
|-bm | 数据库备份模式，模式[1]：每天全备，模式[2]：周六全备，周日到周五增备[2]|2|×|
|-mp |优化数据库时物理内存占比|80|×|
|-om |OLTP模式，0=一般业务/OLAP/1=高并发OLTP，影响SORT_FLAG和UNDO_RETENTION|0|×|
|-m  |仅配置操作系统|N|×|
|-ud |仅安装达梦数据库软件|N|×|
|-oid|仅初始化数据库|N|×|
|-opd|自动优化数据库|Y|×|
|-oopd|脚本仅优化数据库|N|×|
|-iso|部署集群或时间服务器，需要挂载ISO镜像，脚本自动配置 YUM 源[Y]|Y|x|
|-ti |时间服务器IP地址||×|

## 数据守护参数

数据守护安装最多支持1主8备，需要所有节点挂载 ISO 用来配置 YUM 源，所有节点的 root 密码保持一致。

| 参数缩写   | 参数用途                                                                                  | 参数默认值 | 是否必填 |
| ------ | ------------------------------------------------------------------------------------- | ----- | :--: |
| -osp   | 服务器ssh端口                                                                              | 22    |  x   |
| -rp    | root用户密码                                                                              |       |  √   |
| -hn    | 主机名前缀，配置每个节点主机名为dw01,dw02...，                                                         |       |  ×   |
| -dpi   | DW 实[即]时主备公网IP，异[同]步主库公网IP，如果是实[即]时主备公网IP，以逗号隔开，例如：-dpi 192.168.31.181,192.168.31.182 |       |  √   |
| -dmi   | DW 实[即]时主备私网IP，异[同]步主库私网IP，如果是实[即]时主备公网IP，以逗号隔开，例如：-dmi 1.1.1.181,1.1.1.182           |       |  √   |
| -api   | DW 异步备库公网IP，以逗号隔开，例如：-api 192.168.31.183                                              |       |  x   |
| -ami   | DW 异步备库私网IP，以逗号隔开，例如：-dmi 1.1.1.183                                                   |       |  x   |
| -spi   | DW 同步备库公网IP，以逗号隔开，例如：-spi 192.168.31.184                                              |       |  x   |
| -smi   | DW 同步备库私网IP，以逗号隔开，例如：-dmi 1.1.1.184                                                   |       |  x   |
| -dmoi  | 监视器主机IP，例如：-dmoi 192.168.31.185                                                       |       |  x   |
| -dgn   | 数据守护组名                                                                                | GRP1  |  ×   |
| -mpn   | 私网监听端口号,取值范围：1024~65535                                                               | 5336  |  ×   |
| -mdpn  | 守护进程端口号,取值范围：1024~65535                                                               | 5436  |  ×   |
| -midpn | 实例监听守护进程端口号,取值范围：1024~65535                                                           | 5536  |  ×   |
| -at    | 数据守护归档模式，0=REALTIME(实时归档，日志写入前发送)/1=TIMELY(即时归档，日志写入后发送)                                             | 0     |  x   |
| -awa   | 数据守护性能模式，0=高性能(备库立即响应)/1=事务一致(备库重演完成再响应)                                                 | 1     |  x   |
| -ri    | 主库向异步备库发送归档时间间隔，取值：0~60秒                                                              | 60    |  x   |
| -art   | 同步备库异步恢复的时间间隔，单位秒，取值范围：1~86400                                                        | 1     |  x   |
| -sfi   | sftp服务器IP，例如：-dmi 192.168.31.186                                                      |       |  x   |
| -sfo   | sftp服务器端口                                                                             | 22    |  x   |
| -sfu   | sftp服务器用户名                                                                            |       |  x   |
| -sfp   | sftp服务器密码                                                                             |       |  x   |
| -sfd   | sftp服务器根目录，例如：/home/sftpuser/uploads                                                  |       |  x   |
DSC参数
DSC安装脚本最多支持8个节点，需要所有节点挂载 ISO 用来配置 YUM 源，所有节点的 root 密码保持一致。

| 参数缩写 | 参数用途                                                                                     | 参数默认值   | 是否必填 |
| ---- | ---------------------------------------------------------------------------------------- | ------- | :--: |
| -osp | 服务器ssh端口                                                                                 | 22      |  x   |
| -rp  | root 用户密码                                                                                |         |  √   |
| -hn  | 主机名前缀，配置每个节点主机名为dsc01,dsc02...                                                           |         |  ×   |
| -dpi | DSC     所有节点公网IP，以逗号隔开，例如：-dpi 192.168.31.181,192.168.31.182                             |         |  √   |
| -dmi | DSC     所有节点私网IP，以逗号隔开，例如：-dmi 1.1.1.181,1.1.1.182                                       |         |  √   |
| -lci | DSC     第三方确认公网IP，例如：-lci 192.168.31.185                                                 |         |  x   |
| -cdp | CSS     公网通信端口，取值：1024~65534                                                             | 9341    |  ×   |
| -adp | ASM     公网通信端口，取值：1024~65534                                                             | 9351    |  ×   |
| -ddp | DB      公网通信端口，取值：1024~65534                                                             | 9361    |  ×   |
| -amp | ASM     私网通信端口，取值：1024~65534                                                             | 9451    |  x   |
| -dmp | DB      私网通信端口，取值：1024~65534                                                             | 9461    |  x   |
| -dcd | DCR[V]  磁盘列表，DSC集群只能传入一块磁盘，例如：/dev/sdb，DSCM集群时，可以传1，3，5块磁盘，例如：/dev/sdb,/dev/sdc,/dev/sdd |         |  √   |
| -vod | VOTE    磁盘列表，DSC集群只能传入一块磁盘，例如：/dev/sdc，DSCM集群时，不用传此参数                                    |         |  X   |
| -lod | REDO    磁盘列表，可以是一块盘，也可以是多块盘，如果没有redo磁盘，可以不写，例如：/dev/sdd,/dev/sde                         |         |  ×   |
| -ard | ARCH    磁盘列表，可以是一块盘，也可以是多块盘，如果没有arch磁盘，可以不写，例如：/dev/sdf,/dev/sdg                         |         |  ×   |
| -dad | DATA    磁盘列表，可以是一块盘，也可以是多块盘，盘数必须大于等于 1        ，例如：/dev/sdh,/dev/sdi                      |         |  √   |
| -rr  | REDO镜像文件冗余模式(ASM镜像独有参数)，取值：1、2 或 3                                                       | 1       |  x   |
| -ar  | ARCH镜像文件冗余模式(ASM镜像独有参数)，取值：1、2 或 3                                                       | 1       |  x   |
| -dr  | DATA镜像文件冗余模式(ASM镜像独有参数)，取值：1、2 或 3                                                       | 1       |  x   |
| -lgm | 联机日志文件副本数(ASM镜像独有参数)，取值：1、2 或 3                                                          | 1       |  x   |
| -aam | 归档日志文件副本数(ASM镜像独有参数)，取值：1、2 或 3                                                          | 1       |  x   |
| -dtm | SYSTEM/MAIN/ROLL 表空间数据文件副本数(ASM镜像独有参数)，取值：1、2 或 3                                        | 1       |  x   |
| -ctm | dm.ctl 和 dm_service.prikey 文件副本数(ASM镜像独有参数)，取值：1、2 或 3                                   | 1       |  x   |
| -lst | 联机日志条带化粒度(ASM镜像独有参数)，取值：0、32、64、128、256，单位 KB                                            | 64      |  x   |
| -aas | 归档日志条带化粒度(ASM镜像独有参数)，取值：0、32、64、128、256，单位 KB                                            | 64      |  x   |
| -dst | 数据文件条带化粒度(ASM镜像独有参数)，取值：0、32、64、128、256，单位 KB                                            | 32      |  x   |
| -as  | 数据分配单元(ASM镜像独有参数)，取值： 1、2、4、8、16、32、64，单位 BYTES                                          | 4       |  x   |
| -rs  | ASM磁盘组日志文件大小(ASM镜像独有参数)，取值 0、32、64、128、256，单位 MB                                         | 128     |  x   |
| -ila | 是否配置本地归档，如果配置，默认数据库归档目录 [/dmarch]，可以由参数-ad指定具体目录                                         | N       |  ×   |
| -fld | 过滤重复磁盘，保留输出唯一盘符，参数值为非ASM盘符(系统盘等)，例如：-fld sda，多个盘符用逗号拼接：-fld sda,sdb                      | N       |  x   |
| -fmd | 是否需要格式化共享存储盘                                                                             | Y       |  x   |
| -mtp | 是否需要配置multipath多链路聚合，脚本默认不配置                                                             | N       |  ×   |
| -ddn | 数据库DB_NAME                                                                               | DSC     |  x   |
| -den | 数据库每个节点的实例名前缀                                                                            | DSC     |  x   |
| -apd | asm实例密码                                                                                  | Dameng1 |  ×   |

**注意：** 达梦数据库安装以及初始化相关参数，请参考单机安装参数，两者共用。

# 脚本使用

## 单机安装

使用脚本前：

- 安装好干净的 Linux 操作系统（redhat/linux/centos/麒麟）
- 配置好网络（规划 IP 地址）
- 配置好存储（规划存储）
- 解压达梦安装包，将ISO移动到与脚本一个目录下，并指定参数 -di iso镜像名称

以下提供常用安装命令，可根据实际情况进行增删。

### 仅配置操作系统

```bash
./DMShellInstall -hn dmdb `# 主机名`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-ad /dmarch `# 数据库归档目录`\
-bd /dmbak `# 数据库备份目录`\
-cs Y `# 字符串大小写敏感(必填)`\
-c 1 `# 数据库字符集：0=GB18030/1=UTF-8/2=EUC-KR(必填)`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`\
-m Y `# 仅配置操作系统`
```

### 安装软件不建库

```bash
./DMShellInstall -hn dmdb `# 主机名`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-ad /dmarch `# 数据库归档目录`\
-bd /dmbak `# 数据库备份目录`\
-cs Y `# 字符串大小写敏感(必填)`\
-c 1 `# 数据库字符集：0=GB18030/1=UTF-8/2=EUC-KR(必填)`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`\
-ud Y `# 仅安装达梦数据库软件`
```

### 最简化测试环境部署

```bash
./DMShellInstall -di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`\
-cs Y `# 字符串大小写敏感(必填)`\
-c 1 `# 数据库字符集：0=GB18030/1=UTF-8/2=EUC-KR(必填)`
```

### 生产环境安装部署

```bash
./DMShellInstall -hn dmdb `# 主机名`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-ad /dmarch `# 数据库归档目录`\
-bd /dmbak `# 数据库备份目录`\
-dn DAMENG `# 数据库名称`\
-in DMSERVER `#实例名称`\
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感，Y=敏感/N=不敏感(必填)`\
-c 1 `# 数据库字符集，0=GB18030/1=UTF-8/2=EUC-KR(必填)`\
-cm 2 `# 兼容模式，2=Oracle兼容(可选)`\
-bpm 1 `# 空格填充，1=兼容Oracle(可选)`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 仅初始化数据库实例

```bash
./DMShellInstall -dd /dmdata `# 数据库文件目录`\
-dn DAMENG `# 数据库名称`\
-in DMSERVER `#实例名称`\
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感(必填)`\
-c 1 `# 数据库字符集：0=GB18030/1=UTF-8/2=EUC-KR(必填)`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-oid Y `# 仅初始化数据库`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`
```

### 脚本仅优化数据库

```bash
./DMShellInstall -sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-in DMSERVER `#实例名称`\
-oopd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`
```

## 数据守护和DSC安装

使用脚本前：

- 主备节点均安装好干净的 Linux 操作系统（redhat/linux/centos/麒麟）
- 主备节点均配置好网络（规划业务 IP /MAL IP地址）
- 主备节点均配置好存储（规划存储）
- 主备节点均挂载操作系统 ISO 镜像
- 主节点解压达梦安装包，将ISO移动到与脚本一个目录下，并指定参数 -di iso 镜像名称

以下提供常用安装命令，可根据实际情况进行增删。

### 一主四备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183,192.168.31.184,192.168.31.185 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183,1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主两备两异备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183 \
-api 192.168.31.184,192.168.31.185 \
-ami 1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主两备两同备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183 \
-spi 192.168.31.184,192.168.31.185 \
-smi 1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主两备一异备一同备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183 \
-api 192.168.31.184 \
-ami 1.1.1.184 \
-spi 192.168.31.185 \
-smi 1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主四异备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181 \
-dmi 1.1.1.181 \
-api 192.168.31.182,192.168.31.183,192.168.31.184,192.168.31.185 \
-ami 1.1.1.182,1.1.1.183,1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主四同备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181 \
-dmi 1.1.1.181 \
-spi 192.168.31.182,192.168.31.183,192.168.31.184,192.168.31.185 \
-smi 1.1.1.182,1.1.1.183,1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主两同备两异备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181 \
-dmi 1.1.1.181 \
-api 192.168.31.182,192.168.31.183 \
-ami 1.1.1.182,1.1.1.183 \
-spi 192.168.31.184,192.168.31.185 \
-smi 1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主三同备一异备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181 \
-dmi 1.1.1.181 \
-api 192.168.31.182 \
-ami 1.1.1.182 \
-spi 192.168.31.183,192.168.31.184,192.168.31.185 \
-smi 1.1.1.183,1.1.1.184,1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主一同备三异备（手动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181 \
-dmi 1.1.1.181 \
-api 192.168.31.182,192.168.31.183,192.168.31.184 \
-ami 1.1.1.182,1.1.1.183,1.1.1.184 \
-spi 192.168.31.185 \
-smi 1.1.1.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主三备（自动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183,192.168.31.184 \
-dmoi 192.168.31.185 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183,1.1.1.184 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主两备一异备（自动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183 \
-api 192.168.31.184 \
-ami 1.1.1.184 \
-dmoi 192.168.31.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主两备一同备（自动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182,192.168.31.183 \
-dmi 1.1.1.181,1.1.1.182,1.1.1.183 \
-spi 192.168.31.184 \
-smi 1.1.1.184 \
-dmoi 192.168.31.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

### 一主一备一同备一异备（自动切换）

```bash
./DMShellInstall -di dm8_20241011_x86_rh6_64.iso \
-dpi 192.168.31.181,192.168.31.182 \
-dmi 1.1.1.181,1.1.1.182 \
-spi 192.168.31.183 \
-smi 1.1.1.183 \
-api 192.168.31.184 \
-ami 1.1.1.184 \
-dmoi 192.168.31.185 \
-rp 'YZJ20241103' \
-hn dw \
-cs Y -c 1 \
-d /opt/dmdbms -dd /dmdata -ad /dmarch -bd /dmbak
```

## 两节点 dsc

### 磁盘分区：dcr vote data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182 `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-dad /dev/sde,/dev/sdf,/dev/sdg ` #数据盘，此时默认redo日志和归档与数据文件在一起`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 磁盘分区：dcr vote arch data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182 `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-ard /dev/sde `# 归档日志磁盘`\
-dad /dev/sdf,/dev/sdg `# 数据盘，此时默认redo日志与数据文件在一起`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 磁盘分区：dcr vote log data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182 `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-lod /dev/sde `# redo日志磁盘`\
-dad /dev/sdf,/dev/sdg `#数据盘，此时默认归档日志与数据文件在一起`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `#asm 实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 磁盘分区：dcr vote arch log data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182 `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-ard /dev/sde `# 归档日志磁盘`\
-lod /dev/sdf `# redo日志磁盘`\
-dad /dev/sdg `# 数据盘`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

## 三节点 dsc

### 磁盘分区：dcr vote data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182,10.211.55.103 `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182,1.1.1.3 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-dad /dev/sde,/dev/sdf,/dev/sdg `#数据盘，此时默认redo日志和归档与数据文件在一起`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 磁盘分区：dcr vote arch data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182,10.211.55.103  `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182,1.1.1.3 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-ard /dev/sde `# 归档日志磁盘`\
-dad /dev/sdf,/dev/sdg `#数据盘，此时默认redo日志与数据文件在一起`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 磁盘分区：dcr vote log data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182,10.211.55.103  `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182,1.1.1.3 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-lod /dev/sde `# redo日志磁盘`\
-dad /dev/sdf,/dev/sdg `#数据盘，此时默认归档日志与数据文件在一起`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```

### 磁盘分区：dcr vote arch log data

```bash
./DMShellInstall -hn dsc `# dsc主机名前缀`\
-dpi 192.168.31.181,192.168.31.182,10.211.55.103  `# dsc业务IP`\
-dmi 1.1.1.181,1.1.1.182,1.1.1.3 `# 各节点MAL IP`\
-dcd /dev/sdc `# dcr磁盘`\
-vod /dev/sdd `# vote磁盘`\
-ard /dev/sde `# 归档日志磁盘`\
-lod /dev/sdf `# redo日志磁盘`\
-dad /dev/sdg #`数据盘`\
-cdp 12345 `# css通信端口号`\
-adp 12346 `# asm通信端口号`\
-ddp 12347 `# 实例通信端口号`\
-amp 8888  `# mal系统通信端口`\
-rp P@ssw0rdPST `# 服务器 root 用户密码`\
-dp Dameng@123 `# dmdba用户密码`\
-d /dm `# 软件安装目录`\
-dd /dmdata `# 数据库文件目录`\
-bd /dmbak `# 数据库备份目录`\
-apd Dameng1 `# asm实例密码`
-es 32 `# 数据文件簇大小`\
-ps 32 `# 数据页大小`\
-cs Y `# 字符串大小写敏感`\
-c 1 `# 数据库字符集`\
-sl 10240 `# 归档空间大小`\
-pn 5236 `# 监听端口号`\
-sp Dm@SYSDBA1234 `# 数据库SYSDBA用户密码`\
-bm 2 `# 数据库备份模式 1全备 2增量`\
-opd Y `# 优化数据库参数`\
-mp 80 `# 优化数据库物理内存占比`\
-di dm8_20221008_x86_rh6_64.iso `# 达梦ISO镜像名称`
```


---

# 安装结果报告

脚本执行完毕后，会自动生成安装配置报告文件，方便您保存和查阅。

## 报告文件位置

报告文件保存在脚本执行目录，命名格式：
```
dm_install_report_YYYYMMDDhhmmss.txt
```

## 报告内容

报告包含以下信息：

### 1. 基础信息
- 生成时间
- 安装模式（单机/数据守护/DSC/DSCM）
- 主机名、节点号

### 2. 目录信息
- 软件安装目录（$DM_HOME）
- 数据文件目录
- 归档目录、备份目录
- Core目录、脚本目录

### 3. 数据库初始化参数
- 数据库名称、实例名
- 字符集（含详细说明）
- 大小写敏感设置
- 页大小、簇大小
- 兼容模式
- 监听端口

### 4. 账号密码信息（重要）
⚠️ **警告：以下密码信息非常重要，请妥善保管！**
- dmdba系统用户密码
- SYSDBA密码
- SYSAUDITOR密码
- SYSSSO密码（安全版）

### 5. 备份配置
- 备份模式（全备/增量）
- 备份时间
- 归档空间限制

### 6. 服务管理信息
- 开机启动状态
- 服务启停命令
- 启动/停止顺序

### 7. 快捷命令参考
- 切换dmdba用户
- 连接数据库
- 查看数据库状态
- 启动管理工具

## 安全提醒

⚠️ **报告文件包含明文密码信息，请：**
- 妥善保管报告文件
- 不要将报告文件上传到公共位置
- 查看后建议加密保存或删除

---

# 服务管理指南

## 开机启动状态

数据库服务默认设置为开机自启动，通过 `dm_service_installer.sh` 注册为 systemd 服务。

## 单机模式服务管理

### 服务名称
```
DmService<数据库名>
例如：DmServiceDAMENG
```

### 常用命令
```bash
# 启动数据库
systemctl start DmServiceDAMENG

# 停止数据库
systemctl stop DmServiceDAMENG

# 重启数据库
systemctl restart DmServiceDAMENG

# 查看状态
systemctl status DmServiceDAMENG

# 设置开机自启
systemctl enable DmServiceDAMENG

# 禁用开机自启
systemctl disable DmServiceDAMENG
```

## 数据守护模式服务管理

### 服务名称
1. **数据库服务**：`DmService<数据库名>`
2. **守护进程服务**：`DmWatcherService<组名>`

例如：
```
DmServiceDAMENG
DmWatcherServiceGRP1
```

### 启动顺序
```bash
# 1. 先启动数据库
systemctl start DmServiceDAMENG

# 2. 再启动守护进程
systemctl start DmWatcherServiceGRP1
```

### 停止顺序（重要）
```bash
# 1. 先停止守护进程
systemctl stop DmWatcherServiceGRP1

# 2. 再停止数据库
systemctl stop DmServiceDAMENG
```

### 常用命令
```bash
# 查看数据库状态
systemctl status DmServiceDAMENG

# 查看守护进程状态
systemctl status DmWatcherServiceGRP1

# 启动数据守护监视器（确认监视器上执行）
dmmonitor /dmdata/DAMENG/dmmonitor_GRP1.ini
```

## DSC集群服务管理

### 服务名称
1. **CSS服务**：`DmCSSServiceCss`
2. **ASM服务**：`DmASMSvrServiceAsmsvr`（DSC）或 `DmASMSvrmServiceAsmsvr`（DSCM）
3. **数据库服务**：`DmService<数据库名>`

### 启动顺序
```bash
# 1. 先启动CSS服务
systemctl start DmCSSServiceCss

# 2. 再启动ASM服务（DSC）
systemctl start DmASMSvrServiceAsmsvr
# 或 DSCM
systemctl start DmASMSvrmServiceAsmsvr

# 3. 最后启动数据库服务
systemctl start DmServiceDSC
```

### 停止顺序（相反）
```bash
# 1. 先停止数据库服务
systemctl stop DmServiceDSC

# 2. 再停止ASM服务（DSC）
systemctl stop DmASMSvrServiceAsmsvr
# 或 DSCM
systemctl stop DmASMSvrmServiceAsmsvr

# 3. 最后停止CSS服务
systemctl stop DmCSSServiceCss
```

### 常用命令
```bash
# 启动CSSM管理工具
dmcssm /dmdata/DSC/dmcssm.ini

# 查看CSS状态
systemctl status DmCSSServiceCss

# 查看ASM状态
systemctl status DmASMSvrServiceAsmsvr

# 查看数据库状态
systemctl status DmServiceDSC
```

## 注意事项

1. **严格按照顺序启停服务**，否则可能导致服务异常
2. DSC集群中，**CSS服务必须先启动**，它是集群的基础
3. 修改服务配置后，需要执行 `systemctl daemon-reload`
4. 如遇服务启动失败，可查看日志：
   ```bash
   # 查看服务日志
   journalctl -u DmServiceDAMENG -f
   
   # 查看达梦数据库日志
   tail -f $DM_HOME/log/*.log
   ```

