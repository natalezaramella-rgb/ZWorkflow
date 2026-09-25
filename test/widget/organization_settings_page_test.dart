import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/features/organization/presentation/pages/organization_settings_page.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

void main() {
  Widget buildTestableWidget() {
    return const MaterialApp(
      locale: Locale('it'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: OrganizationSettingsPage(),
    );
  }

  testWidgets('OrganizationSettingsPage renders sections and seed demo tile',
      (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify sections rendered
    expect(find.byType(ListTile), findsWidgets);
    expect(find.text('Inizializza Dati Demo'), findsOneWidget);
    expect(find.text('Popola reparti, gerarchia e budget su Firestore'),
        findsOneWidget);

    // Tap on Inizializza Dati Demo to open dialog
    await tester.tap(find.text('Inizializza Dati Demo'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Inizializzazione Dati Demo'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.text('Inizializza'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
