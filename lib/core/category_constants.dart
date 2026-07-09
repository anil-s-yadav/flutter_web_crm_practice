class CategoryConstants {
  static const List<String> categories = [
    'House Maid',
    'Cook',
    'Babysitter',
    'Nanny',
    'Japa Maid',
    'Patient Care',
    'Elderly Care',
    'Driver'
  ];

  static const Map<String, List<String>> skillsByCategory = {
    'House Maid': [
      'Daily sweeping & mopping',
      'Laundry & ironing',
      'Kitchen & utensil cleaning',
      'Bathroom sanitizing',
      'Dusting & deep cleaning',
      'Home organization',
      'Pet friendly',
    ],
    'Cook': [
      'Breakfast, lunch & dinner',
      'North Indian',
      'South Indian',
      'Continental',
      'Diet & health meal planning',
      'Grocery list management',
      'Baking',
    ],
    'Babysitter': [
      'Feeding & diaper changes',
      'Engaging playtime',
      'Sterilizing bottles/toys',
      'Nap schedule management',
      'First aid & CPR',
    ],
    'Nanny': [
      'Homework assistance',
      'Extracurricular prep',
      'Hygiene & bath routine',
      'Healthy meal feeding',
      'School pick-up/drop-off',
    ],
    'Japa Maid': [
      'Newborn massage & bath',
      'Mother diet & care',
      'Lactation support',
      'Sleep training assistance',
      'Post-natal recovery support',
    ],
    'Patient Care': [
      'Medication reminders',
      'Mobility assistance',
      'Bed sore prevention',
      'Bathing & grooming',
      'Vital monitoring (BP/Sugar)',
      'Physiotherapy assistance',
    ],
    'Elderly Care': [
      'Daily routine assistance',
      'Companionship & engagement',
      'Medication management',
      'Doctor visit accompaniment',
      'Dementia/Alzheimer care',
    ],
    'Driver': [
      'Safe city driving',
      'Outstation travel',
      'Vehicle cleaning & upkeep',
      'Route planning',
      'Luxury car handling (Auto)',
      'Luxury car handling (Manual)',
    ],
  };

  static const Map<String, double> baseSalaries = {
    'House Maid': 8000,
    'Cook': 12000,
    'Babysitter': 10000,
    'Nanny': 15000,
    'Japa Maid': 20000,
    'Patient Care': 18000,
    'Elderly Care': 16000,
    'Driver': 15000,
  };
}
