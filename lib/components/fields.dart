import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


// Custom form text field
class CustomFormTextField extends StatefulWidget {
  const CustomFormTextField({
    super.key,
    required this.label,
    required this.prefix,
    this.isObscure = false,
    this.validator,
    this.validate = false,
    this.suffix,
    this.controller
  });

  final String label;
  final bool isObscure;
  final Widget prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final bool validate;
  final TextEditingController? controller;

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
        style: TextStyle(color: notifire!.getMainText),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide:  BorderSide(color: notifire!.isDark?   notifire!.geticoncolor  :Colors.grey.shade200)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide:  BorderSide(color: notifire!.isDark?   notifire!.geticoncolor  :Colors.grey.shade200)),
          hintText: widget.label,
          hintStyle: mediumGreyTextStyle,
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix,
        ),
        obscureText: widget.isObscure,
        validator: (value) {
          if (widget.validate) {
            if (value == null && value!.isEmpty) {
              return "Ce champs est obligatoire";
            }
            widget.validator != null ? widget.validator!(value) : null;
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
    this.onChanged
  });

  final String value;
  final String label;
  final Widget? prefix;
  final Widget? suffix;
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
              borderSide:  BorderSide(color: notifire!.isDark? notifire!.geticoncolor:Colors.grey.shade200)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide:  BorderSide(color: notifire!.isDark? notifire!.geticoncolor:Colors.grey.shade200)),
          hintText: widget.label,
          hintStyle: mediumGreyTextStyle,
          prefixIcon: widget.prefix,
        ),
        icon: cusIcon(FontAwesomeIcons.sort),
        items: widget.items,
        onChanged: widget.onChanged
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
    this.validator
  });

  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

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
      suffix: GestureDetector(
        onTap: () {
          setState(() {
            isObscure = !isObscure;
          });
        },
        child: cusIcon(isObscure ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash),
      ),
      validator: widget.validator,
    );
  }
}

