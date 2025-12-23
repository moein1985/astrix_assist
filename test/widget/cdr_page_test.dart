import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:astrix_assist/l10n/app_localizations.dart';
import 'package:astrix_assist/presentation/pages/cdr_page.dart';
import 'package:astrix_assist/presentation/blocs/cdr_bloc.dart';
import 'package:astrix_assist/domain/entities/cdr_record.dart';

// Mock classes
class MockCdrBloc extends Mock implements CdrBloc {
  final StreamController<CdrState> _controller = StreamController<CdrState>.broadcast();
  CdrState _currentState = CdrInitial();

  MockCdrBloc() {
    _controller.add(_currentState);
  }

  @override
  CdrState get state => _currentState;

  @override
  Stream<CdrState> get stream => _controller.stream;

  @override
  Future<void> close() async {
    await _controller.close();
  }

  void setState(CdrState newState) {
    _currentState = newState;
    _controller.add(newState);
  }
}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get cdrTitle => 'CDR Records';

  @override
  String get filter => 'Filter';

  @override
  String get noRecords => 'No records found';

  @override
  String get loadingError => 'Loading Error';

  @override
  String get retryButton => 'Retry';

  @override
  String get recordCount => 'Record count';

  @override
  String get records => 'records';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get saved => 'Saved';

  @override
  String get saveError => 'Save Error';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get authenticationError => 'Authentication Error';

  @override
  String get recordingNotFound => 'Recording not found';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get saving => 'Saving...';

  @override
  String get fileSaved => 'File saved';

  @override
  String get path => 'Path';

  @override
  String get fileSaveError => 'File save error';

  @override
  String get filterCalls => 'Filter Calls';

  @override
  String get dateRange => 'Date Range';

  @override
  String get fromDate => 'From Date';

  @override
  String get toDate => 'To Date';

  @override
  String get sourceNumber => 'Source Number';

  @override
  String get destinationNumber => 'Destination Number';

  @override
  String get callStatus => 'Call Status';

  @override
  String get all => 'All';

  @override
  String get answered => 'Answered';

  @override
  String get noAnswer => 'No Answer';

  @override
  String get busy => 'Busy';

  @override
  String get failed => 'Failed';

  @override
  String get cancel => 'Cancel';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get duration => 'Duration';

  @override
  String get status => 'Status';

  @override
  String get server => 'Server';

  @override
  String get connectionDisconnected => 'Disconnected';
}

class _MockLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations mockLocalizations;

  const _MockLocalizationsDelegate(this.mockLocalizations);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => mockLocalizations;

  @override
  bool shouldReload(_MockLocalizationsDelegate old) => false;
}

void main() {
  late MockCdrBloc mockCdrBloc;
  late MockAppLocalizations mockL10n;

  setUpAll(() {
    registerFallbackValue(LoadCdrRecords());
  });

  setUp(() {
    mockCdrBloc = MockCdrBloc();
    mockL10n = MockAppLocalizations();
  });

  tearDown(() async {
    reset(mockCdrBloc);
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: [
        _MockLocalizationsDelegate(mockL10n),
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<CdrBloc>.value(
        value: mockCdrBloc,
        child: const CdrPage(),
      ),
    );
  }

  group('CdrPage Widget Tests', () {
    testWidgets('should render app bar with correct title and actions', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      mockCdrBloc.setState(CdrInitial());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('CDR Records'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should show no records message when loaded with empty list', (tester) async {
      mockCdrBloc.setState(CdrLoaded([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No records found'), findsOneWidget);
    });

    testWidgets('should display CDR records when loaded', (tester) async {
      final testRecords = [
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"John Doe" <1234>',
          src: '1234',
          dst: '5678',
          dcontext: 'from-internal',
          channel: 'SIP/1234-0001',
          dstChannel: 'SIP/5678-0002',
          lastApp: 'Dial',
          lastData: 'SIP/5678,30,Tt',
          duration: '45',
          billsec: '42',
          disposition: 'ANSWERED',
          amaflags: '3',
          uniqueid: '1734945600.1',
          userfield: '',
        ),
      ];

      mockCdrBloc.setState(CdrLoaded(testRecords));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Record count: 1 records'), findsOneWidget);
      expect(find.text('1234 ➜ 5678'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Answered icon
    });

    testWidgets('should show loading state', (tester) async {
      mockCdrBloc.setState(CdrLoading());

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow the widget to rebuild with new state

      // Check if CircularProgressIndicator is found without pumpAndSettle
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state with retry button', (tester) async {
      mockCdrBloc.setState(CdrError('Test error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Loading Error'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should trigger LoadCdrRecords event on refresh', (tester) async {
      mockCdrBloc.setState(CdrInitial());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Reset mock interactions to ignore the initial load
      reset(mockCdrBloc);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      verify(() => mockCdrBloc.add(any(that: isA<LoadCdrRecords>()))).called(1);
    });

    testWidgets('should show export button when records are loaded', (tester) async {
      final testRecords = [
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"John Doe" <1234>',
          src: '1234',
          dst: '5678',
          dcontext: 'from-internal',
          channel: 'SIP/1234-0001',
          dstChannel: 'SIP/5678-0002',
          lastApp: 'Dial',
          lastData: 'SIP/5678,30,Tt',
          duration: '45',
          billsec: '42',
          disposition: 'ANSWERED',
          amaflags: '3',
          uniqueid: '1734945600.1',
          userfield: '',
        ),
      ];

      mockCdrBloc.setState(CdrLoaded(testRecords));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Export CSV'), findsOneWidget);
    });

    testWidgets('should trigger ExportCdrRecords event on export button tap', (tester) async {
      final testRecords = [
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"John Doe" <1234>',
          src: '1234',
          dst: '5678',
          dcontext: 'from-internal',
          channel: 'SIP/1234-0001',
          dstChannel: 'SIP/5678-0002',
          lastApp: 'Dial',
          lastData: 'SIP/5678,30,Tt',
          duration: '45',
          billsec: '42',
          disposition: 'ANSWERED',
          amaflags: '3',
          uniqueid: '1734945600.1',
          userfield: '',
        ),
      ];

      mockCdrBloc.setState(CdrLoaded(testRecords));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export CSV'));
      await tester.pump();

      verify(() => mockCdrBloc.add(any(that: isA<ExportCdrRecords>()))).called(1);
    });

    testWidgets('should show different icons for different dispositions', (tester) async {
      final testRecords = [
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"John Doe" <1234>',
          src: '1234',
          dst: '5678',
          dcontext: 'from-internal',
          channel: 'SIP/1234-0001',
          dstChannel: 'SIP/5678-0002',
          lastApp: 'Dial',
          lastData: 'SIP/5678,30,Tt',
          duration: '45',
          billsec: '42',
          disposition: 'ANSWERED',
          amaflags: '3',
          uniqueid: '1734945600.1',
          userfield: '',
        ),
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"Jane Doe" <1111>',
          src: '1111',
          dst: '2222',
          dcontext: 'from-internal',
          channel: 'SIP/1111-0001',
          dstChannel: 'SIP/2222-0002',
          lastApp: 'Dial',
          lastData: 'SIP/2222,30,Tt',
          duration: '0',
          billsec: '0',
          disposition: 'NO ANSWER',
          amaflags: '3',
          uniqueid: '1734945600.2',
          userfield: '',
        ),
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"Bob Smith" <3333>',
          src: '3333',
          dst: '4444',
          dcontext: 'from-internal',
          channel: 'SIP/3333-0001',
          dstChannel: 'SIP/4444-0002',
          lastApp: 'Dial',
          lastData: 'SIP/4444,30,Tt',
          duration: '0',
          billsec: '0',
          disposition: 'BUSY',
          amaflags: '3',
          uniqueid: '1734945600.3',
          userfield: '',
        ),
        CdrRecord(
          callDate: '2025-12-23 10:00:00',
          clid: '"Alice Brown" <5555>',
          src: '5555',
          dst: '6666',
          dcontext: 'from-internal',
          channel: 'SIP/5555-0001',
          dstChannel: 'SIP/6666-0002',
          lastApp: 'Dial',
          lastData: 'SIP/6666,30,Tt',
          duration: '0',
          billsec: '0',
          disposition: 'FAILED',
          amaflags: '3',
          uniqueid: '1734945600.4',
          userfield: '',
        ),
      ];

      mockCdrBloc.setState(CdrLoaded(testRecords));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget); // ANSWERED
      expect(find.byIcon(Icons.phone_missed), findsOneWidget); // NO ANSWER
      expect(find.byIcon(Icons.phone_locked), findsOneWidget); // BUSY
      expect(find.byIcon(Icons.error), findsOneWidget); // FAILED
    });
  });
}