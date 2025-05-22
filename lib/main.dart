import 'package:ed_repair/pages/AddOrders.dart';
import 'package:ed_repair/pages/EditProfile.dart';
import 'package:ed_repair/pages/FeedbackPage.dart';
import 'package:ed_repair/pages/LoginSelectionPage.dart';
import 'package:ed_repair/pages/ManageServiceCenterPage.dart';
import 'package:ed_repair/pages/ProfilePage.dart';
import 'package:ed_repair/pages/ResetSucessPage.dart';
import 'package:ed_repair/pages/ServiceOptionsPage.dart';
import 'package:ed_repair/pages/VerifyPassPage.dart';
import 'package:flutter/material.dart';

void main(){
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'ED Repair',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ServiceOptionsPage()
    );
  }
}