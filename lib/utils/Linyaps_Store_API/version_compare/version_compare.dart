// 用于对比"1.1.5.3"这样的版本号的类

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

class VersionCompare {
  // 用于返回ver1是否大于ver2
  static bool isFirstGreaterThanSec (String ver1, String ver2) {
    List <String> parted_ver1 = ver1.split('.');
    List <String> parted_ver2 = ver2.split('.');
    int parted1 = 0,parted2 = 0;
    int i=0;   // 用于下放循环检查
    for (i=0;i<parted_ver1.length;i++) {
      parted1 = int.tryParse(parted_ver1[i])!;
      parted2 = int.tryParse(parted_ver2[i])!;
      // 发现同级有大的直接返回判断
      if (parted1>parted2) return true;
      if (parted2>parted1) return false;
    }
    // 发现版本号一样也返回假
    return false;
  }
}
