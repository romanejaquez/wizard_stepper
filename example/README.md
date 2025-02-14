# Wizard Stepper Example

Below are two examples on how to use the ```wizard_stepper``` package in your applications.
For more examples, go to the provided ```example``` folder.

## Basic Wizard

Create a StatefulWidget and its ```initState```, instantiate a ```WizardStepperController``` controller; use it straight out of the box with the default values or override it with your own options.

```dart

import 'package:example/sample_wizards/sample_child_pages.dart';
import 'package:flutter/material.dart';
import 'package:wizard_stepper/wizard_stepper.dart';

class BasicWizard extends StatefulWidget {
  const BasicWizard({super.key});

  @override
  BasicWizardState createState() => BasicWizardState();
}

class BasicWizardState extends State<BasicWizard> {

  late WizardStepperController controller;

  @override
  void initState() {
    super.initState();

    // STEP 1: INSTANTIATE A WIZARD STEPPER CONTROLLER
    // default orientation is vertical
    // default position is left,

    controller = WizardStepperController(
      showNavigationButtons: true,
      onMovedToLastStep: () {
         Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FinalPage())
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // STEP 2: CREATE THE WIZARDSTEPPER WIDGET
            // Provide the instantiated controller above
            // as well as the steps you want to display
            // within your wizard
            Expanded(
              child: WizardStepper(
                controller: controller,
                steps: [
                  OneStep(),
                  OneStep(),
                  OneStep(),
                  OneStep(),
                  OneStep(),
                ],
              )
            ),

            SizedBox(height: 32),
            
            // (optional): you can control some of the functions in the wizard
            // via the controller instance (i.e. resetting the wizard)
            ElevatedButton(onPressed: () {
              controller.resetWizard();
            }, child: Text('Reset Wizard')),
          ],
        ),
      )
    );
  }
}
```

Make sure the child pages that will represent your steps in the wizard use the available ```WizardStep``` mixin to be part of the wizard.

```dart

/// Pretty much widget can be a step in the WizardStepper, and to tap 
/// into the capabilities of the WizardStepper (i.e. listen for when the step is complete, when it becomes the current step. etc.)
/// then you should add the WizardStep mixin to your widget.

class OneStep extends StatelessWidget with WizardStep {
  OneStep({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ValueListenableBuilder<bool>(

        // isCompleteNotifier available via the WizardStep mixin
        // which you can use to listen to when the step has been flagged as completed
        valueListenable: isCompleteNotifier,
        builder: (context, isComplete, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // both stepNumber and isComplete are available via the WizardStep mixin
              // which you can use to get your index in the wizard steps
              // as well as its completion status respectively
              
              Text('I am step ${stepNumber + 1} and I am ${isComplete ? 'complete' : 'incomplete'}', 
                style: Theme.of(context).textTheme.headlineMedium),

              TextButton(onPressed: () {

                // completeStep is available via the WizardStep mixin
                // which you can use from inside your step widget to trigger
                // its completion 
                completeStep(true);
              }, 
              child: Text('Press me'))
            ],
          );
        }
      ),
    );
  }
}

```

## Wizard with Icons

```dart

import 'package:example/sample_wizards/sample_child_pages.dart';
import 'package:flutter/material.dart';
import 'package:wizard_stepper/wizard_stepper.dart';

class WizardWithIcons extends StatefulWidget {
  const WizardWithIcons({super.key});

  @override
  WizardWithIconsState createState() => WizardWithIconsState();
}

class WizardWithIconsState extends State<WizardWithIcons> {

  late WizardStepperController controller;

  @override
  void initState() {
    super.initState();

    // STEP 1: INSTANTIATE A WIZARD STEPPER CONTROLLER
    // customize it using the available properties
    // and tap into any of the callbacks provided
    controller = WizardStepperController(
      orientation: WizardStepperOrientation.vertical,
      position: WizardStepperPosition.right,
      showNavigationButtons: true,
      currentStepColor: Colors.deepPurpleAccent,
      completedStepColor: Colors.pinkAccent,
      onMovedToLastStep: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FinalPage())
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // STEP 2: CREATE THE WIZARDSTEPPER WIDGET
            // Provide the instantiated controller above
            // as well as the steps you want to display
            // within your wizard, and the icons you want to use
            // instead of the default wizard step indicators
            // NOTE: ADD THE SAME NUMBER OF STEPS AND ICONS
            Expanded(
              child: WizardStepper(
                controller: controller,
                stepIcons: const [
                  Icons.ac_unit,
                  Icons.house,
                  Icons.account_circle,
                  Icons.bus_alert,
                  Icons.wind_power,
                  Icons.airline_seat_flat,
                ],
                steps: [
                  OneStep(),
                  OneStep(),
                  OneStep(),
                  OneStep(),
                  OneStep(),
                ],
              )
            ),
            
            SizedBox(height: 32),

            ElevatedButton(onPressed: () {
              controller.resetWizard();
            }, child: Text('Reset Wizard')),
          ],
        ),
      )
    );
  }
}

```
