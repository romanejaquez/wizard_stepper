import 'dart:async';
import 'package:flutter/material.dart';

/// Describes the position based on the
/// orientation; top and bottom when WizardStepperOrientation is horizontal,
/// and left and right when WizardStepperOrientation is vertical.
enum WizardStepperPosition { top, bottom, left, right }

/// Describes the display orientation of the wizard steps
enum WizardStepperOrientation { horizontal, vertical }

/// Describes the orientation of the divider pieces
/// in between the wizard steps
enum WizardStepperDividerOrientation { horizontal, vertical }

/// Mixin that must be added to a given widget that wants to become
/// a step in the wizard; applies to any page-level widget
/// or any widget for that matter, but mostly recommended for
/// top-level widgets. By applying this mixin, a widget can easily
/// query the following information:
/// stepNumber: the corresponding step index in the wizard (zero based)
/// isComplete: whether the step is complete or not
/// isCurrentStep: check whether the step is the current step being viewed
/// completeStep: callback to let the wizard know whether this step is complete or not
mixin WizardStep on Widget {
  final ValueNotifier<int> _stepNumber = ValueNotifier(0);
  final ValueNotifier<bool> _isComplete = ValueNotifier(false);
  final ValueNotifier<bool> _isCurrentStep = ValueNotifier(false);
  late final Function(bool) completeStep;

  // is complete
  bool get isComplete {
    return _isComplete.value;
  }

  ValueNotifier<bool> get isCompleteNotifier {
    return _isComplete;
  }

  set isComplete(bool value) {
    _isComplete.value = value;
  }

  // is current step
  bool get isCurrentStep {
    return _isCurrentStep.value;
  }

  set isCurrentStep(bool value) {
    _isCurrentStep.value = value;
  }

  ValueNotifier<bool> get isCurrentStepNotifier {
    return _isCurrentStep;
  }

  // step number
  int get stepNumber {
    return _stepNumber.value;
  }

  ValueNotifier<int> get stepNumberNotifier {
    return _stepNumber;
  }

  set stepNumber(int value) {
    _stepNumber.value = value;
  }
}

/// The actual widget that represents the wizard stepper
/// It is controlled by a controller named WizardStepperController
/// which receives all properties, flags, callbacks, etc. that brings
/// the wizard to life.
class WizardStepper extends StatefulWidget {
  final WizardStepperController controller;
  final List<WizardStep> steps;
  final List<Widget> stepWidgets;
  final List<IconData> stepIcons;

  const WizardStepper({
    super.key,
    required this.controller,
    required this.steps,
    this.stepIcons = const [],
    this.stepWidgets = const [],
  });

  @override
  WizardStepperState createState() => WizardStepperState();
}

/// The stateful portion of the WizardStepper widget
class WizardStepperState extends State<WizardStepper> {
  // The controller that manages the wizard
  late WizardStepperController controller;

  // flags to be used when the user selects to
  // use the default navigation provided by the wizard
  bool _enablePreviousButton = false;
  bool _enableNextButton = false;

  @override
  void initState() {
    super.initState();

    // initializes the wizard
    controller = widget.controller;
    controller.initialize(
      widget.steps,
      wizardStepIcons: widget.stepIcons,
      wizardStepWidgets: widget.stepWidgets,
    );
  }

  /// based on the index of the current wizard step,
  /// determine what the appropriate color should be applied
  /// for the divider lines in the wizard
  Color _generateLineColor(int index) {
    return index < controller._steps.length - 1 &&
                controller._steps[index].isComplete &&
                controller._steps[index + 1].isCurrentStep ||
            index < controller._steps.length - 1 &&
                controller._steps[index].isComplete &&
                controller._steps[index + 1].isComplete
        ? controller.theme!.completedStepColor
        : controller.theme!.stepColor;
  }

  /// based on the index of the current wizard step,
  /// determine what the appropriate color should be applied
  /// for the circle / wizard step indicator in the wizard
  Color _generateCircleColor(int index) {
    return controller._steps[index].isComplete
        ? controller.theme!.completedStepColor
        : (controller._steps[index].isCurrentStep
            ? controller.theme!.currentStepColor
            : controller.theme!.stepColor);
  }

  @override
  Widget build(BuildContext context) {

    final lightTheme = controller.lightTheme ?? WizardStepperThemeData(
      completedStepColor: controller.completedStepColor,
      currentStepColor: controller.currentStepColor,
      stepColor: controller.stepColor,
      stepNumberColor: controller.stepNumberColor,
      dividerColor: controller.dividerColor,
    );

    final darkTheme = controller.darkTheme ?? WizardStepperThemeData(
      completedStepColor: controller.completedStepColor,
      currentStepColor: controller.currentStepColor,
      stepColor: controller.stepColor,
      stepNumberColor: controller.stepNumberColor,
      dividerColor: controller.dividerColor,
    );

    return WizardStepperTheme(
      light: lightTheme,
      dark: darkTheme,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
      
          final theme = WizardStepperTheme.of(context);
          controller.theme = theme;
      
          _enablePreviousButton = controller.canMoveToPreviousStep();
          _enableNextButton =
              controller.canMoveToNextStep() || controller.allStepsCompleted();
      
          return Column(
            children: [
              Expanded(
                  child: controller.orientation ==
                          WizardStepperOrientation.horizontal
                      ? Column(
                          children: [
                            Visibility(
                              visible: controller.position ==
                                  WizardStepperPosition.bottom,
                              child: Expanded(child: controller._currentStep!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(controller._steps.length,
                                  (index) {
                                final lineColor = _generateLineColor(index);
                                final circleColor = _generateCircleColor(index);
      
                                return Expanded(
                                    flex: index < controller._steps.length - 1
                                        ? 1
                                        : 0,
                                    child: Row(
                                      children: [
                                        WizardStepperHotSpot(
                                          step: controller._steps[index],
                                          color: circleColor,
                                          controller: controller,
                                          onStepEvent: () {
                                            controller.onStepSelected(index);
                                          },
                                        ),
                                        Visibility(
                                          visible: index <
                                              controller._steps.length - 1,
                                          child: WizardStepperDivider(
                                            color: lineColor,
                                            direction:
                                                WizardStepperDividerOrientation
                                                    .horizontal,
                                            margin: controller.dividerMargin,
                                            radius: controller.dividerRadius,
                                            thickness:
                                                controller.dividerThickness,
                                          ),
                                        )
                                      ],
                                    ));
                              }),
                            ),
                            Visibility(
                              visible: controller.position ==
                                  WizardStepperPosition.top,
                              child: Expanded(child: controller._currentStep!),
                            )
                          ],
                        )
                      : Row(
                          children: [
                            Visibility(
                              visible: controller.position ==
                                  WizardStepperPosition.right,
                              child: Expanded(child: controller._currentStep!),
                            ),
                            Column(
                              children: List.generate(controller._steps.length,
                                  (index) {
                                final lineColor = _generateLineColor(index);
                                final circleColor = _generateCircleColor(index);
      
                                return Expanded(
                                    flex: index < controller._steps.length - 1
                                        ? 1
                                        : 0,
                                    child: Column(children: [
                                      WizardStepperHotSpot(
                                        step: controller._steps[index],
                                        color: circleColor,
                                        controller: controller,
                                        onStepEvent: () {
                                          controller.onStepSelected(index);
                                        },
                                      ),
                                      Visibility(
                                        visible:
                                            index < controller._steps.length - 1,
                                        child: WizardStepperDivider(
                                          color: lineColor,
                                          direction:
                                              WizardStepperDividerOrientation
                                                  .vertical,
                                          margin: controller.dividerMargin,
                                          radius: controller.dividerRadius,
                                          thickness: controller.dividerThickness,
                                        ),
                                      )
                                    ]));
                              }),
                            ),
                            Visibility(
                                visible: controller.position ==
                                    WizardStepperPosition.left,
                                child: Expanded(child: controller._currentStep!))
                          ],
                        )),
      
              // show navigation?
              Visibility(
                visible: controller.showNavigationButtons,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        style: controller.previousButtonStyle,
                        onPressed: _enablePreviousButton
                            ? () {
                                controller.moveToPreviousStep();
                              }
                            : null,
                        child: Text(controller.previousButtonLabel)),
                    TextButton(
                        style: controller.nextButtonStyle,
                        onPressed: _enableNextButton
                            ? () {
                                if (controller.allStepsCompleted() &&
                                    controller.isLastStep()) {
                                  controller.moveToLastStep();
                                } else {
                                  controller.moveToNextStep();
                                }
                              }
                            : null,
                        child: Text(
                          controller.allStepsCompleted() &&
                                  controller.isLastStep()
                              ? controller.finalStepButtonLabel
                              : controller.nextButtonLabel,
                        )),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// The widget that represents the division between steps
class WizardStepperDivider extends StatelessWidget {
  final double? thickness;
  final Color color;
  final double margin;
  final WizardStepperDividerOrientation direction;
  final double radius;

  const WizardStepperDivider({
    super.key,
    required this.direction,
    required this.color,
    this.thickness,
    this.margin = 0,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: direction == WizardStepperDividerOrientation.horizontal
            ? EdgeInsets.only(left: margin, right: margin)
            : EdgeInsets.only(top: margin, bottom: margin),
        height: direction == WizardStepperDividerOrientation.horizontal
            ? thickness
            : null,
        width: direction == WizardStepperDividerOrientation.vertical
            ? thickness
            : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// The widget that represents the step indicator in the wizard
class WizardStepperHotSpot extends StatelessWidget {
  final WizardStep step;
  final VoidCallback onStepEvent;
  final WizardStepperController controller;
  final Color color;

  const WizardStepperHotSpot(
      {super.key,
      required this.step,
      required this.color,
      required this.controller,
      required this.onStepEvent});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: step.isCurrentStep || step.isComplete
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onStepEvent,
        child: SizedBox(
          width: controller.stepBackgroundSize,
          height: controller.stepBackgroundSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: step.isCurrentStep && controller._stepWidgets.isEmpty,
                child: Container(
                  decoration: BoxDecoration(
                    shape: controller.stepShape,
                    border: Border.all(
                      color: color,
                      width: controller.borderSize,
                    ),
                    borderRadius: controller.stepShape != BoxShape.circle
                        ? BorderRadius.circular(controller.borderSize)
                        : null,
                  ),
                ),
              ),

              // step widgets take the priority
              controller._stepWidgets.isNotEmpty
                  ? SizedBox.square(
                      dimension: controller.stepIconSize,
                      child: controller._stepWidgets[step.stepNumber],
                    )
                  :

                  // step icons show if no widgets are provided
                  controller._stepIcons.isNotEmpty
                      ? Icon(
                          controller._stepIcons[step.stepNumber],
                          size: controller.stepIconSize,
                          color: color,
                        )
                      :

                      // otherwise, a basic circle gets shown
                      Container(
                          width: controller.stepSize,
                          height: controller.stepSize,
                          decoration: BoxDecoration(
                            shape: controller.stepShape,
                            color: color,
                            borderRadius: controller.stepShape !=
                                    BoxShape.circle
                                ? BorderRadius.circular(controller.borderSize)
                                : null,
                          ),
                          child:
                              // if we want to show the step number inside the step indicator
                              (controller.showStepNumber &&
                                      controller._stepIcons.isEmpty
                                  ? Container(
                                      alignment: Alignment.center,
                                      width: controller.stepSize,
                                      height: controller.stepSize,
                                      child: Text('${step.stepNumber + 1}',
                                          textAlign: TextAlign.center,
                                          style: controller.stepLabelStyle.copyWith(
                                            color: controller.theme!.stepNumberColor),
                                          ),
                                    )
                                  : null)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The controller that orchestrates the wizard interactions and
/// the creation of all elements that come together to bring the wizard to life
class WizardStepperController extends ChangeNotifier {
  // step-related properties
  WizardStep? _currentStep;
  int _currentStepIndex = 0;
  List<WizardStep> _steps = [];
  List<IconData> _stepIcons = [];
  List<Widget> _stepWidgets = [];

  // callbacks
  Function(int, bool)? onStepCompleted;
  Function(int)? onSelectedStep;
  Function()? onMovedToNext;
  Function()? onMovedToPrevious;
  Function()? onWizardReset;
  Function()? onMovedToLastStep;
  Function()? onOrientationSwitched;

  // colors
  Color stepColor;
  Color dividerColor;
  Color completedStepColor;
  Color currentStepColor;
  Color stepNumberColor;

  // themes
  WizardStepperThemeData? lightTheme;
  WizardStepperThemeData? darkTheme;
  WizardStepperThemeData? activeTheme;

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
  TextStyle stepLabelStyle;

  // enums
  WizardStepperOrientation orientation;
  WizardStepperPosition position;

  // streams to subscribe and listen to wizard stepper events
  late StreamController<WizardStepperEvent> stepChangesController;
  late Stream<WizardStepperEvent> stepChanges;

  WizardStepperController({
    // callbacks
    this.onStepCompleted,
    this.onSelectedStep,
    this.onMovedToNext,
    this.onMovedToPrevious,
    this.onWizardReset,
    this.onMovedToLastStep,
    this.onOrientationSwitched,

    // position & orientation
    this.orientation = WizardStepperOrientation.horizontal,
    this.position = WizardStepperPosition.top,

    // colors
    this.completedStepColor = Colors.green,
    this.currentStepColor = Colors.blue,
    this.stepColor = Colors.grey,
    this.stepNumberColor = Colors.white,
    this.dividerColor = Colors.grey,

    // themes
    this.lightTheme,
    this.darkTheme,

    // values
    this.stepSize = 20,
    this.dividerThickness = 6,
    this.dividerMargin = 6,
    this.dividerRadius = 0,
    this.borderSize = 5,
    this.stepBackgroundSize = 36,
    this.stepShape = BoxShape.circle,
    this.stepIconSize = 20,
    this.stepBorderRadius = 20,
    this.stepLabelStyle = const TextStyle(fontSize: 12),

    // flags
    this.showStepDividers = true,
    this.showStepNumber = true,

    // button-related properties
    this.showNavigationButtons = false,
    this.previousButtonLabel = 'Previous',
    this.nextButtonLabel = 'Next',
    this.finalStepButtonLabel = 'Complete',
    this.previousButtonStyle,
    this.nextButtonStyle,
  });

  /// Broadcasts the internal state of the wizard to any
  /// interested listening entity. It broadcasts a WizardStepperEvent
  /// which contains the state of every single wizard step
  void _streamStepsEvent() {
    stepChangesController.add(
      WizardStepperEvent(
        steps: _steps
            .map((s) => WizardStepperMetadata(
                isComplete: s.isComplete, isCurrentStep: s.isCurrentStep))
            .toList(),
      ),
    );
  }

  /// Performs some basic checks to warn the user about the usage of the wizard
  /// by notifying the user in the form of exceptions
  void _performChecks() {
    if (orientation == WizardStepperOrientation.horizontal &&
        (position == WizardStepperPosition.left ||
            position == WizardStepperPosition.right)) {
      throw Exception(
          'Error: When WizardStepper orientation is horizontal, position must be top or bottom.');
    }

    if (orientation == WizardStepperOrientation.vertical &&
        (position == WizardStepperPosition.top ||
            position == WizardStepperPosition.bottom)) {
      throw Exception(
          'Error: When WizardStepper orientation is vertical, position must be left or right.');
    }

    if (_steps.isEmpty) {
      throw Exception(
          'You must add steps for the WidgetStepper to function properly.');
    }

    if (_steps.isNotEmpty &&
        _stepIcons.isNotEmpty &&
        _steps.length != _stepIcons.length) {
      throw Exception('You must have the same amount of steps and icons.');
    }

    if (_steps.isNotEmpty &&
        _stepWidgets.isNotEmpty &&
        _steps.length != _stepWidgets.length) {
      throw Exception(
          'You must have the same amount of steps and step widgets.');
    }
  }

  /// Resets all steps and only makes the current step the current one
  void _resetCurrentStep() {
    for (int i = 0; i < _steps.length; i++) {
      _steps[i].isCurrentStep = _steps[i] == _currentStep;
    }
  }

  /// Sets the current step to be whatever the current step index is
  void _setCurrentStep() {
    _currentStep = _steps[_currentStepIndex];
    _resetCurrentStep();

    _streamStepsEvent();
    notifyListeners();
  }

  /// Bootstraps the wizard and sets up its internals
  /// wizardSteps: the steps to be displayed in the wizard
  /// wizardStepIcons: (optional) the icons to display instead of the default wizard steps indicators
  /// wizardStepWidgets: (optional) the widgets to display instead of icons or wizard step indicators
  void initialize(List<WizardStep> wizardSteps,
      {List<IconData> wizardStepIcons = const [],
      List<Widget> wizardStepWidgets = const []}) {
    stepChangesController = StreamController<WizardStepperEvent>.broadcast();
    stepChanges = stepChangesController.stream;

    _steps = wizardSteps;
    _currentStepIndex = 0;

    for (var (index, element) in _steps.indexed) {
      element.stepNumber = index;
      element.isCurrentStep = false;
      element.isComplete = false;

      // wire up the ability for the user to complete a step
      // from within by sending the boolean flag whether it is complete or not
      element.completeStep = (isStepComplete) {
        int stepNum = _currentStep!.stepNumber;

        if (stepNum <= _steps.length - 1) {
          _currentStep!.isComplete = isStepComplete;
        }

        if (onStepCompleted != null) {
          onStepCompleted!(stepNum, isStepComplete);
        }

        _streamStepsEvent();
        notifyListeners();
      };
    }

    _stepIcons = wizardStepIcons;
    _stepWidgets = wizardStepWidgets;

    _performChecks();
    _setCurrentStep();

    Future.delayed(const Duration(seconds: 0), () {
      _streamStepsEvent();
    });
  }

  /// Switches orientation of the wizard, provided the orientation of the wizard and position of the wizard steps
  /// newOrientation: the new orientation of the wizard (horizontal or vertical)
  /// newPosition: the new position of the wizard stepper items (top, bottom for horizontal; left, right for vertical)
  void switchOrientation(WizardStepperOrientation newOrientation,
      WizardStepperPosition newPosition) {
    orientation = newOrientation;
    position = newPosition;

    _performChecks();
    notifyListeners();

    if (onOrientationSwitched != null) {
      onOrientationSwitched!();
    }
  }

  /// Resets the wizard to its initial (default) state
  void resetWizard() {
    for (int i = 0; i < _steps.length; i++) {
      var step = _steps[i];
      step.isCurrentStep = false;
      step.isComplete = false;
    }

    _currentStepIndex = 0;
    _setCurrentStep();

    if (onWizardReset != null) {
      onWizardReset!();
    }
  }

  /// Selects the index in question, provided that the user taps on
  /// the desired wizard step indicator circle, icon or widget
  /// selectedStepIndex: the index of the selected step
  void onStepSelected(int selectedStepIndex) {
    WizardStep selectedStep = _steps[selectedStepIndex];

    if (selectedStep.isComplete) {
      _currentStepIndex = selectedStepIndex;
      _currentStep = selectedStep;

      _resetCurrentStep();

      if (onSelectedStep != null) {
        onSelectedStep!(_currentStepIndex);
      }

      _streamStepsEvent();
      notifyListeners();
    }
  }

  /// Returns whether all steps in the wizard have been completed accordingly
  bool allStepsCompleted() {
    return _steps.isNotEmpty && _steps.every((s) => s.isComplete);
  }

  /// Returns whether the wizard can be moved to the next step
  bool canMoveToNextStep() {
    return _currentStep != null &&
        _currentStep!.isComplete &&
        _currentStep!.stepNumber < _steps.length - 1;
  }

  /// Returns whether the wizard can be moved to the previous step
  bool canMoveToPreviousStep() {
    return _currentStep != null && _currentStep!.stepNumber > 0;
  }

  /// Returns whether the wizard can be moved to the last step
  bool canMoveToLastStep() {
    return _currentStep != null &&
        _currentStep!.stepNumber <= _steps.length - 1;
  }

  /// Returns whether the wizard is at the first step
  bool isFirstStep() {
    return _currentStep != null && _currentStep == _steps.first;
  }

  /// Returns whether the wizard is at the last step
  bool isLastStep() {
    return _currentStep != null && _currentStep == _steps.last;
  }

  /// Triggers the ability to move to the next step in turn
  /// given the proper conditions
  void moveToNextStep() {
    if (canMoveToNextStep()) {
      _currentStepIndex++;

      _setCurrentStep();

      if (onMovedToNext != null) {
        onMovedToNext!();
      }
    }
  }

  /// Triggers the ability to move to the previous step in turn
  /// given the proper conditions
  void moveToPreviousStep() {
    if (canMoveToPreviousStep()) {
      _currentStepIndex--;

      _setCurrentStep();

      if (onMovedToPrevious != null) {
        onMovedToPrevious!();
      }
    }
  }

  /// Triggers the ability to move to the very last step so the
  /// last step can be displayed
  void moveToLastStep() {
    if (canMoveToLastStep()) {
      _currentStepIndex = _steps.length - 1;
      _setCurrentStep();

      if (onMovedToLastStep != null) {
        onMovedToLastStep!();
      }
    }
  }

  /// Returns the current step index
  int get currentStepIndex {
    return _currentStepIndex;
  }

  /// Returns the current wizard step
  WizardStep? get currentStep {
    return _currentStep;
  }

  /// Returns the number of steps in the wizard
  int get numberOfSteps {
    return _steps.length;
  }

  /// Returns all steps in the wizard as a List
  List<WizardStep> get steps {
    return _steps;
  }

  /// Returns all icons used for the wizard step indicators
  List<IconData> get stepIcons {
    return _stepIcons;
  }

  /// Returns all the widgets used as wizard step indicators
  List<Widget> get stepWidgets {
    return _stepWidgets;
  }

  WizardStepperThemeData? get theme {
    return activeTheme;
  }

  set theme(WizardStepperThemeData? value) {
    activeTheme = value;
  }

  /// disposes of any resources
  @override
  void dispose() {
    super.dispose();
    stepChangesController.close();
  }
}

/// The metadata associated with each wizard step; this data
/// will be broadcasted and wrapped inside a WizardStepperEvent
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

/// Represents the event to be dispatched to any listening entities
/// regarding the state of the wizard at various states
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

/// Encapsulates the theme data for the wizard stepper as far as colors
class WizardStepperThemeData {
  final Color stepColor;
  final Color dividerColor;
  final Color completedStepColor;
  final Color currentStepColor;
  final Color stepNumberColor;

  WizardStepperThemeData({
    required this.stepColor,
    required this.dividerColor,
    required this.completedStepColor,
    required this.currentStepColor,
    required this.stepNumberColor,
  });
}

/// Provides an inherited widget at the root of the wizard stepper hierarchy
/// in order to provide the theming in a top-down approach
class WizardStepperInheritedTheme extends InheritedWidget {
  final WizardStepperThemeData data;
  const WizardStepperInheritedTheme({
    required this.data,
    required super.child,
    super.key,
  });
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>     
      oldWidget != this;
}

/// Wraps the theme around the wizard stepper
class WizardStepperTheme extends StatelessWidget {
  final WizardStepperThemeData light;
  final WizardStepperThemeData dark;
  final Widget child;

  const WizardStepperTheme({
    super.key,
    required this.light,
    required this.dark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final data = brightness == Brightness.light ? light : dark;
     
    return WizardStepperInheritedTheme(
      data: data,
      child: child,
    );
  }
  
  static WizardStepperThemeData of(BuildContext context){
    return context
        .dependOnInheritedWidgetOfExactType<WizardStepperInheritedTheme>()!
        .data;
  }
}