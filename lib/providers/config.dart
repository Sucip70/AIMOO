import 'package:universal_io/io.dart';

class TestConfig {
  late final String cosmosDBUrl;
  late final String cosmosDBMasterKey;
  late final bool ignoreSelfSignedCertificates;

  TestConfig() {
    cosmosDBUrl =
        Platform.environment['COSMOS_DB_URL'] ?? 'https://cosmoo.documents.azure.com/';
    cosmosDBMasterKey = Platform.environment['COSMOS_DB_MASTER_KEY'] ??
        'uYkMk9K7DuQRGj6aYST6idLP7oygndmLK3Huq2NNvetWQW3neTSJGzvVho1OhkW59YRXiMpmqPSvACDbebXTUA==';
    ignoreSelfSignedCertificates =
        Platform.environment['COSMOS_DB_IGNORE_SSL'] != null;
  }
}