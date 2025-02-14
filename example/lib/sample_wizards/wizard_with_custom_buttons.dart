import 'package:example/sample_wizards/child_pages.dart';
import 'package:flutter/material.dart';
import 'package:wizard_stepper/wizard_stepper.dart';

class WizardWithCustomButtons extends StatefulWidget {
  const WizardWithCustomButtons({super.key});

  @override
  WizardWithCustomButtonsState createState() => WizardWithCustomButtonsState();
}

class WizardWithCustomButtonsState extends State<WizardWithCustomButtons> {
  List<WizardStep> steps = [];
  String returnedValue = 'Sample';
  int currentStepIndex = 0;
  bool enableNextButton = false;
  bool enablePreviousButton = false;
  bool moveToNextStep = false;
  late WizardStepperController controller;

  @override
  void initState() {
    super.initState();

    controller = WizardStepperController(
      orientation: WizardStepperOrientation.vertical,
      position: WizardStepperPosition.left,
      onStepCompleted: (int stepNumber, bool isStepComplete) {
        updateButtonsState();
      },
      onSelectedStep: (int stepNumber) {
        updateButtonsState();
      },
      onMovedToNext: () {
        updateButtonsState();
      },
      onMovedToLastStep: () {
        updateButtonsState();

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FinalPage())
        );
      },
      onMovedToPrevious: () {
        updateButtonsState();
      },
      onWizardReset: () {
        updateButtonsState();
      }
    );
  }

  void updateButtonsState() {
    setState(() {
      enableNextButton = controller.canMoveToNextStep() || controller.allStepsCompleted();
      enablePreviousButton = controller.canMoveToPreviousStep();
    });
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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.arrow_back),
                  iconAlignment: IconAlignment.start,
                  onPressed: enablePreviousButton ? () {
                    controller.moveToPreviousStep();
                  } : null,
                  label: Text('Previous')
                ),

                ElevatedButton.icon(
                  icon: Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  onPressed: enableNextButton ? () {

                    if (controller.allStepsCompleted() && controller.isLastStep()) {
                      controller.moveToLastStep();
                    }
                    else {
                      controller.moveToNextStep();
                    }
                  } : null,
                  label: Text(controller.allStepsCompleted() && controller.isLastStep() ? 'Complete Wizard' : 'Next')
                ),
              ],
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