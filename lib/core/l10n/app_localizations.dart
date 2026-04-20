import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _strings = {};

  static Future<AppLocalizations> load(Locale locale) async {
    final instance = AppLocalizations(locale);
    final jsonString = await rootBundle.loadString(
      'assets/l10n/${locale.languageCode}.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    instance._strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
    return instance;
  }

  String _t(String key) => _strings[key] ?? key;

  // ── App ─────────────────────────────────────────────────────────────────
  String get appName => _t('appName');
  String get appTagline => _t('appTagline');

  // ── Login ────────────────────────────────────────────────────────────────
  String get loginSignIn => _t('loginSignIn');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginTypeEmail => _t('loginTypeEmail');
  String get loginTypeMobile => _t('loginTypeMobile');
  String get loginLabelMobileNumber => _t('loginLabelMobileNumber');
  String get loginLabelEmail => _t('loginLabelEmail');
  String get loginHintMobileNumber => _t('loginHintMobileNumber');
  String get loginHintEmail => _t('loginHintEmail');
  String get loginValidationMobileRequired =>
      _t('loginValidationMobileRequired');
  String get loginValidationEmailRequired => _t('loginValidationEmailRequired');
  String get loginValidationMobileLength => _t('loginValidationMobileLength');
  String get loginValidationMobileInvalid => _t('loginValidationMobileInvalid');
  String get loginValidationEmailInvalid => _t('loginValidationEmailInvalid');
  String get loginSendOtpButton => _t('loginSendOtpButton');

  // ── Verify OTP ───────────────────────────────────────────────────────────
  String get verifyOtpScreenTitle => _t('verifyOtpScreenTitle');
  String get verifyOtpHeading => _t('verifyOtpHeading');
  String verifyOtpSentTo(String identifier) =>
      _t('verifyOtpSentTo').replaceAll('{identifier}', identifier);
  String get verifyOtpButton => _t('verifyOtpButton');
  String get verifyOtpResendButton => _t('verifyOtpResendButton');
  String get verifyOtpResendSuccess => _t('verifyOtpResendSuccess');

  // ── Dashboard ────────────────────────────────────────────────────────────
  String get dashboardTitle => _t('dashboardTitle');
  String get dashboardRefreshTooltip => _t('dashboardRefreshTooltip');
  String get dashboardNavDashboard => _t('dashboardNavDashboard');
  String get dashboardNavMyPolls => _t('dashboardNavMyPolls');
  String get dashboardNavWorkspaces => _t('dashboardNavWorkspaces');
  String get dashboardNavProfile => _t('dashboardNavProfile');
  String get dashboardNavSettings => _t('dashboardNavSettings');
  String get dashboardWelcomeBack => _t('dashboardWelcomeBack');
  String get dashboardVoteraSubtitle => _t('dashboardVoteraSubtitle');
  String get dashboardStatActivePolls => _t('dashboardStatActivePolls');
  String get dashboardStatVotesCast => _t('dashboardStatVotesCast');
  String get dashboardStatVoters => _t('dashboardStatVoters');
  String get dashboardActivePollsSection => _t('dashboardActivePollsSection');
  String get dashboardNoActivePolls => _t('dashboardNoActivePolls');
  String dashboardPollVotesDaysLeft(int votes, int daysLeft) {
    final template = daysLeft == 1
        ? _t('dashboardPollVotesAndDaysLeft')
        : _t('dashboardPollVotesAndDaysLeftPlural');
    return template
        .replaceAll('{votes}', '$votes')
        .replaceAll('{daysLeft}', '$daysLeft');
  }

  String get dashboardPollStatusVoted => _t('dashboardPollStatusVoted');
  String get dashboardPollStatusNotVoted => _t('dashboardPollStatusNotVoted');
  String dashboardWelcomeOverlayTitle(String appName) =>
      _t('dashboardWelcomeOverlayTitle').replaceAll('{appName}', appName);
  String get dashboardGetStartedButton => _t('dashboardGetStartedButton');
  String get dashboardCompleteProfileTitle =>
      _t('dashboardCompleteProfileTitle');
  String get dashboardCompleteProfileBody => _t('dashboardCompleteProfileBody');
  String get dashboardCompleteProfileButton =>
      _t('dashboardCompleteProfileButton');
  String get dashboardCompleteProfileSkip => _t('dashboardCompleteProfileSkip');

  // ── Join Workspace ────────────────────────────────────────────────────────
  String get joinWorkspaceTitle => _t('joinWorkspaceTitle');
  String get joinWorkspaceSearchHint => _t('joinWorkspaceSearchHint');
  String get joinWorkspaceFilterVerifiedOnly =>
      _t('joinWorkspaceFilterVerifiedOnly');
  String get joinWorkspaceEmptySearchTitle =>
      _t('joinWorkspaceEmptySearchTitle');
  String get joinWorkspaceEmptyDefaultTitle =>
      _t('joinWorkspaceEmptyDefaultTitle');
  String get joinWorkspaceEmptySearchCaption =>
      _t('joinWorkspaceEmptySearchCaption');
  String get joinWorkspaceEmptyDefaultCaption =>
      _t('joinWorkspaceEmptyDefaultCaption');
  String joinWorkspaceMemberCount(int count) =>
      _t('joinWorkspaceMemberCount').replaceAll('{count}', '$count');
  String joinWorkspacePollCount(int count) =>
      _t('joinWorkspacePollCount').replaceAll('{count}', '$count');
  String get joinWorkspaceRequestedChip => _t('joinWorkspaceRequestedChip');
  String get joinWorkspaceJoinButton => _t('joinWorkspaceJoinButton');

  // ── Workspace Invite ──────────────────────────────────────────────────────
  String get workspaceJoinInviteTitle => _t('workspaceJoinInviteTitle');
  String workspaceInvitedAsRole(String role) =>
      _t('workspaceInvitedAsRole').replaceAll('{role}', role);
  String get workspaceInviteExpiresLabel => _t('workspaceInviteExpiresLabel');
  String get workspaceInviteUsageLabel => _t('workspaceInviteUsageLabel');
  String get workspaceJoinButton => _t('workspaceJoinButton');
  String get workspaceJoinSendRequestButton =>
      _t('workspaceJoinSendRequestButton');
  String get workspaceJoinCloseButton => _t('workspaceJoinCloseButton');
  String get workspaceInviteJoinButton => _t('workspaceInviteJoinButton');
  String get workspaceInviteSendRequestButton =>
      _t('workspaceInviteSendRequestButton');
  String get workspaceInviteCloseButton => _t('workspaceInviteCloseButton');
  String get workspaceInviteErrorTitle => _t('workspaceInviteErrorTitle');
  String get workspaceInviteErrorHeading => _t('workspaceInviteErrorHeading');
  String get workspaceInviteRetryButton => _t('workspaceInviteRetryButton');
  String get workspaceInviteErrorRetry => _t('workspaceInviteErrorRetry');
  String get workspaceInviteErrorClose => _t('workspaceInviteErrorClose');

  // ── Add Poll ──────────────────────────────────────────────────────────────
  String get addPollScreenTitle => _t('addPollScreenTitle');
  String get addPollNoWorkspaceSnackbar => _t('addPollNoWorkspaceSnackbar');
  String get addPollNoCategorySnackbar => _t('addPollNoCategorySnackbar');
  String get addPollNoWorkspaceDialogTitle =>
      _t('addPollNoWorkspaceDialogTitle');
  String get addPollNoWorkspaceDialogBody => _t('addPollNoWorkspaceDialogBody');
  String get addPollNoWorkspaceDialogCancel =>
      _t('addPollNoWorkspaceDialogCancel');
  String get addPollNoWorkspaceDialogAddWorkspace =>
      _t('addPollNoWorkspaceDialogAddWorkspace');
  String get addPollFieldLabelTitle => _t('addPollFieldLabelTitle');
  String get addPollTitleHint => _t('addPollTitleHint');
  String get addPollTitleRequired => _t('addPollTitleRequired');
  String get addPollFieldLabelDescription => _t('addPollFieldLabelDescription');
  String get addPollDescriptionHint => _t('addPollDescriptionHint');
  String get addPollFieldLabelQuestion => _t('addPollFieldLabelQuestion');
  String get addPollQuestionHint => _t('addPollQuestionHint');
  String get addPollQuestionRequired => _t('addPollQuestionRequired');
  String get addPollFieldLabelWorkspace => _t('addPollFieldLabelWorkspace');
  String get addPollWorkspaceHint => _t('addPollWorkspaceHint');
  String get addPollFieldLabelCategory => _t('addPollFieldLabelCategory');
  String get addPollCategoryHint => _t('addPollCategoryHint');
  String get addPollFieldLabelVisibility => _t('addPollFieldLabelVisibility');
  String get addPollVisibilityHint => _t('addPollVisibilityHint');
  String get addPollFieldLabelOptions => _t('addPollFieldLabelOptions');
  String addPollOptionHint(int number) =>
      _t('addPollOptionHint').replaceAll('{number}', '$number');
  String get addPollOptionRequired => _t('addPollOptionRequired');
  String get addPollAddOptionButton => _t('addPollAddOptionButton');
  String get addPollAnonymousVotingTitle => _t('addPollAnonymousVotingTitle');
  String get addPollAnonymousVotingSubtitle =>
      _t('addPollAnonymousVotingSubtitle');
  String get addPollFieldLabelExpiryDate => _t('addPollFieldLabelExpiryDate');
  String get addPollExpiryDateHint => _t('addPollExpiryDateHint');
  String get addPollNoExpiry => _t('addPollNoExpiry');
  String get addPollSubmitButton => _t('addPollSubmitButton');

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settingsScreenTitle => _t('settingsScreenTitle');
  String get settingsChooseThemeTitle => _t('settingsChooseThemeTitle');
  String get settingsThemeLight => _t('settingsThemeLight');
  String get settingsThemeDark => _t('settingsThemeDark');
  String get settingsThemeSystem => _t('settingsThemeSystem');
  String get settingsChooseLanguageTitle => _t('settingsChooseLanguageTitle');
  String get settingsLanguageEnglish => _t('settingsLanguageEnglish');
  String get settingsLanguageHindi => _t('settingsLanguageHindi');
  String get settingsLanguageTileTitle => _t('settingsLanguageTileTitle');
  String get settingsDeleteAccountDialogTitle =>
      _t('settingsDeleteAccountDialogTitle');
  String get settingsDeleteAccountDialogBody =>
      _t('settingsDeleteAccountDialogBody');
  String get settingsDeleteAccountDialogCancel =>
      _t('settingsDeleteAccountDialogCancel');
  String get settingsDeleteAccountDialogConfirm =>
      _t('settingsDeleteAccountDialogConfirm');
  String get settingsAccountDeletedDialogTitle =>
      _t('settingsAccountDeletedDialogTitle');
  String get settingsAccountDeletedOk => _t('settingsAccountDeletedOk');
  String get settingsLegalDialogClose => _t('settingsLegalDialogClose');
  String get settingsSectionAppearance => _t('settingsSectionAppearance');
  String get settingsThemeTileTitle => _t('settingsThemeTileTitle');
  String get settingsSectionNotifications => _t('settingsSectionNotifications');
  String get settingsPushNotificationsTitle =>
      _t('settingsPushNotificationsTitle');
  String get settingsPushNotificationsSubtitle =>
      _t('settingsPushNotificationsSubtitle');
  String get settingsSectionAccount => _t('settingsSectionAccount');
  String get settingsEditProfileTitle => _t('settingsEditProfileTitle');
  String get settingsDeleteAccountTileTitle =>
      _t('settingsDeleteAccountTileTitle');
  String get settingsDeleteAccountTileSubtitle =>
      _t('settingsDeleteAccountTileSubtitle');
  String get settingsSectionLegal => _t('settingsSectionLegal');
  String get settingsTermsOfServiceTitle => _t('settingsTermsOfServiceTitle');
  String get settingsPrivacyPolicyTitle => _t('settingsPrivacyPolicyTitle');
  String get settingsSectionAbout => _t('settingsSectionAbout');
  String get settingsAppVersionTitle => _t('settingsAppVersionTitle');
  String get settingsAppVersionValue => _t('settingsAppVersionValue');
  String get settingsRateVoteraTitle => _t('settingsRateVoteraTitle');
  String get settingsRateVoteraSnackbar => _t('settingsRateVoteraSnackbar');
  String get settingsContactUsTitle => _t('settingsContactUsTitle');
  String get settingsContactUsSubtitle => _t('settingsContactUsSubtitle');
  String get settingsContactUsSnackbar => _t('settingsContactUsSnackbar');

  // ── Profile ───────────────────────────────────────────────────────────────
  String get profileScreenTitle => _t('profileScreenTitle');
  String get profileEditButton => _t('profileEditButton');
  String get profileCancelButton => _t('profileCancelButton');
  String get profileSaveButton => _t('profileSaveButton');
  String get profileUpdatedSnackbar => _t('profileUpdatedSnackbar');
  String get profileRetryButton => _t('profileRetryButton');
  String get profileFieldFullName => _t('profileFieldFullName');
  String get profileFieldNameRequired => _t('profileFieldNameRequired');
  String get profileFieldMobile => _t('profileFieldMobile');
  String get profileFieldEmail => _t('profileFieldEmail');
  String get profileFieldPictureUrl => _t('profileFieldPictureUrl');
  String get profileSaveChangesButton => _t('profileSaveChangesButton');
  String get profilePictureUrlDialogTitle => _t('profilePictureUrlDialogTitle');
  String get profilePictureUrlHint => _t('profilePictureUrlHint');
  String get profilePictureUrlCancelButton =>
      _t('profilePictureUrlCancelButton');
  String get profilePictureUrlApplyButton => _t('profilePictureUrlApplyButton');

  // ── Drawer ────────────────────────────────────────────────────────────────
  String get drawerSectionPolls => _t('drawerSectionPolls');
  String get drawerMenuDashboard => _t('drawerMenuDashboard');
  String get drawerMenuMyPolls => _t('drawerMenuMyPolls');
  String get drawerSectionWorkspaces => _t('drawerSectionWorkspaces');
  String get drawerMenuMyWorkspaces => _t('drawerMenuMyWorkspaces');
  String get drawerMenuInbox => _t('drawerMenuInbox');
  String get drawerSectionAccount => _t('drawerSectionAccount');
  String get drawerMenuNotifications => _t('drawerMenuNotifications');
  String get drawerMenuProfile => _t('drawerMenuProfile');
  String get drawerMenuSettings => _t('drawerMenuSettings');
  String get drawerLogOut => _t('drawerLogOut');

  // ── Workspace screens ─────────────────────────────────────────────────────
  String get workspaceListTitle => _t('workspaceListTitle');
  String get workspaceListCreateButton => _t('workspaceListCreateButton');
  String get workspaceInviteLinksTitle => _t('workspaceInviteLinksTitle');
  String get workspaceInviteLinksCreateButton =>
      _t('workspaceInviteLinksCreateButton');
  String get workspaceInviteLinksCopy => _t('workspaceInviteLinksCopy');
  String get workspaceInviteLinksShare => _t('workspaceInviteLinksShare');
  String get workspaceInboxTitle => _t('workspaceInboxTitle');
  String get workspaceVerificationTitle => _t('workspaceVerificationTitle');
  String get workspaceAddTitle => _t('workspaceAddTitle');
  String get inviteMemberTitle => _t('inviteMemberTitle');

  // ── Polls & Notifications ─────────────────────────────────────────────────
  String get pollsListTitle => _t('pollsListTitle');
  String get pollsHomeTitle => _t('pollsHomeTitle');
  String get notificationsTitle => _t('notificationsTitle');
  String get notificationsRetry => _t('notificationsRetry');

  // ── Workspace detail ──────────────────────────────────────────────────────
  String get workspaceLeaveButton => _t('workspaceLeaveButton');
  String get workspaceLeaveDialogTitle => _t('workspaceLeaveDialogTitle');
  String get workspaceLeaveDialogBody => _t('workspaceLeaveDialogBody');
  String get workspaceLeaveDialogBodySuffix =>
      _t('workspaceLeaveDialogBodySuffix');
  String get workspaceLeaveDialogWarning => _t('workspaceLeaveDialogWarning');
  String get workspaceLeaveConfirm => _t('workspaceLeaveConfirm');
  String get workspaceLeaveCancel => _t('workspaceLeaveCancel');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
