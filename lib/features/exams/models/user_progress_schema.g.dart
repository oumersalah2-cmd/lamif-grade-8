// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserProgressCollection on Isar {
  IsarCollection<UserProgress> get userProgress => this.collection();
}

const UserProgressSchema = CollectionSchema(
  name: r'UserProgress',
  id: 518958300452706037,
  properties: {
    r'accuracyPercentage': PropertySchema(
      id: 0,
      name: r'accuracyPercentage',
      type: IsarType.double,
    ),
    r'formattedStudyTime': PropertySchema(
      id: 1,
      name: r'formattedStudyTime',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastStudiedAt': PropertySchema(
      id: 3,
      name: r'lastStudiedAt',
      type: IsarType.dateTime,
    ),
    r'subjectId': PropertySchema(
      id: 4,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'subjectTitleOm': PropertySchema(
      id: 5,
      name: r'subjectTitleOm',
      type: IsarType.string,
    ),
    r'totalCorrectAnswers': PropertySchema(
      id: 6,
      name: r'totalCorrectAnswers',
      type: IsarType.long,
    ),
    r'totalQuestionsAttempted': PropertySchema(
      id: 7,
      name: r'totalQuestionsAttempted',
      type: IsarType.long,
    ),
    r'totalTimeSpentSeconds': PropertySchema(
      id: 8,
      name: r'totalTimeSpentSeconds',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 9,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _userProgressEstimateSize,
  serialize: _userProgressSerialize,
  deserialize: _userProgressDeserialize,
  deserializeProp: _userProgressDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'subjectId': IndexSchema(
      id: 440306668014799972,
      name: r'subjectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastStudiedAt': IndexSchema(
      id: -8304652482822949363,
      name: r'lastStudiedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastStudiedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _userProgressGetId,
  getLinks: _userProgressGetLinks,
  attach: _userProgressAttach,
  version: '3.1.0+1',
);

int _userProgressEstimateSize(
  UserProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.formattedStudyTime.length * 3;
  bytesCount += 3 + object.subjectId.length * 3;
  bytesCount += 3 + object.subjectTitleOm.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _userProgressSerialize(
  UserProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracyPercentage);
  writer.writeString(offsets[1], object.formattedStudyTime);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeDateTime(offsets[3], object.lastStudiedAt);
  writer.writeString(offsets[4], object.subjectId);
  writer.writeString(offsets[5], object.subjectTitleOm);
  writer.writeLong(offsets[6], object.totalCorrectAnswers);
  writer.writeLong(offsets[7], object.totalQuestionsAttempted);
  writer.writeLong(offsets[8], object.totalTimeSpentSeconds);
  writer.writeString(offsets[9], object.userId);
}

UserProgress _userProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserProgress(
    id: id,
    isSynced: reader.readBoolOrNull(offsets[2]) ?? false,
    lastStudiedAt: reader.readDateTimeOrNull(offsets[3]),
    subjectId: reader.readStringOrNull(offsets[4]) ?? '',
    totalCorrectAnswers: reader.readLongOrNull(offsets[6]) ?? 0,
    totalQuestionsAttempted: reader.readLongOrNull(offsets[7]) ?? 0,
    totalTimeSpentSeconds: reader.readLongOrNull(offsets[8]) ?? 0,
    userId: reader.readStringOrNull(offsets[9]) ?? '',
  );
  return object;
}

P _userProgressDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 9:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userProgressGetId(UserProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userProgressGetLinks(UserProgress object) {
  return [];
}

void _userProgressAttach(
    IsarCollection<dynamic> col, Id id, UserProgress object) {
  object.id = id;
}

extension UserProgressQueryWhereSort
    on QueryBuilder<UserProgress, UserProgress, QWhere> {
  QueryBuilder<UserProgress, UserProgress, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhere> anyLastStudiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastStudiedAt'),
      );
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhere> anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension UserProgressQueryWhere
    on QueryBuilder<UserProgress, UserProgress, QWhereClause> {
  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> subjectIdEqualTo(
      String subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      subjectIdNotEqualTo(String subjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastStudiedAt',
        value: [null],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastStudiedAt',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtEqualTo(DateTime? lastStudiedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastStudiedAt',
        value: [lastStudiedAt],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtNotEqualTo(DateTime? lastStudiedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastStudiedAt',
              lower: [],
              upper: [lastStudiedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastStudiedAt',
              lower: [lastStudiedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastStudiedAt',
              lower: [lastStudiedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastStudiedAt',
              lower: [],
              upper: [lastStudiedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtGreaterThan(
    DateTime? lastStudiedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastStudiedAt',
        lower: [lastStudiedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtLessThan(
    DateTime? lastStudiedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastStudiedAt',
        lower: [],
        upper: [lastStudiedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      lastStudiedAtBetween(
    DateTime? lowerLastStudiedAt,
    DateTime? upperLastStudiedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastStudiedAt',
        lower: [lowerLastStudiedAt],
        includeLower: includeLower,
        upper: [upperLastStudiedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause> isSyncedEqualTo(
      bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension UserProgressQueryFilter
    on QueryBuilder<UserProgress, UserProgress, QFilterCondition> {
  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      accuracyPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracyPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      accuracyPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracyPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      accuracyPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracyPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      accuracyPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracyPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedStudyTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedStudyTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedStudyTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      formattedStudyTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedStudyTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      lastStudiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastStudiedAt',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      lastStudiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastStudiedAt',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      lastStudiedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastStudiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      lastStudiedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastStudiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      lastStudiedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastStudiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      lastStudiedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastStudiedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectTitleOm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectTitleOm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectTitleOm',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      subjectTitleOmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectTitleOm',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalCorrectAnswersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCorrectAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalCorrectAnswersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCorrectAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalCorrectAnswersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCorrectAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalCorrectAnswersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCorrectAnswers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalQuestionsAttemptedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalQuestionsAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalQuestionsAttemptedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalQuestionsAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalQuestionsAttemptedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalQuestionsAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalQuestionsAttemptedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalQuestionsAttempted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalTimeSpentSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTimeSpentSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalTimeSpentSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTimeSpentSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalTimeSpentSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTimeSpentSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      totalTimeSpentSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTimeSpentSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension UserProgressQueryObject
    on QueryBuilder<UserProgress, UserProgress, QFilterCondition> {}

extension UserProgressQueryLinks
    on QueryBuilder<UserProgress, UserProgress, QFilterCondition> {}

extension UserProgressQuerySortBy
    on QueryBuilder<UserProgress, UserProgress, QSortBy> {
  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByAccuracyPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByAccuracyPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByFormattedStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByFormattedStudyTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortByLastStudiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedAt', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByLastStudiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedAt', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortBySubjectTitleOm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortBySubjectTitleOmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByTotalCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrectAnswers', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByTotalCorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrectAnswers', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByTotalQuestionsAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByTotalQuestionsAttemptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByTotalTimeSpentSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSpentSeconds', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      sortByTotalTimeSpentSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSpentSeconds', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserProgressQuerySortThenBy
    on QueryBuilder<UserProgress, UserProgress, QSortThenBy> {
  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByAccuracyPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByAccuracyPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByFormattedStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByFormattedStudyTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenByLastStudiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedAt', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByLastStudiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedAt', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenBySubjectTitleOm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenBySubjectTitleOmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByTotalCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrectAnswers', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByTotalCorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrectAnswers', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByTotalQuestionsAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByTotalQuestionsAttemptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByTotalTimeSpentSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSpentSeconds', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy>
      thenByTotalTimeSpentSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSpentSeconds', Sort.desc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserProgressQueryWhereDistinct
    on QueryBuilder<UserProgress, UserProgress, QDistinct> {
  QueryBuilder<UserProgress, UserProgress, QDistinct>
      distinctByAccuracyPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracyPercentage');
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct>
      distinctByFormattedStudyTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedStudyTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct>
      distinctByLastStudiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastStudiedAt');
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct> distinctBySubjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct> distinctBySubjectTitleOm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectTitleOm',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct>
      distinctByTotalCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCorrectAnswers');
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct>
      distinctByTotalQuestionsAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalQuestionsAttempted');
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct>
      distinctByTotalTimeSpentSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTimeSpentSeconds');
    });
  }

  QueryBuilder<UserProgress, UserProgress, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension UserProgressQueryProperty
    on QueryBuilder<UserProgress, UserProgress, QQueryProperty> {
  QueryBuilder<UserProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserProgress, double, QQueryOperations>
      accuracyPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracyPercentage');
    });
  }

  QueryBuilder<UserProgress, String, QQueryOperations>
      formattedStudyTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedStudyTime');
    });
  }

  QueryBuilder<UserProgress, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<UserProgress, DateTime?, QQueryOperations>
      lastStudiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastStudiedAt');
    });
  }

  QueryBuilder<UserProgress, String, QQueryOperations> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<UserProgress, String, QQueryOperations>
      subjectTitleOmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectTitleOm');
    });
  }

  QueryBuilder<UserProgress, int, QQueryOperations>
      totalCorrectAnswersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCorrectAnswers');
    });
  }

  QueryBuilder<UserProgress, int, QQueryOperations>
      totalQuestionsAttemptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalQuestionsAttempted');
    });
  }

  QueryBuilder<UserProgress, int, QQueryOperations>
      totalTimeSpentSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTimeSpentSeconds');
    });
  }

  QueryBuilder<UserProgress, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
