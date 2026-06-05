import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pending_operation_model.dart';
import '../utils/global_keys.dart';
import '../utils/constants.dart';

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isSyncing = false;
  bool _isInitialized = false;
  StreamSubscription? _connSub;

  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
        await Hive.openBox<PendingOperationModel>(AppConstants.pendingOperationsBox);
      }
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      debugPrint('SyncService init failed: $e');
    }

    _connSub?.cancel();
    _connSub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isOnline = results.contains(ConnectivityResult.mobile) || 
                      results.contains(ConnectivityResult.wifi) || 
                      results.contains(ConnectivityResult.ethernet);
      if (isOnline) {
        replay();
      }
    });
    Connectivity().checkConnectivity().then((results) {
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi) || 
          results.contains(ConnectivityResult.ethernet)) {
        replay();
      }
    });
  }

  void dispose() {
    _connSub?.cancel();
  }

  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.contains(ConnectivityResult.mobile) || 
             result.contains(ConnectivityResult.wifi) || 
             result.contains(ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  Future<void> replay() async {
    if (!_isInitialized) return;
    if (_isSyncing) return;
    if (!Hive.isBoxOpen(AppConstants.pendingOperationsBox)) return;
    
    final box = Hive.box<PendingOperationModel>(AppConstants.pendingOperationsBox);
    if (box.isEmpty) return;

    _isSyncing = true;
    
    final operations = box.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    debugPrint('SyncService: Replaying ${operations.length} operations');
    
    for (final op in operations) {
      if (!await _hasConnectivity()) break;
      
      bool success = false;
      int attempts = 0;
      
      while (!success && attempts < 3) {
        try {
          await _executeOperation(op);
          await box.delete(op.key);
          success = true;
          debugPrint('SyncService: Synced ${op.id}');
        } catch (e) {
          attempts++;
          debugPrint('SyncService: Attempt $attempts failed for ${op.id}: $e');
          if (attempts < 3) {
            await Future.delayed(
              Duration(seconds: attempts * 2), // backoff
            );
          }
        }
      }
      
      if (!success) {
        debugPrint('SyncService: Moving ${op.id} to failed operations');
        try {
          if (!Hive.isBoxOpen('failed_operations')) {
            await Hive.openBox('failed_operations');
          }
          if (Hive.isBoxOpen('failed_operations')) {
            final failedBox = Hive.box('failed_operations');
            await failedBox.put(op.id, {
              'collection': op.collection,
              'documentId': op.documentId,
              'data': op.data,
              'operationType': op.operationType,
              'timestamp': op.timestamp.toIso8601String(),
              'failedAt': DateTime.now().toIso8601String(),
              'reason': 'Max retries exceeded',
            });
            await box.delete(op.key);
          }
        } catch (e) {
          debugPrint('SyncService: Could not move to failed: $e');
        }
      }
    }

    _isSyncing = false;
    final remaining = box.length;
    if (remaining == 0) {
      GlobalKeys.showSnackbar("Offline sync complete.");
    }
  }

  Future<void> _executeOperation(PendingOperationModel op) async {
    const centerId = AppConstants.defaultCenterId;
    final baseDoc = _db.collection(AppConstants.centersCollection).doc(centerId);

    if (op.operationType == 'delete') {
      if (op.collection == AppConstants.communicationsSubcollection) {
         final orderId = op.data['orderId'];
         if (orderId != null) {
           await baseDoc.collection(AppConstants.ordersCollection).doc(orderId)
               .collection(AppConstants.communicationsSubcollection).doc(op.documentId).delete();
         }
      } else {
        await baseDoc.collection(op.collection).doc(op.documentId).delete();
      }
      return;
    }

    if (op.collection == AppConstants.centersCollection) {
      await baseDoc.set(op.data, SetOptions(merge: true));
    } else if (op.collection == AppConstants.communicationsSubcollection) {
      final orderId = op.data['orderId'];
      if (orderId == null) {
        throw Exception("Missing orderId for communication log sync");
      }
      await baseDoc.collection(AppConstants.ordersCollection).doc(orderId)
          .collection(AppConstants.communicationsSubcollection).doc(op.documentId).set(op.data, SetOptions(merge: true));
    } else {
      await baseDoc.collection(op.collection).doc(op.documentId).set(op.data, SetOptions(merge: true));
    }
  }
}
