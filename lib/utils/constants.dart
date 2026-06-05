class AppConstants {
  static const String appName = 'UPS Service Manager';
  static const String defaultCenterId = 'default_center';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String centersCollection = 'centers';
  static const String ordersCollection = 'orders';
  static const String customersCollection = 'customers';
  static const String partsCollection = 'parts';
  static const String techniciansCollection = 'technicians';
  static const String appointmentsCollection = 'appointments';
  
  // Subcollections
  static const String notesSubcollection = 'notes';
  static const String communicationsSubcollection = 'communications';
  static const String photosSubcollection = 'photos';
  static const String partsUsedSubcollection = 'partsUsed';

  // Hive Boxes
  static const String settingsBox = 'settingsBox';
  static const String partsCacheBox = 'partsCacheBox';
  static const String pendingOperationsBox = 'pendingOperationsBox';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleTechnician = 'technician';
  static const String roleViewer = 'viewer';

  // Order Statuses
  static const String statusPending = 'Pending';
  static const String statusPendingPickup = 'Pending Pickup';
  static const String statusPickedUp = 'Picked Up';
  static const String statusDiagnosed = 'Diagnosed';
  static const String statusInRepair = 'In Progress';
  static const String statusWaitingForParts = 'Waiting for Parts';
  static const String statusReadyForDelivery = 'Ready for Delivery';
  static const String statusOutForDelivery = 'Out for Delivery';
  static const String statusCompleted = 'Completed';
  static const String statusDelivered = 'Delivered';
  static const String statusCancelled = 'Cancelled';
}
