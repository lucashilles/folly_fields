import 'package:flutter/material.dart';
import 'package:folly_fields/util/email_validator.dart';
import 'package:folly_fields/widgets/validator_field.dart';

///
///
///
class EmailField extends ValidatorField {
  ///
  ///
  ///
  EmailField({
    Key key,
    String validatorMessage = 'Informe o e-mail.',
    String prefix,
    String label,
    TextEditingController controller,
    TextAlign textAlign = TextAlign.start,
    int maxLength,
    FormFieldSetter<String> onSaved,
    String initialValue,
    bool enabled = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    ValueChanged<String> onChanged,
    FocusNode focusNode,
    TextInputAction textInputAction,
    ValueChanged<String> onFieldSubmitted,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    bool filled = false,
  }) : super(
          key: key,
          abstractValidator: EmailValidator(),
          validatorMessage: validatorMessage,
          prefix: prefix,
          label: label,
          controller: controller,
          textAlign: textAlign,
          maxLength: maxLength,
          onSaved: onSaved,
          initialValue: initialValue,
          enabled: enabled,
          autoValidateMode: autoValidateMode,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          scrollPadding: scrollPadding,
          enableInteractiveSelection: enableInteractiveSelection,
          filled: filled,
        );
}
