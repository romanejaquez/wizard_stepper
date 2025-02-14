import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizard_stepper/wizard_stepper.dart';

// Mock WizardStep widget
class MockWizardStep extends StatelessWidget with WizardStep {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


void main() {
  group('WizardStepperController Tests', () {
    late WizardStepperController controller;
    late List<WizardStep> steps;

    setUp(() {
      steps = List.generate(3, (index) => MockWizardStep());
      controller = WizardStepperController();
    });

    test('Initialize controller', () {
      controller.initialize(steps);
      expect(controller.steps.length, 3);
      expect(controller.currentStepIndex, 0);
      expect(controller.currentStep, steps[0]);
      expect(steps[0].stepNumber, 0);
      expect(steps[1].stepNumber, 1);
      expect(steps[2].stepNumber, 2);
    });

    test('Initialize controller with icons', () {
      final icons = [Icons.abc, Icons.ac_unit, Icons.abc_sharp];
      controller.initialize(steps, wizardStepIcons: icons);
      expect(controller.stepIcons.length, 3);
      expect(controller.stepIcons, icons);
    });

    test('Initialize controller with widgets', () {
      final widgets = [Container(), Container(), Container()];
      controller.initialize(steps, wizardStepWidgets: widgets);
      expect(controller.stepWidgets.length, 3);
      expect(controller.stepWidgets, widgets);
    });


    test('Initial state', () {
      controller.initialize(steps);
      expect(controller.isFirstStep(), true);
      expect(controller.isLastStep(), false);
      expect(controller.canMoveToNextStep(), false); // Initially incomplete
      expect(controller.canMoveToPreviousStep(), false);
    });

    test('Move to next step', () {
      controller.initialize(steps);
      controller.currentStep!.completeStep(true); // Complete the first step
      controller.moveToNextStep();
      expect(controller.currentStepIndex, 1);
      expect(controller.currentStep, steps[1]);
      expect(controller.isFirstStep(), false);
      expect(controller.isLastStep(), false);
    });


    test('Move to previous step', () {
      controller.initialize(steps);
      controller.currentStep!.completeStep(true);
      controller.moveToNextStep();
      controller.moveToPreviousStep();
      expect(controller.currentStepIndex, 0);
      expect(controller.currentStep, steps[0]);
    });

    test('Move to last step', () {
      controller.initialize(steps);
      bool movedToLastStep = false;
      controller.onMovedToLastStep = () => movedToLastStep = true;

      for (var step in steps) {
        step.completeStep(true);
        if (!controller.isLastStep()) {
          controller.moveToNextStep();
        }
      }
      controller.moveToLastStep(); // Explicitly call moveToLastStep
      expect(movedToLastStep, true);
    });

    test('Complete all steps', () {
      controller.initialize(steps);
      for (var step in steps) {
        step.completeStep(true);
        if (!controller.isLastStep()) {
          controller.moveToNextStep();
        }
      }
      expect(controller.allStepsCompleted(), true);
      expect(controller.isLastStep(), true);
    });

    test('Reset wizard', () {
      controller.initialize(steps);
      steps[0].completeStep(true);
      controller.moveToNextStep();
      controller.resetWizard();
      expect(controller.currentStepIndex, 0);
      expect(steps[0].isComplete, false);
      expect(steps[1].isComplete, false);
      expect(controller.isFirstStep(), true);
    });

    test('onStepSelected callback', () {
      controller.initialize(steps);
      int selectedStep = -1;
      controller.onSelectedStep = (stepNum) => selectedStep = stepNum;
      steps[0].completeStep(true);
      controller.onStepSelected(0);
      expect(selectedStep, 0);
    });

    test('Stream steps event', () async{
      controller.initialize(steps);
      final event = await controller.stepChanges.first;
      expect(event.steps.length, steps.length);
    });

    test('Switch orientation', () {
      controller.initialize(steps);
      expect(controller.orientation, WizardStepperOrientation.horizontal);
      expect(() => controller.switchOrientation(WizardStepperOrientation.vertical, WizardStepperPosition.top), throwsException);
      expect(controller.orientation, WizardStepperOrientation.vertical);
      expect(() => controller.switchOrientation(WizardStepperOrientation.horizontal, WizardStepperPosition.left), throwsException);

      controller.switchOrientation(WizardStepperOrientation.vertical, WizardStepperPosition.left);
      expect(controller.orientation, WizardStepperOrientation.vertical);
      expect(controller.position, WizardStepperPosition.left);
    });

     test('Throws exception for invalid horizontal orientation', () {
      controller = WizardStepperController(
        orientation: WizardStepperOrientation.horizontal,
        position: WizardStepperPosition.left);
      expect(() => controller.initialize(steps), throwsException);
    });

    test('Throws exception for invalid vertical orientation', () {
      controller = WizardStepperController(
        orientation: WizardStepperOrientation.vertical,
        position: WizardStepperPosition.top);
      expect(() => controller.initialize(steps), throwsException);
    });

    test('Throws exception for empty steps', () {
       expect(() => controller.initialize([]), throwsException);
    });

    test('Throws exception for unequal steps and icons', () {
      final icons = [Icons.abc, Icons.ac_unit];
      expect(() => controller.initialize(steps, wizardStepIcons: icons), throwsException);
    });

    test('Throws exception for unequal steps and stepWidgets', () {
      final widgets = [Container(), Container()];
      expect(() => controller.initialize(steps, wizardStepWidgets: widgets), throwsException);
    });

    test('Dispose controller', () {
      controller.initialize(steps);
      expect(controller.stepChangesController.isClosed, false);
      controller.dispose();
      expect(controller.stepChangesController.isClosed, true);
    });
  });
}
