import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'equation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackgroundService.initialize(onStart);

  runApp(MyApp());
}

class Repository {
  List<Equation> equations = [];
}

final getListKey = 'getList';
void onStart() {
  List<Equation> equations = [];

  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();

  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
    if (event["action"] == "add") { 
       equations.add(Equation.fromJson(event['equation']));
          service.sendData({
            getListKey: json.encode(equations.map((e) => e.toJson()).toList())
          });
    
    }

    if (event["action"] == getListKey) {
      service.sendData(
          {getListKey: json.encode(equations.map((e) => e.toJson()).toList())});
    }
  });

  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (equations.length > 0) {
      equations.forEach((e) {
        if (e.time.second == DateTime.now().second) {
          // service.sendData({'equation': e.toJson()});
          service.setNotificationInfo(
              title: 'solved',
              content:
                  '${e.firstOpeartor} ${e.opeartor} ${e.secondOpeartor} = ${e.result}');
          // equations.remove(e);

          e.completed = true;
          service.sendData({
            getListKey: json.encode(equations.map((e) => e.toJson()).toList())
          });
        }
      });
    }

    if (!(await service.isServiceRunning())) timer.cancel();
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            // ElevatedButton(
            //   child: Text("Show completed"),
            //   onPressed: () {
            //     FlutterBackgroundService().sendData({
            //       "action": completedKey,
            //     });
            //   },
            // ),
            // ElevatedButton(
            //   child: Text("Show unompleted"),
            //   onPressed: () {
            //     FlutterBackgroundService().sendData({
            //       "action": unCompletedKey,
            //     });
            //   },
            // ),
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().onDataReceived,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                if (data[getListKey] != null) {
                  final List<Equation> list =
                      (json.decode(data[getListKey]) as List)
                          .map((e) => Equation.fromJson(e))
                          .toList();
                  return Column(children: [
                    
    //  ElevatedButton(
    //           child: Text("Show unompleted"),
    //           onPressed: () {
    //             FlutterBackgroundService().sendData({
    //               "action": unCompletedKey,
    //             });
    //           },
    //         ),

                    Text('Completed'),
                    for (final e in list.where((element) => element.completed))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('${e.firstOpeartor}'),
                          Text(e.opeartor),
                          Text('${e.secondOpeartor}'),
                          Text('='),
                          Text('${e.result}'),
                        ],
                      ),
                          Text('unCompleted'),
                    for (final e in list.where((element) => element.completed==false))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('${e.firstOpeartor}'),
                          Text(e.opeartor),
                          Text('${e.secondOpeartor}'),
                          Text('='),
                          Text('${e.result}'),
                        ],
                      )
                  ]);
                }

             
                return Text('com');
              },
            ),
            //   StreamBuilder<Map<String, dynamic>?>(
            //   stream: FlutterBackgroundService().onDataReceived,
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return Center(
            //         child: CircularProgressIndicator(),
            //       );
            //     }

            //     final data = snapshot.data!;

            //     if (data['unCompleted'] != null) {
            //       final List<Equation> list =
            //           (json.decode(data['unCompleted']) as List)
            //               .map((e) => Equation.fromJson(e))
            //               .toList();
            //       return Column(children: [
            //         Text('unCompleted'),
            //         for (final e in list)
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceAround,
            //             children: [
            //               Text('${e.firstOpeartor}'),
            //               Text(e.opeartor),
            //               Text('${e.secondOpeartor}'),
            //               Text('='),
            //               Text('${e.result}'),
            //             ],
            //           )
            //       ]);
            //     }
            //     return Text('');
            //   },
            // ),
            ElevatedButton(
              child: Text("First Equation"),
              onPressed: () {
                FlutterBackgroundService().sendData({
                  "action": "add",
                  'equation': Equation(
                          firstOpeartor: 2,
                          secondOpeartor: 3,
                          opeartor: '+',
                          time: DateTime.now().add(Duration(seconds: 10)))
                      .toJson()
                });
              },
            ),
            ElevatedButton(
              child: Text("Second Equation"),
              onPressed: () {
                FlutterBackgroundService().sendData({
                  "action": "add",
                  'equation': Equation(
                          firstOpeartor: 122,
                          secondOpeartor: 3,
                          opeartor: '-',
                          time: DateTime.now().add(Duration(seconds: 2)))
                      .toJson()
                });
              },
            ),
            ElevatedButton(
              child: Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService()
                    .sendData({"action": "setAsForeground"});
              },
            ),
            ElevatedButton(
              child: Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService()
                    .sendData({"action": "setAsBackground"});
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                var isRunning =
                    await FlutterBackgroundService().isServiceRunning();
                if (isRunning) {
                  FlutterBackgroundService().sendData(
                    {"action": "stopService"},
                  );
                } else {
                  FlutterBackgroundService.initialize(onStart);
                }
                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
