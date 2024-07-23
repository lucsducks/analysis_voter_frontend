import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociopolitico/screens/home_screen.dart';
import 'package:sociopolitico/screens/person_screen.dart';
import 'package:sociopolitico/screens/resultados_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => NoTransitionPage(child: HomeScreen()),
    ),
    GoRoute(
      path: '/person',
      pageBuilder: (context, state) => NoTransitionPage(child: PersonScreen()),
    ),
    GoRoute(
      path: '/resultados',
      pageBuilder: (context, state) =>
          NoTransitionPage(child: ResultadosScreen()),
    ),
  ],
);

class NoTransitionPage extends CustomTransitionPage<void> {
  NoTransitionPage({required Widget child})
      : super(
          child: child,
          transitionsBuilder: _transitionNone,
        );

  static Widget _transitionNone(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // This means no animation
  }
}
