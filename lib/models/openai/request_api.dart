
class Request {
  final List<Map<String, String>> messages;
  final double temperature;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;
  final int maxTokens;
  final List<String>? stop;

  Request(this.messages, this.temperature, this.topP, this.frequencyPenalty,
      this.presencePenalty, this.maxTokens, this.stop);

  Request.fromJson(Map<String, dynamic> json)
      : messages = json['messages'] as List<Map<String, String>>,
        temperature = json['temperature'] as double,
        topP = json['top_p'] as double,
        frequencyPenalty = json['frequency_penalty'] as double,
        presencePenalty = json['presence_penalty'] as double,
        maxTokens = json['max_tokens'] as int,
        stop = json['stop'] as List<String>?;

  Map<String, dynamic> toJson() => {
        'messages': messages,
        'temperature': temperature,
        'top_p': topP,
        'frequency_penalty': frequencyPenalty,
        'presence_penalty': presencePenalty,
        'max_tokens': maxTokens,
        'stop': stop?.isEmpty ?? true ? null : stop,
      };
}

class RequestIndexer {
  final List<Map<String, String>> messages;
  final double temperature;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;
  final int maxTokens;
  final List<String>? stop;
  final ListDataSource dataSources;

  RequestIndexer(
      this.messages,
      this.temperature,
      this.topP,
      this.frequencyPenalty,
      this.presencePenalty,
      this.maxTokens,
      this.stop,
      this.dataSources);

  RequestIndexer.fromJson(Map<String, dynamic> json)
      : messages = json['messages'] as List<Map<String, String>>,
        temperature = json['temperature'] as double,
        topP = json['top_p'] as double,
        frequencyPenalty = json['frequency_penalty'] as double,
        presencePenalty = json['presence_penalty'] as double,
        maxTokens = json['max_tokens'] as int,
        stop = json['stop'] as List<String>?,
        dataSources = ListDataSource.fromJson(json['dataSources']);

  Map<String, dynamic> toJson() => {
        'messages': messages,
        'temperature': temperature,
        'top_p': topP,
        'frequency_penalty': frequencyPenalty,
        'presence_penalty': presencePenalty,
        'max_tokens': maxTokens,
        'stop': stop?.isEmpty ?? true ? null : stop,
        'dataSources': dataSources.list
            .map((e) => {
                  'type': e.type,
                  'parameters': {
                    'endpoint': e.param.endpoint,
                    'key': e.param.key,
                    'indexName': e.param.indexName,
                    "queryType": "vectorSimpleHybrid",
                    "fieldsMapping": {
                      "contentFieldsSeparator": "\n",
                      "contentFields": ["content"],
                      "filepathField": "filepath",
                      "titleField": "title",
                      "urlField": "url",
                      "vectorFields": ["contentVector"]
                    },
                    "inScope": true,
                    "roleInformation":
                        "kamu memiliki nama MinBlu, Virtual Assistant Layanan Banking dari BCA Digital yang siap membantu SobatBlu.\nuser secara default dinamakan \"SobatBlu\"\ndiawal respon saya akan memperkenalkan diri serta menanyakan \"Halooo kakak SobatBlu, Aku bisa panggil kakaknya apa nihh? Kakak/Ibu/Bapak\"\nTidak kaku dalam texting\nlebih ekspresif dan variatif untuk visual emoji\nMemiliki Pribadi yang Modern & Innovative seperti Savvy, Smart, and Up-to-date dengan tren digital dan kultur (millennial & zillenials).\nMemiliki Pribadi yang Motivating & Encouraging sebagai contoh memposisikan untuk Menjadi ”saudara” (setara dengan customer) yang bisa diandalkan dan selalu bisa memberi saran/solusi.\nMemiliki Pribadi yang Human seperti ”Nyambung” dan bisa tap in ke momen-momen yang menarik untuk sobatblu.\nMemiliki Pribadi yang Empathetic sebagai contoh Hangat dan thoughtful, bisa mengerti perasaan sobatblu.\nMemiliki karakter yang Ceria & Optimis sebagai contoh Percaya diri, cerdas, tajam, humoris, positif serta Merespon & engage dengan sopan namun menyenangkan & informatif.\nMemiliki karakter yang Mudah Dimengerti sebagai contoh menempatkan posisi yang Terasa dekat, ramah, solutif dengan jawaban clear serta Memperhatikan feedback nasabah sesuai konteks.\nMemiliki karakter yang Bisa Dipercaya & Bermakna sebagai contoh Jujur, tidak memihak, loyal, mengerti problem & feedback nasabah serta Memperhatikan konteks pertanyaan/feedback. \nMemiliki karakter yang Friendly & Cheerful sebagai contoh Baik, peduli, menyenangkan, mudah bergaul, menyukai komunikasi dengan manusia serta Mengucapkan salam “Halo”, “Maaf”, atau  “Terima kasih”.\nTidak Merespon secara agresif\nTidak Merespon untuk menyebarkan informasi bohong/harapan palsu\nTidak Merespon komentar yang kasar/jahat/diskriminatif/SARA/membandingkan brand lain/menjelekkan blu\njika pelanggan menanyakan informasi maka akan menambahkan kalimat \"Semoga Bermanfaat\" di akhir jawaban. jika pelanggan menanyakan atau memberikan keluhan atau komplain maka akan menambahkan kalimat \"Mohon maaf atas ketidaknyamanannya\" di awal jawaban diikuti emoji. jika pelanggan memberikan saran atau kritik maka akan memberikan jawaban \"Terima kasih atas sarannya, kami akan sampaikan keunit terkait\". jika pelanggan memberikan permintaan atau request maka akan memberikan jawaban \"Kami akan sampaikan untuk diproses ke unit terkait\".",
                    "strictness": 3,
                    "topNDocuments": 5,
                    "embeddingDeploymentName": "embeddingpocblu"
                  }
                })
            .toList()
      };
}

class ListDataSource {
  late List<IndexerDataSources> list;

  ListDataSource({required this.list});

  ListDataSource.fromJson(List<Map<String, dynamic>> json) {
    list = <IndexerDataSources>[];
    for(var j in json){
      list.add(IndexerDataSources.fromJson(j));
    }
  }
}

class IndexerDataSources {
  final String type;
  final DataSourcesParam param;

  IndexerDataSources.fromJson(Map<String, dynamic> json)
      : type = json['type'] as String,
        param = DataSourcesParam.fromJson(json['parameters']);
}

class DataSourcesParam {
  final String endpoint;
  final String key;
  final String indexName;
  final String queryType;
  final bool inScope;
  final String roleInformation;
  final int strictness;
  final int topNDocuments;
  final String embeddingDeploymentName;
  late FieldMapping fieldsMapping;

  DataSourcesParam.fromJson(Map<String, dynamic> json)
      : endpoint = json['endpoint'] as String,
        key = json['key'] as String,
        indexName = json['indexName'] as String,
        queryType = json['queryType'] as String,
        inScope = json['inScope'] as bool,
        roleInformation = json['roleInformation'] as String,
        strictness = json['strictness'] as int,
        topNDocuments = json['topNDocuments'] as int,
        embeddingDeploymentName = json['embeddingDeploymentName'] as String,
        fieldsMapping = FieldMapping.fromJson(json['fieldsMapping']);
}

class FieldMapping {
  final String contentFieldsSeparator;
  final String filepathField;
  final String titleField;
  final String urlField;
  final List<String> contentFields;
  final List<String> vectorFields;

  FieldMapping.fromJson(Map<String, dynamic> json)
      : contentFieldsSeparator = json['contentFieldsSeparator'] as String,
        filepathField = json['filepathField'] as String,
        titleField = json['titleField'] as String,
        urlField = json['urlField'] as String,
        contentFields = json['contentFields'] as List<String>,
        vectorFields = json['vectorFields'] as List<String>;
}
