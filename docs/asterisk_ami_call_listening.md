# Asterisk AMI Call Listening Capabilities

## Overview
Asterisk Manager Interface (AMI) provides capabilities for listening to both recorded calls and live conversations through dialplan applications invoked via AMI actions.

## 🚀 Quick Start Guide

### Prerequisites Checklist
```bash
# 1. Verify AMI is enabled
grep "enabled = yes" /etc/asterisk/manager.conf

# 2. Check required modules
asterisk -rx "module show like chanspy"
asterisk -rx "module show like playback"

# 3. Test AMI connection
telnet your-server 5038
# Expected: "Asterisk Call Manager/X.XX"

# 4. Verify dialplan contexts exist
asterisk -rx "dialplan show spy-context"
asterisk -rx "dialplan show playback-context"
```

### Minimal Working Example

**1. Configure manager.conf:**
```ini
[astrix_test]
secret = test123
permit = 0.0.0.0/0.0.0.0
read = system,call,all
write = system,call,originate
```

**2. Add to extensions.conf:**
```ini
[spy-context]
exten => s,1,ChanSpy(${SPYTARGET},bq)
 same => n,Hangup()
```

**3. Reload Asterisk:**
```bash
asterisk -rx "manager reload"
asterisk -rx "dialplan reload"
```

**4. Test via telnet:**
```bash
telnet localhost 5038
# Then type:
Action: Login
Username: astrix_test
Secret: test123

Action: Originate
Channel: SIP/1000
Context: spy-context
Exten: s
Priority: 1
Variable: SPYTARGET=SIP/1001
Async: true
```

## 🎧 Listening to Recorded Calls (Playback)

### Primary Mechanism: Playback Dialplan Application
- **Purpose**: Play back recorded call files
- **Prerequisites**: Recordings must be created first (MixMonitor/Record)
- **AMI Integration**: Use `Originate` action to call dialplan context executing Playback

### Playback Application Details
- **Syntax**: `Playback(filename&[filename2[&...]], [options])`
- **Supported Formats**: WAV, GSM, and URLs
- **Options**:
  - `skip`: Don't play if channel not answered
  - `noanswer`: Playback without answering
  - `say`: Use say.conf for playback
  - `mix`: Mix filename with say.conf

### ControlPlayback AMI Action
- **Purpose**: Control ongoing playback operations
- **Controls**:
  - `stop`: Stop playback
  - `forward`: Skip forward (default 3000ms)
  - `reverse`: Skip backward (default 3000ms)
  - `pause`: Pause/unpause
  - `restart`: Restart playback

## 👂 Listening to Live Conversations (Eavesdropping)

### Primary Mechanism: ChanSpy Dialplan Application
- **Purpose**: Listen to audio from active Asterisk channels
- **Modes**:
  - **Spy**: Listen-only mode
  - **Whisper**: Talk to one party without being heard by the other
  - **Barge**: Join both parties in conversation

### ChanSpy Application Details
- **Syntax**: `ChanSpy([chanprefix, [options]])`
- **Key Options**:
  - `b`: Spy on bridged calls only
  - `B`: Barge in on both channels
  - `w`: Enable whisper mode
  - `W`: Private whisper mode
  - `r(basename)`: Record the spying session
  - `v(value)`: Set volume (-4 to 4)

### DTMF Controls (Real-time)
- `#`: Cycle volume levels
- `*`: Stop and find next channel
- `4`: Spy mode (with `d` option)
- `5`: Whisper mode (with `d` option)
- `6`: Barge mode (with `d` option)

## 🔧 Implementation via AMI

### AMI Connection & Login
```ami
Action: Login
Username: astrix_proxy
Secret: your-password
```

**Response:**
```ami
Response: Success
Message: Authentication accepted
```

### Originate Action for Live Listen (ChanSpy)
```ami
Action: Originate
Channel: SIP/supervisor_extension
Application: ChanSpy
Data: SIP/target_extension,bq
Async: true
CallerID: "Supervisor" <1000>
Timeout: 30000
Variable: SPYTARGET=SIP/target_extension
ActionID: listen-job-123
```

**Options Explained:**
- `b`: Only spy on bridged channels (active calls)
- `q`: Quiet mode (no beeps)
- `Async: true`: Non-blocking operation
- `ActionID`: Track this specific request

**Response:**
```ami
Response: Success
ActionID: listen-job-123
Message: Originate successfully queued
```

### Originate Action for Playback
```ami
Action: Originate
Channel: SIP/supervisor_extension
Context: playback-context
Exten: s
Priority: 1
Async: true
Timeout: 30000
Variable: RECFILE=/var/spool/asterisk/monitor/20251220-1234.wav
ActionID: playback-job-456
```

**Alternative (Direct Application):**
```ami
Action: Originate
Channel: SIP/supervisor_extension
Application: Playback
Data: /var/spool/asterisk/monitor/20251220-1234
Async: true
ActionID: playback-job-456
```

### ControlPlayback Action
```ami
Action: ControlPlayback
Channel: SIP/supervisor_extension-00000001
Control: pause
```

**Control Commands:**
- `stop`: Stop playback completely
- `forward`: Skip forward 3 seconds
- `reverse`: Skip backward 3 seconds
- `pause`: Pause playback
- `restart`: Restart from beginning

### Hangup Action (Stop Listen/Playback)
```ami
Action: Hangup
Channel: SIP/supervisor_extension-00000001
Cause: 16
```

**Cause Codes:**
- `16`: Normal clearing
- `21`: Call rejected

### Alternative: ExtenSpy
- Similar to ChanSpy but extension-based instead of channel-based
- Syntax: `ExtenSpy([exten@context, [options]])`
- Useful when you don't know exact channel name

```ami
Action: Originate
Channel: SIP/supervisor_extension
Application: ExtenSpy
Data: 101@default,bq
Async: true
```

## 📡 AMI Events to Monitor

### ChanSpy Events

**ChanSpyStart Event:**
```ami
Event: ChanSpyStart
Privilege: call,all
SpyerChannel: SIP/supervisor-00000001
SpyeeChannel: SIP/target-00000002
```
- Fired when spy session begins
- Use to update UI status to "listening"

**ChanSpyStop Event:**
```ami
Event: ChanSpyStop
Privilege: call,all
SpyerChannel: SIP/supervisor-00000001
SpyeeChannel: SIP/target-00000002
```
- Fired when spy session ends
- Update UI status to "stopped"

### Playback Events

**PlaybackStart Event:**
```ami
Event: PlaybackStart
Privilege: call,all
Channel: SIP/supervisor-00000001
Playback: /var/spool/asterisk/monitor/20251220-1234
Language: en
```

**PlaybackFinish Event:**
```ami
Event: PlaybackFinish
Privilege: call,all
Channel: SIP/supervisor-00000001
Playback: /var/spool/asterisk/monitor/20251220-1234
```

### Originate Events

**OriginateResponse Event:**
```ami
Event: OriginateResponse
Privilege: call,all
ActionID: listen-job-123
Response: Success
Channel: SIP/supervisor-00000001
Context: spy-context
Exten: s
Reason: 4
Uniqueid: 1734789123.456
CallerIDNum: 1000
CallerIDName: Supervisor
```

**Reasons:**
- `0`: No such extension or number
- `1`: No answer
- `4`: Answered
- `5`: Busy
- `8`: Congestion or not available

### Hangup Event
```ami
Event: Hangup
Privilege: call,all
Channel: SIP/supervisor-00000001
Uniqueid: 1734789123.456
CallerIDNum: 1000
Cause: 16
Cause-txt: Normal Clearing
```

## 🔒 Security Considerations

### Authentication & Permissions
- AMI requires authentication via `manager.conf`
- Users need specific permissions (system, call, all)
- Use read/write filters to restrict access

### Privacy & Legal
- Eavesdropping raises privacy concerns
- Ensure legal compliance (consent requirements)
- Playback may involve data protection regulations

### Access Controls
- Channel variables like `SPYGROUP` for group-based access
- Limit AMI user permissions to necessary actions only

## 📋 Implementation Requirements

### Dialplan Configuration
- Configure `extensions.conf` with contexts for Playback/ChanSpy
- Example context:
```
[playback-context]
exten => _X.,1,Playback(${ARG1})
exten => _X.,n,Hangup()
```

**Complete Example Dialplan:**
```ini
; Spy context - for live listening
[spy-context]
exten => s,1,NoOp(Starting ChanSpy on ${SPYTARGET})
 same => n,Set(TIMEOUT(absolute)=3600)  ; 1 hour max
 same => n,ChanSpy(${SPYTARGET},bq)
 same => n,Hangup()

; Alternative with user input
exten => spy,1,NoOp(Interactive spy)
 same => n,Read(TARGET,enter-target-extension,4)
 same => n,ChanSpy(SIP/${TARGET},bq)
 same => n,Hangup()

; Playback context - for recorded files
[playback-context]
exten => s,1,NoOp(Playing recording: ${RECFILE})
 same => n,Answer()
 same => n,Wait(1)
 same => n,Playback(${RECFILE})
 same => n,Hangup()

; With error handling
exten => s,1,NoOp(Playing: ${RECFILE})
 same => n,Answer()
 same => n,GotoIf($[${STAT(e,${RECFILE}.wav)}]?play:notfound)
 same => n(play),Playback(${RECFILE})
 same => n,Hangup()
 same => n(notfound),Playback(file-not-found)
 same => n,Hangup()

; Whisper mode (talk to agent only)
[whisper-context]
exten => s,1,NoOp(Whisper to ${SPYTARGET})
 same => n,ChanSpy(${SPYTARGET},w)
 same => n,Hangup()

; Barge mode (join conversation)
[barge-context]
exten => s,1,NoOp(Barge into ${SPYTARGET})
 same => n,ChanSpy(${SPYTARGET},B)
 same => n,Hangup()
```

### AMI Connection Setup
- TCP connection to Asterisk AMI port (default 5038)
- Authentication with Login action
- Event handling for ChanSpyStart/ChanSpyStop

**manager.conf Configuration:**
```ini
[general]
enabled = yes
port = 5038
bindaddr = 0.0.0.0

[astrix_proxy]
secret = SecurePassword123!
deny = 0.0.0.0/0.0.0.0
permit = 192.168.1.0/255.255.255.0  ; Your app server IP range
read = system,call,log,verbose,agent,command,reporting,cdr,dialplan
write = system,call,originate,reporting
writetimeout = 5000
```

**Security Best Practices:**
- Use strong passwords (min 16 chars)
- Restrict IPs with permit/deny
- Minimal permissions (don't use `read = all, write = all`)
- Enable TLS if possible (tlsenable = yes)
- Regular password rotation

**Connection Flow:**
1. Open TCP socket to `asterisk-server:5038`
2. Send Login action
3. Wait for Response: Success
4. Start listening for events
5. Send actions (Originate, etc.)
6. Handle events asynchronously
7. Send Logoff when done

### Dependencies
- `app_chanspy` module loaded
- `app_playback` module loaded
- Storage access for recordings

**Verify Modules:**
```bash
asterisk -rx "module show like chanspy"
asterisk -rx "module show like playback"
```

**Load Modules (if needed):**
```bash
asterisk -rx "module load app_chanspy.so"
asterisk -rx "module load app_playback.so"
```

**Recording Storage:**
- Default: `/var/spool/asterisk/monitor/`
- Set via `MONITOR_DIR` in globals or channel variable
- Permissions: `asterisk:asterisk` user ownership
- Format: WAV, GSM, MP3 (with appropriate codecs)

**File Naming Convention:**
```
# MixMonitor default
/var/spool/asterisk/monitor/YYYYMMDD-HHMMSS-uniqueid.wav

# With custom naming
/var/spool/asterisk/monitor/client-123/call-456.wav
```

## 🎯 Key Benefits for Astrix Assist

1. **Call Monitoring**: Real-time eavesdropping on active calls
2. **Quality Assurance**: Recording playback for training/review
3. **Supervisory Control**: Whisper/barge capabilities for supervisors
4. **Recording Management**: Access to historical call recordings

## 🐛 Troubleshooting Common Issues

### Issue: ChanSpy Not Working

**Symptoms:**
- Originate succeeds but no audio heard
- ChanSpyStart event not firing

**Solutions:**
1. Verify `app_chanspy` loaded: `asterisk -rx "module show like chanspy"`
2. Check channel format: `ChanSpy(SIP/101)` not `ChanSpy(101)`
3. Ensure target is in active call (use `b` option)
4. Check codec compatibility
5. Verify supervisor endpoint is answered

**Debug Commands:**
```bash
asterisk -rx "core show channels"  # Find active channels
asterisk -rx "core show channel SIP/101-00000001"  # Channel details
```

### Issue: Playback File Not Found

**Symptoms:**
- OriginateResponse success but playback doesn't start
- "File not found" in Asterisk logs

**Solutions:**
1. Verify file path: `/var/spool/asterisk/monitor/file.wav`
2. Don't include extension in Playback: `Playback(file)` not `Playback(file.wav)`
3. Check file permissions: `ls -l /var/spool/asterisk/monitor/`
4. Ensure asterisk user can read: `sudo -u asterisk cat /path/to/file.wav`
5. Test absolute vs relative paths

**Debug:**
```bash
asterisk -rx "core show file formats"  # Supported formats
file /var/spool/asterisk/monitor/file.wav  # Verify file type
```

### Issue: AMI Connection Refused

**Symptoms:**
- Cannot connect to port 5038
- Connection timeout

**Solutions:**
1. Check AMI enabled: `grep "enabled = yes" /etc/asterisk/manager.conf`
2. Verify port: `grep "port =" /etc/asterisk/manager.conf`
3. Firewall: `sudo ufw allow 5038/tcp`
4. Bind address: `bindaddr = 0.0.0.0` not `127.0.0.1`
5. Restart Asterisk: `sudo systemctl restart asterisk`

**Test Connection:**
```bash
telnet asterisk-server 5038
# Should see: "Asterisk Call Manager/X.XX"
```

### Issue: Permission Denied

**Symptoms:**
- AMI login fails
- Actions return "Permission denied"

**Solutions:**
1. Check username/password in manager.conf
2. Verify IP in permit list
3. Ensure user has correct read/write permissions
4. Check `read = call,originate` includes needed perms

### Issue: No Audio in Recording

**Symptoms:**
- Recording file exists but is silent
- Playback works but no sound

**Solutions:**
1. Verify MixMonitor was active during call
2. Check recording direction: `MixMonitor(file.wav,b)` for both sides
3. Codec compatibility
4. Ensure call was answered before recording started
5. Test with: `play /var/spool/asterisk/monitor/file.wav`

### Issue: Spy Session Ends Immediately

**Symptoms:**
- ChanSpyStart followed immediately by ChanSpyStop
- "No channel matching" message

**Solutions:**
1. Target channel must be in active call
2. Use `b` option: `ChanSpy(SIP/101,b)`
3. Check channel name format: `SIP/101` not just `101`
4. Verify extension is actually on a call: `core show channels`

## 📊 Performance Considerations

### Concurrent Spy Sessions
- Each spy session consumes resources
- Recommend max 10-20 concurrent sessions per server
- Monitor with: `asterisk -rx "core show channels"`

### Recording Storage
- WAV files: ~10MB per hour (depends on codec)
- Plan for growth: estimate calls/day × avg duration × 10MB
- Implement rotation/cleanup policy
- Consider compression (MP3, Opus)

### Network Bandwidth
- RTP audio: 64-128 Kbps per session
- AMI events: minimal (<1 Kbps)
- Recording transfer: depends on file size

## 📚 Reference Links
- [Asterisk AMI Documentation](https://docs.asterisk.org/Asterisk_20_Documentation/API_Documentation/AMI_Actions/)
- [ChanSpy Application](https://docs.asterisk.org/Asterisk_20_Documentation/API_Documentation/Dialplan_Applications/ChanSpy/)
- [Playback Application](https://docs.asterisk.org/Asterisk_20_Documentation/API_Documentation/Dialplan_Applications/Playback/)

---
*Documented: December 21, 2025*
*Source: Official Asterisk Documentation*