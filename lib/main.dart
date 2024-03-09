import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:flutter/material.dart';
import 'package:minimal/constants/app_constants.dart';
import 'package:minimal/firebase_options.dart';
import 'package:minimal/models/cosmosdb_model.dart';
import 'package:minimal/pages/pages.dart';
import 'package:minimal/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}
class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  MyApp({super.key, required this.prefs});

  MyAppState createState () => MyAppState();
}
class MyAppState extends State<MyApp> {
  final CosmosDbServer cosmosDbServer = CosmosDbServer(AppConstants.cosmoDB, masterKey: AppConstants.masterKey);
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  late CosmosDbContainer cosmosDbContainer;

  @override
  void initState(){
    _init();
  }

  Future _init () async {
    final db = await cosmosDbServer.databases.open(AppConstants.database);
    final indexingPolicy = IndexingPolicy(indexingMode: IndexingMode.consistent)
      ..excludedPaths.add(IndexPath('/*'))
      ..includedPaths.add(IndexPath('/"due-date"/?'))
      ..compositeIndexes.add([
        IndexPath('/label', order: IndexOrder.ascending),
        IndexPath('/"due-date"', order: IndexOrder.descending)
      ]);
      try {
        
    cosmosDbContainer = await db.containers.openOrCreate("messages", partitionKey: PartitionKeySpec.id, indexingPolicy: indexingPolicy);
    cosmosDbContainer.registerBuilder<Messages>(Messages.fromJson);
      } catch (e) {
        throw e;
      }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: widget.prefs,
            cosmosDB: cosmosDbServer
          ),
        ),
        Provider<HomeProvider>(
          create: (_) => HomeProvider(
            cosmosDbServer: cosmosDbServer
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            firebaseFirestore: firebaseFirestore,
            prefs: widget.prefs,
            cosmosDbServer: cosmosDbServer,
            firebaseStorage: firebaseStorage,
            cosmosDbContainer: cosmosDbContainer
          ),
        ),
      ],
      child:
    MaterialApp(
      // Wrapping the app with a builder method makes breakpoints
      // accessible throughout the widget tree.
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (context) {
          return BouncingScrollWrapper.builder(
              context, buildPage(settings.name ?? ''),
              dragWithMouse: true);
        });
      },
      debugShowCheckedModeBanner: false,
    ));
  }

  // onGenerateRoute route switcher.
  // Navigate using the page name, `Navigator.pushNamed(context, ListPage.name)`.
  Widget buildPage(String name) {
    switch (name) {
      case '/':
      case SplashPage.name:
        return SplashPage();
      case ListPage.name:
        return const ListPage();
      case PostPage.name:
        // Custom "per-page" breakpoints.
        return const ResponsiveBreakpoints(breakpoints: [
          Breakpoint(start: 0, end: 480, name: MOBILE),
          Breakpoint(start: 481, end: 1200, name: TABLET),
          Breakpoint(start: 1201, end: double.infinity, name: DESKTOP),
        ], child: PostPage());
      case TypographyPage.name:
        return const TypographyPage();
      default:
        return const SizedBox.shrink();
    }
  }
}
