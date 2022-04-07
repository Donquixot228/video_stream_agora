

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

const appId= '25749d2e1889404c94d32f26824173f7';
const token='00625749d2e1889404c94d32f26824173f7IAA/D8iGaY9hFerQAqNJVkHvf//9L2jvhxRkkSN1JRqeQdzDPrsAAAAAEAB5z62Rk4pQYgEAAQCSilBi';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter VideoStream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const MyHomePage( 'Agora video stream'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.title);

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int? _remoteUid;
  late RtcEngine _engine;
  @override
  void initState() {
    super.initState();
    initForAgora();
  }
  Future<void> initForAgora()async{
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(null, "firstchannel", null, 0);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: _renderRemoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: _renderLocalPreview(),
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _renderLocalPreview(){
    return Transform.rotate(angle: 90 * pi/180,child: RtcLocalView.SurfaceView() ,);
  }
  Widget _renderRemoteVideo(){
    if(_remoteUid != null){
      return RtcRemoteView.SurfaceView(uid: _remoteUid!,channelId: 'firstchannel',);
    }else{
      return const Text(
        'PLease wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}
