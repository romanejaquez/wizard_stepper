import 'package:example/sample_wizards/basic_wizard.dart';
import 'package:example/sample_wizards/wizard_with_animated_icons.dart';
import 'package:example/sample_wizards/wizard_with_custom_buttons.dart';
import 'package:example/sample_wizards/wizard_with_icons.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: BasicWizard()
      // home: WizardWithIcons(),
      // home: WizardWithAnimatedIcons(),
      //home: WizardWithCustomButtons(),
      ));
}
