import 'package:flutter/material.dart';
import 'package:flutter_scale_ruler/flutter_scale_ruler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Scale Ruler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Scale Ruler'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScaleValue? _scaleValue;
  ScaleValue? _scaleValueCms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${_scaleValue?.feet ?? "0"} Feet ${_scaleValue?.inch ?? "0"} inches",
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              ScaleRuler.lengthMeasurement(
                maxValue: 8,
                minValue: 0,
                initialValue: 4,
                isFeet: true,
                axis: Axis.vertical,
                stepIndicatorColor: Colors.brown,
                stepIndicatorDividerColor: Colors.blue,
                onChanged: (ScaleValue? scaleValue) {
                  if (mounted) {
                    setState(() {
                      _scaleValue = scaleValue;
                    });
                    debugPrint(
                        "${scaleValue?.feet} Feet ${scaleValue?.inch} inches");
                  }
                },
              ),
              const SizedBox(height: 20.0),
              ScaleRuler.lengthMeasurement(
                maxValue: 80,
                minValue: 0,
                initialValue: 40,
                axis: Axis.horizontal,
                backgroundColor: Colors.yellow[500]!,
                sliderActiveColor: Colors.green[500]!,
                sliderInactiveColor: Colors.greenAccent,
                onChanged: (ScaleValue? scaleValue) {
                  if (mounted) {
                    setState(() {
                      _scaleValueCms = scaleValue;
                    });
                    debugPrint("${scaleValue?.cms} cms");
                  }
                },
              ),
              const SizedBox(height: 20.0),
              Text(
                "${_scaleValueCms?.cms ?? "0"} cms",
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
