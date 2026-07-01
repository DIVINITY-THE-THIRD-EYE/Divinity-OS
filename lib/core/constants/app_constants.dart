abstract final class AppConstants {
  // Supabase — loaded from .env at startup
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // App
  static const String appName = 'Divinity';
  static const String appTagline = 'The Third Eye';

  // Geo attendance
  static const double geofenceDefaultRadius = 100.0; // metres

  // Streak
  static const int streakFreezeGraceDays = 1;
}
