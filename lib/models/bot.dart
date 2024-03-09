import 'package:minimal/models/arguments.dart';

class BotCustom{
  int chatStatus = 0;
  int chatMode = -1;
  List<OneChat> hist = List.empty();
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

  BotCustom(){
    setWho("Kakak");
  }

  String askWho = "Hai Minblu disini! Minblu bisa panggil kakak, ibu, atau bapak?";
  String askNeeds = "";
  String who = "Kakak";
  String askAgain = "";
  String askMore = "";
  String end = "";
  String close = "";
  String unwanted = "Please try another";
  String unwantedRes = "Mohon maaf saat ini MinBlu tidak dapat menjawab pertanyaan tersebut, boleh ditanyakan pertanyaan lain atau mau disambungkan ke Agent kami? 😊";
  String error = "Mohon maaf ada kesalahan pada sistem kami!";

  String responseNeeds(String type){
    String ans = "";
    switch(type){
      case "1": ans="$who mau tanya apa ke Minblu? Kalau Minblu tau, Minblu jawab ya!";break;
      case "2": ans="Yahh. Minblu minta maaf ya $who! Minblu jawab komplain $who sebisanya, oke?!";break;
      case "3": ans="Saran baik apa ingin $who sampaikan? Nanti Minblu kasih tau ke unit bersangkutan";break;
      case "4": ans="$who mau minta apa ke Minblu? Nanti Minblu kasih tau ke unit bersangkutan";break;
    }
    return ans;
  }

  String thanks(int type){
    var lType = ["komplain", "saran", "permintaan"];
    var pre = ["Minblu minta maaf $who atas ketidaknyamanannya.", "Minblu berterimakasih atas sarannya. Minblu akan sampaikan keunit terkait.", "Oke $who! Minblu sampaikan untuk diproses ke unit terkait ya!"];
    var res = "${pre[type]} Ada lagi ${lType[type]} yang ingin disampaikan? Kalau mau ganti, ketik 1 untuk tanya info ke Minblu, ";
    for(var i=0; i<lType.length; i++){
      if(i != type){
        res += "${i+2} untuk ${lType[i]}, ";
      }
    }
    res += "atau 5 untuk selesai ya!";
    return res;
  }

  void setWho(String who){
    this.who = who;
    askAgain = "Apakah ada lagi $who yang bisa minblu bantu?";
    end = "Karena tidak ada respons lagi dari $who, chat ini minblu akhiri ya. Semoga harinya menyenangkan $who";
    askMore = "Ada yang $who ingin tanyakan lagi?";
    askNeeds = "Selamat datang $who di percakapan haloblue. Minblu bisa bantu apa? Ketik angka di bawah ini untuk pilih jenis pertayaan $who ya!\n1. Informasi (Tanya Minblu)\n2. Komplain\n3. Saran\n4. Permintaan\n5. Selesai";
    close = """Terimakasih sudah menghubungi bluchat. \n\nApabila ada hal lain yang ingin ditanyakan, haloblu siap membantu $who 24/7 melalui:\nTelepon : 1500668/telepon bebas pulsa melalui aplikasi haloBCA (pilih "BCA Digital")\nX : @haloblu dan @blubybcadigital\nInstagram : @blubybcadigital\nWhatsapp : 0811-6500-668\nEmail : haloblu@bcadigital.co.id\n\nTerimakasih telah menggunakan layanan haloblu""";
  }

  String greet(){
    DateTime now = DateTime.now();
    int index =  greetings.indexWhere((element) => element['from'] <= now.hour && element['to'] >= now.hour); //koreksi menit
    return greetings[index]['value'];
  }
}