class ServiceInfo {
  final String name;
  final String description;
  final double startingPrice;
  final List<String> whatsIncluded;
  final String iconName;

  const ServiceInfo({
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.whatsIncluded,
    required this.iconName,
  });

  String get formattedStartingPrice =>
      '₹${startingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}* /mo';
}

class CategoryConstants {
  static const List<String> categories = [
    'House Maid',
    'Cook',
    'Babysitter',
    'Nanny',
    'Japa Maid',
    'Patient Care',
    'Elderly Care',
    'Driver',
  ];

  static const Map<String, String> serviceDescriptions = {
    'House Maid':
        'Verified house maids for daily cleaning, laundry, mopping, and home upkeep.',
    'Cook':
        'Experienced home cooks who prepare hygienic, delicious meals to your taste.',
    'Babysitter':
        'Caring babysitters for your little ones – feeding, playing, and safe supervision.',
    'Nanny':
        'Full-time nannies for complete childcare – from infants to school-age kids.',
    'Japa Maid':
        'Experienced post-natal care – mother & newborn care after delivery.',
    'Patient Care':
        'Professional patient care attendants for post-surgery recovery and illness support.',
    'Elderly Care':
        'Compassionate elderly care companions for your parents and senior family members.',
    'Driver':
        'Verified, licensed drivers for personal and family transportation needs.',
  };

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
      'Regional & special cuisines',
      'Diet & health meal planning',
      'Grocery list management',
      'North Indian & South Indian',
      'Snacks & Beverages',
    ],
    'Babysitter': [
      'Feeding & diaper changes',
      'Engaging playtime',
      'Sterilizing bottles/toys',
      'Nap schedule management',
      'Child safety & supervision',
    ],
    'Nanny': [
      'Homework assistance',
      'Extracurricular prep',
      'Hygiene & bath routine',
      'Healthy meal feeding',
      'Full-day infant & toddler care',
    ],
    'Japa Maid': [
      'Newborn massage & bath',
      'Mother diet & care',
      'Lactation support',
      'Sleep training assistance',
      'Post-natal recovery care',
    ],
    'Patient Care': [
      'Medication reminders',
      'Mobility assistance',
      'Bed sore prevention',
      'Bathing & grooming',
      'Vital monitoring (BP/Sugar)',
      'Post-operative care',
    ],
    'Elderly Care': [
      'Daily routine assistance',
      'Companionship & engagement',
      'Medication management',
      'Doctor visit accompaniment',
      'Mobility & walking support',
    ],
    'Driver': [
      'Safe city driving',
      'Outstation travel',
      'Vehicle cleaning & upkeep',
      'Route planning & navigation',
      'Automatic & Manual vehicles',
    ],
  };

  static const List<ServiceInfo> services = [
    ServiceInfo(
      name: 'House Maid',
      description:
          'Verified house maids for daily cleaning, laundry, mopping, and..',
      startingPrice: 8000,
      whatsIncluded: [
        'Daily sweeping & mopping',
        'Laundry & ironing',
        'Kitchen & utensil cleaning',
        'Bathroom sanitizing',
        'And More...',
      ],
      iconName: 'home',
    ),
    ServiceInfo(
      name: 'Cook',
      description:
          'Experienced home cooks who prepare hygienic, delicious meals to your..',
      startingPrice: 12000,
      whatsIncluded: [
        'Breakfast, lunch & dinner',
        'Regional & special cuisines',
        'Diet & health meal planning',
        'Grocery list management',
        'And More...',
      ],
      iconName: 'restaurant',
    ),
    ServiceInfo(
      name: 'Babysitter',
      description:
          'Caring babysitters for your little ones – feeding, playing, and safe..',
      startingPrice: 10000,
      whatsIncluded: [
        'Feeding & diaper changes',
        'Engaging playtime',
        'Sterilizing bottles/toys',
        'Nap schedule management',
        'And More...',
      ],
      iconName: 'child_care',
    ),
    ServiceInfo(
      name: 'Nanny',
      description:
          'Full-time nannies for complete childcare – from infants to school-..',
      startingPrice: 15000,
      whatsIncluded: [
        'Homework assistance',
        'Extracurricular prep',
        'Hygiene & bath routine',
        'Healthy meal feeding',
        'And More...',
      ],
      iconName: 'favorite',
    ),
    ServiceInfo(
      name: 'Japa Maid',
      description:
          'Experienced post-natal care – mother & newborn care after delivery.',
      startingPrice: 20000,
      whatsIncluded: [
        'Newborn massage & bath',
        'Mother diet & care',
        'Lactation support',
        'Sleep training assistance',
        'And More...',
      ],
      iconName: 'pregnant_woman',
    ),
    ServiceInfo(
      name: 'Patient Care',
      description:
          'Professional patient care attendants for post-surgery recovery and illness..',
      startingPrice: 18000,
      whatsIncluded: [
        'Medication reminders',
        'Mobility assistance',
        'Bed sore prevention',
        'Bathing & grooming',
        'And More...',
      ],
      iconName: 'medical_services',
    ),
    ServiceInfo(
      name: 'Elderly Care',
      description:
          'Compassionate elderly care companions for your parents and..',
      startingPrice: 16000,
      whatsIncluded: [
        'Daily routine assistance',
        'Companionship & engagement',
        'Medication management',
        'Doctor visit accompaniment',
        'And More...',
      ],
      iconName: 'elderly',
    ),
    ServiceInfo(
      name: 'Driver',
      description:
          'Verified, licensed drivers for personal and family transportation needs.',
      startingPrice: 15000,
      whatsIncluded: [
        'Safe city driving',
        'Outstation travel',
        'Vehicle cleaning & upkeep',
        'Route planning',
        'And More...',
      ],
      iconName: 'directions_car',
    ),
  ];

  static const List<String> educationLevels = [
    '10th Pass',
    'Below 10th',
    'Below 8th',
    'Below 5th',
    'Illiterate (Non-literate)',
    '12th Pass',
    'Graduate',
    'Post Graduate',
    'Not Specified',
  ];
}
