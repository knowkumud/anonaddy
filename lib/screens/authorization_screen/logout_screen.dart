import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/state_management/authorization/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutScreen extends StatefulWidget {
  static const routeName = 'logoutScreen';

  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  Future<void> logout() async {
    await context.read(authStateNotifier.notifier).logout(context);
  }

  @override
  void initState() {
    super.initState();
    logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
