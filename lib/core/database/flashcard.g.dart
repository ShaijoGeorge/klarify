// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFlashcardCollection on Isar {
  IsarCollection<Flashcard> get flashcards => this.collection();
}

const FlashcardSchema = CollectionSchema(
  name: r'Flashcard',
  id: -5712857134961670327,
  properties: {
    r'article': PropertySchema(
      id: 0,
      name: r'article',
      type: IsarType.string,
    ),
    r'consecutiveCorrect': PropertySchema(
      id: 1,
      name: r'consecutiveCorrect',
      type: IsarType.long,
    ),
    r'nextReviewDate': PropertySchema(
      id: 2,
      name: r'nextReviewDate',
      type: IsarType.dateTime,
    ),
    r'pluralForm': PropertySchema(
      id: 3,
      name: r'pluralForm',
      type: IsarType.string,
    ),
    r'translation': PropertySchema(
      id: 4,
      name: r'translation',
      type: IsarType.string,
    ),
    r'word': PropertySchema(
      id: 5,
      name: r'word',
      type: IsarType.string,
    )
  },
  estimateSize: _flashcardEstimateSize,
  serialize: _flashcardSerialize,
  deserialize: _flashcardDeserialize,
  deserializeProp: _flashcardDeserializeProp,
  idName: r'id',
  indexes: {
    r'word': IndexSchema(
      id: -2031626334120420267,
      name: r'word',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'word',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _flashcardGetId,
  getLinks: _flashcardGetLinks,
  attach: _flashcardAttach,
  version: '3.1.0+1',
);

int _flashcardEstimateSize(
  Flashcard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.article;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pluralForm;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.translation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.word;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _flashcardSerialize(
  Flashcard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.article);
  writer.writeLong(offsets[1], object.consecutiveCorrect);
  writer.writeDateTime(offsets[2], object.nextReviewDate);
  writer.writeString(offsets[3], object.pluralForm);
  writer.writeString(offsets[4], object.translation);
  writer.writeString(offsets[5], object.word);
}

Flashcard _flashcardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Flashcard();
  object.article = reader.readStringOrNull(offsets[0]);
  object.consecutiveCorrect = reader.readLong(offsets[1]);
  object.id = id;
  object.nextReviewDate = reader.readDateTimeOrNull(offsets[2]);
  object.pluralForm = reader.readStringOrNull(offsets[3]);
  object.translation = reader.readStringOrNull(offsets[4]);
  object.word = reader.readStringOrNull(offsets[5]);
  return object;
}

P _flashcardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _flashcardGetId(Flashcard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _flashcardGetLinks(Flashcard object) {
  return [];
}

void _flashcardAttach(IsarCollection<dynamic> col, Id id, Flashcard object) {
  object.id = id;
}

extension FlashcardQueryWhereSort
    on QueryBuilder<Flashcard, Flashcard, QWhere> {
  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyWord() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'word'),
      );
    });
  }
}

extension FlashcardQueryWhere
    on QueryBuilder<Flashcard, Flashcard, QWhereClause> {
  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'word',
        value: [null],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'word',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordEqualTo(
      String? word) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'word',
        value: [word],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordNotEqualTo(
      String? word) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [],
              upper: [word],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [word],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [word],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [],
              upper: [word],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordGreaterThan(
    String? word, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'word',
        lower: [word],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordLessThan(
    String? word, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'word',
        lower: [],
        upper: [word],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordBetween(
    String? lowerWord,
    String? upperWord, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'word',
        lower: [lowerWord],
        includeLower: includeLower,
        upper: [upperWord],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordStartsWith(
      String WordPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'word',
        lower: [WordPrefix],
        upper: ['$WordPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'word',
        value: [''],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> wordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'word',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'word',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'word',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'word',
              upper: [''],
            ));
      }
    });
  }
}

extension FlashcardQueryFilter
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {
  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'article',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'article',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'article',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'article',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'article',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'article',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'article',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'article',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'article',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'article',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> articleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'article',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      articleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'article',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveCorrectEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveCorrectGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutiveCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveCorrectLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutiveCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveCorrectBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutiveCorrect',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextReviewDate',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextReviewDate',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextReviewDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pluralForm',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      pluralFormIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pluralForm',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pluralForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      pluralFormGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pluralForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pluralForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pluralForm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      pluralFormStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pluralForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pluralForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pluralForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> pluralFormMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pluralForm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      pluralFormIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pluralForm',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      pluralFormIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pluralForm',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'translation',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'translation',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'translation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'translation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translation',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'translation',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'word',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'word',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'word',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'word',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'word',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> wordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'word',
        value: '',
      ));
    });
  }
}

extension FlashcardQueryObject
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {}

extension FlashcardQueryLinks
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {}

extension FlashcardQuerySortBy on QueryBuilder<Flashcard, Flashcard, QSortBy> {
  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByArticle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'article', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByArticleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'article', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByConsecutiveCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByConsecutiveCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByNextReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByPluralForm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluralForm', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByPluralFormDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluralForm', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByTranslation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByTranslationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByWord() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByWordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.desc);
    });
  }
}

extension FlashcardQuerySortThenBy
    on QueryBuilder<Flashcard, Flashcard, QSortThenBy> {
  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByArticle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'article', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByArticleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'article', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByConsecutiveCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByConsecutiveCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByNextReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByPluralForm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluralForm', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByPluralFormDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluralForm', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByTranslation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByTranslationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByWord() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByWordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.desc);
    });
  }
}

extension FlashcardQueryWhereDistinct
    on QueryBuilder<Flashcard, Flashcard, QDistinct> {
  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByArticle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'article', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByConsecutiveCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveCorrect');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextReviewDate');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByPluralForm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pluralForm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByTranslation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'translation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByWord(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'word', caseSensitive: caseSensitive);
    });
  }
}

extension FlashcardQueryProperty
    on QueryBuilder<Flashcard, Flashcard, QQueryProperty> {
  QueryBuilder<Flashcard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> articleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'article');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> consecutiveCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveCorrect');
    });
  }

  QueryBuilder<Flashcard, DateTime?, QQueryOperations>
      nextReviewDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextReviewDate');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> pluralFormProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pluralForm');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> translationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'translation');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> wordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'word');
    });
  }
}
