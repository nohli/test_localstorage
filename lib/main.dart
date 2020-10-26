import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalStorage storage = LocalStorage('test.json');
  Map _counter = {'counter': 0};
  bool _running = false;
  bool _error = false;

  Future<void> _startStop() async {
    _running = !_running;
    while (_running) {
      await Future.delayed(const Duration(milliseconds: 1));
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.ready,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData == true) {
          try {
            _counter = (storage.getItem('counter') ?? {'counter': 0}) as Map;
            _counter['counter']++;
            storage.setItem('counter', _counter);
          } catch (error) {
            debugPrint(error.toString());
            if (mounted) {
              setState(() {
                _running = false;
                _error = true;
              });
            }
          }
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Localstorage has successfully saved and loaded that many times:',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Text('${_counter['counter']}', style: Theme.of(context).textTheme.headline4),
                  const SizedBox(height: 10),
                  if (_error) const Icon(Icons.error, color: Colors.red),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _startStop,
              backgroundColor: Colors.green,
              child: _running ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
