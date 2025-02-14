import 'package:example/sample_wizards/sample_child_pages.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:wizard_stepper/wizard_stepper.dart';

class WizardWithAnimatedIcons extends StatefulWidget {
  const WizardWithAnimatedIcons({super.key});

  @override
  State<WizardWithAnimatedIcons> createState() => _WizardWithAnimatedIconsState();
}

class _WizardWithAnimatedIconsState extends State<WizardWithAnimatedIcons> {
  late WizardStepperController controller;

  @override
  void initState() {
    super.initState();

    controller = WizardStepperController(
      orientation: WizardStepperOrientation.horizontal,
      position: WizardStepperPosition.top,
      showNavigationButtons: true,
      stepIconSize: 60,
      dividerRadius: 20,
      currentStepColor: Color(0xFF481878),
      completedStepColor: Color(0xFFFF7676),
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
                stepWidgets: List.generate(RiveIcons.values.length, (index) {
                  return RiveIconWrapper(
                    stepStream: controller.stepChanges, 
                    icon: RiveIcons.values[index],
                    index: index,
                  );
                }),
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

class RiveIconWrapper extends StatelessWidget {

  final Stream<WizardStepperEvent> stepStream;
  final RiveIcons icon;
  final int index;
  const RiveIconWrapper({super.key, required this.stepStream, required this.icon, required this.index });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WizardStepperEvent>(
      stream: stepStream,
      builder: (context, snapshot) {

        RiveIconActions action = RiveIconActions.idle;

        if (snapshot.hasData) {
          final riveData = snapshot.data!.steps[index];
          action = getActionFromMetadata(riveData);
        }

        return RiveIcon(
          icon: icon, 
          action: action,
        );
      }
    );
  }

  RiveIconActions getActionFromMetadata(WizardStepperMetadata metadata) {
    if (metadata.isCurrentStep && !metadata.isComplete) {
      return RiveIconActions.current;
    }
    
    else if (!metadata.isCurrentStep && metadata.isComplete) {
      return RiveIconActions.completed;
    }

    else if (metadata.isCurrentStep && metadata.isComplete) {
      return RiveIconActions.completed;
    }

    return RiveIconActions.idle;
  }
}

class RiveIcon extends StatefulWidget {

  final RiveIcons icon;
  final double size;
  final RiveIconActions action;
  const RiveIcon({super.key, required this.icon, this.size = 60, this.action = RiveIconActions.idle, });

  @override
  State<RiveIcon> createState() => _RiveIconState();
}

class _RiveIconState extends State<RiveIcon> {

  late RiveAnimation anim;
  late StateMachineController ctrl;
  bool actionsLoaded = false;

  Map<RiveIconActions, SMITrigger> iconActions = {};

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/simplenavitems.riv',
      artboard: widget.icon.name,
      onInit: onRiveInit,
      fit: BoxFit.contain,
    );
  }

  void onRiveInit(Artboard ab) {
    ctrl = StateMachineController.fromArtboard(ab, widget.icon.name)!;
    ab.addController(ctrl);

    for(var action in RiveIconActions.values) {
      iconActions[action] = ctrl.findSMI(action.name) as SMITrigger;
    }

    setState(() {
      actionsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (actionsLoaded) {
      iconActions[widget.action]!.fire();
    }

    return SizedBox.square(
      dimension: widget.size,
      child: anim,
    );
  }
}

enum RiveIcons {
  clients,
  users,
  notifications,
  settings,
  bookings,
  inventory,
}

enum RiveIconActions {
  idle,
  current,
  completed,
}