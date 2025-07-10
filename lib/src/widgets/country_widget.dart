import 'package:flutter/material.dart';
import 'package:phone_number_field/src/model/country.dart';

class CountryWidget extends StatelessWidget {
  const CountryWidget({super.key, required this.country, this.onPressed});

  final Country country;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      title: Text(country.name),
      leading: Text(country.emoji, style: TextStyle(fontSize: 24)),
      trailing: Text(
        '+${country.code}',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
