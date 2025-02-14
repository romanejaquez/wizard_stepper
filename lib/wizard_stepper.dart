library flutter_wizard;

import 'dart:async';
import 'package:flutter/material.dart';

enum WizardStepperPosition {
  top,
  bottom,
  left,
  right
}

enum WizardStepperOrientation {
  horizontal,
  vertical
}

enum WizardStepperDividerOrientation {
  horizontal,
  vertical
}

mixin WizardStep on Widget {
  int stepNumber = 0;
  bool isComplete = false;
  bool isCurrentStep = false;
  late Function onCompleteStep;
}

class WizardStepper extends StatefulWidget {

  final WizardStepperController controller;
  final List<WizardStep> steps;
  final List<Widget> stepWidgets;
  final List<IconData> stepIcons;

  const WizardStepper({Key? key, 
    required this.controller,
    required this.steps,
    this.stepIcons = const [],
    this.stepWidgets = const [],
  }) : super(key: key);

  @override
  _WizardStepperState createState() => _WizardStepperState();
}

class _WizardStepperState extends State<WizardStepper> {

  late WizardStepperController controller;
  bool enablePreviousButton = false;
  bool enableNextButton = false;

  @override 
  void initState() {
    super.initState();
    
    controller = widget.controller;
    controller.initialize(
      widget.steps, 
      wizardStepIcons: widget.stepIcons,
      wizardStepWidgets: widget.stepWidgets,
    );
  }

  Color generateLineColor(int index) {
    return index < controller.steps.length - 1
                    && controller.steps[index].isComplete && controller.steps[index + 1].isCurrentStep ||
                    index < controller.steps.length - 1 && controller.steps[index].isComplete && controller.steps[index + 1].isComplete
                        ? controller.completedStepColor : controller.stepColor;
  }

  Color generateCircleColor(int index) {
    return controller.steps[index].isComplete ? controller.completedStepColor :
                              (controller.steps[index].isCurrentStep ?
                                controller.currentStepColor : controller.stepColor);
  }

  @override
  Widget build(BuildContext context) {
    
    return ListenableBuilder(
      listenable: controller, 
      builder:(context, child) {

        enablePreviousButton = controller.canMoveToPreviousStep();
        enableNextButton = controller.canMoveToNextStep() || controller.allStepsCompleted();

        return Column(
          children: [
            Expanded(
              child: controller.orientation == WizardStepperOrientation.horizontal ? 
                Column(
                  children: [
                    Visibility(
                      visible: controller.position == WizardStepperPosition.bottom,
                      child: Expanded(
                        child: controller.currentStep!
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(controller.steps.length, (index) {
              
                        final lineColor = generateLineColor(index);
                        final circleColor = generateCircleColor(index);
              
                          return Expanded(
                            flex: index < controller.steps.length - 1 ? 1 : 0,
                            child: Row(
                              children: [
                                WizardStepperHotSpot(
                                  step: controller.steps[index],
                                  color: circleColor,
                                  controller: controller, 
                                  onStepEvent: () {
                                    controller.onStepSelected(index);
                                  },
                                ),
                                Visibility(
                                  visible: index < controller.steps.length - 1,
                                  child: WizardStepperDivider(
                                    color: lineColor,
                                    direction: WizardStepperDividerOrientation.horizontal,
                                    margin: controller.dividerMargin,
                                    radius: controller.dividerRadius,
                                    thickness: controller.dividerThickness,
                                  ),
                                )
                              ],
                            )
                          );
                        }
                      ),
                    ),
                    Visibility(
                      visible: controller.position == WizardStepperPosition.top,
                      child: Expanded(
                        child: controller.currentStep!
                      ),
                    )
                  ],
                ) :
                Row(
                  children: [
                    Visibility(
                      visible: controller.position == WizardStepperPosition.right,
                      child: Expanded(
                        child: controller.currentStep!
                      ),
                    ),
                    Column(
                      children: List.generate(controller.steps.length, (index) {
              
                        final lineColor = generateLineColor(index);
                        final circleColor = generateCircleColor(index);
              
                        return Expanded(
                          flex: index < controller.steps.length - 1 ? 1 : 0,
                          child: Column(
                            children: [
                              WizardStepperHotSpot(
                                step: controller.steps[index], 
                                color: circleColor,
                                controller: controller, 
                                onStepEvent: () {
                                  controller.onStepSelected(index);
                                },
                              ),
                              Visibility(
                                visible: index < controller.steps.length - 1,
                                child: WizardStepperDivider(
                                  color: lineColor,
                                  direction: WizardStepperDividerOrientation.vertical,
                                  margin: controller.dividerMargin,
                                  radius: controller.dividerRadius,
                                  thickness: controller.dividerThickness,
                                ),
                              )
                            ]
                          )
                        );
                      }),
                    ),
                    Visibility(
                      visible: controller.position == WizardStepperPosition.left,
                      child: Expanded(
                        child: controller.currentStep!
                      )
                    )
                  ],
                )
              
            ),

            // show navigation?
            Visibility(
              visible: controller.showNavigationButtons,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: controller.previousButtonStyle,
                    onPressed: enablePreviousButton ? () {
                      controller.moveToPreviousStep();
                    } : null,
                    child: Text(controller.previousButtonLabel)
                  ),

                  TextButton(
                    style: controller.nextButtonStyle,
                    onPressed: enableNextButton ? () {
                      if (controller.allStepsCompleted() && controller.isLastStep()) {
                        controller.moveToLastStep();
                      }
                      else {
                        controller.moveToNextStep();
                      }
                    } : null,
                    child: Text(controller.allStepsCompleted() && controller.isLastStep() ? 
                      controller.finalStepButtonLabel : controller.nextButtonLabel,
                    )
                  ),
                ],
              ),
            )
          ],
        );
      },);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class WizardStepperDivider extends StatelessWidget {

  final double? thickness;
  final Color color;
  final double margin;
  final WizardStepperDividerOrientation direction;
  final double radius;
  const WizardStepperDivider({super.key, required this.direction, this.thickness, this.margin = 0, this.radius = 0, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: direction == WizardStepperDividerOrientation.horizontal ? 
          EdgeInsets.only(left: margin, right: margin) :
          EdgeInsets.only(top: margin, bottom: margin),
        height: direction == WizardStepperDividerOrientation.horizontal ? thickness : null,
        width: direction == WizardStepperDividerOrientation.vertical ? thickness : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class WizardStepperHotSpot extends StatelessWidget {

  final WizardStep step;
  final VoidCallback onStepEvent;
  final WizardStepperController controller;
  final Color color;
  const WizardStepperHotSpot({Key? key, required this.step, required this.color, required this.controller, required this.onStepEvent }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: step.isCurrentStep || step.isComplete ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onStepEvent,
        
        child: SizedBox(
          width: controller.stepBackgroundSize,
          height: controller.stepBackgroundSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: step.isCurrentStep && controller.stepWidgets.isEmpty,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,//controller.stepShape,
                    border: Border.all(
                      color: color,
                      width: controller.borderSize,
                    ),
                    borderRadius: controller.stepShape != BoxShape.circle ? BorderRadius.circular(controller.borderSize) : null,
                  ),
                ),
              ),
              controller.stepWidgets.isNotEmpty ?
                SizedBox.square(
                  dimension: controller.stepIconSize,
                  child: controller.stepWidgets[step.stepNumber],
                ) :
              controller.stepIcons.isNotEmpty ?
                  Icon(
                    controller.stepIcons[step.stepNumber],
                    size: controller.stepIconSize,
                    color: color,
                  ) :
              Container(
                width: controller.stepSize,
                height: controller.stepSize,
                decoration: BoxDecoration(
                  shape: controller.stepShape,
                  color: color,
                  borderRadius: controller.stepShape != BoxShape.circle ? BorderRadius.circular(controller.borderSize) : null,
                ),
                child: 
                  (controller.showStepNumber && controller.stepIcons.isEmpty ? 
                    Container(
                      
                      alignment: Alignment.center,
                      width: controller.stepSize,
                      height: controller.stepSize,
                      child: Text(
                        (step.stepNumber + 1).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: controller.stepNumberColor)
                      ),
                    ) 
                    : null)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WizardStepperController extends ChangeNotifier {

  // step-related properties
  WizardStep? currentStep;
  int currentStepIndex = 0;
  List<WizardStep> steps = [];
  List<IconData> stepIcons = [];
  List<Widget> stepWidgets = [];

  // callbacks
  Function(int, bool)? onStepCompleted;
  Function(int)? onSelectedStep;
  Function()? onMovedToNext;
  Function()? onMovedToPrevious;
  Function()? onWizardReset;
  Function()? onMovedToLastStep;

  // colors
  Color stepColor;
  Color dividerColor;
  Color completedStepColor;
  Color currentStepColor;
  Color stepNumberColor;

  // flags
  bool showStepDividers;
  bool showStepNumber;

  // buttons
  bool showNavigationButtons;
  String previousButtonLabel;
  String nextButtonLabel;
  String finalStepButtonLabel;
  ButtonStyle? previousButtonStyle;
  ButtonStyle? nextButtonStyle;

  // properties
  double dividerThickness;
  double dividerMargin;
  double dividerRadius;
  double stepBorderRadius;
  double stepSize;
  double borderSize;
  double stepBackgroundSize;
  BoxShape stepShape;
  double stepIconSize;
  WizardStepperOrientation orientation;
  WizardStepperPosition position;

  late StreamController<WizardStepperEvent> stepChangesController;
  late Stream<WizardStepperEvent> stepChanges;

  WizardStepperController({
    this.onStepCompleted,
    this.onSelectedStep,
    this.onMovedToNext,
    this.onMovedToPrevious,
    this.onWizardReset,
    this.onMovedToLastStep,

    this.stepSize = 20,
    this.orientation = WizardStepperOrientation.horizontal,
    this.position = WizardStepperPosition.top,

    this.completedStepColor = Colors.green,
    this.currentStepColor = Colors.blue,
    this.stepColor = Colors.grey,
    this.stepNumberColor = Colors.white,
    this.dividerColor = Colors.grey,

    this.dividerThickness = 6,
    this.dividerMargin = 6,
    this.dividerRadius = 0,
    
    this.borderSize = 5,
    this.stepBackgroundSize = 36,
    this.stepShape = BoxShape.circle,
    this.stepIconSize = 20,

    this.showStepDividers = true,
    this.showStepNumber = true,

    // buttons
    this.showNavigationButtons = false,
    this.previousButtonLabel = 'Previous',
    this.nextButtonLabel = 'Next',
    this.finalStepButtonLabel = 'Complete',
    this.previousButtonStyle,
    this.nextButtonStyle,
    
    this.stepBorderRadius = 20,
  }) {
    stepChangesController = StreamController<WizardStepperEvent>.broadcast();
    stepChanges = stepChangesController.stream;
  }

  void initialize(List<WizardStep> wizardSteps, { 
    List<IconData> wizardStepIcons = const [], List<Widget> wizardStepWidgets = const [] }) {

    steps = wizardSteps;
    currentStepIndex = 0;
    for (var (index, element) in steps.indexed) {
      element.stepNumber = index;
    }

    if (wizardStepIcons.isNotEmpty) {
      stepIcons = wizardStepIcons; 
    }

    if (wizardStepWidgets.isNotEmpty) {
      stepWidgets = wizardStepWidgets;
    }

    performChecks();
    setCurrentStep();

    Future.delayed(const Duration(seconds: 0),() {
      streamStepsEvent();
    });
  }

  void performChecks() {
    if (orientation == WizardStepperOrientation.horizontal &&
      (position == WizardStepperPosition.left || position == WizardStepperPosition.right)) {
        throw Exception('Error: When WizardStepper orientation is horizontal, position must be top or bottom.');
      }
    
    if (orientation == WizardStepperOrientation.vertical &&
      (position == WizardStepperPosition.top || position == WizardStepperPosition.bottom)) {
        throw Exception('Error: When WizardStepper orientation is vertical, position must be left or right.');
      }

    if (steps.isEmpty) {
      throw Exception('You must add steps for the WidgetStepper to function properly.');
    }

    if (steps.isNotEmpty && stepIcons.isNotEmpty && steps.length != stepIcons.length) {
      throw Exception('You must have the same amount of steps and icons.');
    }

    if (steps.isNotEmpty && stepWidgets.isNotEmpty && steps.length != stepWidgets.length) {
      throw Exception('You must have the same amount of steps and step widgets.');
    }
  }

  void resetCurrentStep() {
    for(int i = 0; i < steps.length; i++){
        steps[i].isCurrentStep = steps[i] == currentStep;
    }
  }

  void switchOrientation(WizardStepperOrientation newOrientation) {
    orientation = newOrientation;

    performChecks();
    notifyListeners();
  }
  
  void resetWizard() {
    for(int i = 0; i < steps.length; i++){
        steps[i].isCurrentStep = false;
        steps[i].isComplete = false;
    }

    currentStepIndex = 0;
    setCurrentStep();

    if (onWizardReset != null) {
      onWizardReset!();
    }
  }

  void setCurrentStep() {

    currentStep = steps[currentStepIndex];
    resetCurrentStep();

    currentStep!.onCompleteStep = (isStepComplete) {
      int stepNum = currentStep!.stepNumber;

      if (stepNum <= steps.length - 1) {
        currentStep!.isComplete = isStepComplete;
      }

      if (onStepCompleted != null) {
        onStepCompleted!(stepNum, isStepComplete);
      }

      streamStepsEvent();
      notifyListeners();
    };

    streamStepsEvent();
    notifyListeners();
  }

  void onStepSelected(int selectedStepIndex) {
    WizardStep selectedStep = steps[selectedStepIndex];

    if (selectedStep.isComplete) {
      currentStepIndex = selectedStepIndex;
      currentStep = selectedStep;

      resetCurrentStep();
      
      if (onSelectedStep != null) {
        onSelectedStep!(currentStepIndex);
      }

      streamStepsEvent();
      notifyListeners();
    }
  }
  
  void streamStepsEvent() {
    stepChangesController.add(
      WizardStepperEvent(
        steps: steps.map((s) => WizardStepperMetadata(isComplete: s.isComplete, isCurrentStep: s.isCurrentStep)).toList(),
      ),
    );
  }

  bool allStepsCompleted() {
    return steps.isNotEmpty && steps.every((s) => s.isComplete);
  }

  bool canMoveToNextStep() {
    return currentStep != null && currentStep!.isComplete && currentStep!.stepNumber < steps.length - 1;
  }

  bool canMoveToPreviousStep() {
    return currentStep != null && currentStep!.stepNumber > 0;
  }

  bool isFirstStep() {
    return currentStep != null && currentStep == steps.first;
  }

  bool isLastStep() {
    return currentStep != null && currentStep == steps.last;
  }

  void moveToNextStep() {
    
    if (canMoveToNextStep()) {
      currentStepIndex++;
    }

    setCurrentStep();

    if (onMovedToNext != null) {
      onMovedToNext!();
    }
  }

  void moveToPreviousStep() {
    if (canMoveToPreviousStep()) {
      currentStepIndex--;
    }

    setCurrentStep();

    if (onMovedToPrevious != null) {
      onMovedToPrevious!();
    }
  }
    
  void moveToLastStep() {
    currentStepIndex = steps.length - 1;
    setCurrentStep();

    if (onMovedToLastStep != null) {
      onMovedToLastStep!();
    }
  }
  
  @override
  void dispose() {
    super.dispose();
    stepChangesController.close();
  }
}

class WizardStepperMetadata {
  bool isComplete = false;
  bool isCurrentStep = false;

  WizardStepperMetadata({
    required this.isComplete,
    required this.isCurrentStep,
  });

  @override
  String toString() {
    return 'isCurrent: $isCurrentStep, isComplete: $isComplete';
  }
}

class WizardStepperEvent {
  final List<WizardStepperMetadata> steps;


  const WizardStepperEvent({
    required this.steps,
  });

  @override
  String toString() {
    return steps.map((s) => s.toString()).join(',');
  }
}