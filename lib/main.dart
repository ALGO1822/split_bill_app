import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_bill_app/cubit/split_bill_cubit.dart';
import 'package:split_bill_app/presentation/screens/split_bill_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplitBillCubit(),
      child: MaterialApp(
        title: 'Split Bill Calculator',
        debugShowCheckedModeBanner: false,
        home: SplitBillScreen(),
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
      ),
    );
  }
}
