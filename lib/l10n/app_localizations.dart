import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Astrix Assist'**
  String get appTitle;

  /// Title for saved servers list
  ///
  /// In en, this message translates to:
  /// **'Saved Servers'**
  String get savedServers;

  /// Button to add a new server
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get addServer;

  /// Message when no servers are saved
  ///
  /// In en, this message translates to:
  /// **'No servers saved'**
  String get noServers;

  /// Instruction to add first server
  ///
  /// In en, this message translates to:
  /// **'Add a server to get started'**
  String get addServerToStart;

  /// Label for server name field
  ///
  /// In en, this message translates to:
  /// **'Server Name'**
  String get serverName;

  /// Label for IP address field
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// Label for port field
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// Label for username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Title for add server dialog
  ///
  /// In en, this message translates to:
  /// **'Add New Server'**
  String get addNewServer;

  /// Title for edit server dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Server'**
  String get editServer;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete server button text
  ///
  /// In en, this message translates to:
  /// **'Delete Server'**
  String get deleteServer;

  /// Confirmation message for deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteConfirm;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Active status text
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Mock mode button text
  ///
  /// In en, this message translates to:
  /// **'Test Mode (Mock Data)'**
  String get mockMode;

  /// Mock mode description
  ///
  /// In en, this message translates to:
  /// **'Login without Asterisk server'**
  String get mockModeDesc;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// Navigation item for dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation item for extensions
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get navExtensions;

  /// Navigation item for calls
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get navCalls;

  /// Navigation item for queues
  ///
  /// In en, this message translates to:
  /// **'Queues'**
  String get navQueues;

  /// Navigation item for reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Quick tip shown on dashboard
  ///
  /// In en, this message translates to:
  /// **'Click on cards to view detailed information and manage your PBX system'**
  String get dashboardQuickTip;

  /// System resources section title
  ///
  /// In en, this message translates to:
  /// **'System Resources'**
  String get systemResources;

  /// Extensions page title
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get extensions;

  /// Active calls section title
  ///
  /// In en, this message translates to:
  /// **'Active Calls'**
  String get activeCalls;

  /// Queues page title
  ///
  /// In en, this message translates to:
  /// **'Queues'**
  String get queues;

  /// Waiting status text
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// Available status text
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Call text
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Online status text
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline status text
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Connection status: connected
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectionConnected;

  /// Connection status: connecting
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connectionConnecting;

  /// Connection status: error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get connectionError;

  /// Connection status: disconnected
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get connectionDisconnected;

  /// Server details dialog title
  ///
  /// In en, this message translates to:
  /// **'Server Info'**
  String get serverInfoTitle;

  /// Label for server status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get serverLabelStatus;

  /// Label for server address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get serverLabelAddress;

  /// Label for server port
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get serverLabelPort;

  /// Label for server username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get serverLabelUsername;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Search bar hint for extensions
  ///
  /// In en, this message translates to:
  /// **'Search by extension or IP'**
  String get searchByExtensionOrIp;

  /// Recent calls section title
  ///
  /// In en, this message translates to:
  /// **'Recent Calls'**
  String get recentCalls;

  /// Call history section title
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get callHistory;

  /// Message when no active calls
  ///
  /// In en, this message translates to:
  /// **'No active calls'**
  String get noActiveCalls;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// CDR page title
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get cdrTitle;

  /// Record count label
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get recordCount;

  /// Records text
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// Export CSV button text
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// Answered call status
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No answer call status
  ///
  /// In en, this message translates to:
  /// **'No Answer'**
  String get noAnswer;

  /// Busy call status
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Failed call status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Message when no records found
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecords;

  /// Error message for loading data
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get loadingError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Filter dialog title
  ///
  /// In en, this message translates to:
  /// **'Filter Calls'**
  String get filterCalls;

  /// Date range label
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// From date label
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// To date label
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// Source number label
  ///
  /// In en, this message translates to:
  /// **'Source Number'**
  String get sourceNumber;

  /// Destination number label
  ///
  /// In en, this message translates to:
  /// **'Destination Number'**
  String get destinationNumber;

  /// Call status label
  ///
  /// In en, this message translates to:
  /// **'Call Status'**
  String get callStatus;

  /// All option text
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Apply filter button text
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// Saved status text
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Save error text
  ///
  /// In en, this message translates to:
  /// **'Save Error'**
  String get saveError;

  /// File saved success message
  ///
  /// In en, this message translates to:
  /// **'File saved successfully'**
  String get fileSaved;

  /// Path label
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// File save error message
  ///
  /// In en, this message translates to:
  /// **'Error saving file'**
  String get fileSaveError;

  /// Saving status text
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Filter text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Name required validation message
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// IP required validation message
  ///
  /// In en, this message translates to:
  /// **'IP address is required'**
  String get ipRequired;

  /// Port required validation message
  ///
  /// In en, this message translates to:
  /// **'Port is required'**
  String get portRequired;

  /// Overall stats title
  ///
  /// In en, this message translates to:
  /// **'Overall Stats'**
  String get overallStats;

  /// Last updated label
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get lastUpdated;

  /// Average wait label
  ///
  /// In en, this message translates to:
  /// **'Avg Wait'**
  String get averageWait;

  /// Seconds unit text
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Auto refresh label
  ///
  /// In en, this message translates to:
  /// **'Auto Refresh'**
  String get autoRefresh;

  /// Interval label
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Retry text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading status text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Refresh text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Settings text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme text
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme text
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme text
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// Persian language option
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get persianLanguage;

  /// English language subtitle
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishSubtitle;

  /// Persian language subtitle
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persianSubtitle;

  /// Background service enabled message
  ///
  /// In en, this message translates to:
  /// **'Background service enabled'**
  String get backgroundServiceEnabled;

  /// Background service disabled message
  ///
  /// In en, this message translates to:
  /// **'Background service disabled'**
  String get backgroundServiceDisabled;

  /// Server section title
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// Current server label
  ///
  /// In en, this message translates to:
  /// **'Current Server'**
  String get currentServer;

  /// No server connected message
  ///
  /// In en, this message translates to:
  /// **'No server connected'**
  String get noServerConnected;

  /// Disconnect button text
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Return to server selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Return to server selection'**
  String get returnToServerSelection;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Local notifications label
  ///
  /// In en, this message translates to:
  /// **'Local Notifications'**
  String get localNotifications;

  /// Receive notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for system events'**
  String get receiveNotificationsForEvents;

  /// Background service label
  ///
  /// In en, this message translates to:
  /// **'Background Service'**
  String get backgroundService;

  /// Check server status subtitle
  ///
  /// In en, this message translates to:
  /// **'Check server status in background'**
  String get checkServerStatusInBackground;

  /// Information label
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Queues checked information
  ///
  /// In en, this message translates to:
  /// **'Queues are checked every 5 minutes'**
  String get queuesCheckedEvery5Minutes;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Asterisk/Issabel management subtitle
  ///
  /// In en, this message translates to:
  /// **'Asterisk/Issabel Management'**
  String get asteriskIssabelManagement;

  /// Select server dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Server'**
  String get selectServer;

  /// No servers saved message
  ///
  /// In en, this message translates to:
  /// **'No servers saved'**
  String get noServersSaved;

  /// About dialog description
  ///
  /// In en, this message translates to:
  /// **'Manage Asterisk and Issabel servers via AMI'**
  String get manageAsteriskIssabelViaAMI;

  /// Features label
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// Extensions management feature
  ///
  /// In en, this message translates to:
  /// **'• Extensions Management'**
  String get extensionsManagement;

  /// Active calls monitoring feature
  ///
  /// In en, this message translates to:
  /// **'• Active Calls Monitoring'**
  String get activeCallsMonitoring;

  /// Queue management feature
  ///
  /// In en, this message translates to:
  /// **'• Queue Management'**
  String get queueManagement;

  /// Originate calls feature
  ///
  /// In en, this message translates to:
  /// **'• Originate Calls'**
  String get originateCalls;

  /// Current language display for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguageEnglish;

  /// Current language display for Persian
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get currentLanguagePersian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
