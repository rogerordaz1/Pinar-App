import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<HomeCubit>()..loadHome()),
        // Agregar futuros cubits aquí:
        // BlocProvider(create: (_) => di.sl<BusquedaCubit>()),
      ],
      child: const App(),
    ),
  );
}
