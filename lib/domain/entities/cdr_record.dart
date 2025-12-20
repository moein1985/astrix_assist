import 'package:equatable/equatable.dart';

class CdrRecord extends Equatable {
  final String callDate;
  final String clid;
  final String src;
  final String dst;
  final String dcontext;
  final String channel;
  final String dstChannel;
  final String lastApp;
  final String lastData;
  final String duration;
  final String billsec;
  final String disposition;
  final String amaflags;
  final String uniqueid;
  final String userfield;

  const CdrRecord({
    required this.callDate,
    required this.clid,
    required this.src,
    required this.dst,
    required this.dcontext,
    required this.channel,
    required this.dstChannel,
    required this.lastApp,
    required this.lastData,
    required this.duration,
    required this.billsec,
    required this.disposition,
    required this.amaflags,
    required this.uniqueid,
    required this.userfield,
  });

  @override
  List<Object?> get props => [
        callDate,
        clid,
        src,
        dst,
        dcontext,
        channel,
        dstChannel,
        lastApp,
        lastData,
        duration,
        billsec,
        disposition,
        amaflags,
        uniqueid,
        userfield,
      ];
}
