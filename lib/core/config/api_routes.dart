/// All API route paths (relative to [AppConfig.apiBaseUrl]).
/// Base URL already contains `/api` so paths start after that.
abstract final class ApiRoutes {
  // ── Auth ────────────────────────────────────────────────
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';

  // ── User ────────────────────────────────────────────────
  static const userProfile = '/user/profile';
  static const updateProfile = '/user/update-profile';
  static const deleteAccount = '/user/delete-account';
  // ── Workspace ───────────────────────────────────────────
  static const createWorkspace = '/workspace/create';
  static const userWorkspaces = '/workspace/user';
  static const publicWorkspaces = '/workspace/public';
  static String workspaceById(int id) => '/workspace/$id';
  static const inviteMember = '/workspace/invite';
  static const joinWorkspace = '/workspace/join';
  static const workspaceSearch = '/workspace/search';
  static const approveMember = '/workspace/approve-member';
  static String workspaceMembers(int id) => '/workspace/$id/members';
  static const requestVerification = '/workspace/request-verification';
  static String verificationStatus(int id) =>
      '/workspace/$id/verification-status';
  static const workspaceTypes = '/workspace/workspace-types';
  static const memberInvites = '/workspace/member-invites';
  static const respondInvite = '/workspace/respond-invite';

  // ── Poll ────────────────────────────────────────────────
  static const activePolls = '/poll/active';
  static const dashboardStats = '/poll/dashboard-stats';
  static const createPoll = '/poll/create';
  static String pollsByUser(int userId) => '/poll/list/$userId';
  static String pollById(int pollId) => '/poll/$pollId';
  static const castVote = '/poll/vote';
  static String pollResults(int pollId) => '/poll/results/$pollId';

  // ── Category ────────────────────────────────────────────
  static const pollCategories = '/poll/categories';

  // ── Reaction ────────────────────────────────────────────
  static const addReaction = '/reaction';
  static String reactionsByPoll(int pollId) => '/reaction/$pollId';

  // ── Comment ─────────────────────────────────────────────
  static const addComment = '/comment';
  static String commentsByPoll(int pollId) => '/comment/$pollId';

  // ── Report ──────────────────────────────────────────────
  static const reportWorkspace = '/report/workspace';

  // ── Notification ────────────────────────────────────────
  static const notifications = '/notification/list';
  static String markNotificationRead(int id) => '/notification/read/$id';
  static const markAllNotificationsRead = '/notification/read-all';
}
