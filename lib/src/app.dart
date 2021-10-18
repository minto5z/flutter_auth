import 'package:auth/src/app_router.dart';
import 'package:auth/src/features/auth/logic/cubit/auth_cubit.dart';
import 'package:auth/src/features/auth/logic/models/user.dart';
import 'package:auth/src/features/auth/logic/repository/auth_repository.dart';
import 'package:auth/src/features/home/views/screens/home_screen.dart';
import 'package:auth/src/features/notification/views/widgets/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> materialKey = GlobalKey();

  final appRouter = AppRouter();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _InitProviders(
      child: Stack(
        children: [
          MaterialApp(
            navigatorKey: MyApp.materialKey,
            debugShowCheckedModeBanner: false,
            initialRoute: HomeScreen.routeName,
            onGenerateRoute: appRouter.onGenerateRoute,
            theme: ThemeData(
              primaryColor: Color(0xff4C525C),
              secondaryHeaderColor: Color(0xffFFAE48),
              highlightColor: Color(0xff58BFE6),
            ),
          ),
          NotificationHandler(),
        ],
      ),
    );
  }
}

class _InitProviders extends StatelessWidget {
  final Widget child;

  const _InitProviders({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(
          authRepository: context.read<AuthRepository>(),
        ),
        child: BlocListener<AuthCubit, User?>(
          listenWhen: (prev, curr) => prev != null && curr == null,
          listener: (context, user) {
            final route = ModalRoute.of(context)?.settings.name;

            if (user == null && route != HomeScreen.routeName) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.routeName,
                (route) => false,
              );
            }
          },
          child: child,
        ),
      ),
    );
  }
}
