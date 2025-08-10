import 'package:feature_tooltip/src/feature_tooltip.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Demonstrates the usage of [FeatureTooltip].
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeatureTooltip Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeatureTooltip Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FeatureTooltip(
              message: 'This tooltip appears above. Tap to toggle.',
              direction: TooltipDirection.up,
              triggerMode: ToolTipTriggerMode.tap,
              backgroundColor: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              displayDuration: const Duration(seconds: 3),
              child: const Icon(Icons.info, size: 32),
            ),
            const SizedBox(height: 40),
            FeatureTooltip(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 4),
                  Text(
                    'Custom content with blur',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              direction: TooltipDirection.down,
              triggerMode: ToolTipTriggerMode.longPress,
              backgroundColor: Colors.deepPurple,
              blurBackground: true,
              arrowWidth: 16,
              arrowLength: 12,
              child: const Text(
                'Long press me',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}