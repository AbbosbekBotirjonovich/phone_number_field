import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number_field/src/formatter/country_formatter.dart';
import 'package:phone_number_field/src/formatter/mask_input_formatter.dart';
import 'package:phone_number_field/src/model/country.dart';

import '../mixin/country_mixin.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    this.onCountrySelected,
    this.initialCountry,
    this.label,
    this.borderColor,
    this.focusColor,
    this.borderRadius = 8,
    this.labelStyle,
    this.isLabelInside = false,
    this.onChanged,
    this.initialCountryCode,
    this.onCompleted,
    this.suffix,
    this.contentPaddingCode,
    this.contentPaddingNumber,
  });

  /// Called when the user selects a country.
  final ValueChanged<Country?>? onCountrySelected;

  /// The initial country to display.
  final Country? initialCountry;

  /// The initial country code to display. only works one time create widget
  final String? initialCountryCode;

  /// The label displayed above the text field.
  final String? label;

  ///This color is used to colorize the border when the text field is focused. defaults to [Theme.of(context).colorScheme.primary]
  final Color? focusColor;

  ///This color is used to colorize the border when the text field is not focused. defaults to [Theme.of(context).colorScheme.secondary]
  final Color? borderColor;

  /// The border radius of the text field. defaults to 8
  final double borderRadius;

  /// The style of the label.
  final TextStyle? labelStyle;

  /// If true, the label is displayed inside the text field. defaults to false
  final bool isLabelInside;

  /// Called when the text in the text field changes.
  final ValueChanged<String>? onChanged;

  /// Called when the text in the text field is completed
  final ValueChanged<String>? onCompleted;

  /// The suffix widget to display at the end of the text field.
  final Widget? suffix;

  /// The padding of the text field.
  final EdgeInsetsGeometry? contentPaddingCode;

  /// The padding of the text field.
  final EdgeInsetsGeometry? contentPaddingNumber;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> with CountryMixin {
  late FocusNode _codeFocusNode;
  late FocusNode _numberFocusNode;

  late TextEditingController _codeController;
  late TextEditingController _numberController;

  final ValueNotifier<Country?> _selectedCountry = ValueNotifier(null);

  final ValueNotifier<bool> _isFocused = ValueNotifier(false);

  void _onCountrySelectListener() {
    widget.onCountrySelected?.call(_selectedCountry.value);
  }

  void _focusListener() {
    _isFocused.value = _codeFocusNode.hasFocus || _numberFocusNode.hasFocus;
  }

  @override
  void initState() {
    _codeFocusNode = FocusNode()
      ..requestFocus()
      ..addListener(_focusListener);
    _numberFocusNode = FocusNode()..addListener(_focusListener);
    _codeController = TextEditingController();
    _numberController = TextEditingController();
    getCountries();
    _selectedCountry.addListener(_onCountrySelectListener);

    if (widget.initialCountryCode != null) {
      _selectedCountry.value = findCountryCode(widget.initialCountryCode!);
      _codeController.text = widget.initialCountryCode!;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PhoneNumberField oldWidget) {
    if (oldWidget.initialCountry != widget.initialCountry && widget.initialCountry != null) {
      _selectedCountry.value = widget.initialCountry;
      _codeController.text = widget.initialCountry!.code;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _codeFocusNode
      ..removeListener(_focusListener)
      ..dispose();
    _numberFocusNode
      ..removeListener(_focusListener)
      ..dispose();
    _codeController.dispose();
    _numberController.dispose();
    _selectedCountry.removeListener(_onCountrySelectListener);
    _selectedCountry.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, ctc) {
        var maxWidth = ctc.maxWidth;
        return ValueListenableBuilder(
          valueListenable: _isFocused,
          builder: (_, value, _) {
            return CustomPaint(
              painter: _PhoneNumberFieldBorderPainter(
                isLabelInside: widget.isLabelInside,
                radius: widget.borderRadius,
                labelStyle: widget.labelStyle,
                label: widget.label,
                color: value
                    ? (widget.focusColor ?? Theme.of(context).colorScheme.primary)
                    : (widget.borderColor ?? Theme.of(context).colorScheme.secondary),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      decoration: _InputDecoration(
                        prefixIcon: Padding(
                          padding: widget.contentPaddingCode ?? const EdgeInsets.only(left: 14),
                          child: Text('+'),
                        ),
                        suffixIcon: CustomPaint(
                          painter: _VerticalDividerPainter(),
                          child: Text(''),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        _selectedCountry.value = findCountryCode(value);

                        if (value.length >= 2 && _selectedCountry.value != null) {
                          _codeController.text = _selectedCountry.value!.code;

                          FocusScope.of(context).requestFocus(_numberFocusNode);
                          return;
                        }

                        if (value.length >= 4) {
                          _selectedCountry.value ??= findCountryStartWith(value);
                          if (_selectedCountry.value != null) {
                            _codeController.text = _selectedCountry.value!.code;
                            _numberController.text = value.replaceFirst(
                              _selectedCountry.value!.code,
                              '',
                            );
                            widget.onCountrySelected?.call(_selectedCountry.value!);
                          }
                          FocusScope.of(context).requestFocus(_numberFocusNode);
                        }
                      },
                      inputFormatters: [CountryFormatter(maxLength: 4)],
                    ),
                  ),
                  KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (value) {
                      if (value.logicalKey == LogicalKeyboardKey.backspace &&
                          _numberController.text.isEmpty) {
                        FocusScope.of(context).requestFocus(_codeFocusNode);
                      }
                    },
                    child: SizedBox(
                      width: maxWidth * .75,
                      child: ValueListenableBuilder(
                        valueListenable: _selectedCountry,
                        builder: (context, value, child) => TextFormField(
                          controller: _numberController,
                          focusNode: _numberFocusNode,
                          keyboardType: TextInputType.phone,
                          decoration: _InputDecoration(
                            contentPadding:
                                widget.contentPaddingNumber ?? const EdgeInsets.only(left: 16),
                            suffix: widget.suffix,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              FocusScope.of(context).requestFocus(_codeFocusNode);
                            }
                          },
                          onFieldSubmitted: (value) {
                            widget.onCompleted?.call(
                              '+${_codeController.text}${_numberController.text.replaceAll(' ', '')}',
                            );
                          },
                          inputFormatters: [
                            CountryFormatter(),
                            if (value != null && value.format != null && value.format!.isNotEmpty)
                              MaskTextInputFormatter(
                                mask: value.format,
                                filter: {'X': RegExp(r'[0-9]')},
                                initialText: _numberController.text,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PhoneNumberFieldBorderPainter extends CustomPainter {
  final Color? color;
  final String? label;
  final double radius;
  final bool isLabelInside;
  final TextStyle? labelStyle;

  _PhoneNumberFieldBorderPainter({
    this.label,
    this.color,
    this.radius = 8,
    this.isLabelInside = false,
    this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    final textSpan = TextSpan(
      text: label,
      style: labelStyle ?? TextStyle(color: color, fontSize: 12),
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    final labelOffset = isLabelInside
        ? Offset(14, rect.height / 4 - textPainter.height)
        : Offset(14, -textPainter.height / 2);
    final labelWidth = textPainter.width;

    final borderPaint = Paint()
      ..color = color ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    final left = rect.left;
    final top = rect.top - (isLabelInside ? 4 : 0);
    final right = rect.right;
    final bottom = rect.bottom + (isLabelInside ? 4 : 0);

    path.moveTo(left + radius, top);
    path.lineTo(isLabelInside || label == null ? rect.center.dx : labelOffset.dx - 4, top);

    path.moveTo(labelOffset.dx + labelWidth + 4, top);
    path.lineTo(right - radius, top);

    path.arcToPoint(Offset(right, top + radius), radius: Radius.circular(radius));
    path.lineTo(right, bottom - radius);
    path.arcToPoint(Offset(right - radius, bottom), radius: Radius.circular(radius));

    path.lineTo(left + radius, bottom);
    path.arcToPoint(Offset(left, bottom - radius), radius: Radius.circular(radius));

    path.lineTo(left, top + radius);
    path.arcToPoint(Offset(left + radius, top), radius: Radius.circular(radius));

    canvas.drawPath(path, borderPaint);

    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InputDecoration extends InputDecoration {
  final EdgeInsetsGeometry? $contentPadding;
  final Widget? $suffix;
  final Widget? $prefix;
  final Widget? $prefixIcon;
  final Widget? $suffixIcon;

  const _InputDecoration({
    super.prefixIcon,
    super.suffixIcon,
    super.prefix,
    super.suffix,
    super.contentPadding,
  }) : $prefix = prefix,
       $suffix = suffix,
       $contentPadding = contentPadding,
       $prefixIcon = prefixIcon,
       $suffixIcon = suffixIcon,
       super(
         border: InputBorder.none,
         focusedBorder: InputBorder.none,
         enabledBorder: InputBorder.none,
         errorBorder: InputBorder.none,
         disabledBorder: InputBorder.none,
         enabled: true,
         prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
         suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
       );
}

class _VerticalDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(rect.bottomCenter, rect.topCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
