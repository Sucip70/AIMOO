import 'dart:collection';

import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:minimal/constants/app_constants.dart';
import 'package:minimal/constants/firestore_constants.dart';

class HomeProvider {
  // final FirebaseFirestore firebaseFirestore;
  final CosmosDbServer cosmosDbServer;

  HomeProvider({required this.cosmosDbServer});

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) async {
    final db = await cosmosDbServer.databases.open(AppConstants.database);
    final col = await db.containers.openOrCreate(collectionPath, partitionKey: PartitionKeySpec.id,);
    final obj = await col.query(Query('SELECT * FROM c WHERE c.id = @id', params: {'@id': path}),);
    
    col.patch(obj.first, setPatch(dataNeedUpdate));
  }

  Patch setPatch(Map<String, String> data){
    var patch = Patch();
    data.forEach((key, value) {
      patch.replace(key, value);
    });
    return patch;
  }

  Future<Stream<Iterable<BaseDocument>>> getStreamFireStore(String pathCollection, int limit, String? textSearch) async {
    final db = await cosmosDbServer.databases.open(AppConstants.database);
    final col = await db.containers.openOrCreate(pathCollection, partitionKey: PartitionKeySpec.id,);
    if (textSearch?.isNotEmpty == true) {
      return col.query(Query("SELECT top @limit * FROM c WHERE c.nickname like '%@s%'", params: {'@limit' : limit, '@s': textSearch}),).asStream();
      
      // return firebaseFirestore
      //     .collection(pathCollection)
      //     .limit(limit)
      //     .where(FirestoreConstants.nickname, isEqualTo: textSearch)
      //     .snapshots();
    } else {
      // final res = firebaseFirestore.collection(pathCollection).limit(limit).snapshots();
      return col.query(Query("SELECT top @limit * FROM c", params: {'@limit' : limit}),).asStream();
    }
  }
}
