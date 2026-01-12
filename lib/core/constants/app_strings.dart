abstract class AppStrings {
  // App
  static const String appName = 'ember.';
  static const String appTagline = 'Small daily sparks become lasting flames';

  // Navigation
  static const String home = 'Home';
  static const String settings = 'Settings';
  static const String habits = 'Habits';

  // Activities
  static const String createActivity = 'Create Activity';
  static const String editActivity = 'Edit Activity';
  static const String deleteActivity = 'Delete Activity';
  static const String activityName = 'Activity Name';
  static const String activityUnit = 'Unit';
  static const String noActivities = 'No activities yet';
  static const String noActivitiesSubtitle =
      'Create your first activity to start tracking';
  static const String activityNameHint = 'e.g., Drink water';
  static const String activityUnitHint = 'e.g., glasses';

  // Tracking Types
  static const String trackingTypeLabel = 'How do you want to track it?';
  static const String trackingTypeCompletion = 'Yes / No';
  static const String trackingTypeCompletionDesc = 'Track whether you did it';
  static const String trackingTypeQuantity = 'Measured';
  static const String trackingTypeQuantityDesc = 'Track how much you did';

  // Form Labels
  static const String colorLabel = 'Color';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String add = 'Add';
  static const String addHabit = 'Add an Activity';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';

  // Confirmation
  static const String deleteHabitTitle = 'Delete Habit?';
  static const String deleteHabitMessage =
      'This will permanently delete this habit and all its entries.';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorLoadingHabits = 'Failed to load habits';
  static const String errorSavingHabit = 'Failed to save habit';
  static const String errorDeletingHabit = 'Failed to delete habit';

  // Validation
  static const String validationRequired = 'This field is required';
  static const String validationPositiveNumber = 'Must be a positive number';
  static const String validationNonNegative = 'Must be zero or greater';

  // Entry Editor
  static const String logEntry = 'Log Entry';
  static const String entryValue = 'Value';
  static const String clear = 'Clear';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String markAsDone = 'Mark as Done';
  static const String markAsNotDone = 'Mark as Not Done';
  static const String completed = 'Completed';
  static const String notDoneToday = 'Not done today';

  // Habit Details
  static const String habitDetails = 'Habit Details';
  static const String viewYear = 'View Year';
  static const String yearView = 'Year View';
  static const String weekView = 'Week View';
  static const String monthView = 'Month View';

  // Statistics
  static const String statistics = 'Statistics';
  static const String currentStreak = 'Current Streak';
  static const String longestStreak = 'Longest Streak';
  static const String totalLogged = 'Total Logged';
  static const String dailyAverage = 'Daily Average';
  static const String days = 'days';
  static const String day = 'day';
  static const String noEntry = 'No entry';
}
