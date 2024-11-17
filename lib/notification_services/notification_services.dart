
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/message_screen.dart';

class NotificationServices{
  // cresting instance of firebase messaging
  FirebaseMessaging messaging=FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    // declaring notification setting to request permission
    NotificationSettings settings=await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      sound: true,
      provisional: true
    );

    // checking condition weather user authorize it or not
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      // thiis is for android
      print('user granted permission');
    }else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      // provisional is for iphone
      print('user granted provisional permission');
    }else{
      print('user not granted permission');
    }
  }

  void initLocalNotification(BuildContext context, RemoteMessage message)async{
    // initializing android and ios settings
    var androidInitializationSetting=const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSetting=const DarwinInitializationSettings();

    // assign these settings in InitializationSettings parameter android and ios
    var inializationSetting=InitializationSettings(
      android: androidInitializationSetting,
      iOS: iosInitializationSetting
    );

    // now call initialize function through FlutterLocalNotificationsPlugin object and assign
    // InitializationSettings
    await _flutterLocalNotificationsPlugin.initialize(
      inializationSetting,
      // payload is extra data that is required to send like id title body these are also payload
      onDidReceiveNotificationResponse: (payload){
        handleMessage(context, message);
      }
    );
  }

  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel channel=AndroidNotificationChannel(
      // id
        Random.secure().nextInt(100000).toString(),
        // name
        'High importance Notification',
        // importance
        importance: Importance.max
    );

    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker'
    );

    // its not compulsory bcz firebase dont use this for ios notification
    const DarwinNotificationDetails darwinNotificationDetails=DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true
    );

    // providing details of android and ios in notification detail
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
      );
    }

    );


  }


  // this funtion is called in init function of homeScreen
  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message){
      if(Platform.isAndroid){
        initLocalNotification(context, message);
        showNotification(message);

        print(message.data.toString());
        print(message.data['type'].toString());
        print(message.data['id'].toString());
      }else{
        showNotification(message);
      }
    });
  }

  // function to handle when notification recieves when we click it redirect to that screen
  void handleMessage(BuildContext context,RemoteMessage message){
    if(message.data['type']=='message'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MessageScreen(id: message.data['id'],)));
    }
  }

  // function to handle notification when app is in background or terminated
  Future<void> hanldeIntractMessage(BuildContext context)async{
    RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();

    // when app is terminated
    if(initialMessage != null){
       handleMessage(context, initialMessage);
    }
    //   when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event){
      handleMessage(context, event);
    });
  }


  // function to get device token from android
  Future<String> getDeviceToken()async{
    String? token=await messaging.getToken();
    return token!;
  }

  // fuction to check token is refreshed or not
  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event){
      event.toString();
      print('refreshed');
    });
  }



}