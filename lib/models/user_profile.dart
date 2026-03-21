class UserProfile {
  String name;
  int age;
  String gender; // 'Male', 'Female', 'Other'
  double heightCm;
  double weightKg;
  double targetWeightKg;
  double initialWeightKg;
  String activityLevel; // 'Sedentary','Light','Moderate','Active','Very Active'
  double restingHeartRate;
  String goal; // 'Lose Weight','Build Muscle','Improve Endurance','Maintain Fitness','Improve Flexibility'

  UserProfile({
    this.name = 'Alex',
    this.age = 28,
    this.gender = 'Male',
    this.heightCm = 175,
    this.weightKg = 76,
    this.targetWeightKg = 70,
    this.initialWeightKg = 80,
    this.activityLevel = 'Moderate',
    this.restingHeartRate = 72,
    this.goal = 'Lose Weight',
  });
}
