/// Type of a purchase request: capital expenditure or operational expenditure.
enum RequestType {
  /// Capital expenditure — investments, durable goods.
  capex,

  /// Operational expenditure — recurring operational costs.
  opex,
}

/// Status of a purchase request in the approval workflow.
enum RequestStatus {
  /// The request is being drafted and has not been submitted yet.
  draft,

  /// The request has been submitted and awaits first approval.
  submitted,

  /// The request is currently being reviewed by an approver.
  pendingApproval,

  /// The request has been fully approved.
  approved,

  /// The request has been rejected by an approver.
  rejected,

  /// An approver has requested changes from the requester.
  changesRequested,

  /// The request was returned after changes were made and re-submitted.
  resubmitted,
}

/// Priority level of a purchase request.
enum RequestPriority {
  /// Low priority — no urgency.
  low,

  /// Medium priority — standard processing.
  medium,

  /// High priority — expedited processing.
  high,

  /// Urgent — requires immediate attention.
  urgent,
}

/// Action that an approver can take on a purchase request.
enum ApprovalAction {
  /// Approve the request and forward it to the next level or finalize it.
  approved,

  /// Reject the request with a mandatory reason.
  rejected,

  /// Request modifications from the original requester.
  changesRequested,
}

/// Role that a user can have within a tenant organization.
enum UserRole {
  /// Platform-level super administrator.
  superAdmin,

  /// Tenant-level administrator who configures the organization.
  admin,

  /// Regular employee who can submit purchase requests.
  requester,

  /// Manager in the approval chain who can approve/reject requests.
  approver,

  /// Finance/controller role with global visibility on requests and budgets.
  controller,
}
