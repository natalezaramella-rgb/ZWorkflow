import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'ZWorkflow'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In it, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @requests.
  ///
  /// In it, this message translates to:
  /// **'Richieste'**
  String get requests;

  /// No description provided for @inbox.
  ///
  /// In it, this message translates to:
  /// **'Approvazioni'**
  String get inbox;

  /// No description provided for @budget.
  ///
  /// In it, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @profile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @organization.
  ///
  /// In it, this message translates to:
  /// **'Organizzazione'**
  String get organization;

  /// No description provided for @login.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get login;

  /// No description provided for @register.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In it, this message translates to:
  /// **'Conferma password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In it, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @loginWithGoogle.
  ///
  /// In it, this message translates to:
  /// **'Accedi con Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithEmail.
  ///
  /// In it, this message translates to:
  /// **'Accedi con email'**
  String get loginWithEmail;

  /// No description provided for @noAccount.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account?'**
  String get haveAccount;

  /// No description provided for @newRequest.
  ///
  /// In it, this message translates to:
  /// **'Nuova richiesta'**
  String get newRequest;

  /// No description provided for @description.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get description;

  /// No description provided for @estimatedAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo stimato'**
  String get estimatedAmount;

  /// No description provided for @type.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @capex.
  ///
  /// In it, this message translates to:
  /// **'CAPEX'**
  String get capex;

  /// No description provided for @opex.
  ///
  /// In it, this message translates to:
  /// **'OPEX'**
  String get opex;

  /// No description provided for @category.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @supplier.
  ///
  /// In it, this message translates to:
  /// **'Fornitore'**
  String get supplier;

  /// No description provided for @requestDate.
  ///
  /// In it, this message translates to:
  /// **'Data richiesta'**
  String get requestDate;

  /// No description provided for @desiredDeliveryDate.
  ///
  /// In it, this message translates to:
  /// **'Data consegna desiderata'**
  String get desiredDeliveryDate;

  /// No description provided for @priority.
  ///
  /// In it, this message translates to:
  /// **'Priorità'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In it, this message translates to:
  /// **'Bassa'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In it, this message translates to:
  /// **'Media'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In it, this message translates to:
  /// **'Alta'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In it, this message translates to:
  /// **'Urgente'**
  String get priorityUrgent;

  /// No description provided for @notes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get notes;

  /// No description provided for @costCenter.
  ///
  /// In it, this message translates to:
  /// **'Centro di costo'**
  String get costCenter;

  /// No description provided for @submit.
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get submit;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get edit;

  /// No description provided for @approve.
  ///
  /// In it, this message translates to:
  /// **'Approva'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In it, this message translates to:
  /// **'Rifiuta'**
  String get reject;

  /// No description provided for @requestChanges.
  ///
  /// In it, this message translates to:
  /// **'Richiedi modifiche'**
  String get requestChanges;

  /// No description provided for @rejectionReason.
  ///
  /// In it, this message translates to:
  /// **'Motivazione rifiuto'**
  String get rejectionReason;

  /// No description provided for @changesRequested.
  ///
  /// In it, this message translates to:
  /// **'Modifiche richieste'**
  String get changesRequested;

  /// No description provided for @approved.
  ///
  /// In it, this message translates to:
  /// **'Approvata'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In it, this message translates to:
  /// **'Rifiutata'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In it, this message translates to:
  /// **'In attesa'**
  String get pending;

  /// No description provided for @draft.
  ///
  /// In it, this message translates to:
  /// **'Bozza'**
  String get draft;

  /// No description provided for @submitted.
  ///
  /// In it, this message translates to:
  /// **'Inviata'**
  String get submitted;

  /// No description provided for @statusPendingApproval.
  ///
  /// In it, this message translates to:
  /// **'In attesa di approvazione'**
  String get statusPendingApproval;

  /// No description provided for @statusChangesRequested.
  ///
  /// In it, this message translates to:
  /// **'Modifiche richieste'**
  String get statusChangesRequested;

  /// No description provided for @allRequests.
  ///
  /// In it, this message translates to:
  /// **'Tutte le richieste'**
  String get allRequests;

  /// No description provided for @myRequests.
  ///
  /// In it, this message translates to:
  /// **'Le mie richieste'**
  String get myRequests;

  /// No description provided for @pendingApproval.
  ///
  /// In it, this message translates to:
  /// **'Da approvare'**
  String get pendingApproval;

  /// No description provided for @budgetRemaining.
  ///
  /// In it, this message translates to:
  /// **'Budget residuo'**
  String get budgetRemaining;

  /// No description provided for @budgetAllocated.
  ///
  /// In it, this message translates to:
  /// **'Budget allocato'**
  String get budgetAllocated;

  /// No description provided for @budgetConsumed.
  ///
  /// In it, this message translates to:
  /// **'Budget consumato'**
  String get budgetConsumed;

  /// No description provided for @budgetWarning.
  ///
  /// In it, this message translates to:
  /// **'Attenzione: questa richiesta supera il budget residuo di {amount}'**
  String budgetWarning(String amount);

  /// No description provided for @departments.
  ///
  /// In it, this message translates to:
  /// **'Reparti'**
  String get departments;

  /// No description provided for @employees.
  ///
  /// In it, this message translates to:
  /// **'Dipendenti'**
  String get employees;

  /// No description provided for @categories.
  ///
  /// In it, this message translates to:
  /// **'Categorie'**
  String get categories;

  /// No description provided for @costCenters.
  ///
  /// In it, this message translates to:
  /// **'Centri di costo'**
  String get costCenters;

  /// No description provided for @approvalRules.
  ///
  /// In it, this message translates to:
  /// **'Regole di approvazione'**
  String get approvalRules;

  /// No description provided for @hierarchy.
  ///
  /// In it, this message translates to:
  /// **'Gerarchia'**
  String get hierarchy;

  /// No description provided for @manager.
  ///
  /// In it, this message translates to:
  /// **'Responsabile'**
  String get manager;

  /// No description provided for @department.
  ///
  /// In it, this message translates to:
  /// **'Reparto'**
  String get department;

  /// No description provided for @role.
  ///
  /// In it, this message translates to:
  /// **'Ruolo'**
  String get role;

  /// No description provided for @roles.
  ///
  /// In it, this message translates to:
  /// **'Ruoli'**
  String get roles;

  /// No description provided for @admin.
  ///
  /// In it, this message translates to:
  /// **'Amministratore'**
  String get admin;

  /// No description provided for @requester.
  ///
  /// In it, this message translates to:
  /// **'Richiedente'**
  String get requester;

  /// No description provided for @approver.
  ///
  /// In it, this message translates to:
  /// **'Approvatore'**
  String get approver;

  /// No description provided for @controller.
  ///
  /// In it, this message translates to:
  /// **'Controller'**
  String get controller;

  /// No description provided for @superAdmin.
  ///
  /// In it, this message translates to:
  /// **'Super Admin'**
  String get superAdmin;

  /// No description provided for @year.
  ///
  /// In it, this message translates to:
  /// **'Anno'**
  String get year;

  /// No description provided for @amount.
  ///
  /// In it, this message translates to:
  /// **'Importo'**
  String get amount;

  /// No description provided for @minAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo minimo'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo massimo'**
  String get maxAmount;

  /// No description provided for @requiredLevels.
  ///
  /// In it, this message translates to:
  /// **'Livelli approvazione richiesti'**
  String get requiredLevels;

  /// No description provided for @approvalHistory.
  ///
  /// In it, this message translates to:
  /// **'Cronologia approvazioni'**
  String get approvalHistory;

  /// No description provided for @level.
  ///
  /// In it, this message translates to:
  /// **'Livello'**
  String get level;

  /// No description provided for @action.
  ///
  /// In it, this message translates to:
  /// **'Azione'**
  String get action;

  /// No description provided for @comment.
  ///
  /// In it, this message translates to:
  /// **'Commento'**
  String get comment;

  /// No description provided for @date.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @search.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In it, this message translates to:
  /// **'Filtra'**
  String get filter;

  /// No description provided for @noResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato'**
  String get noResults;

  /// No description provided for @loading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In it, this message translates to:
  /// **'Errore'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @welcomeBack.
  ///
  /// In it, this message translates to:
  /// **'Bentornato!'**
  String get welcomeBack;

  /// No description provided for @requestsToApprove.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessuna richiesta da approvare} =1{1 richiesta da approvare} other{{count} richieste da approvare}}'**
  String requestsToApprove(num count);

  /// No description provided for @totalBudgetCapex.
  ///
  /// In it, this message translates to:
  /// **'Budget CAPEX totale'**
  String get totalBudgetCapex;

  /// No description provided for @totalBudgetOpex.
  ///
  /// In it, this message translates to:
  /// **'Budget OPEX totale'**
  String get totalBudgetOpex;

  /// No description provided for @addDepartment.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi reparto'**
  String get addDepartment;

  /// No description provided for @addEmployee.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi dipendente'**
  String get addEmployee;

  /// No description provided for @addCategory.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi categoria'**
  String get addCategory;

  /// No description provided for @addCostCenter.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi centro di costo'**
  String get addCostCenter;

  /// No description provided for @addRule.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi regola'**
  String get addRule;

  /// No description provided for @editDepartment.
  ///
  /// In it, this message translates to:
  /// **'Modifica reparto'**
  String get editDepartment;

  /// No description provided for @editEmployee.
  ///
  /// In it, this message translates to:
  /// **'Modifica dipendente'**
  String get editEmployee;

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @code.
  ///
  /// In it, this message translates to:
  /// **'Codice'**
  String get code;

  /// No description provided for @active.
  ///
  /// In it, this message translates to:
  /// **'Attivo'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In it, this message translates to:
  /// **'Inattivo'**
  String get inactive;

  /// No description provided for @confirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get confirm;

  /// No description provided for @deleteConfirmation.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare questo elemento?'**
  String get deleteConfirmation;

  /// No description provided for @savedSuccessfully.
  ///
  /// In it, this message translates to:
  /// **'Salvato con successo'**
  String get savedSuccessfully;

  /// No description provided for @errorSaving.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il salvataggio'**
  String get errorSaving;

  /// No description provided for @requestSubmitted.
  ///
  /// In it, this message translates to:
  /// **'Richiesta inviata con successo'**
  String get requestSubmitted;

  /// No description provided for @requestApproved.
  ///
  /// In it, this message translates to:
  /// **'Richiesta approvata'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In it, this message translates to:
  /// **'Richiesta rifiutata'**
  String get requestRejected;

  /// No description provided for @currentApprover.
  ///
  /// In it, this message translates to:
  /// **'Approvatore corrente'**
  String get currentApprover;

  /// No description provided for @approvalLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello {current} di {total}'**
  String approvalLevel(int current, int total);

  /// No description provided for @notifications.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get notifications;

  /// No description provided for @notificationPreferences.
  ///
  /// In it, this message translates to:
  /// **'Preferenze notifiche'**
  String get notificationPreferences;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In it, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In it, this message translates to:
  /// **'Modalità scura'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In it, this message translates to:
  /// **'Modalità chiara'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In it, this message translates to:
  /// **'Segui sistema'**
  String get systemMode;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
