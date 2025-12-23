# CDR Format Comparison

## Research Summary

This document compares Call Detail Record (CDR) formats across different Asterisk versions to understand parsing requirements for multi-generation testing.

**Research Date**: December 23, 2025  
**Sources**: Asterisk Documentation and CSV samples

## Generation 1: Asterisk 11.x (14 columns)

### CSV Header
```
accountcode,src,dst,dcontext,clid,channel,dstchannel,lastapp,lastdata,calldate,duration,billsec,disposition,amaflags
```

### Sample Record
```
,1003,09155119004,from-internal,"John Doe" <1003>,SIP/1003-000000c6,SIP/trunk-000000c7,Dial,SIP/trunk/09155119004,300,T,2025-12-23 12:41:27,29,23,ANSWERED,DOCUMENTATION
```

### Field Descriptions
1. **accountcode**: Account code (empty if not set)
2. **src**: Source extension
3. **dst**: Destination number
4. **dcontext**: Dialplan context
5. **clid**: Caller ID string
6. **channel**: Source channel
7. **dstchannel**: Destination channel
8. **lastapp**: Last application executed
9. **lastdata**: Application data
10. **calldate**: Call start time (no timezone)
11. **duration**: Total call duration in seconds
12. **billsec**: Billable seconds
13. **disposition**: Call disposition (ANSWERED, NO ANSWER, etc.)
14. **amaflags**: AMA flags

## Generation 2: Asterisk 13.x (17 columns)

### New Fields Added
- **uniqueid**: Unique call identifier
- **userfield**: User-defined field
- **answerdate**: Call answer time

### CSV Header
```
accountcode,src,dst,dcontext,clid,channel,dstchannel,lastapp,lastdata,calldate,duration,billsec,disposition,amaflags,uniqueid,userfield,answerdate
```

### Sample Record
```
,1003,09155119004,from-internal,"John Doe" <1003>,SIP/1003-000000c6,SIP/trunk-000000c7,Dial,SIP/trunk/09155119004,300,T,2025-12-23 12:41:27,29,23,ANSWERED,DOCUMENTATION,1441234567.123,,2025-12-23 12:41:33
```

## Generation 3: Asterisk 16.x (19 columns)

### New Fields Added
- **enddate**: Call end time
- **sequence**: CDR sequence number

### CSV Header
```
accountcode,src,dst,dcontext,clid,channel,dstchannel,lastapp,lastdata,calldate,duration,billsec,disposition,amaflags,uniqueid,userfield,answerdate,enddate,sequence
```

### Sample Record
```
,1003,09155119004,from-internal,"John Doe" <1003>,SIP/1003-000000c6,SIP/trunk-000000c7,Dial,SIP/trunk/09155119004,300,T,2025-12-23 12:41:27,29,23,ANSWERED,DOCUMENTATION,1441234567.123,,2025-12-23 12:41:33,2025-12-23 12:41:56,1
```

## Generation 4: Asterisk 18.x/20.x (20+ columns)

### New Fields Added
- **linkedid**: Linked call identifier
- **peeraccount**: Peer account
- **Additional CEL fields** (if enabled)

### CSV Header
```
accountcode,src,dst,dcontext,clid,channel,dstchannel,lastapp,lastdata,calldate,duration,billsec,disposition,amaflags,uniqueid,userfield,answerdate,enddate,sequence,linkedid,peeraccount
```

### Sample Record
```
,1003,09155119004,from-internal,"John Doe" <1003>,SIP/1003-000000c6,SIP/trunk-000000c7,Dial,SIP/trunk/09155119004,300,T,2025-12-23 12:41:27,29,23,ANSWERED,DOCUMENTATION,1441234567.123,,2025-12-23 12:41:33,2025-12-23 12:41:56,1,1441234567.123,
```

## Key Differences Summary

### Timezone Handling
- **Gen 1**: No timezone info, assume UTC
- **Gen 2-4**: ISO 8601 format with potential timezone

### Unique Identifiers
- **Gen 1**: No uniqueid
- **Gen 2+**: uniqueid in format: timestamp.sequence
- **Gen 4**: linkedid for call linking

### Date Fields
- **Gen 1**: Only calldate
- **Gen 2**: Added answerdate
- **Gen 3**: Added enddate
- **Gen 4**: All dates available

## Parsing Strategy

### For Multi-Generation Support
1. **Column Count Detection**: Determine generation by column count
2. **Field Mapping**: Map fields by position, not name
3. **Optional Fields**: Handle missing fields gracefully
4. **Date Parsing**: Use appropriate timezone handling

### Implementation Notes
```dart
// Column count to generation mapping
int getGenerationFromColumnCount(int columns) {
  if (columns <= 14) return 1;
  if (columns <= 17) return 2;
  if (columns <= 19) return 3;
  return 4; // 20+
}

// Safe field access
String? getField(List<String> parts, int index) {
  return index < parts.length ? parts[index] : null;
}
```

## Testing Considerations

### Fixture Generation
- Generate sample records for each generation
- Include edge cases (missing fields, special characters)
- Test parsing with various column counts

### Compatibility Testing
- Verify parsing works across all generations
- Test date parsing with/without timezone
- Validate field mapping accuracy