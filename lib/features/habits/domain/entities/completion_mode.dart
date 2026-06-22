/// How a *shared* habit's day is considered complete. Ignored for personal
/// (local) habits, which are always effectively [any].
///
/// - [any] — "Shared": anyone logging it completes the day for everyone (the
///   original shared behavior).
/// - [all] — "Together": every participant must check in; the day is complete
///   only once all of them have.
enum HabitCompletionMode { any, all }
