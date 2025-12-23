# Generation Specifications

## Complete Technical Specifications for Multi-Generation Support

**Document Version**: 1.0  
**Date**: December 23, 2025  
**Purpose**: Define exact specifications for each generation

---

## Generation 1: Legacy (CentOS 6 + Asterisk 11)

### System Information
- **OS**: CentOS 6.x (Final)
- **Kernel**: 2.6.x
- **Asterisk**: 11.x LTS (End of Life: October 2019)
- **Python**: 2.6.x
- **Timeline**: 2012-2015

### Asterisk Configuration
- **AMI Version**: 1.1
- **CDR Backend**: csv
- **Channel Drivers**: chan_sip (primary), chan_dahdi
- **Codecs**: alaw, ulaw, gsm, g729
- **Recording**: WAV only

### CDR Specification
- **File Path**: `/var/log/asterisk/cdr-csv/Master.csv`
- **Columns**: 14
- **Date Format**: `YYYY-MM-DD HH:MM:SS` (no timezone)
- **Unique ID**: None
- **Recording Path**: `/var/spool/asterisk/monitor/`

### SSH Specification
- **Port**: 22
- **Auth Methods**: password
- **Key Support**: None
- **Python Path**: `/usr/bin/python2.6`

### Limitations
- No CoreShowChannels command
- No PJSIP support
- No JSON responses
- No CEL
- Basic CDR fields only

---

## Generation 2: Transition (CentOS 7 + Asterisk 13)

### System Information
- **OS**: CentOS 7.x
- **Kernel**: 3.10.x
- **Asterisk**: 13.x LTS (End of Life: October 2021)
- **Python**: 2.7.x / 3.4.x
- **Timeline**: 2015-2018

### Asterisk Configuration
- **AMI Version**: 2.0
- **CDR Backend**: csv (enhanced)
- **Channel Drivers**: chan_sip, chan_pjsip (basic), chan_dahdi
- **Codecs**: alaw, ulaw, gsm, g729, opus (basic)
- **Recording**: WAV, GSM

### CDR Specification
- **File Path**: `/var/log/asterisk/cdr-csv/Master.csv`
- **Columns**: 17
- **Date Format**: `YYYY-MM-DD HH:MM:SS`
- **Unique ID**: `timestamp.sequence`
- **Recording Path**: `/var/spool/asterisk/monitor/YYYY/MM/DD/`

### SSH Specification
- **Port**: 22
- **Auth Methods**: password, publickey (RSA, DSA)
- **Key Support**: Basic
- **Python Path**: `/usr/bin/python2.7` or `/usr/bin/python3.4`

### New Features
- CoreShowChannels command
- Basic PJSIP support
- Enhanced CDR with uniqueid
- Date-based recording subdirectories

---

## Generation 3: Modern (Rocky Linux 8 + Asterisk 16)

### System Information
- **OS**: Rocky Linux 8.x (RHEL 8 compatible)
- **Kernel**: 4.18.x
- **Asterisk**: 16.x LTS (End of Life: October 2023)
- **Python**: 3.6.x+
- **Timeline**: 2018-2022

### Asterisk Configuration
- **AMI Version**: 2.5
- **CDR Backend**: csv + JSON support
- **Channel Drivers**: chan_pjsip (primary), chan_sip, chan_dahdi
- **Codecs**: alaw, ulaw, gsm, g729, opus, speex
- **Recording**: WAV, GSM, MP3

### CDR Specification
- **File Path**: `/var/log/asterisk/cdr-csv/Master.csv`
- **Columns**: 19
- **Date Format**: `YYYY-MM-DD HH:MM:SS` (timezone aware)
- **Unique ID**: `timestamp.sequence`
- **Linked ID**: Basic support
- **Recording Path**: `/var/spool/asterisk/monitor/YYYY/MM/DD/`

### SSH Specification
- **Port**: 22
- **Auth Methods**: publickey preferred, password fallback
- **Key Types**: RSA, ECDSA, Ed25519
- **Python Path**: `/usr/bin/python3.6`

### New Features
- Full PJSIP support
- JSON AMI responses
- Enhanced CDR with enddate, sequence
- Timezone support
- Advanced recording formats

---

## Generation 4: Latest (Rocky Linux 9 + Asterisk 18/20)

### System Information
- **OS**: Rocky Linux 9.x (RHEL 9 compatible)
- **Kernel**: 5.14.x
- **Asterisk**: 18.x/20.x LTS
- **Python**: 3.9.x+
- **Timeline**: 2022-Present

### Asterisk Configuration
- **AMI Version**: 3.0+
- **CDR Backend**: csv, JSON, CEL
- **Channel Drivers**: chan_pjsip (primary), chan_dahdi
- **Codecs**: alaw, ulaw, gsm, g729, opus, speex, silk
- **Recording**: WAV, Opus, MP3, OGG

### CDR Specification
- **File Path**: `/var/log/asterisk/cdr-csv/Master.csv`
- **Columns**: 20+
- **Date Format**: `YYYY-MM-DD HH:MM:SS±TZ`
- **Unique ID**: `timestamp.sequence`
- **Linked ID**: Full support
- **CEL**: Enabled by default
- **Recording Path**: `/var/spool/asterisk/monitor/YYYY/MM/DD/`

### SSH Specification
- **Port**: 22
- **Auth Methods**: publickey + 2FA
- **Key Types**: Ed25519 preferred, RSA, ECDSA
- **Security**: Enhanced SSH config
- **Python Path**: `/usr/bin/python3.9`

### New Features
- Full CEL support
- Advanced PJSIP features
- Multi-format recordings
- Enhanced security
- Performance improvements

---

## Compatibility Matrix

| Feature | Gen 1 | Gen 2 | Gen 3 | Gen 4 |
|---------|-------|-------|-------|-------|
| AMI Version | 1.1 | 2.0 | 2.5 | 3.0+ |
| CDR Columns | 14 | 17 | 19 | 20+ |
| CoreShowChannels | ❌ | ✅ | ✅ | ✅ |
| PJSIP Support | ❌ | Basic | Full | Full |
| JSON Responses | ❌ | ❌ | ✅ | ✅ |
| CEL Support | ❌ | ❌ | ❌ | ✅ |
| Timezone CDR | ❌ | ❌ | ✅ | ✅ |
| SSH 2FA | ❌ | ❌ | ❌ | ✅ |
| Python Version | 2.6 | 2.7/3.4 | 3.6+ | 3.9+ |

---

## Implementation Requirements

### Code Structure
```
lib/core/generation/
├── generation_config.dart (interface)
├── generation_1_config.dart
├── generation_2_config.dart
├── generation_3_config.dart
└── generation_4_config.dart

lib/core/adapters/
├── ami_adapter.dart
├── ssh_adapter.dart
└── cdr_adapter.dart
```

### Testing Structure
```
test/fixtures/generation_1/
├── cdr_samples.json
├── ami_responses.json
└── ssh_outputs.json

test/fixtures/generation_2/
├── ...

tools/mock_servers/
├── mock_ssh_server.dart
└── mock_ami_server.dart
```

### Configuration Points
- Compile-time: `AppConfig.defaultGeneration`
- Runtime: `AppConfig.setGeneration()`
- Testing: Environment variables or test setup

---

## Migration Strategy

### From Current Codebase
1. Extract hardcoded values to generation configs
2. Add adapter layer for version-specific logic
3. Implement mock servers for testing
4. Add comprehensive test coverage

### Backward Compatibility
- Keep existing API stable
- Add new features behind feature flags
- Graceful degradation for missing features

---

## Success Criteria

### Functional
- [ ] All 4 generations fully supported
- [ ] Runtime switching works correctly
- [ ] Mock servers provide realistic responses
- [ ] All existing features work on all generations

### Quality
- [ ] Test coverage > 75%
- [ ] No breaking changes to existing API
- [ ] Documentation complete
- [ ] Performance acceptable

### Maintainability
- [ ] Code is extensible for future generations
- [ ] Clear separation of concerns
- [ ] Comprehensive error handling
- [ ] Logging and debugging support