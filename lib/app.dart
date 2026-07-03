import 'package:flutter/material.dart';
import 'package:moto_gp_schedule/core/constants/app_theme.dart';
import 'package:moto_gp_schedule/data/models/datasources/local/motogp_local_datasource.dart';
import 'package:moto_gp_schedule/presentation/screens/home/HomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:moto_gp_schedule/data/models/datasources/remot/motogp_remote_datasource.dart';
import 'package:moto_gp_schedule/data/models/datasources/repositories/motogp_repository.dart';
import 'package:moto_gp_schedule/presentation/providers/reminder_provider.dart';
import 'package:moto_gp_schedule/presentation/providers/schedule_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MotoGpRepository(
      remoteDataSource: MotoGpRemoteDataSource(),
      localDataSource: MotoGpLocalDataSource(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(repository: repository)
            ..loadSchedule(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(repository: repository)
            ..loadReminders(),
        ),
      ],
      child: MaterialApp(
        title: 'MotoGP Schedule',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: HomeScreen(),
        
        ),
      
    );
  }
}