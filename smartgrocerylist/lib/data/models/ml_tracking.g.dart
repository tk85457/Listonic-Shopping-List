// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ml_tracking.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTypingPatternCollection on Isar {
  IsarCollection<TypingPattern> get typingPatterns => this.collection();
}

const TypingPatternSchema = CollectionSchema(
  name: r'TypingPattern',
  id: -6977889349057970625,
  properties: {
    r'frequency': PropertySchema(
      id: 0,
      name: r'frequency',
      type: IsarType.long,
    ),
    r'pattern': PropertySchema(
      id: 1,
      name: r'pattern',
      type: IsarType.string,
    )
  },
  estimateSize: _typingPatternEstimateSize,
  serialize: _typingPatternSerialize,
  deserialize: _typingPatternDeserialize,
  deserializeProp: _typingPatternDeserializeProp,
  idName: r'id',
  indexes: {
    r'pattern': IndexSchema(
      id: 7754415363613759321,
      name: r'pattern',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'pattern',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _typingPatternGetId,
  getLinks: _typingPatternGetLinks,
  attach: _typingPatternAttach,
  version: '3.1.0+1',
);

int _typingPatternEstimateSize(
  TypingPattern object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.pattern.length * 3;
  return bytesCount;
}

void _typingPatternSerialize(
  TypingPattern object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.frequency);
  writer.writeString(offsets[1], object.pattern);
}

TypingPattern _typingPatternDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TypingPattern();
  object.frequency = reader.readLong(offsets[0]);
  object.id = id;
  object.pattern = reader.readString(offsets[1]);
  return object;
}

P _typingPatternDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _typingPatternGetId(TypingPattern object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _typingPatternGetLinks(TypingPattern object) {
  return [];
}

void _typingPatternAttach(
    IsarCollection<dynamic> col, Id id, TypingPattern object) {
  object.id = id;
}

extension TypingPatternByIndex on IsarCollection<TypingPattern> {
  Future<TypingPattern?> getByPattern(String pattern) {
    return getByIndex(r'pattern', [pattern]);
  }

  TypingPattern? getByPatternSync(String pattern) {
    return getByIndexSync(r'pattern', [pattern]);
  }

  Future<bool> deleteByPattern(String pattern) {
    return deleteByIndex(r'pattern', [pattern]);
  }

  bool deleteByPatternSync(String pattern) {
    return deleteByIndexSync(r'pattern', [pattern]);
  }

  Future<List<TypingPattern?>> getAllByPattern(List<String> patternValues) {
    final values = patternValues.map((e) => [e]).toList();
    return getAllByIndex(r'pattern', values);
  }

  List<TypingPattern?> getAllByPatternSync(List<String> patternValues) {
    final values = patternValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'pattern', values);
  }

  Future<int> deleteAllByPattern(List<String> patternValues) {
    final values = patternValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'pattern', values);
  }

  int deleteAllByPatternSync(List<String> patternValues) {
    final values = patternValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'pattern', values);
  }

  Future<Id> putByPattern(TypingPattern object) {
    return putByIndex(r'pattern', object);
  }

  Id putByPatternSync(TypingPattern object, {bool saveLinks = true}) {
    return putByIndexSync(r'pattern', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPattern(List<TypingPattern> objects) {
    return putAllByIndex(r'pattern', objects);
  }

  List<Id> putAllByPatternSync(List<TypingPattern> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'pattern', objects, saveLinks: saveLinks);
  }
}

extension TypingPatternQueryWhereSort
    on QueryBuilder<TypingPattern, TypingPattern, QWhere> {
  QueryBuilder<TypingPattern, TypingPattern, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TypingPatternQueryWhere
    on QueryBuilder<TypingPattern, TypingPattern, QWhereClause> {
  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause> idBetween(
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

  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause> patternEqualTo(
      String pattern) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pattern',
        value: [pattern],
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterWhereClause>
      patternNotEqualTo(String pattern) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pattern',
              lower: [],
              upper: [pattern],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pattern',
              lower: [pattern],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pattern',
              lower: [pattern],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pattern',
              lower: [],
              upper: [pattern],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TypingPatternQueryFilter
    on QueryBuilder<TypingPattern, TypingPattern, QFilterCondition> {
  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      frequencyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      frequencyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      frequencyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      frequencyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pattern',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pattern',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pattern',
        value: '',
      ));
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterFilterCondition>
      patternIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pattern',
        value: '',
      ));
    });
  }
}

extension TypingPatternQueryObject
    on QueryBuilder<TypingPattern, TypingPattern, QFilterCondition> {}

extension TypingPatternQueryLinks
    on QueryBuilder<TypingPattern, TypingPattern, QFilterCondition> {}

extension TypingPatternQuerySortBy
    on QueryBuilder<TypingPattern, TypingPattern, QSortBy> {
  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy>
      sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> sortByPattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pattern', Sort.asc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> sortByPatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pattern', Sort.desc);
    });
  }
}

extension TypingPatternQuerySortThenBy
    on QueryBuilder<TypingPattern, TypingPattern, QSortThenBy> {
  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy>
      thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> thenByPattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pattern', Sort.asc);
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QAfterSortBy> thenByPatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pattern', Sort.desc);
    });
  }
}

extension TypingPatternQueryWhereDistinct
    on QueryBuilder<TypingPattern, TypingPattern, QDistinct> {
  QueryBuilder<TypingPattern, TypingPattern, QDistinct> distinctByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency');
    });
  }

  QueryBuilder<TypingPattern, TypingPattern, QDistinct> distinctByPattern(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pattern', caseSensitive: caseSensitive);
    });
  }
}

extension TypingPatternQueryProperty
    on QueryBuilder<TypingPattern, TypingPattern, QQueryProperty> {
  QueryBuilder<TypingPattern, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TypingPattern, int, QQueryOperations> frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<TypingPattern, String, QQueryOperations> patternProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pattern');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecentItemCollection on Isar {
  IsarCollection<RecentItem> get recentItems => this.collection();
}

const RecentItemSchema = CollectionSchema(
  name: r'RecentItem',
  id: 3858223537154387385,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _recentItemEstimateSize,
  serialize: _recentItemSerialize,
  deserialize: _recentItemDeserialize,
  deserializeProp: _recentItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'addedAt': IndexSchema(
      id: -8595779697745674092,
      name: r'addedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _recentItemGetId,
  getLinks: _recentItemGetLinks,
  attach: _recentItemAttach,
  version: '3.1.0+1',
);

int _recentItemEstimateSize(
  RecentItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _recentItemSerialize(
  RecentItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.name);
}

RecentItem _recentItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecentItem();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  return object;
}

P _recentItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recentItemGetId(RecentItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recentItemGetLinks(RecentItem object) {
  return [];
}

void _recentItemAttach(IsarCollection<dynamic> col, Id id, RecentItem object) {
  object.id = id;
}

extension RecentItemQueryWhereSort
    on QueryBuilder<RecentItem, RecentItem, QWhere> {
  QueryBuilder<RecentItem, RecentItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhere> anyAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'addedAt'),
      );
    });
  }
}

extension RecentItemQueryWhere
    on QueryBuilder<RecentItem, RecentItem, QWhereClause> {
  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> addedAtEqualTo(
      DateTime addedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addedAt',
        value: [addedAt],
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> addedAtNotEqualTo(
      DateTime addedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [],
              upper: [addedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [addedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [addedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [],
              upper: [addedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> addedAtGreaterThan(
    DateTime addedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addedAt',
        lower: [addedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> addedAtLessThan(
    DateTime addedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addedAt',
        lower: [],
        upper: [addedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterWhereClause> addedAtBetween(
    DateTime lowerAddedAt,
    DateTime upperAddedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addedAt',
        lower: [lowerAddedAt],
        includeLower: includeLower,
        upper: [upperAddedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecentItemQueryFilter
    on QueryBuilder<RecentItem, RecentItem, QFilterCondition> {
  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> addedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition>
      addedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> addedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension RecentItemQueryObject
    on QueryBuilder<RecentItem, RecentItem, QFilterCondition> {}

extension RecentItemQueryLinks
    on QueryBuilder<RecentItem, RecentItem, QFilterCondition> {}

extension RecentItemQuerySortBy
    on QueryBuilder<RecentItem, RecentItem, QSortBy> {
  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension RecentItemQuerySortThenBy
    on QueryBuilder<RecentItem, RecentItem, QSortThenBy> {
  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RecentItem, RecentItem, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension RecentItemQueryWhereDistinct
    on QueryBuilder<RecentItem, RecentItem, QDistinct> {
  QueryBuilder<RecentItem, RecentItem, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<RecentItem, RecentItem, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension RecentItemQueryProperty
    on QueryBuilder<RecentItem, RecentItem, QQueryProperty> {
  QueryBuilder<RecentItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecentItem, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<RecentItem, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetItemFrequencyCollection on Isar {
  IsarCollection<ItemFrequency> get itemFrequencys => this.collection();
}

const ItemFrequencySchema = CollectionSchema(
  name: r'ItemFrequency',
  id: 5700009674009603846,
  properties: {
    r'frequency': PropertySchema(
      id: 0,
      name: r'frequency',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _itemFrequencyEstimateSize,
  serialize: _itemFrequencySerialize,
  deserialize: _itemFrequencyDeserialize,
  deserializeProp: _itemFrequencyDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _itemFrequencyGetId,
  getLinks: _itemFrequencyGetLinks,
  attach: _itemFrequencyAttach,
  version: '3.1.0+1',
);

int _itemFrequencyEstimateSize(
  ItemFrequency object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _itemFrequencySerialize(
  ItemFrequency object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.frequency);
  writer.writeString(offsets[1], object.name);
}

ItemFrequency _itemFrequencyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ItemFrequency();
  object.frequency = reader.readLong(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  return object;
}

P _itemFrequencyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _itemFrequencyGetId(ItemFrequency object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _itemFrequencyGetLinks(ItemFrequency object) {
  return [];
}

void _itemFrequencyAttach(
    IsarCollection<dynamic> col, Id id, ItemFrequency object) {
  object.id = id;
}

extension ItemFrequencyByIndex on IsarCollection<ItemFrequency> {
  Future<ItemFrequency?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  ItemFrequency? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<ItemFrequency?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<ItemFrequency?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(ItemFrequency object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(ItemFrequency object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<ItemFrequency> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<ItemFrequency> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension ItemFrequencyQueryWhereSort
    on QueryBuilder<ItemFrequency, ItemFrequency, QWhere> {
  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ItemFrequencyQueryWhere
    on QueryBuilder<ItemFrequency, ItemFrequency, QWhereClause> {
  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> idBetween(
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

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ItemFrequencyQueryFilter
    on QueryBuilder<ItemFrequency, ItemFrequency, QFilterCondition> {
  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      frequencyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      frequencyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      frequencyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      frequencyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension ItemFrequencyQueryObject
    on QueryBuilder<ItemFrequency, ItemFrequency, QFilterCondition> {}

extension ItemFrequencyQueryLinks
    on QueryBuilder<ItemFrequency, ItemFrequency, QFilterCondition> {}

extension ItemFrequencyQuerySortBy
    on QueryBuilder<ItemFrequency, ItemFrequency, QSortBy> {
  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy>
      sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ItemFrequencyQuerySortThenBy
    on QueryBuilder<ItemFrequency, ItemFrequency, QSortThenBy> {
  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy>
      thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ItemFrequencyQueryWhereDistinct
    on QueryBuilder<ItemFrequency, ItemFrequency, QDistinct> {
  QueryBuilder<ItemFrequency, ItemFrequency, QDistinct> distinctByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency');
    });
  }

  QueryBuilder<ItemFrequency, ItemFrequency, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension ItemFrequencyQueryProperty
    on QueryBuilder<ItemFrequency, ItemFrequency, QQueryProperty> {
  QueryBuilder<ItemFrequency, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ItemFrequency, int, QQueryOperations> frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<ItemFrequency, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContextualSuggestionCollection on Isar {
  IsarCollection<ContextualSuggestion> get contextualSuggestions =>
      this.collection();
}

const ContextualSuggestionSchema = CollectionSchema(
  name: r'ContextualSuggestion',
  id: -7246946087991905255,
  properties: {
    r'patternKey': PropertySchema(
      id: 0,
      name: r'patternKey',
      type: IsarType.string,
    ),
    r'suggestions': PropertySchema(
      id: 1,
      name: r'suggestions',
      type: IsarType.stringList,
    )
  },
  estimateSize: _contextualSuggestionEstimateSize,
  serialize: _contextualSuggestionSerialize,
  deserialize: _contextualSuggestionDeserialize,
  deserializeProp: _contextualSuggestionDeserializeProp,
  idName: r'id',
  indexes: {
    r'patternKey': IndexSchema(
      id: -7255828189836942106,
      name: r'patternKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'patternKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _contextualSuggestionGetId,
  getLinks: _contextualSuggestionGetLinks,
  attach: _contextualSuggestionAttach,
  version: '3.1.0+1',
);

int _contextualSuggestionEstimateSize(
  ContextualSuggestion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.patternKey.length * 3;
  bytesCount += 3 + object.suggestions.length * 3;
  {
    for (var i = 0; i < object.suggestions.length; i++) {
      final value = object.suggestions[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _contextualSuggestionSerialize(
  ContextualSuggestion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.patternKey);
  writer.writeStringList(offsets[1], object.suggestions);
}

ContextualSuggestion _contextualSuggestionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContextualSuggestion();
  object.id = id;
  object.patternKey = reader.readString(offsets[0]);
  object.suggestions = reader.readStringList(offsets[1]) ?? [];
  return object;
}

P _contextualSuggestionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contextualSuggestionGetId(ContextualSuggestion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contextualSuggestionGetLinks(
    ContextualSuggestion object) {
  return [];
}

void _contextualSuggestionAttach(
    IsarCollection<dynamic> col, Id id, ContextualSuggestion object) {
  object.id = id;
}

extension ContextualSuggestionByIndex on IsarCollection<ContextualSuggestion> {
  Future<ContextualSuggestion?> getByPatternKey(String patternKey) {
    return getByIndex(r'patternKey', [patternKey]);
  }

  ContextualSuggestion? getByPatternKeySync(String patternKey) {
    return getByIndexSync(r'patternKey', [patternKey]);
  }

  Future<bool> deleteByPatternKey(String patternKey) {
    return deleteByIndex(r'patternKey', [patternKey]);
  }

  bool deleteByPatternKeySync(String patternKey) {
    return deleteByIndexSync(r'patternKey', [patternKey]);
  }

  Future<List<ContextualSuggestion?>> getAllByPatternKey(
      List<String> patternKeyValues) {
    final values = patternKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'patternKey', values);
  }

  List<ContextualSuggestion?> getAllByPatternKeySync(
      List<String> patternKeyValues) {
    final values = patternKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'patternKey', values);
  }

  Future<int> deleteAllByPatternKey(List<String> patternKeyValues) {
    final values = patternKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'patternKey', values);
  }

  int deleteAllByPatternKeySync(List<String> patternKeyValues) {
    final values = patternKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'patternKey', values);
  }

  Future<Id> putByPatternKey(ContextualSuggestion object) {
    return putByIndex(r'patternKey', object);
  }

  Id putByPatternKeySync(ContextualSuggestion object, {bool saveLinks = true}) {
    return putByIndexSync(r'patternKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPatternKey(List<ContextualSuggestion> objects) {
    return putAllByIndex(r'patternKey', objects);
  }

  List<Id> putAllByPatternKeySync(List<ContextualSuggestion> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'patternKey', objects, saveLinks: saveLinks);
  }
}

extension ContextualSuggestionQueryWhereSort
    on QueryBuilder<ContextualSuggestion, ContextualSuggestion, QWhere> {
  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContextualSuggestionQueryWhere
    on QueryBuilder<ContextualSuggestion, ContextualSuggestion, QWhereClause> {
  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      patternKeyEqualTo(String patternKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'patternKey',
        value: [patternKey],
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterWhereClause>
      patternKeyNotEqualTo(String patternKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patternKey',
              lower: [],
              upper: [patternKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patternKey',
              lower: [patternKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patternKey',
              lower: [patternKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patternKey',
              lower: [],
              upper: [patternKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ContextualSuggestionQueryFilter on QueryBuilder<ContextualSuggestion,
    ContextualSuggestion, QFilterCondition> {
  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patternKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'patternKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'patternKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'patternKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'patternKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'patternKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
          QAfterFilterCondition>
      patternKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'patternKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
          QAfterFilterCondition>
      patternKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'patternKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patternKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> patternKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'patternKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'suggestions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'suggestions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'suggestions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'suggestions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'suggestions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
          QAfterFilterCondition>
      suggestionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'suggestions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
          QAfterFilterCondition>
      suggestionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'suggestions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestions',
        value: '',
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'suggestions',
        value: '',
      ));
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'suggestions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'suggestions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'suggestions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'suggestions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'suggestions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion,
      QAfterFilterCondition> suggestionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'suggestions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ContextualSuggestionQueryObject on QueryBuilder<ContextualSuggestion,
    ContextualSuggestion, QFilterCondition> {}

extension ContextualSuggestionQueryLinks on QueryBuilder<ContextualSuggestion,
    ContextualSuggestion, QFilterCondition> {}

extension ContextualSuggestionQuerySortBy
    on QueryBuilder<ContextualSuggestion, ContextualSuggestion, QSortBy> {
  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterSortBy>
      sortByPatternKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternKey', Sort.asc);
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterSortBy>
      sortByPatternKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternKey', Sort.desc);
    });
  }
}

extension ContextualSuggestionQuerySortThenBy
    on QueryBuilder<ContextualSuggestion, ContextualSuggestion, QSortThenBy> {
  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterSortBy>
      thenByPatternKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternKey', Sort.asc);
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QAfterSortBy>
      thenByPatternKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patternKey', Sort.desc);
    });
  }
}

extension ContextualSuggestionQueryWhereDistinct
    on QueryBuilder<ContextualSuggestion, ContextualSuggestion, QDistinct> {
  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QDistinct>
      distinctByPatternKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'patternKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContextualSuggestion, ContextualSuggestion, QDistinct>
      distinctBySuggestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suggestions');
    });
  }
}

extension ContextualSuggestionQueryProperty on QueryBuilder<
    ContextualSuggestion, ContextualSuggestion, QQueryProperty> {
  QueryBuilder<ContextualSuggestion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContextualSuggestion, String, QQueryOperations>
      patternKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patternKey');
    });
  }

  QueryBuilder<ContextualSuggestion, List<String>, QQueryOperations>
      suggestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestions');
    });
  }
}

