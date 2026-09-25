// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZWorkflow';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get requests => 'Requests';

  @override
  String get inbox => 'Approvals';

  @override
  String get budget => 'Budget';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get organization => 'Organization';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Log out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fullName => 'Full name';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithEmail => 'Sign in with email';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get newRequest => 'New request';

  @override
  String get description => 'Description';

  @override
  String get estimatedAmount => 'Estimated amount';

  @override
  String get type => 'Type';

  @override
  String get capex => 'CAPEX';

  @override
  String get opex => 'OPEX';

  @override
  String get category => 'Category';

  @override
  String get supplier => 'Supplier';

  @override
  String get requestDate => 'Request date';

  @override
  String get desiredDeliveryDate => 'Desired delivery date';

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get notes => 'Notes';

  @override
  String get costCenter => 'Cost center';

  @override
  String get submit => 'Submit';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get requestChanges => 'Request changes';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get changesRequested => 'Changes requested';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String get draft => 'Draft';

  @override
  String get submitted => 'Submitted';

  @override
  String get statusPendingApproval => 'Pending approval';

  @override
  String get statusChangesRequested => 'Changes requested';

  @override
  String get allRequests => 'All requests';

  @override
  String get myRequests => 'My requests';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get budgetRemaining => 'Remaining budget';

  @override
  String get budgetAllocated => 'Allocated budget';

  @override
  String get budgetConsumed => 'Consumed budget';

  @override
  String budgetWarning(String amount) {
    return 'Warning: this request exceeds the remaining budget by $amount';
  }

  @override
  String get departments => 'Departments';

  @override
  String get employees => 'Employees';

  @override
  String get categories => 'Categories';

  @override
  String get costCenters => 'Cost centers';

  @override
  String get approvalRules => 'Approval rules';

  @override
  String get hierarchy => 'Hierarchy';

  @override
  String get manager => 'Manager';

  @override
  String get department => 'Department';

  @override
  String get role => 'Role';

  @override
  String get roles => 'Roles';

  @override
  String get admin => 'Administrator';

  @override
  String get requester => 'Requester';

  @override
  String get approver => 'Approver';

  @override
  String get controller => 'Controller';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get year => 'Year';

  @override
  String get amount => 'Amount';

  @override
  String get minAmount => 'Minimum amount';

  @override
  String get maxAmount => 'Maximum amount';

  @override
  String get requiredLevels => 'Required approval levels';

  @override
  String get approvalHistory => 'Approval history';

  @override
  String get level => 'Level';

  @override
  String get action => 'Action';

  @override
  String get comment => 'Comment';

  @override
  String get date => 'Date';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get noResults => 'No results';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String requestsToApprove(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests to approve',
      one: '1 request to approve',
      zero: 'No requests to approve',
    );
    return '$_temp0';
  }

  @override
  String get totalBudgetCapex => 'Total CAPEX budget';

  @override
  String get totalBudgetOpex => 'Total OPEX budget';

  @override
  String get addDepartment => 'Add department';

  @override
  String get addEmployee => 'Add employee';

  @override
  String get addCategory => 'Add category';

  @override
  String get addCostCenter => 'Add cost center';

  @override
  String get addRule => 'Add rule';

  @override
  String get editDepartment => 'Edit department';

  @override
  String get editEmployee => 'Edit employee';

  @override
  String get name => 'Name';

  @override
  String get code => 'Code';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this item?';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get errorSaving => 'Error while saving';

  @override
  String get requestSubmitted => 'Request submitted successfully';

  @override
  String get requestApproved => 'Request approved';

  @override
  String get requestRejected => 'Request rejected';

  @override
  String get currentApprover => 'Current approver';

  @override
  String approvalLevel(int current, int total) {
    return 'Level $current of $total';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get systemMode => 'Follow system';
}
