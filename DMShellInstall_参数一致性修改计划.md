# DMShellInstall 脚本参数一致性检查与修改计划

## 一、问题概述

经过对 `DMShellInstall` 脚本的详细检查，发现帮助文档与实际代码处理之间存在**多处不一致**。这些问题可能导致用户按照帮助文档使用参数时出现错误。

**重要说明**：本计划的执行将遵循"先复制原脚本，再修改副本"的原则，不会直接修改原脚本 `DMShellInstall`。

---

## 二、发现的不一致问题

### 1. 参数定义格式错误（严重）

| 位置 | 问题描述 | 当前代码 | 应修改为 |
|------|---------|---------|---------|
| 第 6436 行 | `-rs` 参数缺少 `--` 前缀 | `-rs | redo_size)` | `-rs | --redo_size)` |

**影响**：此语法错误可能导致参数解析异常。

---

### 2. 参数校验变量引用错误（严重）

以下参数在代码中校验时错误地引用了 `$redo_redun` 变量，而非各自对应的变量：

| 参数 | 帮助文档描述 | 代码行 | 当前校验代码 | 应校验变量 |
|------|-------------|--------|-------------|-----------|
| `-ar` | ARCH镜像文件冗余模式 | 6456 行 | `checkpara_validity "$1" "$redo_redun"` | `"$arch_redun"` |
| `-dr` | DATA镜像文件冗余模式 | 6462 行 | `checkpara_validity "$1" "$redo_redun"` | `"$data_redun"` |

**影响**：用户设置 `-ar` 或 `-dr` 参数时，脚本实际校验的是 `-rr` 的值，导致参数校验失效。

---

### 3. 帮助文档默认值与代码一致性检查

| 参数 | 帮助文档默认值 | 代码中实际默认值 | 状态 |
|------|--------------|----------------|------|
| `-lst` | 64 | 64 | ✅ 一致 |
| `-dst` | 32 | 32 | ✅ 一致 |
| `-aas` | 64 | 64 | ✅ 一致 |
| `-rs` | 128 | 128 | ✅ 一致 |

**注**：经核对，DSC 相关参数的默认值描述与代码一致。

---

### 4. 帮助文档描述问题

#### 4.1 数据守护模式帮助描述错误

| 参数 | 当前描述 | 问题 |
|------|---------|------|
| `-dmi` | "DW 实[即]时主备私网IP，异[同]步主库私网IP，如果是实[即]时主备公网IP，以逗号隔开" | 描述冗余且混乱，最后一句"实[即]时主备**公网IP**"应为"**私网IP**" |
| `-ami` | "DW 异步备库私网IP，以逗号隔开，例如：-dmi 1.1.1.183" | 示例使用了 `-dmi` 而非 `-ami` |
| `-smi` | "DW 同步备库私网IP，以逗号隔开，例如：-dmi 1.1.1.184" | 示例使用了 `-dmi` 而非 `-smi` |

---

## 三、修改执行步骤

### 步骤 1：复制原脚本

```bash
# 创建修改后的脚本副本
cp DMShellInstall DMShellInstall_fixed
```

### 步骤 2：修复语法错误（在副本上操作）

#### 修复 1：修复 `-rs` 参数定义格式
```bash
sed -i 's/-rs | redo_size)/-rs | --redo_size)/' DMShellInstall_fixed
```

#### 修复 2：修复 `-ar` 参数校验变量引用
```bash
sed -i '6456s/"$redo_redun"/"$arch_redun"/' DMShellInstall_fixed
```

#### 修复 3：修复 `-dr` 参数校验变量引用
```bash
sed -i '6462s/"$redo_redun"/"$data_redun"/' DMShellInstall_fixed
```

### 步骤 3：修复帮助文档描述错误（在副本上操作）

#### 修复 4：修正 `-dmi` 描述
```bash
# 行号约 1484，将"如果是实[即]时主备公网IP"改为"如果是实[即]时主备私网IP"
sed -i '1484s/主备公网IP/主备私网IP/' DMShellInstall_fixed
```

#### 修复 5：修正 `-ami` 示例
```bash
# 行号约 1486，将示例中的 -dmi 改为 -ami
sed -i '1486s/-dmi 1.1.1.183/-ami 1.1.1.183/' DMShellInstall_fixed
```

#### 修复 6：修正 `-smi` 示例
```bash
# 行号约 1488，将示例中的 -dmi 改为 -smi
sed -i '1488s/-dmi 1.1.1.184/-smi 1.1.1.184/' DMShellInstall_fixed
```

---

## 四、验证修改结果

### 4.1 语法检查
```bash
bash -n DMShellInstall_fixed
echo "语法检查退出码: $?"
```

### 4.2 对比修改差异
```bash
diff DMShellInstall DMShellInstall_fixed
```

### 4.3 验证帮助文档
```bash
sh DMShellInstall_fixed --help
```

### 4.4 验证参数解析
```bash
# 测试 -rs 参数是否被正确解析
sh DMShellInstall_fixed -rs 256 --help 2>&1 | head -20

# 测试 -ar 和 -dr 参数校验
sh DMShellInstall_fixed -ar 4 -h 2>&1 | grep -E "(ar|redun)"
```

---

## 五、交付物

修改完成后，将生成以下文件：

| 文件名 | 说明 |
|--------|------|
| `DMShellInstall` | 原始脚本（保持不变） |
| `DMShellInstall_fixed` | 修复后的脚本副本 |
| `DMShellInstall_参数一致性修改计划.md` | 本计划文档 |

---

## 六、修改影响评估

| 修改项 | 风险等级 | 影响范围 | 回滚方式 |
|--------|---------|---------|---------|
| 修复 `-rs` 参数格式 | 低 | 参数解析 | 使用原脚本 |
| 修复 `-ar/-dr` 校验变量 | 低 | 参数校验 | 使用原脚本 |
| 帮助文档描述修正 | 极低 | 仅文档显示 | 使用原脚本 |

**回滚说明**：由于采用复制后修改的方式，如修改后出现问题，可直接使用原脚本 `DMShellInstall`。

---

## 七、可选优化建议（本次不执行）

以下参数在代码中已定义，但在普通帮助函数 `help()` 中**未列出**，仅在隐藏帮助 `hidden_help()` 中显示，如需添加可在后续版本中考虑：

| 参数 | 代码中用途 |
|------|-----------|
| `-lic` | VARCHAR类型长度是否以字符为单位 |
| `-dpv` | 初始化数据库特殊参数 |
| `-oguid` | 部署集群时生成6位随机数 |
| `-ari` | 使用别名代替心跳网络IP |

---

## 八、后续修复记录（2026-04-21）

以下问题在后续实际运行中发现并已直接修复原脚本 `DMShellInstall`。

### 8.1 备份 SQL 脚本执行后作业未创建

| 问题 | 根因 | 修复方式 |
|------|------|---------|
| 安装后生成了备份 SQL 脚本，但数据库中未发现备份作业 | `dm_bak()` 生成的 `conf_fullbackup.sql` 和 `conf_incrbackup.sql` 中，`SP_ADD_JOB_STEP` 的第 4 个参数（命令字符串）被拆成两行。`disql` 按行解析时，将第一行视为不完整的 `call` 语句执行报错，第二行被解析为非法 SQL。由于 `disql` 开启了静默模式（`-S`）且 `execute_script()` 返回值未被检查，错误被静默吞噬 | 将 4 处跨行的 `SP_ADD_JOB_STEP` 参数字符串合并为单行 |

**涉及修改位置**：
- `conf_fullbackup.sql`：`bak_full` 和 `bak_arch` 的 `bak_del` 步骤
- `conf_incrbackup.sql`：`bak_inc` 和 `bak_arch` 的 `bak_del` 步骤

### 8.2 默认密码包含 `@` 导致连接串解析歧义

| 问题 | 根因 | 修复方式 |
|------|------|---------|
| 默认密码（如 `Dm@SYSDBA123`）包含 `@`，`disql` 连接串 `username/password:port` 中的 `@` 可能被解析器误识别为 `username/password@host:port` 的分隔符 | 密码设计使用了特殊字符 `@` | 将三个默认临时密码中的 `@` 替换为 `_`：`Dm_SYSDBA123`、`Dm_SYSAUD123`、`Dm_SYSSSO123`，并同步更新参数校验中的固定值比较 |

### 8.3 SYSAUDITOR 密码安装报告与日志不一致

| 问题 | 根因 | 修复方式 |
|------|------|---------|
| 单机安装时，安装报告显示 SYSAUDITOR 密码为固定临时密码，但安装日志中显示的是随机生成的密码 | `modify_pwd()` 中随机生成的密码仅存入局部数组 `user_pwd`，`generate_install_report()` 中 `${sysaud_pwd:-$sysauditor_pwd_temp}` 回退到固定临时密码 | 在 `modify_pwd()` 的 `case` 分支中，将实际使用的密码同步赋值给对应的全局变量 `sysdba_pwd`、`sysaud_pwd`、`syssso_pwd` |

---

*计划创建时间：2026-03-26*  
*检查脚本版本：DMShellInstall (更新时间 2024-12-27)*  
*计划文件位置：/home/dmha/DMShellInstall-master/soft/DMShellInstall_参数一致性修改计划.md*  
*后续修复时间：2026-04-21*
