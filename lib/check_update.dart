// 检查应用更新的类

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

class CheckAppUpdate {
    // 声明当前版本号
    static String cur_version = "1.0.2";
    // 检查程序更新的函数
    static Future <bool> isAppHaveUpate () async {
        return true;
    }
}
