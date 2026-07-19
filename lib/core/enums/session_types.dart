/// The type of the cached session.
///
/// [user] — a logged-in user (auth token saved after OTP verification).
/// [guest] — a guest session (guest token, or no valid session at all).
enum SessionType {
  user,
  guest,
}
