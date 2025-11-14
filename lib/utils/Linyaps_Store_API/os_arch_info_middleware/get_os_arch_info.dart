// 中间抽象类用于返回操作系统当前架构

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:io';

class getOSArchInfo {

  // 用于返回按照"uname -m"标准命令输出的架构信息
  Future <String> getUnameArch () async {
    ProcessResult arch_result;
    arch_result = await Process.run('uname', ['-m']);
    // 更新操作系统架构信息
    String os_arch = arch_result.stdout.toString().trim();
    // 返回架构信息
    return os_arch;
  }

  // 用于返回按照玲珑商店架构要求的架构信息
  Future <String> getLinyapsStoreApiArch () async {
    ProcessResult arch_result;
    arch_result = await Process.run('uname', ['-m']);
    // 更新操作系统架构信息
    String os_arch = arch_result.stdout.toString().trim();
    String repo_arch = "";
    if (os_arch == 'aarch64') repo_arch = 'arm64';
    else repo_arch = os_arch;
    // 返回架构信息
    return repo_arch;
  }
    
}
