# 自定义Cookie配置实现总结

## 修改内容概述

### 1. 代码修改

#### 1.1 抖音Cookie配置
- **文件**: `crawlers/douyin/web/utils.py`
- **修改**: 添加从固定路径 `/opt/tiger/toutiao/app/douyin_cookie.txt` 读取Cookie的功能
- **逻辑**: 优先级顺序为 固定路径文件（内容不为空）> 项目内配置文件 > 默认配置
- **容错机制**: 当固定路径文件存在但内容为空时，系统自动回退到使用默认配置

#### 1.2 TikTok Cookie配置
- **文件**: `crawlers/tiktok/web/utils.py`
- **修改**: 添加从固定路径 `/opt/tiger/toutiao/app/tiktok_cookie.txt` 读取Cookie的功能
- **逻辑**: 优先级顺序为 固定路径文件（内容不为空）> 项目内配置文件 > 默认配置
- **容错机制**: 当固定路径文件存在但内容为空时，系统自动回退到使用默认配置

### 2. 端口修改
- **文件**: `config.yaml`
- **修改**: 将服务端口从 80 改为 8001
- **影响**: 所有相关脚本和文档均已更新为新端口

### 3. 脚本增强
- **新增**: `advanced_update_cookie.sh` - 高级Cookie更新脚本
- **新增**: `setup_fixed_cookie_path.sh` - 固定路径设置脚本
- **新增**: `test_cookie_loading.py` - Cookie加载测试脚本
- **新增**: `restart_service.sh` - 服务重启脚本

### 4. 文档更新
- **更新**: `CUSTOM_COOKIE_USAGE.md` - 使用说明文档，添加固定路径说明
- **新增**: 三种配置方式的优先级说明

## 优先级顺序

### 抖音配置优先级
1. **最高优先级**: `/opt/tiger/toutiao/app/douyin_cookie.txt` (固定路径文件)
2. **第二优先级**: `crawlers/douyin/web/douyin_cookies.yaml` (项目内独立配置)
3. **第三优先级**: `crawlers/douyin/web/config.yaml` (原始配置文件)

### TikTok配置优先级
1. **最高优先级**: `/opt/tiger/toutiao/app/tiktok_cookie.txt` (固定路径文件)
2. **第二优先级**: `crawlers/tiktok/web/config.yaml` (原始配置文件)

## 验证步骤

1. **本地测试**: 运行 `python test_cookie_loading.py` 验证Cookie加载逻辑
2. **服务启动**: 使用 `python start.py` 启动服务（端口8001）
3. **服务重启**: 使用 `./restart_service.sh` 重启服务（更新Cookie后使用）
4. **API测试**: 使用 `curl "http://localhost:8001/api/hybrid/video_data?url=..."` 测试API

## 部署说明

在生产环境中：

### 抖音Cookie部署
1. 将抖音Cookie值写入 `/opt/tiger/toutiao/app/douyin_cookie.txt`
2. 启动服务，系统会自动从固定路径读取抖音Cookie
3. 如需更新Cookie，只需替换文件内容，重启服务即可

### TikTok Cookie部署
1. 将TikTok Cookie值写入 `/opt/tiger/toutiao/app/tiktok_cookie.txt`
2. 启动服务，系统会自动从固定路径读取TikTok Cookie
3. 如需更新Cookie，只需替换文件内容，重启服务即可

## 注意事项

- 固定路径文件必须存在且可读才能被优先使用
- Cookie文件不应包含额外的换行符或其他格式
- 服务重启后新的Cookie才会生效
- 更新Cookie后使用 `./restart_service.sh` 脚本重启服务
- 确保固定路径具有适当的读取权限