import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'FuelUp'**
  String get appTitle;

  /// No description provided for @stations.
  ///
  /// In pl, this message translates to:
  /// **'Stacje'**
  String get stations;

  /// No description provided for @allLocations.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie lokalizacje'**
  String get allLocations;

  /// No description provided for @city.
  ///
  /// In pl, this message translates to:
  /// **'Miasto'**
  String get city;

  /// No description provided for @fuel.
  ///
  /// In pl, this message translates to:
  /// **'Paliwo'**
  String get fuel;

  /// No description provided for @allFuels.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie paliwa'**
  String get allFuels;

  /// No description provided for @clearFilters.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść filtry'**
  String get clearFilters;

  /// No description provided for @noStations.
  ///
  /// In pl, this message translates to:
  /// **'Brak stacji spełniających kryteria'**
  String get noStations;

  /// No description provided for @currentPrices.
  ///
  /// In pl, this message translates to:
  /// **'Aktualne ceny'**
  String get currentPrices;

  /// No description provided for @priceHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia cen'**
  String get priceHistory;

  /// No description provided for @openingHours.
  ///
  /// In pl, this message translates to:
  /// **'Godziny otwarcia'**
  String get openingHours;

  /// No description provided for @update.
  ///
  /// In pl, this message translates to:
  /// **'Aktualizacja'**
  String get update;

  /// No description provided for @closed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięte'**
  String get closed;

  /// No description provided for @details.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły'**
  String get details;

  /// No description provided for @admin.
  ///
  /// In pl, this message translates to:
  /// **'Panel admina'**
  String get admin;

  /// No description provided for @addStation.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj nową stację'**
  String get addStation;

  /// No description provided for @editStation.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj stację'**
  String get editStation;

  /// No description provided for @newStation.
  ///
  /// In pl, this message translates to:
  /// **'Nowa stacja'**
  String get newStation;

  /// No description provided for @stationName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get stationName;

  /// No description provided for @address.
  ///
  /// In pl, this message translates to:
  /// **'Adres'**
  String get address;

  /// No description provided for @websiteUrl.
  ///
  /// In pl, this message translates to:
  /// **'URL strony'**
  String get websiteUrl;

  /// No description provided for @latitude.
  ///
  /// In pl, this message translates to:
  /// **'Szerokość geo.'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In pl, this message translates to:
  /// **'Długość geo.'**
  String get longitude;

  /// No description provided for @scraperType.
  ///
  /// In pl, this message translates to:
  /// **'Typ scrapera'**
  String get scraperType;

  /// No description provided for @filterByCity.
  ///
  /// In pl, this message translates to:
  /// **'Filtruj po mieście'**
  String get filterByCity;

  /// No description provided for @add.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get add;

  /// No description provided for @save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @deleteStation.
  ///
  /// In pl, this message translates to:
  /// **'Usuń stację'**
  String get deleteStation;

  /// No description provided for @deleteStationConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć tę stację?'**
  String get deleteStationConfirm;

  /// No description provided for @openingHoursFor.
  ///
  /// In pl, this message translates to:
  /// **'Godziny otwarcia'**
  String get openingHoursFor;

  /// No description provided for @saveHours.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz godziny'**
  String get saveHours;

  /// No description provided for @opening.
  ///
  /// In pl, this message translates to:
  /// **'Otwarcie'**
  String get opening;

  /// No description provided for @closing.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięcie'**
  String get closing;

  /// No description provided for @error.
  ///
  /// In pl, this message translates to:
  /// **'Błąd'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get retry;

  /// No description provided for @noHistory.
  ///
  /// In pl, this message translates to:
  /// **'Brak historii dla tego paliwa'**
  String get noHistory;

  /// No description provided for @monday.
  ///
  /// In pl, this message translates to:
  /// **'Poniedziałek'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In pl, this message translates to:
  /// **'Wtorek'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In pl, this message translates to:
  /// **'Środa'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In pl, this message translates to:
  /// **'Czwartek'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In pl, this message translates to:
  /// **'Piątek'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In pl, this message translates to:
  /// **'Sobota'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In pl, this message translates to:
  /// **'Niedziela'**
  String get sunday;

  /// No description provided for @holiday.
  ///
  /// In pl, this message translates to:
  /// **'Niehandlowa'**
  String get holiday;

  /// No description provided for @noPrices.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktualnych cen'**
  String get noPrices;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
