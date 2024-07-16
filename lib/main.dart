import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  static const title = 'Flutter App';
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorObserver = ShellNavigatorObserver();

  final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => ShellPage(
                controller: _shellNavigatorObserver.controller,
                child: child,
              ),
          observers: [
            _shellNavigatorObserver
          ],
          routes: [
            GoRoute(
              name: 'zero',
              path: '/',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const ContentPage('page 0'),
              routes: [
                GoRoute(
                  name: 'one',
                  path: 'one',
                  parentNavigatorKey: _shellNavigatorKey,
                  builder: (context, state) => const ContentPage('page 1'),
                  routes: [
                    GoRoute(
                      name: 'two',
                      path: 'two',
                      parentNavigatorKey: _shellNavigatorKey,
                      builder: (context, state) => const ContentPage('page 2'),
                    ),
                  ],
                ),
              ],
            ),
          ]),
    ],
  );

  App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: title,
        routerConfig: _router,
        theme: ThemeData(colorSchemeSeed: Colors.white),
      );
}

class ShellNavigatorObserver extends NavigatorObserver {
  final controller = ShellPageController();

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _navChanged(route);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _navChanged(route);
  }

  void _navChanged(Route route) =>
      controller.navChanged(route.navigator?.canPop() ?? false);
}

class ShellPageController extends ChangeNotifier {
  bool _canPop = false;
  bool get canPop => _canPop;

  void navChanged(bool canPop) {
    _canPop = canPop;
    notifyListeners();
  }
}

class ShellPage extends StatefulWidget {
  final Widget child;
  final ShellPageController controller;

  const ShellPage({super.key, required this.child, required this.controller});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_navChanged);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_navChanged);
  }

  void _navChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: widget.controller.canPop
              ? BackButton(onPressed: context.pop)
              : const SizedBox(),
          title: const Text(App.title),
        ),
        body: Column(
          children: [
            Container(
              height: 100,
              color: Colors.yellow,
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 100,
                    color: Colors.red,
                    child: ListView(
                      children: [
                        ListTile(
                          onTap: () => context.goNamed('zero'),
                          title: const Text('zero'),
                        ),
                        ListTile(
                          onTap: () => context.goNamed('one'),
                          title: const Text('one'),
                        ),
                        ListTile(
                          onTap: () => context.goNamed('two'),
                          title: const Text('two'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: widget.child),
                  Container(
                    width: 100,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              color: Colors.green,
            ),
          ],
        ),
      );
}

class ContentPage extends StatelessWidget {
  const ContentPage(this.content, {super.key});

  final String content;

  @override
  Widget build(BuildContext context) => Center(child: Text(content));
}
