import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/customer_model.dart';
import '../models/part_model.dart';
import '../models/technician_model.dart';
import '../models/payment_model.dart';
import '../models/communication_log_model.dart';
import '../models/company_settings_model.dart';
import '../models/pending_operation_model.dart';
import '../models/appointment_model.dart';
import '../models/center_model.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../utils/global_keys.dart';
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  String _centerId = AppConstants.defaultCenterId;

  void setCenterId(String id) {
    _centerId = id;
  }

  // --- Helper for Offline Writes ---
  Future<void> _performWrite({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    required String type,
    required Future<void> Function() firestoreOp,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      // If not authenticated, we still save to Hive for later sync
      final op = PendingOperationModel(
        id: const Uuid().v4(),
        collection: collection,
        documentId: docId,
        data: data,
        operationType: type,
        timestamp: DateTime.now(),
      );
      await HiveService.addPendingOperation(op);
      GlobalKeys.showSnackbar("Saved locally (Unauthorized). Will sync after login.");
      return;
    }

    try {
      await firestoreOp();
    } catch (e) {
      final op = PendingOperationModel(
        id: const Uuid().v4(),
        collection: collection,
        documentId: docId,
        data: data,
        operationType: type,
        timestamp: DateTime.now(),
      );
      await HiveService.addPendingOperation(op);
      GlobalKeys.showSnackbar("Saved locally. Will sync when online.");
    }
  }

  // --- Orders ---
  Stream<List<OrderModel>> getOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.ordersCollection).orderBy('createdAt', descending: true)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<QuerySnapshot> getOrdersPage({int limit = 20, DocumentSnapshot? startAfter}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    Query query = _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.ordersCollection).orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    return query.get();
  }

  Future<void> addOrder(OrderModel order) async {
    await _performWrite(
      collection: AppConstants.ordersCollection,
      docId: order.id,
      data: order.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.ordersCollection).doc(order.id).set(order.toMap());
      },
    );
  }

  Future<void> updateOrder(OrderModel order) async {
    await _performWrite(
      collection: AppConstants.ordersCollection,
      docId: order.id,
      data: order.toMap(),
      type: 'update',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.ordersCollection).doc(order.id).update(order.toMap());
      },
    );
  }

  Future<void> deleteOrder(String id) async {
    await _performWrite(
      collection: AppConstants.ordersCollection,
      docId: id,
      data: {},
      type: 'delete',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.ordersCollection).doc(id).delete();
      },
    );
  }

  // --- Customers ---
  Stream<List<CustomerModel>> getCustomers() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.customersCollection).orderBy('name')
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => CustomerModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<QuerySnapshot> getCustomersPage({int limit = 20, DocumentSnapshot? startAfter}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    Query query = _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.customersCollection).orderBy('name').limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    return query.get();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _performWrite(
      collection: AppConstants.customersCollection,
      docId: customer.id,
      data: customer.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.customersCollection).doc(customer.id).set(customer.toMap());
      },
    );
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _performWrite(
      collection: AppConstants.customersCollection,
      docId: customer.id,
      data: customer.toMap(),
      type: 'update',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.customersCollection).doc(customer.id).update(customer.toMap());
      },
    );
  }

  Future<void> deleteCustomer(String id) async {
    await _performWrite(
      collection: AppConstants.customersCollection,
      docId: id,
      data: {},
      type: 'delete',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.customersCollection).doc(id).delete();
      },
    );
  }

  // --- Parts ---
  Stream<List<PartModel>> getParts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.partsCollection).orderBy('name')
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => PartModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addPart(PartModel part) async {
    await _performWrite(
      collection: AppConstants.partsCollection,
      docId: part.id,
      data: part.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.partsCollection).doc(part.id).set(part.toMap());
      },
    );
  }

  Future<void> updatePart(PartModel part) async {
    await _performWrite(
      collection: AppConstants.partsCollection,
      docId: part.id,
      data: part.toMap(),
      type: 'update',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.partsCollection).doc(part.id).update(part.toMap());
      },
    );
  }

  Future<void> deletePart(String id) async {
    await _performWrite(
      collection: AppConstants.partsCollection,
      docId: id,
      data: {},
      type: 'delete',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.partsCollection).doc(id).delete();
      },
    );
  }

  // --- Technicians ---
  Stream<List<TechnicianModel>> getTechnicians() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.techniciansCollection)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => TechnicianModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTechnician(TechnicianModel technician) async {
    await _performWrite(
      collection: AppConstants.techniciansCollection,
      docId: technician.id,
      data: technician.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.techniciansCollection).doc(technician.id).set(technician.toMap());
      },
    );
  }

  Future<void> updateTechnician(TechnicianModel technician) async {
    await _performWrite(
      collection: AppConstants.techniciansCollection,
      docId: technician.id,
      data: technician.toMap(),
      type: 'update',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.techniciansCollection).doc(technician.id).update(technician.toMap());
      },
    );
  }

  Future<void> deleteTechnician(String id) async {
    await _performWrite(
      collection: AppConstants.techniciansCollection,
      docId: id,
      data: {},
      type: 'delete',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.techniciansCollection).doc(id).delete();
      },
    );
  }

  Future<void> updateUserRole(String email, String role) async {
    try {
      final userQuery = await _db.collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email).get();
      
      for (var doc in userQuery.docs) {
        await doc.reference.update({'role': role});
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  // --- Centers (Global Management) ---
  Stream<List<CenterModel>> getCenters() {
    return _db.collection(AppConstants.centersCollection)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => CenterModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addCenter(CenterModel center) async {
    await _db.collection(AppConstants.centersCollection).doc(center.id).set(center.toMap());
  }

  Future<void> updateCenter(CenterModel center) async {
    await _db.collection(AppConstants.centersCollection).doc(center.id).update(center.toMap());
  }

  // --- Appointments ---
  Stream<List<AppointmentModel>> getAppointments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.appointmentsCollection).orderBy('appointmentDate')
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    await _performWrite(
      collection: AppConstants.appointmentsCollection,
      docId: appointment.id,
      data: appointment.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.appointmentsCollection).doc(appointment.id).set(appointment.toMap());
      },
    );
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _performWrite(
      collection: AppConstants.appointmentsCollection,
      docId: appointment.id,
      data: appointment.toMap(),
      type: 'update',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.appointmentsCollection).doc(appointment.id).update(appointment.toMap());
      },
    );
  }

  Future<void> deleteAppointment(String id) async {
    await _performWrite(
      collection: AppConstants.appointmentsCollection,
      docId: id,
      data: {},
      type: 'delete',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.appointmentsCollection).doc(id).delete();
      },
    );
  }
  
  // --- Payments ---
  Stream<List<PaymentModel>> getPayments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection('payments').orderBy('date', descending: true)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => PaymentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _performWrite(
      collection: 'payments',
      docId: payment.id,
      data: payment.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection('payments').doc(payment.id).set(payment.toMap());
      },
    );
  }

  // --- Settings ---
  Future<CompanySettingsModel> getSettings() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _db.collection(AppConstants.centersCollection).doc(_centerId).get();
    return CompanySettingsModel.fromMap(doc.data());
  }

  Future<void> updateSettings(CompanySettingsModel settings) async {
    await _performWrite(
      collection: AppConstants.centersCollection,
      docId: _centerId,
      data: settings.toMap(),
      type: 'update',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId).set(settings.toMap(), SetOptions(merge: true));
      },
    );
  }

  // --- Communication Logs ---
  Future<void> addCommunicationLog(CommunicationLogModel log) async {
    await _performWrite(
      collection: AppConstants.communicationsSubcollection,
      docId: log.id,
      data: log.toMap(),
      type: 'create',
      firestoreOp: () {
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        return _db.collection(AppConstants.centersCollection).doc(_centerId)
            .collection(AppConstants.ordersCollection).doc(log.orderId)
            .collection(AppConstants.communicationsSubcollection).doc(log.id).set(log.toMap());
      },
    );
  }

  // --- FCM Token ---
  Future<void> updateFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Update in global users collection
    await _db.collection(AppConstants.usersCollection).doc(user.uid).set({
      'fcmToken': token,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Also update in technicians collection if they belong to the current center
    final techQuery = await _db.collection(AppConstants.centersCollection).doc(_centerId)
        .collection(AppConstants.techniciansCollection).where('uid', isEqualTo: user.uid).get();
    
    for (var doc in techQuery.docs) {
      await doc.reference.update({'fcmToken': token});
    }
  }
}
