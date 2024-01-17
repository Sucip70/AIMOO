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
    return peerIsSearchIndex?{
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
      "stop": peerStop,
      "dataSources": [
          {
              "type": "AzureCognitiveSearch",
              "parameters": {
                  "endpoint": peerSearchEndpoint,
                  "key": peerSearchKey,
                  "indexName": peerSearchIndex
              }
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
}
