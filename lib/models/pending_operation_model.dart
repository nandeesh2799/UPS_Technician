import 'package:hive/hive.dart';

part 'pending_operation_model.g.dart';

@HiveType(typeId: 0)
class PendingOperationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String collection;

  @HiveField(2)
  final String documentId;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final String operationType; // create / update / delete

  @HiveField(5)
  final DateTime timestamp;

  PendingOperationModel({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.operationType,
    required this.timestamp,
  });
}
