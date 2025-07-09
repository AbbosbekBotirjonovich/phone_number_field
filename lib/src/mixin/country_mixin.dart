import 'package:flutter/services.dart';
import 'package:phone_number_field/src/extension/country_extension.dart';

import '../model/country.dart';

mixin CountryMixin {
  List<Country> _countries = [];

  List<Country> get countries => _countries;


  Future<List<Country>> getCountries() async {
    final countriesData = await rootBundle.loadString(
      'packages/phone_number_field/assets/countries.txt',
    );
    var lines = countriesData.split('\n');
    _countries = lines.map((line) {
      var parts = line.trim().split(';');
      return Country(
        code: parts[0],
        emoji: parts[1].countryEmoji,
        name: parts[2],
        format: parts.length > 3 ? parts[3] : null,
      );
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
    return _countries;
  }

  Country? findCountryCode(String value) {
    for (var country in countries) {
      if (country.code == value) {
        return country;
      }
    }
    return null;
  }

  Country? findCountryStartWith(String value) {
    for (var country in countries) {
      if (value.startsWith(country.code)) {
        return country;
      }
    }
    return null;
  }
}
