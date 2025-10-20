// 管理下载中的应用类

import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';


class DownloadQueueManager {
  static final DownloadQueueManager _instance = DownloadQueueManager._internal();
  factory DownloadQueueManager() => _instance;
  DownloadQueueManager._internal();

  final List<LinyapsPackageInfo> _queue = [];
  bool _isProcessing = false;

  // 往下载列表中增加任务
  void addTask (LinyapsPackageInfo task) 
    {
      _queue.add(task);
      if (!_isProcessing) {
        _processQueue();
      }
    }

  // 在下载列表中删除任务
  void deleteTask (LinyapsPackageInfo task) 
    {
      _queue.remove(task);
      if (!_isProcessing) {
        _processQueue();
      }
    }

  Future <void> _processQueue() async 
    {
      // 设置正在处理为真
      _isProcessing = true;
      while (_queue.isNotEmpty) 
        {
          final task = _queue.removeAt(0);
          await _executeTask(task);
        }
      _isProcessing = false;
      return;
    }

  Future <void> _executeTask(LinyapsPackageInfo task) async 
    {
      await LinyapsCliHelper().install_app(
        task.id, 
        task.version, 
        task.current_old_version,
      );
      return;
    }
}
