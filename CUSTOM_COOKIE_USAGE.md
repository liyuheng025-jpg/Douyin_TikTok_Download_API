# 自定义Cookie配置使用说明

本文档介绍了如何使用独立的Cookie配置文件和脚本来管理抖音API的Cookie。

## 目录结构

```
.
├── crawlers/
│   └── douyin/
│       └── web/
│           ├── config.yaml          # 原始配置文件
│           ├── douyin_cookies.yaml  # 新增：独立的Cookie配置文件
│           └── ...
├── update_douyin_cookie.sh         # 更新Cookie脚本（仅更新配置文件）
├── advanced_update_cookie.sh       # 高级更新脚本（同时更新API和配置文件）
└── ...
```

## 配置文件说明

### 1. 独立Cookie配置文件

- **路径**: `crawlers/douyin/web/douyin_cookies.yaml`
- **用途**: 专门存放抖音Web版的Cookie信息
- **优先级**: 系统会优先读取此文件，如果不存在则回退到原始配置文件

### 2. 配置文件内容

`douyin_cookies.yaml` 文件结构如下：

```yaml
TokenManager:
  douyin:
    headers:
      Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2
      User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36
      Referer: https://www.douyin.com/
      Cookie: "你的Cookie值"  # 在此处填入你的抖音Cookie值

    proxies:
      http:
      https:

    msToken:
      # ... 其他配置 ...

    ttwid:
      # ... 其他配置 ...
```

## 使用脚本更新Cookie

### 1. 更新配置文件中的Cookie

```bash
# 直接传入Cookie值
./update_douyin_cookie.sh "your_actual_cookie_value_here"

# 从文件读取Cookie值
./update_douyin_cookie.sh "/path/to/your/cookie_file.txt"
```

### 2. 高级更新（推荐）

```bash
# 高级更新脚本会尝试：
# 1. 通过API更新正在运行的服务 (端口8001)
# 2. 更新配置文件
./advanced_update_cookie.sh "your_actual_cookie_value_here"

# 或从文件读取
./advanced_update_cookie.sh "/path/to/your/cookie_file.txt"
```

## 获取有效的Cookie

### 方法1: 浏览器开发者工具

1. 打开抖音网页版 (https://www.douyin.com)
2. 登录你的账号
3. 按 F12 打开开发者工具
4. 切换到 Network（网络）标签页
5. 刷新页面
6. 找到任意请求（如 `/aweme/v1/web/aweme/detail/`）
7. 在 Headers（请求头）中找到 Cookie 值
8. 复制完整的 Cookie 值

### 方法2: 浏览器扩展

使用如 "Cookie Editor" 等浏览器扩展来方便地复制Cookie。

## 重要提示

1. **Cookie时效性**: Cookie可能会过期，如果发现API失效，可能需要重新获取新的Cookie
2. **安全性**: Cookie包含敏感信息，请妥善保管，不要分享给他人
3. **备份**: 脚本会自动备份原始配置文件，文件名为 `douyin_cookies.yaml.backup.[timestamp]`
4. **服务重启**: 更新配置文件后，需要重启服务才能生效（除非通过API动态更新）

## 故障排除

### 问题1: API更新失败
- 确保服务正在运行（默认端口8001）
- 检查API地址是否正确

### 问题2: 配置文件更新失败
- 检查文件权限
- 确认备份文件是否创建成功

### 问题3: Cookie无效
- 确认Cookie格式正确
- 检查Cookie是否已过期
- 确认是否包含必需的所有Cookie字段