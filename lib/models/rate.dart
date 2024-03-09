import 'package:azure_cosmosdb/azure_cosmosdb.dart';

class Rate extends BaseDocumentWithEtag {
  @override
  final String id;

  double rate;
  String timeStamp;

  Rate._(this.id, this.rate, this.timeStamp);
  Rate(String id, double rate, String timeStamp) : this._(id, rate, timeStamp);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "rate": rate,
      "timeStamp": timeStamp,
    };
  }

  static Rate fromJson(Map json){
    final rate = Rate._(
      json['id'],
      json['rate'],
      json['timeStamp']
    );

    return rate;
  }
}
