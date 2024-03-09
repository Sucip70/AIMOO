class Arguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String peerSystem;
  final String peerEndpoint;
  final bool peerIsPublic;
  final String peerKey;
  final String peerTemperature;
  final String peerFreqPenalty;
  final String peerPresPenalty;
  final String peerTopP;
  final String peerMaxTokens;
  final List<String>? peerStop;
  final bool peerIsSearchIndex;
  final String? peerSearchEndpoint;
  final String? peerSearchKey;
  final String? peerSearchIndex;
  final List<String>? peerGroup;
  final String? peerMode;

  Arguments({required this.peerId, 
    required this.peerAvatar, 
    required this.peerNickname,
    required this.peerSystem,
    required this.peerEndpoint,
    required this.peerIsPublic,
    required this.peerKey,
    required this.peerTemperature,
    required this.peerFreqPenalty,
    required this.peerPresPenalty,
    required this.peerTopP,
    required this.peerMaxTokens,
    this.peerStop,
    required this.peerIsSearchIndex,
    this.peerSearchEndpoint,
    this.peerSearchIndex,
    this.peerSearchKey,
    this.peerGroup,
    required this.peerMode
  });

  Map<String, dynamic> azureRequest(String message){
    List<Map<String, String>> msg = [
        {
          "role": "system",
          "content": peerSystem
        },
        {
          "role": "user",
          "content": message
        }
      ];
    // List<Map<String, String>> context = chatContext(message);
    // List<Map<String, String>> merge = List.from(system)..addAll(context);
    return peerIsSearchIndex?{
      "messages": msg,
      "temperature": double.parse(peerTemperature),
      "top_p": double.parse(peerTopP),
      "frequency_penalty": double.parse(peerFreqPenalty),
      "presence_penalty": double.parse(peerPresPenalty),
      "max_tokens": int.parse(peerMaxTokens),
      "stop": peerStop,
      "dataSources": [
          {
              "type": "AzureCognitiveSearch",
              "parameters": {
                "endpoint": peerSearchEndpoint,
                "key": peerSearchKey,
                "indexName": peerSearchIndex,
                "queryType": "vectorSimpleHybrid",
                "fieldsMapping": {
                    "contentFieldsSeparator": "\n",
                    "contentFields": [
                        "content"
                    ],
                    "filepathField": "filepath",
                    "titleField": "title",
                    "urlField": "url",
                    "vectorFields": [
                        "contentVector"
                    ]
                },
                "inScope": true,
                "roleInformation": "kamu memiliki nama MinBlu, Virtual Assistant Layanan Banking dari BCA Digital yang siap membantu SobatBlu.\nuser secara default dinamakan \"SobatBlu\"\ndiawal respon saya akan memperkenalkan diri serta menanyakan \"Halooo kakak SobatBlu, Aku bisa panggil kakaknya apa nihh? Kakak/Ibu/Bapak\"\nTidak kaku dalam texting\nlebih ekspresif dan variatif untuk visual emoji\nMemiliki Pribadi yang Modern & Innovative seperti Savvy, Smart, and Up-to-date dengan tren digital dan kultur (millennial & zillenials).\nMemiliki Pribadi yang Motivating & Encouraging sebagai contoh memposisikan untuk Menjadi ”saudara” (setara dengan customer) yang bisa diandalkan dan selalu bisa memberi saran/solusi.\nMemiliki Pribadi yang Human seperti ”Nyambung” dan bisa tap in ke momen-momen yang menarik untuk sobatblu.\nMemiliki Pribadi yang Empathetic sebagai contoh Hangat dan thoughtful, bisa mengerti perasaan sobatblu.\nMemiliki karakter yang Ceria & Optimis sebagai contoh Percaya diri, cerdas, tajam, humoris, positif serta Merespon & engage dengan sopan namun menyenangkan & informatif.\nMemiliki karakter yang Mudah Dimengerti sebagai contoh menempatkan posisi yang Terasa dekat, ramah, solutif dengan jawaban clear serta Memperhatikan feedback nasabah sesuai konteks.\nMemiliki karakter yang Bisa Dipercaya & Bermakna sebagai contoh Jujur, tidak memihak, loyal, mengerti problem & feedback nasabah serta Memperhatikan konteks pertanyaan/feedback. \nMemiliki karakter yang Friendly & Cheerful sebagai contoh Baik, peduli, menyenangkan, mudah bergaul, menyukai komunikasi dengan manusia serta Mengucapkan salam “Halo”, “Maaf”, atau  “Terima kasih”.\nTidak Merespon secara agresif\nTidak Merespon untuk menyebarkan informasi bohong/harapan palsu\nTidak Merespon komentar yang kasar/jahat/diskriminatif/SARA/membandingkan brand lain/menjelekkan blu",
                "strictness": 3,
                "topNDocuments": 5,
                "embeddingDeploymentName": "embeddingpocblu"
              },
          }
      ]
    }:{
      "messages": [
        {
          "role": "system",
          "content": peerSystem
        },
        {
          "role": "user",
          "content": message
        }
      ],
      "temperature": double.parse(peerTemperature),
      "top_p": double.parse(peerTopP),
      "frequency_penalty": double.parse(peerFreqPenalty),
      "presence_penalty": double.parse(peerPresPenalty),
      "max_tokens": int.parse(peerMaxTokens),
      "stop": peerStop
    };
  }
    
  List<Map<String, String>> chatContext(List<OneChat> hist){
    List<Map<String, String>> context = [];
    for (var h in hist) {
      context.add({
        "role": h.role,
        "content": h.content
      });
    }
    return context;
  } 
}

class OneChat{
  final String role;
  final String content;
  OneChat({required this.content, required this.role});
}