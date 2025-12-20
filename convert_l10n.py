#!/usr/bin/env python3
import re
import sys

# Mapping from snake_case to camelCase
KEY_MAPPING = {
    'app_title': 'appTitle',
    'saved_servers': 'savedServers',
    'add_server': 'addServer',
    'no_servers': 'noServers',
    'add_server_to_start': 'addServerToStart',
    'server_name': 'serverName',
    'ip_address': 'ipAddress',
    'port': 'port',
    'username': 'username',
    'password': 'password',
    'add_new_server': 'addNewServer',
    'edit_server': 'editServer',
    'save': 'save',
    'cancel': 'cancel',
    'delete_server': 'deleteServer',
    'delete_confirm': 'deleteConfirm',
    'delete': 'delete',
    'edit': 'edit',
    'active': 'active',
    'mock_mode': 'mockMode',
    'mock_mode_desc': 'mockModeDesc',
    'logout': 'logout',
    'logout_confirm': 'logoutConfirm',
    'nav_dashboard': 'navDashboard',
    'nav_extensions': 'navExtensions',
    'nav_calls': 'navCalls',
    'nav_queues': 'navQueues',
    'nav_reports': 'navReports',
    'dashboard': 'dashboard',
    'extensions': 'extensions',
    'active_calls': 'activeCalls',
    'queues': 'queues',
    'waiting': 'waiting',
    'available': 'available',
    'call': 'call',
    'online': 'online',
    'offline': 'offline',
    'recent_calls': 'recentCalls',
    'no_active_calls': 'noActiveCalls',
    'duration': 'duration',
    'cdr_title': 'cdrTitle',
    'record_count': 'recordCount',
    'records': 'records',
    'export_csv': 'exportCsv',
    'answered': 'answered',
    'no_answer': 'noAnswer',
    'busy': 'busy',
    'failed': 'failed',
    'status': 'status',
    'no_records': 'noRecords',
    'loading_error': 'loadingError',
    'retry_button': 'retryButton',
    'filter_calls': 'filterCalls',
    'date_range': 'dateRange',
    'from_date': 'fromDate',
    'to_date': 'toDate',
    'source_number': 'sourceNumber',
    'destination_number': 'destinationNumber',
    'call_status': 'callStatus',
    'all': 'all',
    'apply_filter': 'applyFilter',
    'saved': 'saved',
    'save_error': 'saveError',
    'file_saved': 'fileSaved',
    'path': 'path',
    'file_save_error': 'fileSaveError',
    'saving': 'saving',
    'filter': 'filter',
    'field_required': 'fieldRequired',
    'name_required': 'nameRequired',
    'ip_required': 'ipRequired',
    'port_required': 'portRequired',
    'overall_stats': 'overallStats',
    'last_updated': 'lastUpdated',
    'average_wait': 'averageWait',
    'seconds': 'seconds',
    'view_all': 'viewAll',
    'auto_refresh': 'autoRefresh',
    'interval': 'interval',
    'retry': 'retry',
    'loading': 'loading',
    'error': 'error',
    'refresh': 'refresh',
    'settings': 'settings',
    'language': 'language',
    'theme': 'theme',
    'light': 'light',
    'dark': 'dark',
    'system': 'system',
}

def convert_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace AppLocalizations.of(context) with AppLocalizations.of(context)!
    content = re.sub(
        r'final l10n = AppLocalizations\.of\(context\);',
        r'final l10n = AppLocalizations.of(context)!;',
        content
    )
    
    # Replace l10n.t('key') with l10n!.camelCaseKey or l10n.camelCaseKey
    for snake_key, camel_key in KEY_MAPPING.items():
        content = re.sub(
            rf"l10n\.t\('{snake_key}'\)",
            f'l10n.{camel_key}',
            content
        )
        content = re.sub(
            rf'l10n\.t\("{snake_key}"\)',
            f'l10n.{camel_key}',
            content
        )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Converted: {file_path}")

if __name__ == '__main__':
    files = [
        'lib/presentation/pages/login_page.dart',
        'lib/presentation/pages/dashboard_page.dart',
        'lib/presentation/pages/settings_page.dart',
        'lib/presentation/pages/cdr_page.dart',
    ]
    
    for file in files:
        try:
            convert_file(file)
        except Exception as e:
            print(f"❌ Error converting {file}: {e}")
