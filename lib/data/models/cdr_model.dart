import '../../domain/entities/cdr_record.dart';

class CdrModel extends CdrRecord {
  const CdrModel({
    required super.callDate,
    required super.clid,
    required super.src,
    required super.dst,
    required super.dcontext,
    required super.channel,
    required super.dstChannel,
    required super.lastApp,
    required super.lastData,
    required super.duration,
    required super.billsec,
    required super.disposition,
    required super.amaflags,
    required super.uniqueid,
    required super.userfield,
  });

  factory CdrModel.fromJson(Map<String, dynamic> json) {
    return CdrModel(
      callDate: json['calldate'] ?? '',
      clid: json['clid'] ?? '',
      src: json['src'] ?? '',
      dst: json['dst'] ?? '',
      dcontext: json['dcontext'] ?? '',
      channel: json['channel'] ?? '',
      dstChannel: json['dstchannel'] ?? '',
      lastApp: json['lastapp'] ?? '',
      lastData: json['lastdata'] ?? '',
      duration: json['duration']?.toString() ?? '0',
      billsec: json['billsec']?.toString() ?? '0',
      disposition: json['disposition'] ?? '',
      amaflags: json['amaflags']?.toString() ?? '',
      uniqueid: json['uniqueid'] ?? '',
      userfield: json['userfield'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calldate': callDate,
      'clid': clid,
      'src': src,
      'dst': dst,
      'dcontext': dcontext,
      'channel': channel,
      'dstchannel': dstChannel,
      'lastapp': lastApp,
      'lastdata': lastData,
      'duration': duration,
      'billsec': billsec,
      'disposition': disposition,
      'amaflags': amaflags,
      'uniqueid': uniqueid,
      'userfield': userfield,
    };
  }
}
