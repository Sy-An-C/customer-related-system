// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frontend/providers/auth_provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     final authProvider = context.read<AuthProvider>();
//     await authProvider.initialize();
    
//     if (!mounted) return;
    
//     if (authProvider.isAuthenticated) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blueAccent, Colors.lightBlueAccent],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.calendar_today,
//                 size: 80,
//                 color: Colors.white,
//               ),
//               const SizedBox(height: 30),
//               const CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation(Colors.white),
//                 strokeWidth: 3,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Appointment Booking',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 10,
//                       color: Colors.black.withOpacity(0.2),
//                       offset: const Offset(2, 2),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}