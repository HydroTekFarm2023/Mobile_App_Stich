class PlantPreset {
  final String overallHealth;
  final int overallHealthScore;
  final double currentTemp;
  final int currentHumidity;
  final double nutrientPh;
  final String lightIntensity;
  final double lightProgress;

  final bool waterPumps;
  final double waterPumpsIntensity;
  final String waterPumpsStatus;

  final bool growLights;
  final double growLightsIntensity;
  final String growLightsStatus;

  final bool ventilation;
  final double ventilationIntensity;
  final String ventilationStatus;

  final bool nutrientDosing;
  final double nutrientDosingIntensity;
  final String nutrientDosingStatus;

  final double targetTemp;

  const PlantPreset({
    required this.overallHealth,
    required this.overallHealthScore,
    required this.currentTemp,
    required this.currentHumidity,
    required this.nutrientPh,
    required this.lightIntensity,
    required this.lightProgress,
    required this.waterPumps,
    required this.waterPumpsIntensity,
    required this.waterPumpsStatus,
    required this.growLights,
    required this.growLightsIntensity,
    required this.growLightsStatus,
    required this.ventilation,
    required this.ventilationIntensity,
    required this.ventilationStatus,
    required this.nutrientDosing,
    required this.nutrientDosingIntensity,
    required this.nutrientDosingStatus,
    required this.targetTemp,
  });
}

class PlantPresets {
  static const List<String> plants = [
    'Strawberry',
    'Butter Lettuce',
    'Basil',
    'Tomato',
    'Blueberries',
  ];

  static final Map<String, PlantPreset> presets = {
    'Strawberry': const PlantPreset(
      overallHealth: 'Excellent',
      overallHealthScore: 98,
      currentTemp: 22.4,
      currentHumidity: 64,
      nutrientPh: 6.1,
      lightIntensity: '42klx',
      lightProgress: 0.8,
      waterPumps: true,
      waterPumpsIntensity: 0.85,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 1.00,
      growLightsStatus: 'Scheduled to turn off at 20:00',
      ventilation: false,
      ventilationIntensity: 0.0,
      ventilationStatus: 'Currently idle',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.50,
      nutrientDosingStatus: 'Last dose: 2 hrs ago',
      targetTemp: 22.5,
    ),
    'Butter Lettuce': const PlantPreset(
      overallHealth: 'Optimal',
      overallHealthScore: 95,
      currentTemp: 18.5,
      currentHumidity: 72,
      nutrientPh: 5.8,
      lightIntensity: '30klx',
      lightProgress: 0.6,
      waterPumps: true,
      waterPumpsIntensity: 0.90,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 0.80,
      growLightsStatus: 'Eco mode active',
      ventilation: true,
      ventilationIntensity: 0.40,
      ventilationStatus: 'Running low speed',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.70,
      nutrientDosingStatus: 'Last dose: 1 hr ago',
      targetTemp: 19.0,
    ),
    'Basil': const PlantPreset(
      overallHealth: 'Excellent',
      overallHealthScore: 97,
      currentTemp: 24.2,
      currentHumidity: 60,
      nutrientPh: 6.4,
      lightIntensity: '38klx',
      lightProgress: 0.76,
      waterPumps: true,
      waterPumpsIntensity: 0.75,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 0.90,
      growLightsStatus: 'Scheduled to turn off at 22:00',
      ventilation: true,
      ventilationIntensity: 0.30,
      ventilationStatus: 'Gentle breeze active',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.60,
      nutrientDosingStatus: 'Last dose: 30 mins ago',
      targetTemp: 24.0,
    ),
    'Tomato': const PlantPreset(
      overallHealth: 'Good',
      overallHealthScore: 91,
      currentTemp: 26.5,
      currentHumidity: 55,
      nutrientPh: 6.0,
      lightIntensity: '48klx',
      lightProgress: 0.96,
      waterPumps: true,
      waterPumpsIntensity: 0.95,
      waterPumpsStatus: 'High flow mode',
      growLights: true,
      growLightsIntensity: 0.95,
      growLightsStatus: 'Full spectrum active',
      ventilation: true,
      ventilationIntensity: 0.50,
      ventilationStatus: 'Running medium speed',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.80,
      nutrientDosingStatus: 'Last dose: 3 hrs ago',
      targetTemp: 26.0,
    ),
    'Blueberries': const PlantPreset(
      overallHealth: 'Optimal',
      overallHealthScore: 94,
      currentTemp: 20.8,
      currentHumidity: 68,
      nutrientPh: 5.5,
      lightIntensity: '35klx',
      lightProgress: 0.7,
      waterPumps: true,
      waterPumpsIntensity: 0.80,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 0.70,
      growLightsStatus: 'Scheduled to turn off at 19:00',
      ventilation: false,
      ventilationIntensity: 0.0,
      ventilationStatus: 'Currently idle',
      nutrientDosing: false,
      nutrientDosingIntensity: 0.0,
      nutrientDosingStatus: 'System suspended',
      targetTemp: 21.0,
    ),
  };
}
