import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/chat_bloc_bloc.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBlocBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eat Meh',
        theme: ThemeData(
          fontFamily: "Poppins",
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Bar(),
      ),
    );
  }
}
