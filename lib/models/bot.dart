class BotCustom{
  int chatStatus = 0;
  int chatMode = -1;
  List greetings = [{
    'value': 'Selamat Pagi',
    'from': 0,
    'to': 11
  },{
    'value': 'Selamat Siang',
    'from': 11,
    'to': 15
  },{
    'value': 'Selamat Sore',
    'from': 15,
    'to': 19
  },{
    'value': 'Selamat Malam',
    'from': 19,
    'to': 24
  }];
  String askWho = "Bagaimana kami bisa memanggil anda? kakak/ibu/bapak";
  String askNeeds = "";
  String who = "Kakak";
  String askMore = "";
  String end = "";
  String close = """Terima kasih sudah menghubungi bluchat. 

  Apabila ada hal lain yang ingin ditanyakan, haloblu siap membantu Kakak 24/7 melalui:
  Telepon : 1500668/telepon bebas pulsa melalui aplikasi haloBCA (pilih "BCA Digital")
  X : @haloblu dan @blubybcadigital
  Email : haloblu@bcadigital.co.id
  Instagram : @blubybcadigital
  """;

  String responseNeeds(String type){
    String ans = "";
    switch(type){
      case "1": ans="Baik $who, silahkan mengajukan informasi apa yang ingin $who ketahui!";break;
      case "2": ans="Baik $who, silahkan mengajukan komplain yang $who inginkan. Kami akan teruskan ke customer service kami untuk melanjutkan jawaban dalam kurun waktu 24 jam.";break;
      case "3": ans="Baik $who, silahkan memberi saran kepada kami. Kami akan teruskan ke customer service kami untuk melanjutkan jawaban dalam kurun waktu 24 jam.";break;
      case "4": ans="Baik $who, silahkan mengajukan permintaan kepada kami. Kami akan teruskan ke customer service kami untuk melanjutkan jawaban dalam kurun waktu 24 jam.";break;
    }
    return ans;
  }

  String thanks(int type){
    var lType = ["komplain", "saran", "permintaan"];
    var pre = ["Mohon maaf $who atas ketidaknyamanannya.", "Terima kasih $who atas sarannya, kami akan sampaikan keunit terkait.", "Baik $who, kami akan sampaikan untuk diproses ke unit terkait."];
    var res = "${pre[type]} Apakah ada lagi ${lType[type]} yang ingin disampaikan? Jika ingin mengganti jenis pernyataan, silahkan ketik 1 untuk menanyakan informasi, ";
    for(var i=0; i<lType.length; i++){
      if(i != type){
        res += "${i+2} untuk ${lType[i]}, ";
      }
    }
    res += "atau 5 untuk mengakhiri percakapan!";
    return res;
  }

  void setWho(String who){
    this.who = who;
    end = "Karena tidak ada respons lagi dari $who, chat ini minblu akhiri ya. Semoga harinya menyenangkan $who";
    askMore = "Apakah ada yang $who ingin tanyakan lagi?";
    askNeeds = "Selamat datang $who di percakapan haloblue. Apakah ada yang bisa kami bantu? Silahkan ketik angka di bawah ini untuk memilih jenis pertayaan apa yang ingin $who sampaikan!\n1. Tanya Informasi\n2. Komplain\n3. Saran\n4. Permintaan\n5. Selesai";
  }

  String greet(){
    DateTime now = DateTime.now();
    int index =  greetings.indexWhere((element) => element['from'] <= now.hour && element['to'] >= now.hour); //koreksi menit
    return greetings[index]['value'];
  }
}