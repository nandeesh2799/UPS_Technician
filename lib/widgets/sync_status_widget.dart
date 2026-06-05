import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../models/pending_operation_model.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
      return const SizedBox.shrink();
    }
    
    return ValueListenableBuilder(
      valueListenable: Hive.box<PendingOperationModel>(AppConstants.pendingOperationsBox).listenable(),
      builder: (context, box, _) {
        final count = box.length;
        if (count == 0) {
          return const Tooltip(
            message: 'All synced',
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.cloud_done, color: Colors.green, size: 20),
            ),
          );
        }

        return Tooltip(
          message: '$count items pending sync',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$count pending',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
