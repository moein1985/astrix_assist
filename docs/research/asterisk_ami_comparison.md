# Asterisk AMI Command Comparison

## Research Summary

This document compares Asterisk Manager Interface (AMI) commands across different versions to understand compatibility requirements for multi-generation testing.

**Research Date**: December 23, 2025  
**Sources**: Official Asterisk Documentation

## Generation 1: Asterisk 11.x (Legacy)

### Available Commands
- **Login** - Authenticate with AMI
- **Logoff** - Disconnect from AMI
- **SIPpeers** - List SIP peers
- **SIPshowpeer** - Show detailed SIP peer information
- **QueueStatus** - Get queue status (basic)
- **Status** - Get channel status
- **Command** - Execute CLI command
- **CoreSettings** - Get core settings
- **CoreStatus** - Get core status

### NOT Available
- CoreShowChannels
- PJSIP commands
- JSON responses
- Advanced queue commands

### Response Format
```
Response: Success
Message: Authentication accepted

Event: PeerEntry
Channeltype: SIP
ObjectName: 1001
ChanObjectType: peer
IPaddress: 192.168.1.100
IPport: 5060
Dynamic: yes
Natsupport: no
ACL: no
Status: OK
```

## Generation 2: Asterisk 13.x (Transition)

### New Commands Added
- **CoreShowChannels** - List active channels
- **QueueSummary** - Enhanced queue information
- **QueueAdd** - Add interface to queue
- **QueueRemove** - Remove interface from queue
- **MeetmeList** - List conference participants

### Enhanced Commands
- QueueStatus now includes more details
- SIPpeers supports more options

### Response Format
Same as Generation 1, but with additional fields in some responses.

## Generation 3: Asterisk 16.x (Modern)

### New Commands Added
- **PJSIPShowEndpoints** - List PJSIP endpoints
- **PJSIPShowEndpoint** - Show PJSIP endpoint details
- **PJSIPShowContacts** - List PJSIP contacts
- **ARI commands** - Asterisk REST Interface integration
- **QueueLog** - Enhanced queue logging

### JSON Support
Some commands now support JSON output format.

## Generation 4: Asterisk 18.x/20.x (Latest)

### New Commands Added
- **PJSIPShowRegistrations** - List PJSIP registrations
- **PJSIPQualify** - Qualify PJSIP endpoints
- **CEL** - Channel Event Logging commands
- **Stasis** - Advanced application integration
- **Confbridge** - Enhanced conferencing

### Enhanced Features
- Full JSON support for all commands
- Advanced security features
- Improved error handling
- Better performance monitoring

## Breaking Changes Summary

### From Gen 1 to Gen 2
- Added CoreShowChannels (major improvement for active calls)
- Enhanced QueueStatus

### From Gen 2 to Gen 3
- Added PJSIP support
- JSON responses available
- Enhanced security

### From Gen 3 to Gen 4
- Full PJSIP integration
- CEL support
- Advanced features

## Compatibility Matrix

| Command | Gen 1 | Gen 2 | Gen 3 | Gen 4 |
|---------|-------|-------|-------|-------|
| Login | ✅ | ✅ | ✅ | ✅ |
| SIPpeers | ✅ | ✅ | ✅ | ✅ |
| CoreShowChannels | ❌ | ✅ | ✅ | ✅ |
| PJSIPShowEndpoints | ❌ | ❌ | ✅ | ✅ |
| CEL | ❌ | ❌ | ❌ | ✅ |

## Implementation Notes

### For Multi-Generation Support
1. **CoreShowChannels Fallback**: Use Status command for Gen 1
2. **PJSIP Detection**: Check if PJSIP commands are available
3. **Response Parsing**: Handle both text and JSON formats
4. **Error Handling**: Different error codes across versions

### Testing Strategy
- Test each generation with appropriate mock responses
- Verify command availability before execution
- Handle graceful degradation for missing features