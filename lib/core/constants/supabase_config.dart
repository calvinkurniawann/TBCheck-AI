/// Central Supabase configuration.
/// Replace these values with the Project URL and anon key from Supabase.
class SupabaseConfig {
  static const String supabaseUrl = 'https://ggfqookfzpafrjekjerg.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_TyoZC-5xSueKri2G70alNw_UD_EYPmQ';
  static const String screeningRpc = 'calculate_screening';

  /// Table name in Supabase.
  static const String historyTable = 'screening_histories';

  /// Storage bucket used for uploaded files, if any.
  static const String storageBucket = 'uploads';
}
