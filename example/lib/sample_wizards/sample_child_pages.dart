import 'package:wizard_stepper/wizard_stepper.dart';
import 'package:flutter/material.dart';

class OneStep extends StatelessWidget with WizardStep {
  OneStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ValueListenableBuilder<bool>(
          valueListenable: isCompleteNotifier,
          builder: (context, isComplete, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'I am step ${stepNumber + 1} and I am ${isComplete ? 'complete' : 'incomplete'}',
                    style: Theme.of(context).textTheme.headlineMedium),
                TextButton(
                    onPressed: () {
                      completeStep(true);
                    },
                    child: Text('Press me'))
              ],
            );
          }),
    );
  }
}

class SomeStep extends StatelessWidget with WizardStep {
  SomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('I am another step right here',
              style: Theme.of(context).textTheme.headlineMedium),
          TextButton(
              onPressed: () {
                completeStep(true);
              },
              child: Text('Click me please!')),
          TextButton(
              onPressed: () {
                completeStep(false);
              },
              child: Text('disable it!')),
        ],
      ),
    );
  }
}

class FinalPage extends StatelessWidget with WizardStep {
  FinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Final Page!!!')));
  }
}
