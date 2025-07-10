import 'package:flutter/material.dart';
import 'package:phone_number_field/src/mixin/country_mixin.dart';
import 'package:phone_number_field/src/widgets/country_widget.dart';

import '../model/country.dart';

class CountriesWidget extends StatefulWidget {
  const CountriesWidget({super.key, this.onCountrySelected});

  final ValueChanged<Country>? onCountrySelected;

  @override
  State<CountriesWidget> createState() => _CountriesWidgetState();
}

class _CountriesWidgetState extends State<CountriesWidget> with CountryMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCountries();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: countries.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          widget.onCountrySelected?.call(countries[index]);
        },
        leading: Text(countries[index].emoji, style: TextStyle(fontSize: 26)),
        title: Text(countries[index].name),
        trailing: Text(
          '+${countries[index].code}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class CountrySearchDelegate extends SearchDelegate<Country> with CountryMixin {
  List<Country> _countries = [];

  CountrySearchDelegate() {
    _setCountries();
  }

  void _setCountries() async {
    _countries = await getCountries();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        CloseButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) => BackButton();

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (_, index) => CountryWidget(
        country: _suggestions[index],
        onPressed: () {
          close(context, _suggestions[index]);
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (_, index) => CountryWidget(
        country: _suggestions[index],
        onPressed: () {
          close(context, _suggestions[index]);
        },
      ),
    );
  }

  List<Country> get _suggestions => _countries
      .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}
