import 'package:flutter/material.dart';
import 'package:frontend/screens/splash_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/service_list_screen.dart';
import 'package:frontend/screens/book_appointmant_screen.dart';
import 'package:frontend/screens/book_comfirmation_screen.dart';
import 'package:frontend/screens/appointment_detail_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/appointment_provider.dart';
import 'package:frontend/models/service.dart';
import 'package:frontend/models/appointment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'Appointment Booking',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/services': (context) => const ServiceListScreen(),
          '/book-appointment': (context) {
            final service = ModalRoute.of(context)!.settings.arguments as Service;
            return BookAppointmentScreen(service: service);
          },
          '/confirmation': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return BookingConfirmationScreen(
              service: args['service'] as Service,
              appointment: args['appointment'] as Map<String, dynamic>,
            );
          },
          '/appointment-detail': (context) {
            final appointment = ModalRoute.of(context)!.settings.arguments as Appointment;
            return AppointmentDetailScreen(appointment: appointment);
          },
          '/edit-profile': (context) => const EditProfileScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}