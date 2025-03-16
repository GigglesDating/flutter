import 'package:flutter/material.dart';

class IconMapper {
  static final Map<String, IconData> interestIcons = {
    'movie': Icons.movie,
    'coffee': Icons.coffee,
    'shopping_bag': Icons.shopping_bag,
    'sports_basketball': Icons.sports_basketball,
    'music_note': Icons.music_note,
    'restaurant': Icons.restaurant,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
    'bedroom_baby': Icons.bedroom_baby,
    'hiking': Icons.hiking,
    'local_bar': Icons.local_bar,
    'camera_alt': Icons.camera_alt,
    'travel_explore': Icons.travel_explore,
    'wine_bar': Icons.wine_bar,
    'liquor': Icons.liquor,
    'nightlife': Icons.nightlife,
    'sports_bar': Icons.sports_bar,
    'festival': Icons.festival,
    'soup_kitchen': Icons.soup_kitchen,
    'door_sliding': Icons.door_sliding,
    'deck': Icons.deck,
    'house_siding': Icons.house_siding,
    'beach_access': Icons.beach_access,
    'kayaking': Icons.kayaking,
    'directions_bike': Icons.directions_bike,
    'terrain': Icons.terrain,
    'paragliding': Icons.paragliding,
    'settings_accessibility': Icons.settings_accessibility,
    'sports_handball_sharp': Icons.sports_handball_sharp,
    'sports_tennis': Icons.sports_tennis,
    'circle_rounded': Icons.circle_rounded,
    'self_improvement': Icons.self_improvement,
    'pool': Icons.pool,
    'directions_run': Icons.directions_run,
    'museum': Icons.museum,
    'account_balance': Icons.account_balance,
    'theater_comedy': Icons.theater_comedy,
    'mic': Icons.mic,
    'photo_camera': Icons.photo_camera,
    'construction': Icons.construction,
    'table_bar': Icons.table_bar,
    'casino': Icons.casino,
    'mic_external_on': Icons.mic_external_on,
    'quiz': Icons.quiz,
    'attractions': Icons.attractions,
    'gamepad': Icons.gamepad,
    'extension': Icons.extension,
    'sports_hockey': Icons.sports_hockey,
    'gps_fixed': Icons.gps_fixed,
    'yard': Icons.yard,
    'visibility': Icons.visibility,
    'park': Icons.park,
    'star_rounded': Icons.star_rounded,
    'spa': Icons.spa,
    'hot_tub': Icons.hot_tub,
    'directions_car': Icons.directions_car,
    'menu_book': Icons.menu_book,
    'translate': Icons.translate,
    'smart_toy': Icons.smart_toy,
    'grid_on': Icons.grid_on,
    'edit_note': Icons.edit_note,
    'science': Icons.science,
    'record_voice_over': Icons.record_voice_over,
    'directions_car_outlined': Icons.directions_car_outlined,
    'holiday_village': Icons.holiday_village,
    'location_city': Icons.location_city,
    'backpack': Icons.backpack,
    'landscape': Icons.landscape,
    'tour': Icons.tour,
    'temple_hindu': Icons.temple_hindu,
    'palette': Icons.palette,
    'diamond': Icons.diamond,
    'tag_rounded': Icons.tag_rounded,
    'photo_album': Icons.photo_album,
    'vignette_sharp': Icons.vignette_sharp,
    'auto_awesome': Icons.auto_awesome,
    'code': Icons.code,
    'view_in_ar': Icons.view_in_ar,
    'currency_bitcoin': Icons.currency_bitcoin,
    'draw': Icons.draw,
    'connecting_airports': Icons.connecting_airports,
    'build': Icons.build,
    'video_camera_front': Icons.video_camera_front,
    'local_movies': Icons.local_movies,
    'pedal_bike': Icons.pedal_bike,
    'sports_cricket': Icons.sports_cricket,
    'sports_football': Icons.sports_football,
    'sports_martial_arts': Icons.sports_martial_arts,
    'track_changes_outlined': Icons.track_changes_outlined,
    'sports_volleyball': Icons.sports_volleyball,
    'track_changes': Icons.track_changes,
    'skateboarding': Icons.skateboarding,
    'videocam_sharp': Icons.videocam_sharp,
    'ondemand_video': Icons.ondemand_video,
    'design_services': Icons.design_services,
    'piano': Icons.piano,
    'spoke': Icons.spoke,
    'crisis_alert': Icons.crisis_alert,
    'menu_book_rounded': Icons.menu_book_rounded,
    'volunteer_activism': Icons.volunteer_activism
    // add addtional icons mapping here if needed
  };

  // Helper method to get icon for an interest
  static IconData getIconForInterest(String interest,
      {IconData defaultIcon = Icons.star}) {
    // Convert interest to snake_case for matching
    final snakeCase = interest.toLowerCase().replaceAll(' ', '_');
    return interestIcons[snakeCase] ?? defaultIcon;
  }

  // Helper method to get icon and label for gender
  static IconData getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person;
    }
  }
}
