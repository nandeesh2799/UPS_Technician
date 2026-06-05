import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ups_service_manager/app.dart';
import 'package:ups_service_manager/providers/auth_provider.dart';
import 'package:ups_service_manager/providers/settings_provider.dart';
import 'package:ups_service_manager/providers/order_provider.dart';
import 'package:ups_service_manager/providers/customer_provider.dart';
import 'package:ups_service_manager/providers/technician_provider.dart';
import 'package:ups_service_manager/providers/parts_provider.dart';
import 'package:ups_service_manager/providers/notification_provider.dart';
import 'package:ups_service_manager/providers/connectivity_provider.dart';
import 'package:ups_service_manager/providers/appointment_provider.dart';
import 'package:ups_service_manager/screens/splash/splash_screen.dart';
import 'package:ups_service_manager/screens/main_screen.dart';
import 'package:ups_service_manager/screens/auth/login_screen.dart';
import 'package:ups_service_manager/models/company_settings_model.dart';
import 'package:ups_service_manager/utils/constants.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockSettingsProvider extends Mock implements SettingsProvider {}
class MockOrderProvider extends Mock implements OrderProvider {}
class MockCustomerProvider extends Mock implements CustomerProvider {}
class MockTechnicianProvider extends Mock implements TechnicianProvider {}
class MockPartsProvider extends Mock implements PartsProvider {}
class MockNotificationProvider extends Mock implements NotificationProvider {}
class MockConnectivityProvider extends Mock implements ConnectivityProvider {}
class MockAppointmentProvider extends Mock implements AppointmentProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockSettingsProvider mockSettingsProvider;
  late MockOrderProvider mockOrderProvider;
  late MockCustomerProvider mockCustomerProvider;
  late MockTechnicianProvider mockTechnicianProvider;
  late MockPartsProvider mockPartsProvider;
  late MockNotificationProvider mockNotificationProvider;
  late MockConnectivityProvider mockConnectivityProvider;
  late MockAppointmentProvider mockAppointmentProvider;

  setUpAll(() async {
    // Initialize Hive for tests
    Hive.init('test_hive_path');
    if (!Hive.isBoxOpen(AppConstants.pendingOperationsBox)) {
      await Hive.openBox(AppConstants.pendingOperationsBox);
    }
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSettingsProvider = MockSettingsProvider();
    mockOrderProvider = MockOrderProvider();
    mockCustomerProvider = MockCustomerProvider();
    mockTechnicianProvider = MockTechnicianProvider();
    mockPartsProvider = MockPartsProvider();
    mockNotificationProvider = MockNotificationProvider();
    mockConnectivityProvider = MockConnectivityProvider();
    mockAppointmentProvider = MockAppointmentProvider();

    // Default mock behaviors
    when(() => mockSettingsProvider.isDarkMode).thenReturn(false);
    when(() => mockSettingsProvider.settings).thenReturn(CompanySettingsModel.defaultSettings());
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    
    when(() => mockOrderProvider.orders).thenReturn([]);
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.pendingOrders).thenReturn([]);
    when(() => mockOrderProvider.inProgressOrders).thenReturn([]);
    when(() => mockOrderProvider.completedOrders).thenReturn([]);
    when(() => mockOrderProvider.expiringWarranties).thenReturn([]);
    when(() => mockOrderProvider.totalRevenue).thenReturn(0.0);
    when(() => mockOrderProvider.totalDues).thenReturn(0.0);
    when(() => mockOrderProvider.serviceTypeDistribution).thenReturn({});
    when(() => mockOrderProvider.orderStatusDistribution).thenReturn({});
    when(() => mockOrderProvider.revenueByDay).thenReturn({});
    
    when(() => mockCustomerProvider.customers).thenReturn([]);
    when(() => mockCustomerProvider.isLoading).thenReturn(false);
    
    when(() => mockPartsProvider.parts).thenReturn([]);
    when(() => mockPartsProvider.isLoading).thenReturn(false);
    when(() => mockPartsProvider.lowStockParts).thenReturn([]);
    
    when(() => mockTechnicianProvider.technicians).thenReturn([]);
    when(() => mockTechnicianProvider.isLoading).thenReturn(false);
    
    when(() => mockNotificationProvider.notifications).thenReturn([]);
    when(() => mockNotificationProvider.unreadCount).thenReturn(0);
    
    when(() => mockConnectivityProvider.isOffline).thenReturn(false);

    when(() => mockAppointmentProvider.appointments).thenReturn([]);
    when(() => mockAppointmentProvider.isLoading).thenReturn(false);
    when(() => mockAppointmentProvider.todayAppointments).thenReturn([]);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityProvider>.value(value: mockConnectivityProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: mockSettingsProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: mockNotificationProvider),
        ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
        ChangeNotifierProvider<CustomerProvider>.value(value: mockCustomerProvider),
        ChangeNotifierProvider<PartsProvider>.value(value: mockPartsProvider),
        ChangeNotifierProvider<TechnicianProvider>.value(value: mockTechnicianProvider),
        ChangeNotifierProvider<AppointmentProvider>.value(value: mockAppointmentProvider),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('App launches and shows SplashScreen', (WidgetTester tester) async {
    when(() => mockAuthProvider.isLoading).thenReturn(true);
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Navigation to LoginScreen if not authenticated', (WidgetTester tester) async {
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    
    await tester.pumpWidget(createWidgetUnderTest());
    // Splash duration is 2 seconds
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Navigation to MainScreen if authenticated', (WidgetTester tester) async {
    when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
    
    await tester.pumpWidget(createWidgetUnderTest());
    // Splash duration is 2 seconds
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    expect(find.byType(MainScreen), findsOneWidget);
  });
}
