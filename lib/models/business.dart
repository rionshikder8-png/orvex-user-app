import 'enums.dart';

class BusinessProfile {
  const BusinessProfile({
    this.name = '',
    this.type = 'type_other',
    this.website = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.description = '',
    this.defaultLanguage = 'en',
  });

  final String name;
  final String type;
  final String website;
  final String contactEmail;
  final String contactPhone;
  final String description;
  final String defaultLanguage;

  BusinessProfile copyWith({
    String? name,
    String? type,
    String? website,
    String? contactEmail,
    String? contactPhone,
    String? description,
    String? defaultLanguage,
  }) => BusinessProfile(
    name: name ?? this.name,
    type: type ?? this.type,
    website: website ?? this.website,
    contactEmail: contactEmail ?? this.contactEmail,
    contactPhone: contactPhone ?? this.contactPhone,
    description: description ?? this.description,
    defaultLanguage: defaultLanguage ?? this.defaultLanguage,
  );

  factory BusinessProfile.fromJson(Map<String, dynamic> j) => BusinessProfile(
    name: J.s(j['name']),
    type: J.s(j['type'], 'type_other'),
    website: J.s(j['website']),
    contactEmail: J.s(j['contact_email']),
    contactPhone: J.s(j['contact_phone']),
    description: J.s(j['description']),
    defaultLanguage: J.s(j['default_language'], 'en'),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'website': website,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
    'description': description,
    'default_language': defaultLanguage,
  };
}

class KnowledgeEntry {
  const KnowledgeEntry({
    required this.id,
    required this.question,
    required this.answer,
  });
  final String id;
  final String question;
  final String answer;

  factory KnowledgeEntry.fromJson(Map<String, dynamic> j) => KnowledgeEntry(
    id: J.s(j['id']),
    question: J.s(j['question']),
    answer: J.s(j['answer']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
  };
}

class AgentSettings {
  const AgentSettings({
    this.enabled = false,
    this.name = 'Orvex Assistant',
    this.language = 'bn',
    this.tone = 'tone_friendly',
    this.instructions = '',
    this.collectOrders = true,
    this.suggestProducts = true,
    this.handoverWhenUnsure = true,
  });

  final bool enabled;
  final String name;
  final String language;
  final String tone;
  final String instructions;
  final bool collectOrders;
  final bool suggestProducts;
  final bool handoverWhenUnsure;

  AgentSettings copyWith({
    bool? enabled,
    String? name,
    String? language,
    String? tone,
    String? instructions,
    bool? collectOrders,
    bool? suggestProducts,
    bool? handoverWhenUnsure,
  }) => AgentSettings(
    enabled: enabled ?? this.enabled,
    name: name ?? this.name,
    language: language ?? this.language,
    tone: tone ?? this.tone,
    instructions: instructions ?? this.instructions,
    collectOrders: collectOrders ?? this.collectOrders,
    suggestProducts: suggestProducts ?? this.suggestProducts,
    handoverWhenUnsure: handoverWhenUnsure ?? this.handoverWhenUnsure,
  );

  factory AgentSettings.fromJson(Map<String, dynamic> j) => AgentSettings(
    enabled: J.b(j['enabled']),
    name: J.s(j['name'], 'Orvex Assistant'),
    language: J.s(j['language'], 'bn'),
    tone: J.s(j['tone'], 'tone_friendly'),
    instructions: J.s(j['instructions']),
    collectOrders: J.b(j['collect_orders'], true),
    suggestProducts: J.b(j['suggest_products'], true),
    handoverWhenUnsure: J.b(j['handover_when_unsure'], true),
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'name': name,
    'language': language,
    'tone': tone,
    'instructions': instructions,
    'collect_orders': collectOrders,
    'suggest_products': suggestProducts,
    'handover_when_unsure': handoverWhenUnsure,
  };
}
