import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/firebase_options.dart';
import 'package:club/dynamic_link/dynamic_link.dart';
import 'package:club/screens/home/homeBar.dart';
import 'package:club/screens/organiser/home/organiser_homeBar.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/screens/organiser/home/organiser_home.dart';
import 'package:club/screens/sign_up/init_signup_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:club/search/seach_club.dart' as search;
import 'authentication/phyllo_integration/pyllo_init.dart';
import 'firebase_options.dart';
import 'init/main_init.dart';
import 'screens/home/InfluencerHome.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: matte(),
      systemNavigationBarIconBrightness: Brightness
          .light, // Set the navigation icon brightness (dark or light)
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await initHive();
  }
  await Firebase.initializeApp(
    name: 'club demo',
    options: FirebaseOptions(
      apiKey: 'AIzaSyAmMaAorHzDKkYbOJOtli3Tvz4c877NRRY',
      appId: '1:835379344984:android:ca2c9843fb950070eb7c2d',
      messagingSenderId: '835379344984',
      projectId: 'partyon-artist-demo',
      // databaseURL: 'https://partyon-artist-demo-default-rtdb.firebaseio.com',
      storageBucket: 'partyon-artist-demo.firebasestorage.app',

    ),
  );

  // await initHive();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  await FirebaseDynamicLinkEvent.initReferDynamicLinks();

  // Box box = await HiveDB.openBox();
  // print('Refer Id ${await HiveDB.getKey(box, HiveConst.referMap)}');
  // FirebaseUIAuth.configureProviders([
  //   FacebookProvider(clientId: FACEBOOK_CLIENT_ID),
  // ]);

  runApp(const MyApp());
}

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1080, 2340),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => AnimationProvider()),
              ChangeNotifierProvider(create: (_) => search.SearchController()),
              ChangeNotifierProvider(create: (_) => LogoProvider()),
            ],
            child: SafeArea(
              child: GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  builder: EasyLoading.init(),
                  title: 'PartyOn Demo',
                  theme: ThemeData(
                    useMaterial3: false,
                    textTheme: GoogleFonts.ubuntuTextTheme(
                        Theme.of(context).textTheme),
                    primarySwatch: Colors.blue,
                    scaffoldBackgroundColor: matte(),
                  ),
                  home:
                  const InitialPage() //ClubDetails(email: 'hbk9sj@gmail.com',) //Address(clubName: "clubName", category: "category", description: "description", email: "email", uploadCover: File("path"), openTime: "openTime", closeTime: "closeTime", averageCost: "averageCost"),
              ),
            ),
          );
        });
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb) {
        FlutterNativeSplash.remove();
      }
      print(
          "category: ${await const FlutterSecureStorage().read(key: "businessCategory")}");
      if (FirebaseAuth.instance.currentUser != null) {
        await getHome();
      } else {
        Get.offAll(const LoginPage());
      }
    });

    super.initState();
  }

  Future<void> getHome() async {
    print("main uid : ${uid()}");
    try {
      await FirebaseFirestore.instance
          .collection("Club")
          .where("clubUID", isEqualTo: uid())
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          print("mainlog  1111 ${value.docs.toString()}");
          saveBusinessType("club");
          Get.off(() => const HomeBar());
        } else {
          await FirebaseFirestore.instance
              .collection("Organiser")
              .where("organiserID", isEqualTo: uid())
              .get()
              .then((value) async {
            if (value.docs.isNotEmpty) {
              saveBusinessType("organiser");
              print("mainlog 2222");
              Get.off(() => const OrganiserHomeBar());
            } else {
              print(uid());
              await FirebaseFirestore.instance
                  .collection("Influencer").doc(uid())
                  .get()
                  .then((value) async {
                print('influencer exists ${value.exists}') ;
                print('influencer id ${value.id}');
                if (value.exists) {
                  saveBusinessType("influencer");
                  print("mainlog3333");
                  Get.off(const InfluencerHome());
                }
                else {
                  Get.off(const InitSignupDetails());
                }
              });
            }
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('the error on get home is $e');
      }
      Get.off(const InitSignupDetails());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: matte(),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    );
  }
}
