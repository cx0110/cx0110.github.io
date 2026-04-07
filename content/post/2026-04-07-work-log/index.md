---
title: "📅 2026-04-07 工作日志"
subtitle: "算法、数据库与 Go 语言学习笔记"
summary: "今日工作学习记录：二叉树遍历、最小/最大栈、滑动窗口最大值、MySQL B+树与索引优化、Go Channel 特性"
authors:
  - admin
tags:
  - 学习日志
  - 算法
  - 数据库
  - Go
categories:
  - 工作日志
date: 2026-04-07T09:00:00+08:00
lastmod: 2026-04-07T18:00:00+08:00
featured: false
draft: false
image:
  filename: ""
  focal_point: Smart
  preview_only: false
---

## 🍅 今日番茄

今日完成的学习任务：

- ✅ 力扣 (3 个番茄钟)
- ✅ Go 语言
- ⏳ 分布式、K8s (未完成)
- ✅ 数据库 (1 个番茄钟)
- ✅ AI 学习
- ✅ 架构设计师
- ⏳ 锻炼 (未完成)

---

## 📝 工作记录

### 力扣

#### 二叉树前中后序遍历

- **前序遍历**：根 → 左 → 右
- **中序遍历**：左 → 根 → 右
- **后序遍历**：左 → 右 → 根

> AI 补充：掌握遍历顺序的记忆口诀和代码实现模板

#### 最小栈

使用辅助栈存储当前最小值，入栈时同步更新最小栈。

> AI 补充：minStack 存储 (n, currentMin)，其中 n 为入栈值，currentMin 为此刻最小值；出栈时同步弹出。实现：两个栈一个存值一个存最小值

#### 最大栈

使用辅助栈存储当前最大值，popMax 时需借助临时栈。

> AI 补充：可使用单调递减栈 + 双向链表实现，链表节点包含 value 和当前最大值的指针，popMax 时从链表头部弹出并更新最大指针

#### 239. 滑动窗口最大值

使用单调队列（队首为当前窗口最大值）。

> AI 补充：单调队列核心：
> 1. 入队时删除队尾所有小于新元素的元素
> 2. 出队时如果队首等于要出队的元素则弹出
> 3. 保持队列单调递减，队首始终是当前窗口最大值

---

### 数据库

#### MySQL 为什么用 B+ 树？

- B+ 树的高度更低，跳表或红黑树需要平衡操作较慢
- B+ 树顺序存储，适合范围查找
- 所有叶子节点以链表形式链接

> AI 补充：B+ 树相比跳表、红黑树等平衡树，插入删除时不需要频繁旋转操作；所有叶子节点在同一层且通过链表相连，适合范围查询（BETWEEN、>、< 等）；非叶子节点不存储数据，每个节点可容纳更多分支，树高更低，磁盘 IO 次数更少

#### 索引分类

**根据索引是否存放数据**：
- 聚簇索引：存放数据
- 非聚簇索引：只存放键值

> AI 补充：InnoDB 主键是聚簇索引，叶子节点存储完整行数据；非聚簇索引叶子节点存储索引键和主键 ID，查询时需回表

**根据查询是否覆盖所有字段**：判断是否为覆盖索引

> AI 补充：覆盖索引指索引包含 SELECT、WHERE、ORDER BY、GROUP BY 所需的所有字段，无需回表，查询性能最优

**根据字段前缀进行前缀索引查询**

> AI 补充：适用于长字符串字段，如 VARCHAR(255)，只索引前 N 个字符，平衡 selectivity 和存储空间

#### 创建索引

- 在 WHERE/JOIN 条件中常用的字段创建，或将外键创建成索引
- 关联字段、外键链、区分度高的列适合建索引

> AI 补充：区分度 = COUNT(DISTINCT col)/COUNT(*)，接近 1 时索引效果最佳；外键字段建索引可避免父表更新时的全表锁

#### SQL 优化

**将 ORDER BY 或 WHERE 字段设置为索引**，减少磁盘 IO 和 CPU 消耗

> AI 补充：索引是有序的，可避免额外的排序操作（Using filesort）；组合索引需遵循最左前缀原则

**通过 EXPLAIN 分析执行计划**，使用 FORCE INDEX 强制指定索引，避免优化器选错索引

> AI 补充：EXPLAIN 关键列：type（最好到 ref/range）、key（实际用到的索引）、rows（扫描行数）、Extra（Using index/Using filesort 等）

**将 HAVING 中的字段移到 WHERE 子句中**（先执行 WHERE 再执行 HAVING）

> AI 补充：WHERE 在聚合前过滤，HAVING 在聚合后过滤，将可下推的条件移到 WHERE 可减少聚合数据量，提升性能

示例：

```sql
-- 低效：HAVING 在聚合后过滤
SELECT department, COUNT(*) as cnt
FROM employees
GROUP BY department
HAVING salary > 5000

-- 高效：WHERE 先过滤再聚合
SELECT department, COUNT(*) as cnt
FROM employees
WHERE salary > 5000
GROUP BY department
```

**优化分页偏移量**：避免大 OFFSET，用 WHERE 或游标分页

问题：`LIMIT 10000, 10` 会扫描 10010 行，偏移越大越慢

优化方案：

```sql
-- 低效：OFFSET 10000
SELECT * FROM orders ORDER BY id LIMIT 10000, 10;

-- 高效：基于 ID 游标
SELECT * FROM orders WHERE id > last_id ORDER BY id LIMIT 10;
-- 或
SELECT * FROM orders WHERE id > 10000 ORDER BY id LIMIT 10;
```

#### 大表变更

- 大表变更时表不能进行其他操作，影响业务

> AI 补充：大表 DDL 操作（如添加字段、添加索引）会锁表，阻塞所有读写请求

- **方案**：停机更新、低谷时更新、或新建表导数据

> AI 补充：pt-online-schema-change、gh-ost 等工具可实现在线 DDL，原理：新建表 → 同步数据 → 切换；MySQL 8.0 原生支持即时 DDL

---

### Go

#### Channel 会触发 panic 的情况

- 向已关闭的 channel 发送数据
- 关闭已关闭的 channel

> AI 补充：
> 1. close(nil channel) 会 panic
> 2. send to closed channel 会 panic
> 3. close already closed channel 会 panic

#### 对已关闭的 channel 进行读取和写入操作

- 读取已关闭的 channel：会立即返回零值，不阻塞
- 写入已关闭的 channel：会 panic

#### for range 对集合类型的遍历

- for range 支持 array、slice、map、channel 遍历
- 遍历 map 时顺序随机
- 遍历 channel 会阻塞直到 channel 关闭

#### for range 遍历 channel 时

对业务 channel 会永久阻塞

> AI 补充：for range 遍历 channel 会持续接收值直到 channel 关闭，若 channel 永不关闭则永久阻塞

#### for range 遍历 string 时注意

string 底层是 UTF-8 编码，中文字符占用多个字节，下标可能不连续

> AI 补充：string 底层是 byte 数组，len() 返回字节数而非字符数；中文字符在 UTF-8 占 3 字节，用下标访问可能得到字节片段而非完整字符；正确遍历：`for i, r := range str { // r 是 rune }`

---

## 🍅 番茄日志

- 🍅 WORK (25m) 09:20 - 09:45
- 🍅 WORK (25m) 09:51 - 10:16
- 🍅 WORK (25m) 10:17 - 10:49
- 🍅 WORK (25m) 14:41 - 15:06
- 🍅 WORK (25m) 16:05 - 16:30
- 🥤 BREAK (5m) 16:31 - 16:36
