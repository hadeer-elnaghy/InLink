
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:store/models/Configuration.dart';
import 'package:store/pages/Sells.dart';
import 'package:store/providers/customer_provider.dart';
import 'package:store/providers/invoice_provider.dart';
import 'package:store/providers/purchase_provider.dart';
import 'package:store/providers/setting_provider.dart';
import 'package:store/providers/user_provider.dart';
import 'package:store/route_generator.dart';
import 'package:store/store/AppStore.dart';
import 'package:store/utils/Helper.dart';
import 'models/User.dart';
import 'utils/AppConstant.dart';
import 'package:store/utils/AppTheme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/UserService0.dart' as UserService;

import 'di_container.dart' as di;

AppStore appStore = AppStore();
Helper helper = Helper();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late  User currentUser;
late  Configuration currentUserConfigurations;
late String userToken;
String configurationId = '';
late bool IsLoggedIn;
const secureStorage = FlutterSecureStorage();
AndroidOptions getAndroidOptions() =>
    const AndroidOptions(
      encryptedSharedPreferences: true,
    );


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  await appStore.toggleDarkMode(getBoolAsync(isDarkModeOnPref,defaultValue: false));
  await appStore.toggleLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: 'ar'));

   UserService.getCurrentUser();
  try{
    var containsServerKey = await secureStorage.containsKey(key: CONFID, aOptions: getAndroidOptions());
    if(containsServerKey) {
      configurationId = await secureStorage.read(key: CONFID, aOptions: getAndroidOptions()) ?? '';
    }

  }catch(e){
    print(e);
  }


  await di.init();
   runApp(MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (context) => di.sl<InvoiceProvider>()),
       ChangeNotifierProvider(create: (context) => di.sl<CustomerProvider>()),
       ChangeNotifierProvider(create: (context) => di.sl<UserProvider>()),
       ChangeNotifierProvider(create: (context) => di.sl<SettingProvider>()),
       ChangeNotifierProvider(create: (context) => di.sl<PurchaseProvider>()),
     ],
     child: MyApp(),
   ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    IsLoggedIn = Provider.of<UserProvider>(context, listen: false).isLoggedIn();
    currentUser = Provider.of<UserProvider>(context, listen: false).getUserData();
    userToken = Provider.of<UserProvider>(context, listen: false).getUserToken();
    currentUserConfigurations = Provider.of<UserProvider>(context, listen: false).getUserConfigurations();
  }
  @override
  Widget build(BuildContext context) {
    return
      Observer(
        builder: (_) {
          return MaterialApp(

                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  title: 'INLINK',
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale:  Locale(appStore.mobileLanguage),
                  onGenerateRoute: RouteGenerator.generateRoute,
                  theme: appStore.isDarkModeOn
                      ? AppThemeData.darkTheme
                      : AppThemeData.lightTheme,
                 initialRoute: userToken == null || userToken.isEmpty ? '/login' : '/sells',
                 home: Sells(),

                );
        }
    );
  }

}
class Get {
  static BuildContext get context => navigatorKey.currentContext!;
  static NavigatorState get navigator => navigatorKey.currentState!;
}
