// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_result_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExamResultCollection on Isar {
  IsarCollection<ExamResult> get examResults => this.collection();
}

const ExamResultSchema = CollectionSchema(
  name: r'ExamResult',
  id: -4973695977191503399,
  properties: {
    r'dateTaken': PropertySchema(
      id: 0,
      name: r'dateTaken',
      type: IsarType.dateTime,
    ),
    r'formattedDate': PropertySchema(
      id: 1,
      name: r'formattedDate',
      type: IsarType.string,
    ),
    r'formattedTimeTaken': PropertySchema(
      id: 2,
      name: r'formattedTimeTaken',
      type: IsarType.string,
    ),
    r'isPassed': PropertySchema(
      id: 3,
      name: r'isPassed',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'score': PropertySchema(
      id: 5,
      name: r'score',
      type: IsarType.long,
    ),
    r'scorePercentage': PropertySchema(
      id: 6,
      name: r'scorePercentage',
      type: IsarType.double,
    ),
    r'subjectId': PropertySchema(
      id: 7,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'subjectTitleOm': PropertySchema(
      id: 8,
      name: r'subjectTitleOm',
      type: IsarType.string,
    ),
    r'timeTaken': PropertySchema(
      id: 9,
      name: r'timeTaken',
      type: IsarType.long,
    ),
    r'totalQuestions': PropertySchema(
      id: 10,
      name: r'totalQuestions',
      type: IsarType.long,
    )
  },
  estimateSize: _examResultEstimateSize,
  serialize: _examResultSerialize,
  deserialize: _examResultDeserialize,
  deserializeProp: _examResultDeserializeProp,
  idName: r'id',
  indexes: {
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
    r'dateTaken': IndexSchema(
      id: 9200557840532179902,
      name: r'dateTaken',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateTaken',
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
  getId: _examResultGetId,
  getLinks: _examResultGetLinks,
  attach: _examResultAttach,
  version: '3.1.0+1',
);

int _examResultEstimateSize(
  ExamResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.formattedDate.length * 3;
  bytesCount += 3 + object.formattedTimeTaken.length * 3;
  bytesCount += 3 + object.subjectId.length * 3;
  bytesCount += 3 + object.subjectTitleOm.length * 3;
  return bytesCount;
}

void _examResultSerialize(
  ExamResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTaken);
  writer.writeString(offsets[1], object.formattedDate);
  writer.writeString(offsets[2], object.formattedTimeTaken);
  writer.writeBool(offsets[3], object.isPassed);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeLong(offsets[5], object.score);
  writer.writeDouble(offsets[6], object.scorePercentage);
  writer.writeString(offsets[7], object.subjectId);
  writer.writeString(offsets[8], object.subjectTitleOm);
  writer.writeLong(offsets[9], object.timeTaken);
  writer.writeLong(offsets[10], object.totalQuestions);
}

ExamResult _examResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExamResult(
    dateTaken: reader.readDateTimeOrNull(offsets[0]),
    id: id,
    isSynced: reader.readBoolOrNull(offsets[4]) ?? false,
    score: reader.readLongOrNull(offsets[5]) ?? 0,
    subjectId: reader.readStringOrNull(offsets[7]) ?? '',
    timeTaken: reader.readLongOrNull(offsets[9]) ?? 0,
    totalQuestions: reader.readLongOrNull(offsets[10]) ?? 0,
  );
  return object;
}

P _examResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _examResultGetId(ExamResult object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _examResultGetLinks(ExamResult object) {
  return [];
}

void _examResultAttach(IsarCollection<dynamic> col, Id id, ExamResult object) {
  object.id = id;
}

extension ExamResultQueryWhereSort
    on QueryBuilder<ExamResult, ExamResult, QWhere> {
  QueryBuilder<ExamResult, ExamResult, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhere> anyDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateTaken'),
      );
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhere> anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension ExamResultQueryWhere
    on QueryBuilder<ExamResult, ExamResult, QWhereClause> {
  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> idBetween(
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

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> subjectIdEqualTo(
      String subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> subjectIdNotEqualTo(
      String subjectId) {
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

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateTaken',
        value: [null],
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTaken',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenEqualTo(
      DateTime? dateTaken) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateTaken',
        value: [dateTaken],
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenNotEqualTo(
      DateTime? dateTaken) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTaken',
              lower: [],
              upper: [dateTaken],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTaken',
              lower: [dateTaken],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTaken',
              lower: [dateTaken],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTaken',
              lower: [],
              upper: [dateTaken],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenGreaterThan(
    DateTime? dateTaken, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTaken',
        lower: [dateTaken],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenLessThan(
    DateTime? dateTaken, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTaken',
        lower: [],
        upper: [dateTaken],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> dateTakenBetween(
    DateTime? lowerDateTaken,
    DateTime? upperDateTaken, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTaken',
        lower: [lowerDateTaken],
        includeLower: includeLower,
        upper: [upperDateTaken],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> isSyncedEqualTo(
      bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterWhereClause> isSyncedNotEqualTo(
      bool isSynced) {
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

extension ExamResultQueryFilter
    on QueryBuilder<ExamResult, ExamResult, QFilterCondition> {
  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      dateTakenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateTaken',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      dateTakenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateTaken',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> dateTakenEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      dateTakenGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> dateTakenLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> dateTakenBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTaken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedDate',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedDate',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedTimeTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedTimeTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedTimeTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedTimeTaken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedTimeTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedTimeTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedTimeTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedTimeTaken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedTimeTaken',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      formattedTimeTakenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedTimeTaken',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> isPassedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPassed',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> isSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> scoreEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> scoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> scoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      scorePercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scorePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      scorePercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scorePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      scorePercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scorePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      scorePercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scorePercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> subjectIdEqualTo(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> subjectIdLessThan(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> subjectIdBetween(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> subjectIdEndsWith(
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> subjectIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> subjectIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
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

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      subjectTitleOmContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectTitleOm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      subjectTitleOmMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectTitleOm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      subjectTitleOmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectTitleOm',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      subjectTitleOmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectTitleOm',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> timeTakenEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      timeTakenGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> timeTakenLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition> timeTakenBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeTaken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      totalQuestionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      totalQuestionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      totalQuestionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterFilterCondition>
      totalQuestionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalQuestions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExamResultQueryObject
    on QueryBuilder<ExamResult, ExamResult, QFilterCondition> {}

extension ExamResultQueryLinks
    on QueryBuilder<ExamResult, ExamResult, QFilterCondition> {}

extension ExamResultQuerySortBy
    on QueryBuilder<ExamResult, ExamResult, QSortBy> {
  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByDateTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByFormattedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByFormattedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      sortByFormattedTimeTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTimeTaken', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      sortByFormattedTimeTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTimeTaken', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByIsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByIsPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByScorePercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercentage', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      sortByScorePercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercentage', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortBySubjectTitleOm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      sortBySubjectTitleOmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByTimeTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTaken', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByTimeTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTaken', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> sortByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      sortByTotalQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.desc);
    });
  }
}

extension ExamResultQuerySortThenBy
    on QueryBuilder<ExamResult, ExamResult, QSortThenBy> {
  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByDateTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByFormattedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByFormattedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      thenByFormattedTimeTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTimeTaken', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      thenByFormattedTimeTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTimeTaken', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByIsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByIsPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPassed', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByScorePercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercentage', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      thenByScorePercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercentage', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenBySubjectTitleOm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      thenBySubjectTitleOmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectTitleOm', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByTimeTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTaken', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByTimeTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTaken', Sort.desc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy> thenByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.asc);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QAfterSortBy>
      thenByTotalQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.desc);
    });
  }
}

extension ExamResultQueryWhereDistinct
    on QueryBuilder<ExamResult, ExamResult, QDistinct> {
  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTaken');
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByFormattedDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedDate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByFormattedTimeTaken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedTimeTaken',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByIsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPassed');
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByScorePercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scorePercentage');
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctBySubjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctBySubjectTitleOm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectTitleOm',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByTimeTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeTaken');
    });
  }

  QueryBuilder<ExamResult, ExamResult, QDistinct> distinctByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalQuestions');
    });
  }
}

extension ExamResultQueryProperty
    on QueryBuilder<ExamResult, ExamResult, QQueryProperty> {
  QueryBuilder<ExamResult, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExamResult, DateTime?, QQueryOperations> dateTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTaken');
    });
  }

  QueryBuilder<ExamResult, String, QQueryOperations> formattedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedDate');
    });
  }

  QueryBuilder<ExamResult, String, QQueryOperations>
      formattedTimeTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedTimeTaken');
    });
  }

  QueryBuilder<ExamResult, bool, QQueryOperations> isPassedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPassed');
    });
  }

  QueryBuilder<ExamResult, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ExamResult, int, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<ExamResult, double, QQueryOperations> scorePercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scorePercentage');
    });
  }

  QueryBuilder<ExamResult, String, QQueryOperations> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<ExamResult, String, QQueryOperations> subjectTitleOmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectTitleOm');
    });
  }

  QueryBuilder<ExamResult, int, QQueryOperations> timeTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeTaken');
    });
  }

  QueryBuilder<ExamResult, int, QQueryOperations> totalQuestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalQuestions');
    });
  }
}
