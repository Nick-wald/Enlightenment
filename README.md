# 欢迎

> 就在我人生之旅的中途，
> 
> 我在一座昏暗的森林之中醒悟过来，
>
> 因为我在里面迷失了正确的道路。
>
> ——但丁《神曲·地狱篇》

你好，这里是基于Godot引擎研发的 **启明（Enlightenment）** RPG游戏引擎的源码库。引擎基于面向对象，以节点/组件为基本单位进行开发。为了更快地衔接游戏引擎开发，建议您先阅览下面的简介。

# 代码架构速览

## 文件夹

### res://

- AutoLoad 》 系统组件
- scenes 》 游戏场景
- sources 》 资源文件

### user://

- DLC 》 DLC附加包
- mod 》 mod模组包
- logs 》日志

## 系统组件

- AutoLoad 》 游戏入口，单例模式实现，文件层交互
- Global 》 全局参数，全局方法
- AudioManager 》 音频服务组件（BGM/SFX/BGS……）
- EntityManager 》 实体服务组件（实体构造器，实体对象池……）
- EntityModel（依赖EntityManager） 》 实体模型（实体原型，容器类实体，开关类实体，门实体……）
- CharacterManager 》 角色服务组件（角色构造器，随机角色生成器，角色对象池……）
- CharacterModel（依赖CharacterManager，继承EntityModel/EntityCharacter） 》 角色模型
- ItemManager 》 物品服务组件（高级物品功能）
- ItemModel（依赖于ItemManager）》物品模型（对EntityModel的拓展）
- GameManager 》 游戏服务组件（游戏内部功能函数集，游戏功能调度）
- EnvManager 》 全局环境服务组件（地图载入/生成，地形计算，游戏时间……）
- GUIManager 》 GUI服务组件（绘制GUI）
- GUIModel（依赖GUIManager） 》 GUI模型（设置界面，DLC管理界面，对话框……）
- TOP 》 顶部GUI层（DEBUG开关提示，报错/警告消息……）

## 游戏场景

- Beginning 》 游戏进入首页
- Transition 》 游戏加载过渡界面