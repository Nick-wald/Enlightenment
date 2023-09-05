# 欢迎

> 就在我人生之旅的中途，
> 
> 我在一座昏暗的森林之中醒悟过来，
>
> 因为我在里面迷失了正确的道路。
>
> ——但丁《神曲·地狱篇》


**启明（Enlightenment）** 是基于`Godot`研发的RPG游戏引擎框架。引擎基于面向对象，以节点/组件为基本单位进行开发。为了更快地衔接游戏引擎开发，建议您先阅览下面的简介。

# 代码架构速览

## 文件夹

`Godot` 默认有两个虚拟文件夹，游戏本体文件一般放在`res`，用户数据文件一般放在`user`。为了避免读写权限和文件锁等问题的出现，我们约定，所有的 `DLC/mod/游戏存档` 都存放在user。

### res://

- `AutoLoad` 》 系统组件
- `scenes` 》 游戏场景
- `sources` 》 资源文件
  - `audio` 》 音频（BGM/UI/……）
  - `Character` 》 角色贴图
	- `sheet_definitions` 》 角色精灵资源定义
	- `spritesheets` 》 角色精灵表
  - `fonts` 》 字体
  - `GUI` 》 图像用户界面贴图
  - `shader` 》 着色器

### user://

- `DLC` 》 DLC附加包
- `mod` 》 mod模组包
- `logs` 》日志

## 系统组件

- `AutoLoad` 》 游戏入口，单例模式实现，文件层交互
- `Global` 》 全局参数，全局方法
- `AudioManager` 》 音频服务组件（BGM/SFX/BGS……）
- `EntityManager` 》 实体服务组件（实体构造器，实体对象池……）
  - `EntityModel`（依赖`EntityManager`） 》 实体模型（实体原型，容器类实体，开关类实体，门实体……）
- `CharacterManager` 》 角色服务组件（角色构造器，随机角色生成器，角色对象池……）
  - `CharacterModel`（依赖`CharacterManager`，继承`EntityModel`/`EntityCharacter`） 》 角色模型
- `ItemManager` 》 物品服务组件（高级物品功能）
  - `ItemModel`（依赖于`ItemManager`）》物品模型（对`EntityModel`的拓展）
- `GameManager` 》 游戏服务组件（游戏内部功能函数集，游戏功能调度）
- `EnvManager` 》 全局环境服务组件（地图载入/生成，地形计算，游戏时间……）
- `GUIManager` 》 GUI服务组件（绘制GUI）
  - `GUIModel`（依赖`GUIManager`） 》 GUI模型（设置界面，DLC管理界面，对话框……）
- `TOP` 》 顶部GUI层（DEBUG开关提示，报错/警告消息……）

## 游戏场景

- `Beginning` 》 游戏进入首页
- `Transition` 》 游戏加载过渡界面

# 更新日志

## 2023.9.1

> 游离的箭，飞溅的血。
> 
> ——《斯皮瑞特族纪实》霍特布·瓦，西尔莱夫国家出版社，西历0年出版

- Framework
  - `AudioManager`:
	- 增加：BGM播放系统
  - `EntityModel`:
	- 增加： `model2D` 和 `model3D` 虚函数
  - `GUIModel > Setting`:
	- 设置界面完善（持久化保存+预览）
  - `GUIManager`:
	- `changeShowMode()`更新，优化了处理逻辑

## 2023.9.3

> 代为神罚，惊天动地。
> 
> ——《萨布西斯特族传说集》霍特布·瓦，西尔莱夫国家出版社，西历0年出版

- Framework
  - `Beginning`:
	- 增加：`开始游戏`的进入/退出动画
	- 增加：游戏模式：`Story/Balance/Strategy`
  - `GameManager`:
	- 增加：`setGameMode()`游戏模式调整函数
  - `GUI`:
	- 更新了`背景框`样式
  - `EntityModel`:
	- 增加：人物生成器精灵资源【仅仅是美术资源，待代码实现】（基于[LPC Character generator](https://github.com/Gaurav0/Universal-LPC-Spritesheet-Character-Generator)实现）
  - `TOP`:
	- 完善：`F11`显示调试信息
  - `GUIManager`:
	- 添加：`max_fps`设定功能

## 2023.9.4

> 暗夜无声，大象无形。
> 
>——《沙杜奥斯族纪实》霍特布·瓦，西尔莱夫国家出版社，西历0年出版

- Framework
  - `AutoLoad`:
    - 增加：`WRITEJSON()`
    - 修复：`WRITEFILE()`写入不存在的文件时发生错误
  - `GamemManager`:
    - 增加：`Package`管理功能，通过包组织和拓展游戏内容
  - `AudioManager`:
    - 增加：`SFX`播放功能
    - 增加：一些音效
  - `GUIModel`:
    - 修改：UI音效的绑定

## 2023.9.5

> 奥斯丁魔法指南，助您比肩迪尔勒斯族的大魔法师。
> 
> ——公会广告栏

- Framework
  - `AutoLoad`:
    - 增加：CSV文件读取功能
    - 预备：多语言翻译功能前期准备【施工中】
    - 重大更新：`Package`加载/管理逻辑完善（与之相关的方法几乎全部重写了……）
    - 修复：`Package`索引查找失败问题
  - `AudioManager`:
    - 修复：BGM播放失败问题
    - 修复：更新场景时BGM无法切换问题
    - 修复：音频文件获取失败问题
  - `Global`:
    - 修复：节点载入失败问题
    - 计划：读取设置时原先设置信息被覆盖问题【目标方法: `addSetting()`】
    - 增加：保存/加载设置功能
  - `Setting`:
    - 计划：更新设置读取和写入逻辑【因为`Package加载/管理功能`更新，`Global.Setting`等等索引表结构发生重大改变，需要重新适配】
  - `Enlightenment/PackageAutoLoad`:
    - 更新：包载入时的引导流程
    - 修复：因为`PackageConfig`中`start`组件自启动项中`TOP`和`GUIManager`启动顺序错误造成无限递归的错误（`start`数组的顺序也很重要！）