import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Custom form text field
class CustomFormTextField extends StatefulWidget {
  const CustomFormTextField({
    super.key,
    required this.label,
    this.prefix,
    this.isObscure = false,
    this.validator,
    this.validate = false,
    this.type = TextInputType.text,
    this.maxLines,
    this.suffix,
    this.controller,
    this.onChanged,
  });

  final String label;
  final bool isObscure;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType type;
  final String? Function(String?)? validator;
  final bool validate;
  final int? maxLines;
  final TextEditingController? controller;
  final void Function(dynamic value)? onChanged;

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: widget.controller,
        style: TextStyle(color: notifire.getMainText),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: notifire.getMaingey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: notifire.getMaingey),
          ),
          hintText: widget.label,
          hintStyle: mediumGreyTextStyle,
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix,
        ),
        keyboardType: widget.type,
        maxLines: widget.maxLines,
        obscureText: widget.isObscure,
        validator: (value) {
          if (widget.validate) {
            if (value == null || value.isEmpty) {
              return "Ce champs est obligatoire";
            }
            if (widget.validator != null) {
              return widget.validator!(value);
            }
          }
          return null;
        },
      ),
    );
  }
}

// Custom dropdown button
class CustomDropdownButton extends StatefulWidget {
  const CustomDropdownButton({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.validator,
    this.validate = false,
  });

  final String value;
  final String label;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final bool validate;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color:
                  notifire.isDark
                      ? notifire.geticoncolor
                      : Colors.grey.shade200,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color:
                  notifire.isDark
                      ? notifire.geticoncolor
                      : Colors.grey.shade200,
            ),
          ),
          hintText: widget.label,
          hintStyle: mediumGreyTextStyle,
          prefixIcon: widget.prefix,
        ),
        value: widget.value,
        icon: cusIcon(FontAwesomeIcons.sort),
        validator: (value) {
          if (widget.validate) {
            if (value == null || value.isEmpty) {
              return "Ce champs est obligatoire";
            }
            if (widget.validator != null) return widget.validator!(value);
          }
          return null;
        },
        items: widget.items,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
      ),
    );
  }
}

// Password field
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.validate = false,
  });

  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool validate;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      controller: widget.controller,
      label: widget.label ?? "Mot de passe",
      prefix: cusIcon(FontAwesomeIcons.lock),
      isObscure: isObscure,
      maxLines: 1,
      suffix: GestureDetector(
        onTap: () {
          setState(() {
            isObscure = !isObscure;
          });
        },
        child: cusIcon(
          isObscure ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
        ),
      ),
      validator: widget.validator,
      validate: widget.validate,
    );
  }
}

// email field
class EmailField extends StatefulWidget {
  const EmailField({
    super.key,
    this.label,
    this.controller,
    this.validate = false,
  });
  final String? label;
  final bool validate;
  final TextEditingController? controller;

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      controller: widget.controller,
      label: widget.label ?? "Adresse email",
      prefix: cusIcon(FontAwesomeIcons.at),
      type: TextInputType.emailAddress,
      validate: widget.validate,
      validator: (value) {
        if (!RegExp(
          "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]{2,}?\\.[a-zA-Z]{2,}\$",
        ).hasMatch(value!)) {
          if (!RegExp("^[a-zA-Z0-9._%-]{5,}").hasMatch(value)) {
            return "Entrez au moins 5 caractères avant le '@'";
          }
          if (!RegExp("^[.]*.[a-zA-Z0-9]{2,}\$").hasMatch(value)) {
            return "Nom de domaine invalide !";
          }
          return "Adresse email invalide !";
        }
        return null;
      },
    );
  }
}

// phone number field
class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    this.label,
    this.validate = false,
    this.controller,
  });
  final String? label;
  final bool validate;
  final TextEditingController? controller;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      controller: widget.controller,
      label: widget.label ?? "Numéro de téléphone",
      prefix: cusIcon(FontAwesomeIcons.phone),
      type: TextInputType.phone,
      validate: widget.validate,
      validator: (value) {
        if (!RegExp('^[0-9]{10}\$').hasMatch(value!)) {
          return "Entrez un numéro à 10 chiffres";
        }

        if (!RegExp("^(01|07|05)").hasMatch(value)) {
          return "Le numéro doit commencer par 01, 05 ou 07";
        }
        return null;
      },
    );
  }
}

// multiline field
class MultilineField extends StatefulWidget {
  const MultilineField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.validate = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool validate;

  @override
  State<MultilineField> createState() => _MultilineFieldState();
}

class _MultilineFieldState extends State<MultilineField> {
  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      label: widget.label,
      type: TextInputType.multiline,
      isObscure: false,
      maxLines: 4,
      validator: widget.validator,
      validate: widget.validate,
      controller: widget.controller,
    );
  }
}

// DateTime Field
class CustomDateTimeField extends StatelessWidget {
  const CustomDateTimeField({
    super.key,
    required this.label,
    this.prefix,
    this.suffix,
    this.defaultValue,
    this.firstDate,
    this.lastDate,
    this.validate = false,
    this.onChanged,
    this.validator,
    this.mode = DateTimeFieldPickerMode.dateAndTime,
  });

  final String label;
  final Widget? prefix;
  final Widget? suffix;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? defaultValue;
  final bool validate;
  final void Function(DateTime?)? onChanged;
  final String? Function(DateTime?)? validator;
  final DateTimeFieldPickerMode mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: DateTimeFormField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: notifire.getMaingey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: notifire.getMaingey),
          ),
          hintText: label,
          hintStyle: mediumGreyTextStyle,
          prefixIcon: prefix,
          suffixIcon: suffix,
        ),
        mode: mode,
        firstDate: firstDate,
        lastDate: lastDate,
        initialPickerDateTime: defaultValue ?? DateTime.now(),
        validator: (value) {
          if (validate) {
            if (value == null) {
              return "Ce champs est obligatoire";
            }
            if (validator != null) {
              return validator!(value);
            }
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}
