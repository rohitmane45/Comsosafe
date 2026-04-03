// Indian compliance ingredient database.
//
// Sources:
//   • IS 4707 (Part 1) — Colorants
//   • IS 4707 (Part 2) — Prohibited / restricted raw materials
//   • IS 4707 (Part 4) — UV filters
//   • Schedule Q, Drugs & Cosmetics Rules 1945
//   • CDSCO guidance & EU Cosmetics Regulation (commonly cross-referenced by BIS)

class IngredientEntry {
  final String name;
  final List<String> aliases;
  final String severity; // 'harmful', 'caution', 'safe'
  final String reason;
  final double? maxConcentrationPercent;
  final String? regulatoryRef;
  final bool isAllergen;
  final List<String> badForSkinTypes; // 'oily','dry','sensitive','combination'

  const IngredientEntry({
    required this.name,
    this.aliases = const [],
    required this.severity,
    required this.reason,
    this.maxConcentrationPercent,
    this.regulatoryRef,
    this.isAllergen = false,
    this.badForSkinTypes = const [],
  });
}

/// Master ingredient database — curated from Indian regulatory standards.
class IngredientDatabase {
  IngredientDatabase._();

  static final List<IngredientEntry> _entries = [
    // ═══════════════════════════════════════════
    //  PROHIBITED / HARMFUL  (🔴)
    //  IS 4707 Part 2 — substances NOT permitted
    // ═══════════════════════════════════════════

    const IngredientEntry(
      name: 'Mercury',
      aliases: ['mercurous chloride', 'calomel', 'mercuric', 'thimerosal'],
      severity: 'harmful',
      reason: 'Banned in cosmetics. Neurotoxin and accumulates in organs.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
    ),
    const IngredientEntry(
      name: 'Lead Acetate',
      aliases: ['lead', 'plumbum aceticum', 'lead(II) acetate'],
      severity: 'harmful',
      reason: 'Banned. Toxic heavy metal — neurotoxin, reproductive harm.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
    ),
    const IngredientEntry(
      name: 'Formaldehyde',
      aliases: ['formalin', 'methyl aldehyde', 'methanal', 'formol'],
      severity: 'harmful',
      reason: 'Carcinogen (IARC Group 1). Banned as direct ingredient in India.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Chloroform',
      aliases: ['trichloromethane'],
      severity: 'harmful',
      reason: 'Banned. Toxic solvent — liver and kidney damage.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
    ),
    const IngredientEntry(
      name: 'Bithionol',
      aliases: ['thiobis(dichlorophenol)'],
      severity: 'harmful',
      reason: 'Banned. Causes photoallergic contact dermatitis.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
      isAllergen: true,
    ),
    const IngredientEntry(
      name: 'Methanol',
      aliases: ['methyl alcohol', 'wood alcohol'],
      severity: 'harmful',
      reason: 'Banned as ingredient. Highly toxic — can cause blindness.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
    ),
    const IngredientEntry(
      name: 'Vinyl Chloride',
      aliases: ['chloroethylene', 'chloroethene'],
      severity: 'harmful',
      reason: 'Banned. Known carcinogen.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
    ),
    const IngredientEntry(
      name: 'Zirconium',
      aliases: ['zirconium complexes', 'zirconium salts', 'zirconium lactate'],
      severity: 'harmful',
      reason: 'Banned in aerosol cosmetics. Causes granulomas in lungs.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited in aerosols',
    ),
    const IngredientEntry(
      name: 'Hexachlorophene',
      aliases: ['hexachlorophane'],
      severity: 'harmful',
      reason: 'Banned in OTC cosmetics. Neurotoxic, especially in infants.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Hydroquinone',
      aliases: ['1,4-benzenediol', 'quinol', 'hydrochinon'],
      severity: 'harmful',
      reason: 'Banned in cosmetics (allowed only in Rx). Causes ochronosis.',
      regulatoryRef: 'Drugs & Cosmetics Rules — Prescription only',
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Diethylhexyl Phthalate',
      aliases: ['DEHP', 'di(2-ethylhexyl) phthalate', 'phthalate'],
      severity: 'harmful',
      reason: 'Endocrine disruptor. Reproductive toxicant. Banned in EU cosmetics.',
      regulatoryRef: 'IS 4707:Part 2 — Not permitted',
    ),
    const IngredientEntry(
      name: 'Dibutyl Phthalate',
      aliases: ['DBP'],
      severity: 'harmful',
      reason: 'Endocrine disruptor. Reproductive toxicant.',
      regulatoryRef: 'IS 4707:Part 2 — Not permitted',
    ),
    const IngredientEntry(
      name: 'Toluene',
      aliases: ['methylbenzene', 'toluol'],
      severity: 'harmful',
      reason: 'Neurotoxin. Harmful to respiratory system. Found in nail products.',
      regulatoryRef: 'IS 4707:Part 2',
    ),
    const IngredientEntry(
      name: 'Asbestos',
      aliases: ['chrysotile', 'tremolite'],
      severity: 'harmful',
      reason: 'Carcinogen. Sometimes contaminant in talc.',
      regulatoryRef: 'IS 4707:Part 2 — Prohibited',
    ),

    // ═══════════════════════════════════════════
    //  RESTRICTED / CAUTION  (🟡)
    //  Allowed with concentration / condition limits
    // ═══════════════════════════════════════════

    // --- Preservatives ---
    const IngredientEntry(
      name: 'Methylparaben',
      aliases: ['methyl 4-hydroxybenzoate', 'E218'],
      severity: 'caution',
      reason: 'Allowed up to 0.4% individually, 0.8% total paraben mix. Weak endocrine activity debated.',
      maxConcentrationPercent: 0.4,
      regulatoryRef: 'IS 4707:Part 2 — Restricted Preservative',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Propylparaben',
      aliases: ['propyl 4-hydroxybenzoate', 'E216'],
      severity: 'caution',
      reason: 'Allowed up to 0.14%. Higher estrogenic activity than methylparaben.',
      maxConcentrationPercent: 0.14,
      regulatoryRef: 'IS 4707:Part 2 — Restricted Preservative',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Butylparaben',
      aliases: ['butyl 4-hydroxybenzoate'],
      severity: 'caution',
      reason: 'Allowed up to 0.14%. Highest estrogenic potency among parabens.',
      maxConcentrationPercent: 0.14,
      regulatoryRef: 'IS 4707:Part 2 — Restricted Preservative',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Ethylparaben',
      aliases: ['ethyl 4-hydroxybenzoate', 'E214'],
      severity: 'caution',
      reason: 'Allowed up to 0.4%. Generally considered low concern.',
      maxConcentrationPercent: 0.4,
      regulatoryRef: 'IS 4707:Part 2 — Restricted Preservative',
    ),
    const IngredientEntry(
      name: 'Methylisothiazolinone',
      aliases: ['MIT', 'MI', '2-methyl-4-isothiazolin-3-one'],
      severity: 'caution',
      reason: 'Strong sensitizer. Banned in leave-on products in EU. Restricted in India.',
      maxConcentrationPercent: 0.01,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Methylchloroisothiazolinone',
      aliases: ['CMIT', 'MCI', 'Kathon CG'],
      severity: 'caution',
      reason: 'Potent sensitizer. Only allowed in rinse-off at 15 ppm (with MIT in 3:1 ratio).',
      maxConcentrationPercent: 0.0015,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Triclosan',
      aliases: ['5-chloro-2-(2,4-dichlorophenoxy)phenol', 'irgasan'],
      severity: 'caution',
      reason: 'Restricted to 0.3%. Endocrine disruptor concerns. Contributes to antibiotic resistance.',
      maxConcentrationPercent: 0.3,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Phenoxyethanol',
      aliases: ['2-phenoxyethanol', 'PhE'],
      severity: 'caution',
      reason: 'Allowed up to 1.0%. Generally safe but can irritate sensitive skin.',
      maxConcentrationPercent: 1.0,
      regulatoryRef: 'IS 4707:Part 2 — Restricted Preservative',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Benzalkonium Chloride',
      aliases: ['BAC', 'alkyldimethylbenzylammonium chloride'],
      severity: 'caution',
      reason: 'Restricted. Can cause contact dermatitis and irritation.',
      maxConcentrationPercent: 0.1,
      regulatoryRef: 'IS 4707:Part 2',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry'],
    ),

    // Formaldehyde releasers (restricted)
    const IngredientEntry(
      name: 'DMDM Hydantoin',
      aliases: ['dimethylol dimethyl hydantoin', 'glydant'],
      severity: 'caution',
      reason: 'Formaldehyde releaser. Allowed at limited concentrations. Known sensitizer.',
      maxConcentrationPercent: 0.6,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Imidazolidinyl Urea',
      aliases: ['germall 115'],
      severity: 'caution',
      reason: 'Formaldehyde releaser. Max 0.6%. Can cause contact dermatitis.',
      maxConcentrationPercent: 0.6,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Diazolidinyl Urea',
      aliases: ['germall II'],
      severity: 'caution',
      reason: 'Formaldehyde releaser. Stronger releaser than Imidazolidinyl Urea.',
      maxConcentrationPercent: 0.5,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Quaternium-15',
      aliases: ['dowicil 200', 'N-(3-chloroallyl)hexaminium chloride'],
      severity: 'caution',
      reason: 'Formaldehyde releaser — the strongest one. Top contact allergen.',
      maxConcentrationPercent: 0.2,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry', 'combination'],
    ),
    const IngredientEntry(
      name: 'Bronopol',
      aliases: ['2-bromo-2-nitropropane-1,3-diol'],
      severity: 'caution',
      reason: 'Formaldehyde releaser. Restricted to 0.1%. Can form carcinogenic nitrosamines.',
      maxConcentrationPercent: 0.1,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      isAllergen: true,
    ),

    // --- UV Filters (IS 4707 Part 4) ---
    const IngredientEntry(
      name: 'Oxybenzone',
      aliases: ['benzophenone-3', 'BP-3', '2-hydroxy-4-methoxybenzophenone'],
      severity: 'caution',
      reason: 'Allowed up to 6%. Endocrine disruptor, coral-reef toxin, photoallergenic.',
      maxConcentrationPercent: 6.0,
      regulatoryRef: 'IS 4707:Part 4 — UV Filter',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Octinoxate',
      aliases: ['ethylhexyl methoxycinnamate', 'octyl methoxycinnamate', 'OMC'],
      severity: 'caution',
      reason: 'Allowed up to 7.5%. Endocrine disruptor and coral-reef toxin.',
      maxConcentrationPercent: 7.5,
      regulatoryRef: 'IS 4707:Part 4 — UV Filter',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Homosalate',
      aliases: ['homomenthyl salicylate'],
      severity: 'caution',
      reason: 'Allowed up to 10%. Mild endocrine activity. Accumulates in body.',
      maxConcentrationPercent: 10.0,
      regulatoryRef: 'IS 4707:Part 4 — UV Filter',
    ),
    const IngredientEntry(
      name: 'Octocrylene',
      aliases: ['2-ethylhexyl 2-cyano-3,3-diphenylacrylate'],
      severity: 'caution',
      reason: 'Allowed up to 10%. Can degrade to benzophenone. Photoallergenic.',
      maxConcentrationPercent: 10.0,
      regulatoryRef: 'IS 4707:Part 4 — UV Filter',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Avobenzone',
      aliases: ['butyl methoxydibenzoylmethane', 'parsol 1789'],
      severity: 'caution',
      reason: 'Allowed up to 3%. Photounstable alone — needs stabilizers.',
      maxConcentrationPercent: 3.0,
      regulatoryRef: 'IS 4707:Part 4 — UV Filter',
    ),

    // --- Surfactants / irritants ---
    const IngredientEntry(
      name: 'Sodium Lauryl Sulfate',
      aliases: ['SLS', 'sodium dodecyl sulfate', 'SDS'],
      severity: 'caution',
      reason: 'Strong surfactant. Strips natural oils. Not banned but known irritant.',
      regulatoryRef: 'General safety concern',
      isAllergen: false,
      badForSkinTypes: ['dry', 'sensitive', 'combination'],
    ),
    const IngredientEntry(
      name: 'Sodium Laureth Sulfate',
      aliases: ['SLES', 'sodium lauryl ether sulfate'],
      severity: 'caution',
      reason: 'Milder than SLS but may contain 1,4-dioxane impurity (carcinogen trace).',
      regulatoryRef: 'General safety concern',
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Ammonium Lauryl Sulfate',
      aliases: ['ALS'],
      severity: 'caution',
      reason: 'Similarly irritating to SLS. Strips moisture barrier.',
      badForSkinTypes: ['dry', 'sensitive'],
    ),

    // --- Fragrances & Allergens ---
    const IngredientEntry(
      name: 'Fragrance',
      aliases: ['parfum', 'aroma', 'fragrance oil'],
      severity: 'caution',
      reason: 'Undisclosed blend. Top cause of cosmetic contact dermatitis. May contain 100+ chemicals.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Linalool',
      aliases: [],
      severity: 'caution',
      reason: 'Fragrance allergen. Oxidizes on exposure to air, increasing sensitization.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Limonene',
      aliases: ['d-limonene', 'dipentene'],
      severity: 'caution',
      reason: 'Fragrance allergen. Oxidized limonene is a strong sensitizer.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Citronellol',
      aliases: [],
      severity: 'caution',
      reason: 'Fragrance allergen — one of the 26 EU-listed allergens.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Geraniol',
      aliases: [],
      severity: 'caution',
      reason: 'Fragrance allergen — listed among 26 EU allergens.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Eugenol',
      aliases: [],
      severity: 'caution',
      reason: 'Fragrance allergen. Commonly found in clove-derived ingredients.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Cinnamal',
      aliases: ['cinnamaldehyde', 'cinnamic aldehyde'],
      severity: 'caution',
      reason: 'Fragrance allergen. One of the most potent cosmetic sensitizers.',
      isAllergen: true,
      badForSkinTypes: ['sensitive', 'dry'],
    ),
    const IngredientEntry(
      name: 'Coumarin',
      aliases: [],
      severity: 'caution',
      reason: 'Fragrance allergen. Mildly hepatotoxic at high doses.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Benzyl Alcohol',
      aliases: [],
      severity: 'caution',
      reason: 'Preservative & fragrance. Can be drying and irritating at high concentrations.',
      maxConcentrationPercent: 1.0,
      regulatoryRef: 'IS 4707:Part 2 — Restricted Preservative',
      isAllergen: true,
      badForSkinTypes: ['dry', 'sensitive'],
    ),
    const IngredientEntry(
      name: 'Benzyl Benzoate',
      aliases: [],
      severity: 'caution',
      reason: 'Fragrance allergen. Sensitizer — must be declared above threshold.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Lanolin',
      aliases: ['wool wax', 'wool grease', 'adeps lanae'],
      severity: 'caution',
      reason: 'Natural emollient but one of the most common cosmetic allergens.',
      isAllergen: true,
      badForSkinTypes: ['oily', 'sensitive'],
    ),

    // --- Colorants ---
    const IngredientEntry(
      name: 'Coal Tar',
      aliases: ['CI 77266', 'carbon black (by coal tar)'],
      severity: 'caution',
      reason: 'Restricted. Some coal-tar colors are carcinogenic. Must comply with Schedule Q.',
      regulatoryRef: 'Schedule Q — Drugs & Cosmetics Rules',
    ),
    const IngredientEntry(
      name: 'FD&C Red No. 40',
      aliases: ['allura red', 'CI 16035', 'E129'],
      severity: 'caution',
      reason: 'Allowed per Schedule Q but linked to hyperactivity in children.',
      regulatoryRef: 'Schedule Q',
      isAllergen: true,
    ),

    // --- Other caution ingredients ---
    const IngredientEntry(
      name: 'Mineral Oil',
      aliases: ['paraffinum liquidum', 'liquid paraffin', 'petrolatum liquid'],
      severity: 'caution',
      reason: 'Occlusive. Can clog pores on oily skin. Cosmetic-grade is safe otherwise.',
      badForSkinTypes: ['oily'],
    ),
    const IngredientEntry(
      name: 'Petrolatum',
      aliases: ['petroleum jelly', 'vaseline', 'white petrolatum'],
      severity: 'caution',
      reason: 'Only properly refined petrolatum is safe. Crude form may contain PAHs.',
      badForSkinTypes: ['oily'],
    ),
    const IngredientEntry(
      name: 'Isopropyl Myristate',
      aliases: ['IPM'],
      severity: 'caution',
      reason: 'Highly comedogenic. Clogs pores. Not ideal for acne-prone skin.',
      badForSkinTypes: ['oily', 'combination'],
    ),
    const IngredientEntry(
      name: 'Isopropyl Palmitate',
      aliases: [],
      severity: 'caution',
      reason: 'Comedogenic. Can cause breakouts on oily skin.',
      badForSkinTypes: ['oily'],
    ),
    const IngredientEntry(
      name: 'Alcohol Denat',
      aliases: ['denatured alcohol', 'SD alcohol', 'ethanol'],
      severity: 'caution',
      reason: 'Drying agent. Strips moisture barrier. Fine in small amounts.',
      badForSkinTypes: ['dry', 'sensitive'],
    ),
    const IngredientEntry(
      name: 'Dimethicone',
      aliases: ['polydimethylsiloxane', 'PDMS'],
      severity: 'caution',
      reason: 'Silicone. Safe but creates occlusive film. May trap debris in oily skin.',
      badForSkinTypes: ['oily'],
    ),
    const IngredientEntry(
      name: 'Talc',
      aliases: ['talcum', 'magnesium silicate'],
      severity: 'caution',
      reason: 'Safe if asbestos-free. Cross-contamination is the concern.',
      regulatoryRef: 'IS 4707:Part 2 — must be asbestos-free',
    ),
    const IngredientEntry(
      name: 'Propylene Glycol',
      aliases: ['1,2-propanediol', 'PG'],
      severity: 'caution',
      reason: 'Generally safe humectant. Can irritate eczema-prone or very sensitive skin.',
      isAllergen: true,
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Retinyl Palmitate',
      aliases: ['vitamin A palmitate'],
      severity: 'caution',
      reason: 'Photosensitizer. May accelerate sun damage if not paired with SPF.',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Salicylic Acid',
      aliases: ['BHA', 'beta hydroxy acid'],
      severity: 'caution',
      reason: 'Restricted to 2% in cosmetics. Effective for oily skin but can over-dry.',
      maxConcentrationPercent: 2.0,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      badForSkinTypes: ['dry', 'sensitive'],
    ),
    const IngredientEntry(
      name: 'Benzoyl Peroxide',
      aliases: ['BPO'],
      severity: 'caution',
      reason: 'Restricted to 5% in OTC. Strong oxidizer. Drying and irritating.',
      maxConcentrationPercent: 5.0,
      regulatoryRef: 'Drugs & Cosmetics Rules',
      badForSkinTypes: ['dry', 'sensitive'],
    ),
    const IngredientEntry(
      name: 'Hydrogen Peroxide',
      aliases: ['h2o2'],
      severity: 'caution',
      reason: 'Restricted in cosmetics. Oxidizer — can damage skin at high concentrations.',
      maxConcentrationPercent: 12.0,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Resorcinol',
      aliases: ['1,3-benzenediol'],
      severity: 'caution',
      reason: 'Restricted to 0.5% in cosmetics (5% in hair dyes). Endocrine disruptor.',
      maxConcentrationPercent: 0.5,
      regulatoryRef: 'IS 4707:Part 2 — Restricted',
      badForSkinTypes: ['sensitive'],
    ),

    // ═══════════════════════════════════════════
    //  SAFE INGREDIENTS  (🟢)
    // ═══════════════════════════════════════════

    const IngredientEntry(
      name: 'Water',
      aliases: ['aqua', 'eau', 'purified water', 'deionized water'],
      severity: 'safe',
      reason: 'Universal solvent. Base of most cosmetic formulations.',
    ),
    const IngredientEntry(
      name: 'Glycerin',
      aliases: ['glycerol', 'glycerine', 'vegetable glycerin'],
      severity: 'safe',
      reason: 'Excellent humectant. Draws moisture. Safe for all skin types.',
    ),
    const IngredientEntry(
      name: 'Hyaluronic Acid',
      aliases: ['sodium hyaluronate', 'HA', 'hyaluronan'],
      severity: 'safe',
      reason: 'Gold-standard humectant. Holds 1000x its weight in water.',
    ),
    const IngredientEntry(
      name: 'Niacinamide',
      aliases: ['nicotinamide', 'vitamin B3'],
      severity: 'safe',
      reason: 'Brightening, pore-minimizing, barrier-repairing. Well-studied.',
    ),
    const IngredientEntry(
      name: 'Tocopherol',
      aliases: ['vitamin E', 'tocopheryl acetate', 'd-alpha-tocopherol'],
      severity: 'safe',
      reason: 'Antioxidant. Protects skin from free-radical damage.',
    ),
    const IngredientEntry(
      name: 'Ascorbic Acid',
      aliases: ['vitamin C', 'L-ascorbic acid', 'ascorbyl glucoside'],
      severity: 'safe',
      reason: 'Potent antioxidant. Brightens and boosts collagen.',
    ),
    const IngredientEntry(
      name: 'Aloe Barbadensis',
      aliases: ['aloe vera', 'aloe vera leaf juice', 'aloe extract'],
      severity: 'safe',
      reason: 'Soothing and anti-inflammatory. Excellent for sensitive skin.',
    ),
    const IngredientEntry(
      name: 'Shea Butter',
      aliases: ['butyrospermum parkii', 'shea butter extract'],
      severity: 'safe',
      reason: 'Rich emollient. Anti-inflammatory. Great for dry skin.',
    ),
    const IngredientEntry(
      name: 'Jojoba Oil',
      aliases: ['simmondsia chinensis', 'jojoba seed oil'],
      severity: 'safe',
      reason: 'Mimics skin sebum. Non-comedogenic. Good for all skin types.',
    ),
    const IngredientEntry(
      name: 'Squalane',
      aliases: ['squalene', 'hydrogenated squalene'],
      severity: 'safe',
      reason: 'Lightweight emollient. Naturally found in skin. Non-comedogenic.',
    ),
    const IngredientEntry(
      name: 'Ceramides',
      aliases: ['ceramide NP', 'ceramide AP', 'ceramide EOP', 'ceramide NS'],
      severity: 'safe',
      reason: 'Essential for skin barrier. Replenishes natural lipids.',
    ),
    const IngredientEntry(
      name: 'Panthenol',
      aliases: ['provitamin B5', 'D-panthenol', 'dexpanthenol'],
      severity: 'safe',
      reason: 'Soothing, hydrating. Promotes wound healing.',
    ),
    const IngredientEntry(
      name: 'Allantoin',
      aliases: [],
      severity: 'safe',
      reason: 'Skin protectant. Soothing and anti-irritant.',
    ),
    const IngredientEntry(
      name: 'Centella Asiatica',
      aliases: ['cica', 'gotu kola', 'madecassoside', 'asiaticoside'],
      severity: 'safe',
      reason: 'Anti-inflammatory, wound-healing. Popular in K-beauty.',
    ),
    const IngredientEntry(
      name: 'Green Tea Extract',
      aliases: ['camellia sinensis', 'EGCG', 'green tea leaf extract'],
      severity: 'safe',
      reason: 'Potent antioxidant. Anti-inflammatory and UV-protective.',
    ),
    const IngredientEntry(
      name: 'Zinc Oxide',
      aliases: ['CI 77947'],
      severity: 'safe',
      reason: 'Physical sunscreen. Non-irritating. Gentle on sensitive skin.',
      regulatoryRef: 'IS 4707:Part 4 — Permitted UV Filter (up to 25%)',
    ),
    const IngredientEntry(
      name: 'Titanium Dioxide',
      aliases: ['CI 77891', 'TiO2'],
      severity: 'safe',
      reason: 'Physical sunscreen and white pigment. Well-tolerated.',
      regulatoryRef: 'IS 4707:Part 4 — Permitted UV Filter (up to 25%)',
    ),
    const IngredientEntry(
      name: 'Glycolic Acid',
      aliases: ['AHA', 'alpha hydroxy acid'],
      severity: 'safe',
      reason: 'Exfoliant. Effective at low percentages. Well-studied.',
    ),
    const IngredientEntry(
      name: 'Lactic Acid',
      aliases: ['AHA', 'milk acid'],
      severity: 'safe',
      reason: 'Gentle exfoliant. Also a humectant. Good for dry skin.',
    ),
    const IngredientEntry(
      name: 'Cetyl Alcohol',
      aliases: ['1-hexadecanol'],
      severity: 'safe',
      reason: 'Fatty alcohol (not drying alcohol). Emollient and thickener.',
    ),
    const IngredientEntry(
      name: 'Cetearyl Alcohol',
      aliases: ['cetostearyl alcohol'],
      severity: 'safe',
      reason: 'Fatty alcohol blend. Emollient and emulsifier. Non-irritating.',
    ),
    const IngredientEntry(
      name: 'Stearic Acid',
      aliases: ['octadecanoic acid'],
      severity: 'safe',
      reason: 'Natural fatty acid. Emulsifier and thickener.',
    ),
    const IngredientEntry(
      name: 'Cocamidopropyl Betaine',
      aliases: ['CAPB', 'coco betaine'],
      severity: 'safe',
      reason: 'Gentle surfactant derived from coconut. Much milder than SLS.',
    ),
    const IngredientEntry(
      name: 'Sodium Cocoyl Isethionate',
      aliases: ['SCI', 'baby foam'],
      severity: 'safe',
      reason: 'Ultra-gentle surfactant. pH-balanced. Ideal for sensitive skin.',
    ),
    const IngredientEntry(
      name: 'Azelaic Acid',
      aliases: ['nonanedioic acid'],
      severity: 'safe',
      reason: 'Anti-inflammatory, anti-acne, brightening. Well-tolerated.',
    ),
    const IngredientEntry(
      name: 'Bakuchiol',
      aliases: [],
      severity: 'safe',
      reason: 'Natural retinol alternative. Non-irritating.',
    ),
    const IngredientEntry(
      name: 'Argan Oil',
      aliases: ['argania spinosa kernel oil'],
      severity: 'safe',
      reason: 'Rich in vitamin E and fatty acids. Non-comedogenic.',
    ),
    const IngredientEntry(
      name: 'Rosehip Oil',
      aliases: ['rosa canina seed oil', 'rosa mosqueta'],
      severity: 'safe',
      reason: 'Rich in vitamin A and C. Anti-aging. Non-comedogenic.',
    ),
    const IngredientEntry(
      name: 'Tea Tree Oil',
      aliases: ['melaleuca alternifolia oil'],
      severity: 'safe',
      reason: 'Natural antibacterial. Effective against acne. Use diluted.',
    ),
    const IngredientEntry(
      name: 'Colloidal Oatmeal',
      aliases: ['avena sativa', 'oat kernel extract'],
      severity: 'safe',
      reason: 'FDA-recognized skin protectant. Soothes eczema and irritation.',
    ),
    const IngredientEntry(
      name: 'Peptides',
      aliases: ['palmitoyl tripeptide', 'matrixyl', 'acetyl hexapeptide', 'copper peptide'],
      severity: 'safe',
      reason: 'Signal molecules that boost collagen. Well-tolerated.',
    ),
    const IngredientEntry(
      name: 'Retinol',
      aliases: ['vitamin A', 'retinaldehyde', 'retinoic acid ester'],
      severity: 'safe',
      reason: 'Gold-standard anti-aging. Can be irritating initially but safe.',
      badForSkinTypes: ['sensitive'],
    ),
    const IngredientEntry(
      name: 'Caprylic/Capric Triglyceride',
      aliases: ['CCT', 'coconut-derived triglyceride'],
      severity: 'safe',
      reason: 'Lightweight emollient from coconut. Non-comedogenic.',
    ),
    const IngredientEntry(
      name: 'Bisabolol',
      aliases: ['alpha-bisabolol', 'levomenol'],
      severity: 'safe',
      reason: 'Anti-inflammatory from chamomile. Soothes redness.',
    ),
    const IngredientEntry(
      name: 'Sodium PCA',
      aliases: ['sodium 2-pyrrolidone-5-carboxylate'],
      severity: 'safe',
      reason: 'Natural moisturizing factor. Excellent humectant.',
    ),
    const IngredientEntry(
      name: 'Urea',
      aliases: ['carbamide'],
      severity: 'safe',
      reason: 'Natural moisturizing factor. Excellent for very dry skin.',
    ),
    const IngredientEntry(
      name: 'Xanthan Gum',
      aliases: [],
      severity: 'safe',
      reason: 'Natural thickener. Non-irritating.',
    ),
    const IngredientEntry(
      name: 'Carbomer',
      aliases: ['carbopol'],
      severity: 'safe',
      reason: 'Synthetic thickener. Safe and non-irritating.',
    ),
    const IngredientEntry(
      name: 'Citric Acid',
      aliases: [],
      severity: 'safe',
      reason: 'pH adjuster. Naturally occurring. Safe at cosmetic concentrations.',
    ),
    const IngredientEntry(
      name: 'EDTA',
      aliases: ['disodium EDTA', 'tetrasodium EDTA'],
      severity: 'safe',
      reason: 'Chelating agent. Stabilizes formulas by binding metals.',
    ),
    const IngredientEntry(
      name: 'Sodium Benzoate',
      aliases: ['E211'],
      severity: 'safe',
      reason: 'Mild preservative. Generally well-tolerated.',
    ),
    const IngredientEntry(
      name: 'Potassium Sorbate',
      aliases: ['E202'],
      severity: 'safe',
      reason: 'Mild preservative. Non-irritating alternative.',
    ),
    const IngredientEntry(
      name: 'Ethylhexylglycerin',
      aliases: ['octoxyglycerin'],
      severity: 'safe',
      reason: 'Preservative booster and skin conditioner. Gentle.',
    ),
    const IngredientEntry(
      name: 'Butylene Glycol',
      aliases: ['1,3-butanediol'],
      severity: 'safe',
      reason: 'Humectant and solvent. Well-tolerated by most skin types.',
    ),
  ];

  /// Get all entries.
  static List<IngredientEntry> get all => List.unmodifiable(_entries);

  /// Lookup table keyed by lowercase name + aliases for O(1) matching.
  static final Map<String, IngredientEntry> _lookup = () {
    final map = <String, IngredientEntry>{};
    for (final entry in _entries) {
      map[entry.name.toLowerCase()] = entry;
      for (final alias in entry.aliases) {
        map[alias.toLowerCase()] = entry;
      }
    }
    return map;
  }();

  /// Find an exact (case-insensitive) match.
  static IngredientEntry? findExact(String name) {
    return _lookup[name.toLowerCase().trim()];
  }

  /// Get all known allergens.
  static List<IngredientEntry> get allergens =>
      _entries.where((e) => e.isAllergen).toList();

  /// Get all harmful ingredients.
  static List<IngredientEntry> get harmful =>
      _entries.where((e) => e.severity == 'harmful').toList();

  /// Get all caution ingredients.
  static List<IngredientEntry> get caution =>
      _entries.where((e) => e.severity == 'caution').toList();

  /// Common allergen names for the user to pick from in their profile.
  static const List<String> commonAllergenNames = [
    'Fragrance / Parfum',
    'Formaldehyde releasers',
    'Parabens',
    'Lanolin',
    'Nickel',
    'Cobalt',
    'Methylisothiazolinone (MIT)',
    'Propylene Glycol',
    'Cocamidopropyl Betaine',
    'Benzyl Alcohol',
    'Oxybenzone',
    'Balsam of Peru',
    'Colophony / Rosin',
    'Latex',
    'Sulfates (SLS/SLES)',
    'Essential Oils',
    'Coal Tar Dyes',
    'Cinnamal / Cinnamic Aldehyde',
    'Quaternium-15',
    'DMDM Hydantoin',
  ];
}
