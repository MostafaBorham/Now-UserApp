import 'package:flutter/cupertino.dart';
import 'package:nowdelivery_user_app/common/route/route_guard_imp.dart';

extension RouteManager on BuildContext {
  Future goTo(String routeName, {Map<String, dynamic>? args}) async {
    final String? redirectRoute = await RouteGuardImp().check();
    redirectRoute != null
        ? Navigator.pushNamed(this, redirectRoute)
        : Navigator.pushNamed(this, routeName, arguments: args);
  }

  Future goToReplacement(String routeName, {Map<String, dynamic>? args}) async {
    final String? redirectRoute = await RouteGuardImp().check();
    redirectRoute != null
        ? Navigator.pushReplacementNamed(this, redirectRoute)
        : Navigator.pushReplacementNamed(this, routeName, arguments: args);
  }

  Future back({Map<String, dynamic>? args}) async {
    final String? redirectRoute = await RouteGuardImp().check();
    redirectRoute != null
        ? Navigator.pushReplacementNamed(this, redirectRoute)
        : Navigator.pop(this,args);
  }

}
