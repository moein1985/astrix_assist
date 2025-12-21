# Asterisk AMI Call Listening Capabilities

## Overview
Asterisk Manager Interface (AMI) provides capabilities for listening to both recorded calls and live conversations through dialplan applications invoked via AMI actions.

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

### Originate Action (Core Method)
```ami
Action: Originate
Channel: Local/extension@context
Application: Playback
Data: recording.wav
```

### Alternative: ExtenSpy
- Similar to ChanSpy but extension-based instead of channel-based
- Syntax: `ExtenSpy([exten@context, [options]])`

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

### AMI Connection Setup
- TCP connection to Asterisk AMI port (default 5038)
- Authentication with Login action
- Event handling for ChanSpyStart/ChanSpyStop

### Dependencies
- `app_chanspy` module loaded
- `app_playback` module loaded
- Storage access for recordings

## 🎯 Key Benefits for Astrix Assist

1. **Call Monitoring**: Real-time eavesdropping on active calls
2. **Quality Assurance**: Recording playback for training/review
3. **Supervisory Control**: Whisper/barge capabilities for supervisors
4. **Recording Management**: Access to historical call recordings

## 📚 Reference Links
- [Asterisk AMI Documentation](https://docs.asterisk.org/Asterisk_20_Documentation/API_Documentation/AMI_Actions/)
- [ChanSpy Application](https://docs.asterisk.org/Asterisk_20_Documentation/API_Documentation/Dialplan_Applications/ChanSpy/)
- [Playback Application](https://docs.asterisk.org/Asterisk_20_Documentation/API_Documentation/Dialplan_Applications/Playback/)

---
*Documented: December 21, 2025*
*Source: Official Asterisk Documentation*