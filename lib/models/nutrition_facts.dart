// Owner: Jessica | FR: FR-08, FR-09, FR-11, FR-12

class NutritionFacts {
  const NutritionFacts({
    required this.servingSize,
    required this.servingSizeGrams,
    required this.totalFatGrams,
    required this.saturatedFatGrams,
    required this.sodiumMilligrams,
    required this.carbohydrateGrams,
    required this.fiberGrams,
    required this.totalSugarsGrams,
    required this.proteinGrams,
    this.transFatGrams,
    this.cholesterolMilligrams,
    this.addedSugarsGrams,
    this.vitaminDMicrograms,
    this.calciumMilligrams,
    this.ironMilligrams,
    this.potassiumMilligrams,
    this.isEstimate = true,
  });

  final String servingSize;
  final double servingSizeGrams;
  final double totalFatGrams;
  final double saturatedFatGrams;
  final double? transFatGrams;
  final double? cholesterolMilligrams;
  final double sodiumMilligrams;
  final double carbohydrateGrams;
  final double fiberGrams;
  final double totalSugarsGrams;
  final double? addedSugarsGrams;
  final double proteinGrams;
  final double? vitaminDMicrograms;
  final double? calciumMilligrams;
  final double? ironMilligrams;
  final double? potassiumMilligrams;
  final bool isEstimate;

  NutritionFacts copyWith({
    String? servingSize,
    double? servingSizeGrams,
    double? totalFatGrams,
    double? saturatedFatGrams,
    double? transFatGrams,
    double? cholesterolMilligrams,
    double? sodiumMilligrams,
    double? carbohydrateGrams,
    double? fiberGrams,
    double? totalSugarsGrams,
    double? addedSugarsGrams,
    double? proteinGrams,
    double? vitaminDMicrograms,
    double? calciumMilligrams,
    double? ironMilligrams,
    double? potassiumMilligrams,
    bool? isEstimate,
  }) {
    return NutritionFacts(
      servingSize: servingSize ?? this.servingSize,
      servingSizeGrams: servingSizeGrams ?? this.servingSizeGrams,
      totalFatGrams: totalFatGrams ?? this.totalFatGrams,
      saturatedFatGrams: saturatedFatGrams ?? this.saturatedFatGrams,
      transFatGrams: transFatGrams ?? this.transFatGrams,
      cholesterolMilligrams:
          cholesterolMilligrams ?? this.cholesterolMilligrams,
      sodiumMilligrams: sodiumMilligrams ?? this.sodiumMilligrams,
      carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      totalSugarsGrams: totalFatGrams ?? this.totalFatGrams,
      addedSugarsGrams: addedSugarsGrams ?? this.addedSugarsGrams,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      vitaminDMicrograms: vitaminDMicrograms ?? this.vitaminDMicrograms,
      calciumMilligrams: calciumMilligrams ?? this.calciumMilligrams,
      ironMilligrams: ironMilligrams ?? this.ironMilligrams,
      potassiumMilligrams: potassiumMilligrams ?? this.potassiumMilligrams,
      isEstimate: isEstimate ?? this.isEstimate,
    );
  }
}
