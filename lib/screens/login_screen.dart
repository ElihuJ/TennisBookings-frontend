import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/widgets/containers/bordered_box.dart';

import '../widgets/eventful/eventful.dart';
import '../widgets/header/index.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});
  static const route = 'Login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
            appBar: Header(),
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
      
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Google login
                    },
                    icon: Icon(Icons.login),
                    label: Text('Login with Google'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Email login
                    },
                    icon: Icon(Icons.email),
                    label: Text('Login with Email'),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
