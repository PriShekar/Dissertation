import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:alzaware/Basic%20Resources/LoadingWidget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:toast/toast.dart';

class JournalAlzAware extends StatefulWidget {
  String uId;

  JournalAlzAware(this.uId, {super.key});

  @override
  State<JournalAlzAware> createState() => _JournalAlzAwareState();
}

class _JournalAlzAwareState extends State<JournalAlzAware> {
  var storage = FirebaseStorage.instance;
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioRecorder voiceRecord = AudioRecorder();
  List<bool> playingValList = [], isPlayingStarted = [];
  bool fileInitialized = false, detailsLoaded = false;
  List<Map<String, dynamic>> recordingUrls = [];
  List<File> recordings = [];
  var userData;
  String filePath = "";

  String timerSecondsString = "00", timerMinutesString = "00", alzValue = "";
  int timerSeconds = 0, timerMinutes = 0, recordingCount = 0;
  Timer? timer;
  String completeFileName = "${DateTime.now().microsecondsSinceEpoch}.wav";

  void firebaseInit() {
    FirebaseDatabase fbData = FirebaseDatabase.instance;
    fbData.ref().child(widget.uId).once().then((res) {
      userData = res.snapshot.value;
      print("userData ==> $userData");
      if (userData["recordings"] != null) {
        recordingCount = userData["recordings"].keys.length;
        recordingUrls.clear();
        playingValList.clear();
        isPlayingStarted.clear();
        for (int i = userData["recordings"].keys.length - 1; i >= 0; i--) {
          print(
              "Data url => ${userData["recordings"].values.elementAt(i)["recordingUrl"]} time => ${userData["recordings"].values.elementAt(i)["timestemp"]}");

          recordingUrls.add({
            "url": userData["recordings"].values.elementAt(i)["recordingUrl"],
            "time": userData["recordings"].values.elementAt(i)["timestemp"]
          });
          playingValList.add(false);
          isPlayingStarted.add(false);
        }
      }
      detailsLoaded = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    firebaseInit();
    super.initState();
  }

  @override
  void dispose() {
    voiceRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> uploadRecordingInServer({required String filePath}) async {
    detailsLoaded = false;
    setState(() {});
    File file = File(filePath);
    var storage = FirebaseStorage.instance;
    recordingCount++;
    var uploaded = await storage
        .ref()
        .child("${FirebaseAuth.instance.currentUser?.uid}")
        .child("/recording_$recordingCount")
        .putFile(file);
    var dbInstance = FirebaseDatabase.instance;
    String recordingUrl = await uploaded.ref.getDownloadURL();
    String alzValue = Random().nextInt(101).toString();
    var dbVal = {
      "recordingUrl": recordingUrl,
      "alzValue": alzValue,
      "timestemp": DateTime.now().millisecondsSinceEpoch
    };
    await dbInstance
        .ref()
        .child("${FirebaseAuth.instance.currentUser?.uid}")
        .child("/recordings/recording$recordingCount")
        .set(dbVal);

    firebaseInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journals"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$timerMinutesString : $timerSecondsString",
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor, // Border color
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                        onPressed: () async {
                          bool recording = await voiceRecord.isRecording();
                          if (recording) {
                            await voiceRecord.pause();

                            timerPause();
                          } else {
                            Toast.show("Please start recording!",
                                textStyle: const TextStyle(
                                  color: Colors.red,
                                ),
                                backgroundColor: Colors.white,
                                duration: Toast.lengthLong);
                          }
                        },
                        icon: const Icon(Icons.pause))),
                Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor, // Border color
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                        onPressed: () async {
                          bool paused = await voiceRecord.isPaused();
                          if (paused) {
                            await voiceRecord.resume();

                            timerStart();
                          } else {
                            final Directory tempDir =
                                await getTemporaryDirectory();
                            if (await voiceRecord.hasPermission()) {
                              await voiceRecord.start(
                                  const RecordConfig(encoder: AudioEncoder.wav),
                                  path: '${tempDir.path}/$completeFileName');

                              timerStart();
                            }
                          }
                        },
                        icon: Icon(
                          Icons.mic,
                          color: Theme.of(context).primaryColor,
                        ))),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor, // Border color
                      width: 1.0,
                    ),
                  ),
                  child: IconButton(
                      onPressed: () async {
                        bool recording = await voiceRecord.isRecording();
                        print(recording);

                        String? path = await voiceRecord.stop();
                        print("A..L..O..K... $path");

                        timerStop();
                        setState(() {
                          filePath = path ?? "";
                        });
                        if (filePath.isNotEmpty) {
                          uploadRecordingInServer(filePath: filePath);
                        }
                      },
                      icon: Icon(
                        Icons.stop,
                        color: Colors.red,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
      body: detailsLoaded
          ? recordingUrls.isNotEmpty
              ? ListView.builder(
                  itemCount: recordingUrls.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        tileColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: isPlayingStarted[i]
                            ? Image.asset(
                                'assets/images/run_sounde_wave.gif',
                                height: 40,
                              )
                            : Text(
                                "Recording${i + 1} - ${(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(recordingUrls[i]['time'])))}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        trailing: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  playingValList[i]
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  if (playingValList[i]) {
                                    audioPlayer.pause().then((res) {
                                      playingValList[i] = false;
                                      setState(() {});
                                    });
                                  } else {
                                    if (isPlayingStarted[i]) {
                                      audioPlayer.resume().then((res) {
                                        playingValList[i] = true;
                                        setState(() {});
                                      });
                                    } else {
                                      for (int i = 0;
                                          i < playingValList.length;
                                          i++) {
                                        playingValList[i] = false;
                                        isPlayingStarted[i] = false;
                                      }
                                      setState(() {});
                                      audioPlayer
                                          .play(UrlSource(
                                              recordingUrls[i]['url']))
                                          .then((res) {
                                        playingValList[i] = true;
                                        isPlayingStarted[i] = true;
                                        setState(() {});
                                      });
                                    }

                                    audioPlayer.onPlayerComplete
                                        .listen((event) {
                                      setState(() {
                                        playingValList[i] = false;
                                        isPlayingStarted[i] = false;
                                      });
                                    });
                                  }
                                },
                              ),
                              isPlayingStarted[i]
                                  ? IconButton(
                                      onPressed: () {
                                        audioPlayer.stop().then((res) {
                                          playingValList[i] = false;
                                          isPlayingStarted[i] = false;
                                          setState(() {});
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.stop,
                                        color: Colors.red,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text("No data found!"),
                )
          : LoadingWidget("Fetching Recordings"),
    );
  }

  void timerStop() {
    timer?.cancel();
    timerMinutes = 0;
    timerSeconds = 0;
    timerMinutesString = "00";
    timerSecondsString = "00";
    setState(() {});
  }

  void timerPause() {
    timer?.cancel();
    setState(() {});
  }

  void timerStart() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        timerSeconds++;
        if (timerSeconds == 60) {
          timerMinutes++;
          timerSeconds = 0;
        }
        if (timerSeconds > 9) {
          timerSecondsString = "$timerSeconds";
        } else {
          timerSecondsString = "0$timerSeconds";
        }
        if (timerMinutes > 9) {
          timerMinutesString = "$timerMinutes";
        } else {
          timerMinutesString = "0$timerMinutes";
        }
        setState(() {});
      });
    } else {
      if (!timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          timerSeconds++;
          if (timerSeconds == 60) {
            timerMinutes++;
            timerSeconds = 0;
          }
          if (timerSeconds > 9) {
            timerSecondsString = "$timerSeconds";
          } else {
            timerSecondsString = "0$timerSeconds";
          }
          if (timerMinutes > 9) {
            timerMinutesString = "$timerMinutes";
          } else {
            timerMinutesString = "0$timerMinutes";
          }
          setState(() {});
        });
      }
    }
  }
}
