import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:alzaware/result.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:toast/toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flython/flython.dart';
import 'package:path_provider/path_provider.dart';

import 'Basic Resources/LoadingWidget.dart';
import 'model/wav_response_model.dart';

class PredictAlzAware extends StatefulWidget {
  final String uId, recordCount;

  const PredictAlzAware(this.uId, this.recordCount, {super.key});

  @override
  State<PredictAlzAware> createState() =>
      _PredictAlzAwareState(uId, recordCount);
}

class _PredictAlzAwareState extends State<PredictAlzAware> {
  final voiceRecord = AudioRecorder();
  final audioPlayer = AudioPlayer();
  final Logger logger = Logger();
  final Dio dio = Dio();
  int timerSeconds = 0, timerMinutes = 0, recordingCount = 0;
  List<int> audioData = [];
  String uId,
      recordCount,
      timerSecondsString = "00",
      timerMinutesString = "00",
      alzValue = "";
  Timer? timer;
  bool isPlayingStarted = false, detailsLoaded = false, isPredicting = false;
  var userData;

  String completeFileName = "${DateTime.now().microsecondsSinceEpoch}.wav";
  String filePath = "";
  bool hasSpeech = false;
  _PredictAlzAwareState(this.uId, this.recordCount);
  bool _isPlaying = false;
  @override
  void initState() {
    runPython();
    detailsLoaded = true;
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    voiceRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void runPython() async {
    final opencv = OpenCV();
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.py');
    await file.writeAsString("print('hello world')");
    String fileContent = await file.readAsString();
    print(fileContent);
    await opencv.initialize("python", '${directory.path}/my_file.py', false);
    await opencv.toGray();
    opencv.finalize();
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

  void timerPause() {
    timer?.cancel();
    setState(() {});
  }

  void timerStop() {
    timer?.cancel();
    timerMinutes = 0;
    timerSeconds = 0;
    timerMinutesString = "00";
    timerSecondsString = "00";
    setState(() {});
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play(DeviceFileSource(filePath));
    }
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> uploadRecordingInServer({required String filePath}) async {
    print("======>${filePath.split("/").last}");
    File file = File(filePath);
    var storage = FirebaseStorage.instance;
    recordingCount++;
    var uploaded = await storage
        .ref()
        .child(uId)
        .child("/recording$recordingCount.wav")
        .putFile(file);
    var dbInstance = FirebaseDatabase.instance;
    String recordingUrl = await uploaded.ref.getDownloadURL();
    alzValue = Random().nextInt(101).toString();
    var dbVal = {
      "recordingUrl": recordingUrl,
      "alzValue": alzValue,
      "timestemp": DateTime.now().millisecondsSinceEpoch
    };
    await dbInstance
        .ref()
        .child(uId)
        .child("/recordings/recording$recordingCount")
        .set(dbVal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Predict"),
      ),
      body: detailsLoaded
          ? !isPredicting
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor, // Border color
                            width: 2.0, // Border width
                          ),
                        ),
                        child: Image.asset(
                          "assets/images/Predication.png",
                          height: 250,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Please describe the picture above",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(80)),
                          border: Border.all(width: 4, color: Colors.black45),
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Icon(
                              Icons.mic,
                              color: Colors.red,
                            ),
                            Text(
                              "$timerMinutesString : $timerSecondsString",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 36),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(10.0),
                              ),
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
                                        const RecordConfig(
                                            encoder: AudioEncoder.wav),
                                        path:
                                            '${tempDir.path}/$completeFileName');

                                    timerStart();
                                  }
                                }
                              },
                              child: const Text("Record"),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(10.0),
                              ),
                              onPressed: () async {
                                bool recording =
                                    await voiceRecord.isRecording();
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
                              child: const Text("Pause"),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(10.0),
                              ),
                              onPressed: () async {
                                bool recording =
                                    await voiceRecord.isRecording();
                                print(recording);

                                String? path = await voiceRecord.stop();
                                print("A..L..O..K... $path");

                                timerStop();
                                setState(() {
                                  filePath = path ?? "";
                                });
                              },
                              child: const Text("Stop"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      filePath.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  color: Theme.of(context).primaryColor,
                                ),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      height: 50,
                                      child: Image.asset(
                                        'assets/images/sound_wave.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _togglePlayback();
                                      },
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await audioPlayer.stop();
                                        _isPlaying = false;
                                        setState(() {});
                                      },
                                      icon: _isPlaying
                                          ? const Icon(
                                              Icons.stop,
                                              color: Colors.red,
                                              size: 30,
                                            )
                                          : SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(10.0),
                          ),
                          onPressed: () async {
                            isPredicting = true;
                            setState(() {});
                            // await uploadRecordingInServer(filePath: filePath);
                            await uploadRecording(audioPath: filePath);
                          },
                          child: const Text("Predict"),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )
              : LoadingWidget("Detecting Alzheimers")
          : LoadingWidget("Setting Up Recorder"),
    );
  }

  Future<void> uploadRecording({required String audioPath}) async {
    if (audioPath.isEmpty) {
      isPredicting = false;
      Toast.show("Please record audio first. file not found!",
          textStyle: const TextStyle(
            color: Colors.red,
          ),
          backgroundColor: Colors.white,
          duration: Toast.lengthLong);
      return;
    }

    final formData = FormData.fromMap({
      'wav_file': await MultipartFile.fromFile(audioPath,
          filename: audioPath.split('/').last),
    });

    final response = await dio
        .post('http://23.21.157.18:5000/model_file_upload', data: formData);
    print("response => ${response.data}");
    WavResponseModel model = WavResponseModel.fromJson(response.data);

    print(model.toJson());

    isPredicting = false;
    filePath = '';
    setState(() {});
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultAlzAware("${model.responseCode}")));
  }
}

/*class SoundRecorder {
  final record = AudioRecorder();
  bool isInitialized = false, isRecorded = false;

  Future<bool> get isRecording async => await record.isRecording();

  Future<bool> get isPaused async => await record.isPaused();

  Future init() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Recording permission not granted");
    }

    var permission = await record.hasPermission();

    print(permission);

    isInitialized = true;
  }

  Future dispose() async {
    record.dispose();
    isInitialized = false;
  }

  Future recordStart() async {
    // Check and request permission if needed
    if (await record.hasPermission()) {
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      // Start recording to file
      await record.start(const RecordConfig(),
          path:
              '${appDocDirectory.path}/records/${DateTime.now().millisecondsSinceEpoch}');
      // ... or to stream
    }
    isRecorded = false;
  }

  Future recordStop() async {
    String? data = await record?.stop();
    print("A..L..O..K...");
    print("data => $data");
    isRecorded = true;
  }

  Future recordPause() async {
    await record!.pause();
  }

  Future recordResume() async {
    await record!.resume();
  }
}

class AppAudioPlayer {
  FlutterSoundPlayer? audioPlayer;
  bool isInitialized = false, isDone = false, isFinished = false;

  bool get isPlaying => audioPlayer!.isPlaying;

  bool get isPaused => audioPlayer!.isPaused;
  final player = AudioPlayer();
  Future init() async {
    audioPlayer = FlutterSoundPlayer();
    await audioPlayer!.openAudioSession();
    isInitialized = true;
  }

  Future dispose() async {
    await audioPlayer!.closeAudioSession();
    audioPlayer = null;
    isInitialized = false;
  }

  Future audioPlay(VoidCallback whenFinished) async {
    await player.play(DeviceFileSource(
        "/data/user/0/com.impeccablecreations.alzaware/app_flutter/records/1693249609302.wav"));
*/ /*    await audioPlayer!.startPlayer(
      fromURI: "recording.wav",
      whenFinished: whenFinished,
    );*/ /*
  }

  Future audioStop() async {
    await audioPlayer!.stopPlayer();
  }

  Future audioPause() async {
    await audioPlayer!.pausePlayer();
  }

  Future audioResume() async {
    await audioPlayer!.resumePlayer();
  }
}*/

class OpenCV extends Flython {
  //static const cmdToGray = 1;

  Future<dynamic> toGray(
      //String inputFile,
      //String outputFile,
      ) async {
    var command = {
      //"cmd": cmdToGray,
      //"input": inputFile,
      //"output": outputFile,
    };
    print("togray");
    return await runCommand(command);
  }
}
