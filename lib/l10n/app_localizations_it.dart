// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'ZWorkflow';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get requests => 'Richieste';

  @override
  String get inbox => 'Approvazioni';

  @override
  String get budget => 'Budget';

  @override
  String get profile => 'Profilo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get organization => 'Organizzazione';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Registrati';

  @override
  String get logout => 'Esci';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get fullName => 'Nome completo';

  @override
  String get loginWithGoogle => 'Accedi con Google';

  @override
  String get loginWithEmail => 'Accedi con email';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get haveAccount => 'Hai già un account?';

  @override
  String get newRequest => 'Nuova richiesta';

  @override
  String get description => 'Descrizione';

  @override
  String get estimatedAmount => 'Importo stimato';

  @override
  String get type => 'Tipo';

  @override
  String get capex => 'CAPEX';

  @override
  String get opex => 'OPEX';

  @override
  String get category => 'Categoria';

  @override
  String get supplier => 'Fornitore';

  @override
  String get requestDate => 'Data richiesta';

  @override
  String get desiredDeliveryDate => 'Data consegna desiderata';

  @override
  String get priority => 'Priorità';

  @override
  String get priorityLow => 'Bassa';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityUrgent => 'Urgente';

  @override
  String get notes => 'Note';

  @override
  String get costCenter => 'Centro di costo';

  @override
  String get submit => 'Invia';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get approve => 'Approva';

  @override
  String get reject => 'Rifiuta';

  @override
  String get requestChanges => 'Richiedi modifiche';

  @override
  String get rejectionReason => 'Motivazione rifiuto';

  @override
  String get changesRequested => 'Modifiche richieste';

  @override
  String get approved => 'Approvata';

  @override
  String get rejected => 'Rifiutata';

  @override
  String get pending => 'In attesa';

  @override
  String get draft => 'Bozza';

  @override
  String get submitted => 'Inviata';

  @override
  String get statusPendingApproval => 'In attesa di approvazione';

  @override
  String get statusChangesRequested => 'Modifiche richieste';

  @override
  String get allRequests => 'Tutte le richieste';

  @override
  String get myRequests => 'Le mie richieste';

  @override
  String get pendingApproval => 'Da approvare';

  @override
  String get budgetRemaining => 'Budget residuo';

  @override
  String get budgetAllocated => 'Budget allocato';

  @override
  String get budgetConsumed => 'Budget consumato';

  @override
  String budgetWarning(String amount) {
    return 'Attenzione: questa richiesta supera il budget residuo di $amount';
  }

  @override
  String get departments => 'Reparti';

  @override
  String get employees => 'Dipendenti';

  @override
  String get categories => 'Categorie';

  @override
  String get costCenters => 'Centri di costo';

  @override
  String get approvalRules => 'Regole di approvazione';

  @override
  String get hierarchy => 'Gerarchia';

  @override
  String get manager => 'Responsabile';

  @override
  String get department => 'Reparto';

  @override
  String get role => 'Ruolo';

  @override
  String get roles => 'Ruoli';

  @override
  String get admin => 'Amministratore';

  @override
  String get requester => 'Richiedente';

  @override
  String get approver => 'Approvatore';

  @override
  String get controller => 'Controller';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get year => 'Anno';

  @override
  String get amount => 'Importo';

  @override
  String get minAmount => 'Importo minimo';

  @override
  String get maxAmount => 'Importo massimo';

  @override
  String get requiredLevels => 'Livelli approvazione richiesti';

  @override
  String get approvalHistory => 'Cronologia approvazioni';

  @override
  String get level => 'Livello';

  @override
  String get action => 'Azione';

  @override
  String get comment => 'Commento';

  @override
  String get date => 'Data';

  @override
  String get search => 'Cerca';

  @override
  String get filter => 'Filtra';

  @override
  String get noResults => 'Nessun risultato';

  @override
  String get loading => 'Caricamento...';

  @override
  String get error => 'Errore';

  @override
  String get retry => 'Riprova';

  @override
  String get welcomeBack => 'Bentornato!';

  @override
  String requestsToApprove(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste da approvare',
      one: '1 richiesta da approvare',
      zero: 'Nessuna richiesta da approvare',
    );
    return '$_temp0';
  }

  @override
  String get totalBudgetCapex => 'Budget CAPEX totale';

  @override
  String get totalBudgetOpex => 'Budget OPEX totale';

  @override
  String get addDepartment => 'Aggiungi reparto';

  @override
  String get addEmployee => 'Aggiungi dipendente';

  @override
  String get addCategory => 'Aggiungi categoria';

  @override
  String get addCostCenter => 'Aggiungi centro di costo';

  @override
  String get addRule => 'Aggiungi regola';

  @override
  String get editDepartment => 'Modifica reparto';

  @override
  String get editEmployee => 'Modifica dipendente';

  @override
  String get name => 'Nome';

  @override
  String get code => 'Codice';

  @override
  String get active => 'Attivo';

  @override
  String get inactive => 'Inattivo';

  @override
  String get confirm => 'Conferma';

  @override
  String get deleteConfirmation =>
      'Sei sicuro di voler eliminare questo elemento?';

  @override
  String get savedSuccessfully => 'Salvato con successo';

  @override
  String get errorSaving => 'Errore durante il salvataggio';

  @override
  String get requestSubmitted => 'Richiesta inviata con successo';

  @override
  String get requestApproved => 'Richiesta approvata';

  @override
  String get requestRejected => 'Richiesta rifiutata';

  @override
  String get currentApprover => 'Approvatore corrente';

  @override
  String approvalLevel(int current, int total) {
    return 'Livello $current di $total';
  }

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationPreferences => 'Preferenze notifiche';

  @override
  String get language => 'Lingua';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get lightMode => 'Modalità chiara';

  @override
  String get systemMode => 'Segui sistema';
}
