// 将玲珑包信息抽象为一个标准类

// ignore_for_file: non_constant_identifier_names

class LinyapsPackageInfo {

  // 声明玲珑应用必须有的信息
  String id;   // 应用包名
  String name;  // 应用名称
  String version;   // 应用版本信息
  String description;    // 应用介绍信息
  String arch;  // 应用架构

  // 如果应用不是最新的,存储一下它当前版本,这用于检查应用更新用
  String? current_old_version;

  String? Icon;    // 应用图标
  int? IconUpdated;     // 应用图标是否更新
  String? repoName;    // 应用所在源名称
  String? channel;   // 应用所在渠道
  String? kind;    // 应用所在分类
  String? module;    // 所用的玲珑模块
  String? size;    // 安装包文件大小
  String? base;   // 应用base依赖信息
  String? runtime;     // 应用Runtime依赖信息(注意:可以为没有(null))
  String? schema_version;    // 应用的玲珑schema_version信息

  // 声明应用安装信息
  String? install_time;   // 应用安装时间
  String? permissions;    // 应用所需权限
  String? extensions;    // 该应用所需扩展
  // String? oldVersion;   // 应用的老版本
  String? newVersion;  // 应用的新版本

  // 声明应用后台接口信息
  String? zhName;    // 应用在后台的名称
  String? categoryName;    // 应用分类类名
  String? createTime;   // 上架时间
  int? installCount;    // 安装次数
  String? uninstallCount;   // 卸载次数
  String? uabUrl;   // 应用离线分发包(.uab)下载地址
  String? user;     // 用户名(未知用途)
  String? devName;    // 维护者名称
  LinyapsPackageInfo ({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.arch,
    this.Icon,
    this.IconUpdated,
    this.repoName,
    this.current_old_version,
    this.channel,
    this.kind,
    this.module,
    this.size,
    this.base,
    this.runtime,
    this.schema_version,
    this.install_time,
    this.permissions,
    this.extensions,
    // this.oldVersion,
    this.newVersion,
    this.zhName,
    this.categoryName,
    this.createTime,
    this.installCount,
    this.uninstallCount,
    this.uabUrl,
    this.user,
    this.devName,
  });
}
