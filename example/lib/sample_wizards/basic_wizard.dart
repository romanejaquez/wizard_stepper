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

    controller = WizardStepperController(
      orientation: WizardStepperOrientation.vertical,
      position: WizardStepperPosition.left,
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
            Expanded(
              child: WizardStepper(
                controller: controller,
                steps: [
                  OneStep(),
                  OneStep(),
                  OneStep(),
                  SomeStep(),
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