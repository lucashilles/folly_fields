import 'package:folly_fields/validators/abstract_validator.dart';
import 'package:folly_fields/util/mask_text_input_formatter.dart';

///
///
///
class LocalPhoneValidator extends AbstractValidator<String> {
  ///
  ///
  ///
  LocalPhoneValidator()
      : super(
          ChangeMask(
            firstMask: '####-####',
            secondMask: '#####-####',
          ),
        );

  ///
  ///
  ///
  @override
  String format(String value) => strip(value).replaceAllMapped(
        RegExp(r'^(\d{4,5})(\d{4})$'),
        (Match m) => '${m[1]}-${m[2]}',
      );

  ///
  ///
  ///
  @override
  bool isValid(String phone, {bool stripBeforeValidation = true}) {
    if (stripBeforeValidation) {
      phone = strip(phone);
    }

    /// phone must be defined
    if (phone == null || phone.isEmpty) {
      return false;
    }

    /// phone must have 10 or 11 chars
    if (phone.length < 8 || phone.length > 9) {
      return false;
    }

    /// Números de 9 dígitos sempre iniciam com 9.
    if (phone.length == 9 && phone[0] != '9') {
      return false;
    }

    return true;
  }
}
