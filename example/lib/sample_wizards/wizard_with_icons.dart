import 'package:example/sample_wizards/child_pages.dart';
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