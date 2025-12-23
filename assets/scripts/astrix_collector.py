#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Astrix Assist - Asterisk Data Collector
========================================
Collects CDR, recordings, config, and system info in JSON format
Compatible with: Python 2.6+/3.4+, Asterisk 1.8-22, Issabel, Elastix, FreePBX

Usage:
    python astrix_collector.py info
    python astrix_collector.py cdr --days 7 --limit 1000
    python astrix_collector.py recordings --days 7
    python astrix_collector.py setup-ami --user USERNAME --pass PASSWORD
    python astrix_collector.py check-ami

Author: Astrix Assist Team
Version: 1.0.0
"""

from __future__ import print_function
import sys
import os
import json
import csv
import glob
import re
import subprocess
import random
import string
from datetime import datetime, timedelta

VERSION = "1.0.0"

# Python 2/3 compatibility
if sys.version_info[0] >= 3:
    unicode = str

# ==============================================================================
# PATH DETECTION
# ==============================================================================

class PathDetector:
    """Detect Asterisk paths for different distributions"""
    
    CDR_PATHS = [
        '/var/log/asterisk/cdr-csv/Master.csv',
        '/var/log/asterisk/cdr/Master.csv',
        '/var/log/asterisk/cdr.csv',
    ]
    
    RECORDING_PATHS = [
        '/var/spool/asterisk/monitor/',
        '/var/spool/asterisk/recording/',
        '/var/spool/asterisk/voicemail/',
    ]
    
    CONFIG_PATHS = [
        '/etc/asterisk/',
        '/usr/local/etc/asterisk/',
    ]
    
    @staticmethod
    def find_cdr_file():
        """Find CDR CSV file"""
        for path in PathDetector.CDR_PATHS:
            if os.path.exists(path):
                return path
        return None
    
    @staticmethod
    def find_recording_path():
        """Find recordings directory"""
        for path in PathDetector.RECORDING_PATHS:
            if os.path.exists(path):
                return path
        return None
    
    @staticmethod
    def find_config_path():
        """Find Asterisk config directory"""
        for path in PathDetector.CONFIG_PATHS:
            if os.path.exists(path):
                return path
        return None

# ==============================================================================
# DATE PARSER
# ==============================================================================

class DateParser:
    """Parse dates in multiple formats"""
    
    FORMATS = [
        '%Y-%m-%d %H:%M:%S',
        '%Y/%m/%d %H:%M:%S',
        '%d-%m-%Y %H:%M:%S',
        '%m/%d/%Y %H:%M:%S',
    ]
    
    @staticmethod
    def parse(date_str):
        """Parse date string to datetime object"""
        if not date_str:
            return None
        
        for fmt in DateParser.FORMATS:
            try:
                return datetime.strptime(date_str, fmt)
            except ValueError:
                continue
        return None

# ==============================================================================
# CDR COLLECTOR
# ==============================================================================

class CdrCollector:
    """Collect CDR records from CSV files"""
    
    def __init__(self):
        self.cdr_file = PathDetector.find_cdr_file()
    
    def get_cdrs(self, days=7, limit=1000):
        """Get CDR records - Returns all records up to limit, filtering by date is done on client side"""
        if not self.cdr_file:
            return {
                'success': False,
                'error': 'CDR file not found',
                'error_code': 'FILE_NOT_FOUND',
                'hint': 'Check Asterisk installation and CDR configuration'
            }
        
        try:
            # Note: We don't filter by date here to avoid timezone issues
            # The client (Flutter app) will filter by date using proper timezone handling
            records = []
            total_lines = 0
            
            with open(self.cdr_file, 'r') as f:
                # Handle BOM
                content = f.read()
                if content.startswith(u'\ufeff'):
                    content = content[1:]
                
                lines = content.strip().split('\n')
                total_lines = len(lines)
                
                # Read from END of file (newest records first)
                # Reverse the lines so we process newest first
                lines = reversed(lines)
                
                for line in lines:
                    if not line.strip():
                        continue
                    
                    # Parse CSV with proper quote handling
                    row = self._parse_csv_line(line)
                    
                    if len(row) < 14:
                        continue
                    
                    try:
                        # No date filtering here - client will handle it with proper timezone
                        record = {
                            'accountcode': row[0] if len(row) > 0 else '',
                            'src': row[1] if len(row) > 1 else '',
                            'dst': row[2] if len(row) > 2 else '',
                            'dcontext': row[3] if len(row) > 3 else '',
                            'clid': row[4] if len(row) > 4 else '',
                            'channel': row[5] if len(row) > 5 else '',
                            'dstchannel': row[6] if len(row) > 6 else '',
                            'lastapp': row[7] if len(row) > 7 else '',
                            'lastdata': row[8] if len(row) > 8 else '',
                            'calldate': row[9] if len(row) > 9 else '',
                            'answerdate': row[10] if len(row) > 10 else '',
                            'enddate': row[11] if len(row) > 11 else '',
                            'duration': int(row[12]) if len(row) > 12 and row[12] else 0,
                            'billsec': int(row[13]) if len(row) > 13 and row[13] else 0,
                            'disposition': row[14] if len(row) > 14 else '',
                            'amaflags': row[15] if len(row) > 15 else '',
                            'uniqueid': row[16] if len(row) > 16 else '',
                            'userfield': row[17] if len(row) > 17 else '',
                        }
                        
                        records.append(record)
                        
                        if len(records) >= limit:
                            break
                    
                    except (ValueError, IndexError):
                        continue
            
            result = {
                'success': True,
                'count': len(records),
                'records': records,
                'debug_info': {
                    'cdr_file': self.cdr_file,
                    'total_lines': total_lines,
                    'records_returned': len(records),
                    'limit': limit,
                    'note': 'Date filtering disabled - client handles timezone-aware filtering'
                }
            }
            
            # Add hint if no records found
            if len(records) == 0:
                result['hint'] = 'No CDR records found in file. Possible reasons: 1) CDR file is empty, 2) No calls have been made, 3) CDR not configured in Asterisk'
            
            return result
        
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'error_code': 'READ_ERROR'
            }
    
    def _parse_csv_line(self, line):
        """Parse CSV line with proper quote handling"""
        fields = []
        current = []
        in_quotes = False
        
        for char in line:
            if char == '"':
                in_quotes = not in_quotes
            elif char == ',' and not in_quotes:
                fields.append(''.join(current))
                current = []
            else:
                current.append(char)
        
        fields.append(''.join(current))
        return fields

# ==============================================================================
# RECORDING COLLECTOR
# ==============================================================================

class RecordingCollector:
    """Collect recording file information"""
    
    def __init__(self):
        self.recording_path = PathDetector.find_recording_path()
    
    def get_recordings(self, days=7, date=None):
        """Get list of recordings"""
        if not self.recording_path:
            return {
                'success': False,
                'error': 'Recording path not found',
                'error_code': 'PATH_NOT_FOUND'
            }
        
        try:
            cutoff = datetime.now() - timedelta(days=days)
            recordings = []
            
            # Search for audio files
            extensions = ['*.wav', '*.mp3', '*.gsm']
            
            for ext in extensions:
                pattern = os.path.join(self.recording_path, '**', ext)
                
                # Python 2 doesn't have recursive glob, use os.walk
                for root, dirs, files in os.walk(self.recording_path):
                    for filename in files:
                        if filename.endswith(ext.replace('*', '')):
                            file_path = os.path.join(root, filename)
                            
                            try:
                                stat = os.stat(file_path)
                                mtime = datetime.fromtimestamp(stat.st_mtime)
                                
                                if mtime < cutoff:
                                    continue
                                
                                recordings.append({
                                    'path': file_path,
                                    'filename': filename,
                                    'size': stat.st_size,
                                    'modified': mtime.isoformat(),
                                })
                            except Exception:
                                continue
            
            return {
                'success': True,
                'count': len(recordings),
                'recordings': recordings
            }
        
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'error_code': 'READ_ERROR'
            }

# ==============================================================================
# SYSTEM INFO COLLECTOR
# ==============================================================================

class SystemInfoCollector:
    """Collect system and Asterisk information"""
    
    def get_info(self):
        """Get system information"""
        info = {}
        
        # Python version
        info['python_version'] = sys.version.split()[0]
        
        # Asterisk version
        try:
            result = subprocess.Popen(
                ['asterisk', '-rx', 'core show version'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            output, error = result.communicate()
            info['asterisk_version'] = output.decode('utf-8').strip() if output else 'unknown'
        except Exception:
            info['asterisk_version'] = 'unknown'
        
        # Paths
        info['cdr_path'] = PathDetector.find_cdr_file()
        info['recording_path'] = PathDetector.find_recording_path()
        info['config_path'] = PathDetector.find_config_path()
        
        # CDR enabled
        try:
            cdr_conf = os.path.join(info['config_path'] or '/etc/asterisk/', 'cdr.conf')
            if os.path.exists(cdr_conf):
                with open(cdr_conf, 'r') as f:
                    content = f.read().lower()
                    info['cdr_enabled'] = 'enabled = yes' in content or 'enable = yes' in content
            else:
                info['cdr_enabled'] = None
        except Exception:
            info['cdr_enabled'] = None
        
        # Script version
        info['script_version'] = VERSION
        
        return {
            'success': True,
            'data': info
        }

# ==============================================================================
# AMI MANAGER
# ==============================================================================

class AmiManager:
    """Manage AMI configuration"""
    
    def __init__(self):
        self.config_path = PathDetector.find_config_path()
        self.manager_conf = os.path.join(self.config_path or '/etc/asterisk/', 'manager.conf')
    
    def check_ami(self):
        """Check AMI status"""
        if not os.path.exists(self.manager_conf):
            return {
                'success': False,
                'error': 'manager.conf not found',
                'error_code': 'FILE_NOT_FOUND'
            }
        
        try:
            with open(self.manager_conf, 'r') as f:
                content = f.read()
            
            # Check if AMI is enabled
            enabled = False
            if re.search(r'^\s*enabled\s*=\s*yes', content, re.MULTILINE | re.IGNORECASE):
                enabled = True
            
            # Check if astrix_assist user exists
            user_exists = '[astrix_assist]' in content
            
            return {
                'success': True,
                'data': {
                    'enabled': enabled,
                    'user_exists': user_exists,
                    'config_path': self.manager_conf
                }
            }
        
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'error_code': 'READ_ERROR'
            }
    
    def setup_ami(self, username='astrix_assist', password=None):
        """Setup AMI (enable and create user)"""
        if not os.path.exists(self.manager_conf):
            return {
                'success': False,
                'error': 'manager.conf not found',
                'error_code': 'FILE_NOT_FOUND'
            }
        
        try:
            # Generate password if not provided
            if not password:
                password = self._generate_password()
            
            # Read current config
            with open(self.manager_conf, 'r') as f:
                content = f.read()
            
            # Enable AMI if not enabled
            if not re.search(r'^\s*enabled\s*=\s*yes', content, re.MULTILINE | re.IGNORECASE):
                # Find [general] section and enable
                content = re.sub(
                    r'(\[general\].*?)(enabled\s*=\s*no)',
                    r'\1enabled = yes',
                    content,
                    flags=re.DOTALL | re.IGNORECASE
                )
                
                # If [general] section doesn't exist, add it
                if '[general]' not in content.lower():
                    content = '[general]\nenabled = yes\n\n' + content
            
            # Add user if doesn't exist
            if '[{}]'.format(username) not in content:
                user_config = '''
[{username}]
secret = {password}
deny = 0.0.0.0/0.0.0.0
permit = 0.0.0.0/0.0.0.0
read = system,call,log,verbose,command,agent,user,config,dtmf,reporting,cdr,dialplan,originate
write = system,call,log,verbose,command,agent,user,config,dtmf,reporting,cdr,dialplan,originate
'''.format(username=username, password=password)
                
                content += user_config
            
            # Backup original file
            backup_path = self.manager_conf + '.backup'
            with open(backup_path, 'w') as f:
                with open(self.manager_conf, 'r') as orig:
                    f.write(orig.read())
            
            # Write new config
            with open(self.manager_conf, 'w') as f:
                f.write(content)
            
            # Reload AMI
            try:
                subprocess.call(['asterisk', '-rx', 'manager reload'])
            except Exception:
                pass
            
            return {
                'success': True,
                'data': {
                    'username': username,
                    'password': password,
                    'host': 'localhost',
                    'port': 5038
                }
            }
        
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'error_code': 'WRITE_ERROR'
            }
    
    def _generate_password(self, length=16):
        """Generate random password"""
        chars = string.ascii_letters + string.digits
        return ''.join(random.choice(chars) for _ in range(length))

# ==============================================================================
# CLI INTERFACE
# ==============================================================================

def output_json(data):
    """Output JSON with timestamp"""
    data['timestamp'] = datetime.now().isoformat()
    print(json.dumps(data, indent=2, ensure_ascii=False))

def main():
    """Main CLI interface"""
    if len(sys.argv) < 2:
        output_json({
            'success': False,
            'error': 'No command specified',
            'usage': 'python astrix_collector.py {info|cdr|recordings|setup-ami|check-ami}'
        })
        sys.exit(1)
    
    command = sys.argv[1]
    
    try:
        if command == 'info':
            collector = SystemInfoCollector()
            output_json(collector.get_info())
        
        elif command == 'cdr':
            days = 7
            limit = 1000
            
            # Parse arguments
            i = 2
            while i < len(sys.argv):
                if sys.argv[i] == '--days' and i + 1 < len(sys.argv):
                    days = int(sys.argv[i + 1])
                    i += 2
                elif sys.argv[i] == '--limit' and i + 1 < len(sys.argv):
                    limit = int(sys.argv[i + 1])
                    i += 2
                else:
                    i += 1
            
            collector = CdrCollector()
            output_json(collector.get_cdrs(days=days, limit=limit))
        
        elif command == 'recordings':
            days = 7
            
            # Parse arguments
            i = 2
            while i < len(sys.argv):
                if sys.argv[i] == '--days' and i + 1 < len(sys.argv):
                    days = int(sys.argv[i + 1])
                    i += 2
                else:
                    i += 1
            
            collector = RecordingCollector()
            output_json(collector.get_recordings(days=days))
        
        elif command == 'check-ami':
            manager = AmiManager()
            output_json(manager.check_ami())
        
        elif command == 'setup-ami':
            username = 'astrix_assist'
            password = None
            
            # Parse arguments
            i = 2
            while i < len(sys.argv):
                if sys.argv[i] == '--user' and i + 1 < len(sys.argv):
                    username = sys.argv[i + 1]
                    i += 2
                elif sys.argv[i] == '--pass' and i + 1 < len(sys.argv):
                    password = sys.argv[i + 1]
                    i += 2
                else:
                    i += 1
            
            manager = AmiManager()
            output_json(manager.setup_ami(username=username, password=password))
        
        else:
            output_json({
                'success': False,
                'error': 'Unknown command: {}'.format(command),
                'error_code': 'UNKNOWN_COMMAND'
            })
            sys.exit(1)
    
    except Exception as e:
        output_json({
            'success': False,
            'error': str(e),
            'error_code': 'INTERNAL_ERROR'
        })
        sys.exit(1)

if __name__ == '__main__':
    main()
