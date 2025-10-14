// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Queue extends Table with TableInfo<Queue, QueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Queue(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
      'index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY UNIQUE');
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  late final GeneratedColumnWithTypeConverter<QueueContextType, String>
      context = GeneratedColumn<String>('context', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<QueueContextType>(Queue.$convertercontext);
  static const VerificationMeta _contextIdMeta =
      const VerificationMeta('contextId');
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
      'context_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _currentTrackMeta =
      const VerificationMeta('currentTrack');
  late final GeneratedColumn<bool> currentTrack = GeneratedColumn<bool>(
      'current_track', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'UNIQUE');
  @override
  List<GeneratedColumn> get $columns =>
      [index, sourceId, id, context, contextId, currentTrack];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue';
  @override
  VerificationContext validateIntegrity(Insertable<QueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('index')) {
      context.handle(
          _indexMeta, index.isAcceptableOrUnknown(data['index']!, _indexMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_contextMeta, const VerificationResult.success());
    if (data.containsKey('context_id')) {
      context.handle(_contextIdMeta,
          contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta));
    }
    if (data.containsKey('current_track')) {
      context.handle(
          _currentTrackMeta,
          currentTrack.isAcceptableOrUnknown(
              data['current_track']!, _currentTrackMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {index};
  @override
  QueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueData(
      index: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      context: Queue.$convertercontext.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context'])!),
      contextId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_id']),
      currentTrack: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}current_track']),
    );
  }

  @override
  Queue createAlias(String alias) {
    return Queue(attachedDatabase, alias);
  }

  static JsonTypeConverter2<QueueContextType, String, String>
      $convertercontext =
      const EnumNameConverter<QueueContextType>(QueueContextType.values);
  @override
  bool get dontWriteConstraints => true;
}

class QueueData extends DataClass implements Insertable<QueueData> {
  final int index;
  final int sourceId;
  final String id;
  final QueueContextType context;
  final String? contextId;
  final bool? currentTrack;
  const QueueData(
      {required this.index,
      required this.sourceId,
      required this.id,
      required this.context,
      this.contextId,
      this.currentTrack});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['index'] = Variable<int>(index);
    map['source_id'] = Variable<int>(sourceId);
    map['id'] = Variable<String>(id);
    {
      map['context'] = Variable<String>(Queue.$convertercontext.toSql(context));
    }
    if (!nullToAbsent || contextId != null) {
      map['context_id'] = Variable<String>(contextId);
    }
    if (!nullToAbsent || currentTrack != null) {
      map['current_track'] = Variable<bool>(currentTrack);
    }
    return map;
  }

  QueueCompanion toCompanion(bool nullToAbsent) {
    return QueueCompanion(
      index: Value(index),
      sourceId: Value(sourceId),
      id: Value(id),
      context: Value(context),
      contextId: contextId == null && nullToAbsent
          ? const Value.absent()
          : Value(contextId),
      currentTrack: currentTrack == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTrack),
    );
  }

  factory QueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueData(
      index: serializer.fromJson<int>(json['index']),
      sourceId: serializer.fromJson<int>(json['source_id']),
      id: serializer.fromJson<String>(json['id']),
      context: Queue.$convertercontext
          .fromJson(serializer.fromJson<String>(json['context'])),
      contextId: serializer.fromJson<String?>(json['context_id']),
      currentTrack: serializer.fromJson<bool?>(json['current_track']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'index': serializer.toJson<int>(index),
      'source_id': serializer.toJson<int>(sourceId),
      'id': serializer.toJson<String>(id),
      'context':
          serializer.toJson<String>(Queue.$convertercontext.toJson(context)),
      'context_id': serializer.toJson<String?>(contextId),
      'current_track': serializer.toJson<bool?>(currentTrack),
    };
  }

  QueueData copyWith(
          {int? index,
          int? sourceId,
          String? id,
          QueueContextType? context,
          Value<String?> contextId = const Value.absent(),
          Value<bool?> currentTrack = const Value.absent()}) =>
      QueueData(
        index: index ?? this.index,
        sourceId: sourceId ?? this.sourceId,
        id: id ?? this.id,
        context: context ?? this.context,
        contextId: contextId.present ? contextId.value : this.contextId,
        currentTrack:
            currentTrack.present ? currentTrack.value : this.currentTrack,
      );
  @override
  String toString() {
    return (StringBuffer('QueueData(')
          ..write('index: $index, ')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('context: $context, ')
          ..write('contextId: $contextId, ')
          ..write('currentTrack: $currentTrack')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(index, sourceId, id, context, contextId, currentTrack);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueData &&
          other.index == this.index &&
          other.sourceId == this.sourceId &&
          other.id == this.id &&
          other.context == this.context &&
          other.contextId == this.contextId &&
          other.currentTrack == this.currentTrack);
}

class QueueCompanion extends UpdateCompanion<QueueData> {
  final Value<int> index;
  final Value<int> sourceId;
  final Value<String> id;
  final Value<QueueContextType> context;
  final Value<String?> contextId;
  final Value<bool?> currentTrack;
  const QueueCompanion({
    this.index = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.context = const Value.absent(),
    this.contextId = const Value.absent(),
    this.currentTrack = const Value.absent(),
  });
  QueueCompanion.insert({
    this.index = const Value.absent(),
    required int sourceId,
    required String id,
    required QueueContextType context,
    this.contextId = const Value.absent(),
    this.currentTrack = const Value.absent(),
  })  : sourceId = Value(sourceId),
        id = Value(id),
        context = Value(context);
  static Insertable<QueueData> custom({
    Expression<int>? index,
    Expression<int>? sourceId,
    Expression<String>? id,
    Expression<String>? context,
    Expression<String>? contextId,
    Expression<bool>? currentTrack,
  }) {
    return RawValuesInsertable({
      if (index != null) 'index': index,
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (context != null) 'context': context,
      if (contextId != null) 'context_id': contextId,
      if (currentTrack != null) 'current_track': currentTrack,
    });
  }

  QueueCompanion copyWith(
      {Value<int>? index,
      Value<int>? sourceId,
      Value<String>? id,
      Value<QueueContextType>? context,
      Value<String?>? contextId,
      Value<bool?>? currentTrack}) {
    return QueueCompanion(
      index: index ?? this.index,
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      context: context ?? this.context,
      contextId: contextId ?? this.contextId,
      currentTrack: currentTrack ?? this.currentTrack,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (context.present) {
      map['context'] =
          Variable<String>(Queue.$convertercontext.toSql(context.value));
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (currentTrack.present) {
      map['current_track'] = Variable<bool>(currentTrack.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueCompanion(')
          ..write('index: $index, ')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('context: $context, ')
          ..write('contextId: $contextId, ')
          ..write('currentTrack: $currentTrack')
          ..write(')'))
        .toString();
  }
}

class LastAudioState extends Table
    with TableInfo<LastAudioState, LastAudioStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LastAudioState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _queueModeMeta =
      const VerificationMeta('queueMode');
  late final GeneratedColumnWithTypeConverter<QueueMode, int> queueMode =
      GeneratedColumn<int>('queue_mode', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<QueueMode>(LastAudioState.$converterqueueMode);
  static const VerificationMeta _shuffleIndiciesMeta =
      const VerificationMeta('shuffleIndicies');
  late final GeneratedColumnWithTypeConverter<IList<int>?, String>
      shuffleIndicies = GeneratedColumn<String>(
              'shuffle_indicies', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: '')
          .withConverter<IList<int>?>(
              LastAudioState.$convertershuffleIndiciesn);
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  late final GeneratedColumnWithTypeConverter<RepeatMode, int> repeat =
      GeneratedColumn<int>('repeat', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<RepeatMode>(LastAudioState.$converterrepeat);
  @override
  List<GeneratedColumn> get $columns =>
      [id, queueMode, shuffleIndicies, repeat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_audio_state';
  @override
  VerificationContext validateIntegrity(Insertable<LastAudioStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_queueModeMeta, const VerificationResult.success());
    context.handle(_shuffleIndiciesMeta, const VerificationResult.success());
    context.handle(_repeatMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LastAudioStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastAudioStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      queueMode: LastAudioState.$converterqueueMode.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}queue_mode'])!),
      shuffleIndicies: LastAudioState.$convertershuffleIndiciesn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}shuffle_indicies'])),
      repeat: LastAudioState.$converterrepeat.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repeat'])!),
    );
  }

  @override
  LastAudioState createAlias(String alias) {
    return LastAudioState(attachedDatabase, alias);
  }

  static JsonTypeConverter2<QueueMode, int, int> $converterqueueMode =
      const EnumIndexConverter<QueueMode>(QueueMode.values);
  static TypeConverter<IList<int>, String> $convertershuffleIndicies =
      const IListIntConverter();
  static TypeConverter<IList<int>?, String?> $convertershuffleIndiciesn =
      NullAwareTypeConverter.wrap($convertershuffleIndicies);
  static JsonTypeConverter2<RepeatMode, int, int> $converterrepeat =
      const EnumIndexConverter<RepeatMode>(RepeatMode.values);
  @override
  bool get dontWriteConstraints => true;
}

class LastAudioStateData extends DataClass
    implements Insertable<LastAudioStateData> {
  final int id;
  final QueueMode queueMode;
  final IList<int>? shuffleIndicies;
  final RepeatMode repeat;
  const LastAudioStateData(
      {required this.id,
      required this.queueMode,
      this.shuffleIndicies,
      required this.repeat});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['queue_mode'] =
          Variable<int>(LastAudioState.$converterqueueMode.toSql(queueMode));
    }
    if (!nullToAbsent || shuffleIndicies != null) {
      map['shuffle_indicies'] = Variable<String>(
          LastAudioState.$convertershuffleIndiciesn.toSql(shuffleIndicies));
    }
    {
      map['repeat'] =
          Variable<int>(LastAudioState.$converterrepeat.toSql(repeat));
    }
    return map;
  }

  LastAudioStateCompanion toCompanion(bool nullToAbsent) {
    return LastAudioStateCompanion(
      id: Value(id),
      queueMode: Value(queueMode),
      shuffleIndicies: shuffleIndicies == null && nullToAbsent
          ? const Value.absent()
          : Value(shuffleIndicies),
      repeat: Value(repeat),
    );
  }

  factory LastAudioStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastAudioStateData(
      id: serializer.fromJson<int>(json['id']),
      queueMode: LastAudioState.$converterqueueMode
          .fromJson(serializer.fromJson<int>(json['queue_mode'])),
      shuffleIndicies:
          serializer.fromJson<IList<int>?>(json['shuffle_indicies']),
      repeat: LastAudioState.$converterrepeat
          .fromJson(serializer.fromJson<int>(json['repeat'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queue_mode': serializer
          .toJson<int>(LastAudioState.$converterqueueMode.toJson(queueMode)),
      'shuffle_indicies': serializer.toJson<IList<int>?>(shuffleIndicies),
      'repeat': serializer
          .toJson<int>(LastAudioState.$converterrepeat.toJson(repeat)),
    };
  }

  LastAudioStateData copyWith(
          {int? id,
          QueueMode? queueMode,
          Value<IList<int>?> shuffleIndicies = const Value.absent(),
          RepeatMode? repeat}) =>
      LastAudioStateData(
        id: id ?? this.id,
        queueMode: queueMode ?? this.queueMode,
        shuffleIndicies: shuffleIndicies.present
            ? shuffleIndicies.value
            : this.shuffleIndicies,
        repeat: repeat ?? this.repeat,
      );
  @override
  String toString() {
    return (StringBuffer('LastAudioStateData(')
          ..write('id: $id, ')
          ..write('queueMode: $queueMode, ')
          ..write('shuffleIndicies: $shuffleIndicies, ')
          ..write('repeat: $repeat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, queueMode, shuffleIndicies, repeat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastAudioStateData &&
          other.id == this.id &&
          other.queueMode == this.queueMode &&
          other.shuffleIndicies == this.shuffleIndicies &&
          other.repeat == this.repeat);
}

class LastAudioStateCompanion extends UpdateCompanion<LastAudioStateData> {
  final Value<int> id;
  final Value<QueueMode> queueMode;
  final Value<IList<int>?> shuffleIndicies;
  final Value<RepeatMode> repeat;
  const LastAudioStateCompanion({
    this.id = const Value.absent(),
    this.queueMode = const Value.absent(),
    this.shuffleIndicies = const Value.absent(),
    this.repeat = const Value.absent(),
  });
  LastAudioStateCompanion.insert({
    this.id = const Value.absent(),
    required QueueMode queueMode,
    this.shuffleIndicies = const Value.absent(),
    required RepeatMode repeat,
  })  : queueMode = Value(queueMode),
        repeat = Value(repeat);
  static Insertable<LastAudioStateData> custom({
    Expression<int>? id,
    Expression<int>? queueMode,
    Expression<String>? shuffleIndicies,
    Expression<int>? repeat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queueMode != null) 'queue_mode': queueMode,
      if (shuffleIndicies != null) 'shuffle_indicies': shuffleIndicies,
      if (repeat != null) 'repeat': repeat,
    });
  }

  LastAudioStateCompanion copyWith(
      {Value<int>? id,
      Value<QueueMode>? queueMode,
      Value<IList<int>?>? shuffleIndicies,
      Value<RepeatMode>? repeat}) {
    return LastAudioStateCompanion(
      id: id ?? this.id,
      queueMode: queueMode ?? this.queueMode,
      shuffleIndicies: shuffleIndicies ?? this.shuffleIndicies,
      repeat: repeat ?? this.repeat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queueMode.present) {
      map['queue_mode'] = Variable<int>(
          LastAudioState.$converterqueueMode.toSql(queueMode.value));
    }
    if (shuffleIndicies.present) {
      map['shuffle_indicies'] = Variable<String>(LastAudioState
          .$convertershuffleIndiciesn
          .toSql(shuffleIndicies.value));
    }
    if (repeat.present) {
      map['repeat'] =
          Variable<int>(LastAudioState.$converterrepeat.toSql(repeat.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastAudioStateCompanion(')
          ..write('id: $id, ')
          ..write('queueMode: $queueMode, ')
          ..write('shuffleIndicies: $shuffleIndicies, ')
          ..write('repeat: $repeat')
          ..write(')'))
        .toString();
  }
}

class LastBottomNavState extends Table
    with TableInfo<LastBottomNavState, LastBottomNavStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LastBottomNavState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _tabMeta = const VerificationMeta('tab');
  late final GeneratedColumn<String> tab = GeneratedColumn<String>(
      'tab', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, tab];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_bottom_nav_state';
  @override
  VerificationContext validateIntegrity(
      Insertable<LastBottomNavStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tab')) {
      context.handle(
          _tabMeta, tab.isAcceptableOrUnknown(data['tab']!, _tabMeta));
    } else if (isInserting) {
      context.missing(_tabMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LastBottomNavStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastBottomNavStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tab: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tab'])!,
    );
  }

  @override
  LastBottomNavState createAlias(String alias) {
    return LastBottomNavState(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LastBottomNavStateData extends DataClass
    implements Insertable<LastBottomNavStateData> {
  final int id;
  final String tab;
  const LastBottomNavStateData({required this.id, required this.tab});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tab'] = Variable<String>(tab);
    return map;
  }

  LastBottomNavStateCompanion toCompanion(bool nullToAbsent) {
    return LastBottomNavStateCompanion(
      id: Value(id),
      tab: Value(tab),
    );
  }

  factory LastBottomNavStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastBottomNavStateData(
      id: serializer.fromJson<int>(json['id']),
      tab: serializer.fromJson<String>(json['tab']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tab': serializer.toJson<String>(tab),
    };
  }

  LastBottomNavStateData copyWith({int? id, String? tab}) =>
      LastBottomNavStateData(
        id: id ?? this.id,
        tab: tab ?? this.tab,
      );
  @override
  String toString() {
    return (StringBuffer('LastBottomNavStateData(')
          ..write('id: $id, ')
          ..write('tab: $tab')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tab);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastBottomNavStateData &&
          other.id == this.id &&
          other.tab == this.tab);
}

class LastBottomNavStateCompanion
    extends UpdateCompanion<LastBottomNavStateData> {
  final Value<int> id;
  final Value<String> tab;
  const LastBottomNavStateCompanion({
    this.id = const Value.absent(),
    this.tab = const Value.absent(),
  });
  LastBottomNavStateCompanion.insert({
    this.id = const Value.absent(),
    required String tab,
  }) : tab = Value(tab);
  static Insertable<LastBottomNavStateData> custom({
    Expression<int>? id,
    Expression<String>? tab,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tab != null) 'tab': tab,
    });
  }

  LastBottomNavStateCompanion copyWith({Value<int>? id, Value<String>? tab}) {
    return LastBottomNavStateCompanion(
      id: id ?? this.id,
      tab: tab ?? this.tab,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tab.present) {
      map['tab'] = Variable<String>(tab.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastBottomNavStateCompanion(')
          ..write('id: $id, ')
          ..write('tab: $tab')
          ..write(')'))
        .toString();
  }
}

class LastLibraryState extends Table
    with TableInfo<LastLibraryState, LastLibraryStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LastLibraryState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _tabMeta = const VerificationMeta('tab');
  late final GeneratedColumn<String> tab = GeneratedColumn<String>(
      'tab', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _albumsListMeta =
      const VerificationMeta('albumsList');
  late final GeneratedColumnWithTypeConverter<ListQuery, String> albumsList =
      GeneratedColumn<String>('albums_list', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<ListQuery>(LastLibraryState.$converteralbumsList);
  static const VerificationMeta _artistsListMeta =
      const VerificationMeta('artistsList');
  late final GeneratedColumnWithTypeConverter<ListQuery, String> artistsList =
      GeneratedColumn<String>('artists_list', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<ListQuery>(LastLibraryState.$converterartistsList);
  static const VerificationMeta _playlistsListMeta =
      const VerificationMeta('playlistsList');
  late final GeneratedColumnWithTypeConverter<ListQuery, String> playlistsList =
      GeneratedColumn<String>('playlists_list', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<ListQuery>(LastLibraryState.$converterplaylistsList);
  static const VerificationMeta _songsListMeta =
      const VerificationMeta('songsList');
  late final GeneratedColumnWithTypeConverter<ListQuery, String> songsList =
      GeneratedColumn<String>('songs_list', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<ListQuery>(LastLibraryState.$convertersongsList);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tab, albumsList, artistsList, playlistsList, songsList];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_library_state';
  @override
  VerificationContext validateIntegrity(
      Insertable<LastLibraryStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tab')) {
      context.handle(
          _tabMeta, tab.isAcceptableOrUnknown(data['tab']!, _tabMeta));
    } else if (isInserting) {
      context.missing(_tabMeta);
    }
    context.handle(_albumsListMeta, const VerificationResult.success());
    context.handle(_artistsListMeta, const VerificationResult.success());
    context.handle(_playlistsListMeta, const VerificationResult.success());
    context.handle(_songsListMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LastLibraryStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastLibraryStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tab: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tab'])!,
      albumsList: LastLibraryState.$converteralbumsList.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}albums_list'])!),
      artistsList: LastLibraryState.$converterartistsList.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}artists_list'])!),
      playlistsList: LastLibraryState.$converterplaylistsList.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}playlists_list'])!),
      songsList: LastLibraryState.$convertersongsList.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}songs_list'])!),
    );
  }

  @override
  LastLibraryState createAlias(String alias) {
    return LastLibraryState(attachedDatabase, alias);
  }

  static TypeConverter<ListQuery, String> $converteralbumsList =
      const ListQueryConverter();
  static TypeConverter<ListQuery, String> $converterartistsList =
      const ListQueryConverter();
  static TypeConverter<ListQuery, String> $converterplaylistsList =
      const ListQueryConverter();
  static TypeConverter<ListQuery, String> $convertersongsList =
      const ListQueryConverter();
  @override
  bool get dontWriteConstraints => true;
}

class LastLibraryStateData extends DataClass
    implements Insertable<LastLibraryStateData> {
  final int id;
  final String tab;
  final ListQuery albumsList;
  final ListQuery artistsList;
  final ListQuery playlistsList;
  final ListQuery songsList;
  const LastLibraryStateData(
      {required this.id,
      required this.tab,
      required this.albumsList,
      required this.artistsList,
      required this.playlistsList,
      required this.songsList});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tab'] = Variable<String>(tab);
    {
      map['albums_list'] = Variable<String>(
          LastLibraryState.$converteralbumsList.toSql(albumsList));
    }
    {
      map['artists_list'] = Variable<String>(
          LastLibraryState.$converterartistsList.toSql(artistsList));
    }
    {
      map['playlists_list'] = Variable<String>(
          LastLibraryState.$converterplaylistsList.toSql(playlistsList));
    }
    {
      map['songs_list'] = Variable<String>(
          LastLibraryState.$convertersongsList.toSql(songsList));
    }
    return map;
  }

  LastLibraryStateCompanion toCompanion(bool nullToAbsent) {
    return LastLibraryStateCompanion(
      id: Value(id),
      tab: Value(tab),
      albumsList: Value(albumsList),
      artistsList: Value(artistsList),
      playlistsList: Value(playlistsList),
      songsList: Value(songsList),
    );
  }

  factory LastLibraryStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastLibraryStateData(
      id: serializer.fromJson<int>(json['id']),
      tab: serializer.fromJson<String>(json['tab']),
      albumsList: serializer.fromJson<ListQuery>(json['albums_list']),
      artistsList: serializer.fromJson<ListQuery>(json['artists_list']),
      playlistsList: serializer.fromJson<ListQuery>(json['playlists_list']),
      songsList: serializer.fromJson<ListQuery>(json['songs_list']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tab': serializer.toJson<String>(tab),
      'albums_list': serializer.toJson<ListQuery>(albumsList),
      'artists_list': serializer.toJson<ListQuery>(artistsList),
      'playlists_list': serializer.toJson<ListQuery>(playlistsList),
      'songs_list': serializer.toJson<ListQuery>(songsList),
    };
  }

  LastLibraryStateData copyWith(
          {int? id,
          String? tab,
          ListQuery? albumsList,
          ListQuery? artistsList,
          ListQuery? playlistsList,
          ListQuery? songsList}) =>
      LastLibraryStateData(
        id: id ?? this.id,
        tab: tab ?? this.tab,
        albumsList: albumsList ?? this.albumsList,
        artistsList: artistsList ?? this.artistsList,
        playlistsList: playlistsList ?? this.playlistsList,
        songsList: songsList ?? this.songsList,
      );
  @override
  String toString() {
    return (StringBuffer('LastLibraryStateData(')
          ..write('id: $id, ')
          ..write('tab: $tab, ')
          ..write('albumsList: $albumsList, ')
          ..write('artistsList: $artistsList, ')
          ..write('playlistsList: $playlistsList, ')
          ..write('songsList: $songsList')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tab, albumsList, artistsList, playlistsList, songsList);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastLibraryStateData &&
          other.id == this.id &&
          other.tab == this.tab &&
          other.albumsList == this.albumsList &&
          other.artistsList == this.artistsList &&
          other.playlistsList == this.playlistsList &&
          other.songsList == this.songsList);
}

class LastLibraryStateCompanion extends UpdateCompanion<LastLibraryStateData> {
  final Value<int> id;
  final Value<String> tab;
  final Value<ListQuery> albumsList;
  final Value<ListQuery> artistsList;
  final Value<ListQuery> playlistsList;
  final Value<ListQuery> songsList;
  const LastLibraryStateCompanion({
    this.id = const Value.absent(),
    this.tab = const Value.absent(),
    this.albumsList = const Value.absent(),
    this.artistsList = const Value.absent(),
    this.playlistsList = const Value.absent(),
    this.songsList = const Value.absent(),
  });
  LastLibraryStateCompanion.insert({
    this.id = const Value.absent(),
    required String tab,
    required ListQuery albumsList,
    required ListQuery artistsList,
    required ListQuery playlistsList,
    required ListQuery songsList,
  })  : tab = Value(tab),
        albumsList = Value(albumsList),
        artistsList = Value(artistsList),
        playlistsList = Value(playlistsList),
        songsList = Value(songsList);
  static Insertable<LastLibraryStateData> custom({
    Expression<int>? id,
    Expression<String>? tab,
    Expression<String>? albumsList,
    Expression<String>? artistsList,
    Expression<String>? playlistsList,
    Expression<String>? songsList,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tab != null) 'tab': tab,
      if (albumsList != null) 'albums_list': albumsList,
      if (artistsList != null) 'artists_list': artistsList,
      if (playlistsList != null) 'playlists_list': playlistsList,
      if (songsList != null) 'songs_list': songsList,
    });
  }

  LastLibraryStateCompanion copyWith(
      {Value<int>? id,
      Value<String>? tab,
      Value<ListQuery>? albumsList,
      Value<ListQuery>? artistsList,
      Value<ListQuery>? playlistsList,
      Value<ListQuery>? songsList}) {
    return LastLibraryStateCompanion(
      id: id ?? this.id,
      tab: tab ?? this.tab,
      albumsList: albumsList ?? this.albumsList,
      artistsList: artistsList ?? this.artistsList,
      playlistsList: playlistsList ?? this.playlistsList,
      songsList: songsList ?? this.songsList,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tab.present) {
      map['tab'] = Variable<String>(tab.value);
    }
    if (albumsList.present) {
      map['albums_list'] = Variable<String>(
          LastLibraryState.$converteralbumsList.toSql(albumsList.value));
    }
    if (artistsList.present) {
      map['artists_list'] = Variable<String>(
          LastLibraryState.$converterartistsList.toSql(artistsList.value));
    }
    if (playlistsList.present) {
      map['playlists_list'] = Variable<String>(
          LastLibraryState.$converterplaylistsList.toSql(playlistsList.value));
    }
    if (songsList.present) {
      map['songs_list'] = Variable<String>(
          LastLibraryState.$convertersongsList.toSql(songsList.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastLibraryStateCompanion(')
          ..write('id: $id, ')
          ..write('tab: $tab, ')
          ..write('albumsList: $albumsList, ')
          ..write('artistsList: $artistsList, ')
          ..write('playlistsList: $playlistsList, ')
          ..write('songsList: $songsList')
          ..write(')'))
        .toString();
  }
}

class AppSettingsTable extends Table
    with TableInfo<AppSettingsTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _maxBitrateWifiMeta =
      const VerificationMeta('maxBitrateWifi');
  late final GeneratedColumn<int> maxBitrateWifi = GeneratedColumn<int>(
      'max_bitrate_wifi', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _maxBitrateMobileMeta =
      const VerificationMeta('maxBitrateMobile');
  late final GeneratedColumn<int> maxBitrateMobile = GeneratedColumn<int>(
      'max_bitrate_mobile', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _streamFormatMeta =
      const VerificationMeta('streamFormat');
  late final GeneratedColumn<String> streamFormat = GeneratedColumn<String>(
      'stream_format', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [id, maxBitrateWifi, maxBitrateMobile, streamFormat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettings> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('max_bitrate_wifi')) {
      context.handle(
          _maxBitrateWifiMeta,
          maxBitrateWifi.isAcceptableOrUnknown(
              data['max_bitrate_wifi']!, _maxBitrateWifiMeta));
    } else if (isInserting) {
      context.missing(_maxBitrateWifiMeta);
    }
    if (data.containsKey('max_bitrate_mobile')) {
      context.handle(
          _maxBitrateMobileMeta,
          maxBitrateMobile.isAcceptableOrUnknown(
              data['max_bitrate_mobile']!, _maxBitrateMobileMeta));
    } else if (isInserting) {
      context.missing(_maxBitrateMobileMeta);
    }
    if (data.containsKey('stream_format')) {
      context.handle(
          _streamFormatMeta,
          streamFormat.isAcceptableOrUnknown(
              data['stream_format']!, _streamFormatMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      maxBitrateWifi: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_bitrate_wifi'])!,
      maxBitrateMobile: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_bitrate_mobile'])!,
      streamFormat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stream_format']),
    );
  }

  @override
  AppSettingsTable createAlias(String alias) {
    return AppSettingsTable(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AppSettingsCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<int> maxBitrateWifi;
  final Value<int> maxBitrateMobile;
  final Value<String?> streamFormat;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.maxBitrateWifi = const Value.absent(),
    this.maxBitrateMobile = const Value.absent(),
    this.streamFormat = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int maxBitrateWifi,
    required int maxBitrateMobile,
    this.streamFormat = const Value.absent(),
  })  : maxBitrateWifi = Value(maxBitrateWifi),
        maxBitrateMobile = Value(maxBitrateMobile);
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<int>? maxBitrateWifi,
    Expression<int>? maxBitrateMobile,
    Expression<String>? streamFormat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maxBitrateWifi != null) 'max_bitrate_wifi': maxBitrateWifi,
      if (maxBitrateMobile != null) 'max_bitrate_mobile': maxBitrateMobile,
      if (streamFormat != null) 'stream_format': streamFormat,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? maxBitrateWifi,
      Value<int>? maxBitrateMobile,
      Value<String?>? streamFormat}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      maxBitrateWifi: maxBitrateWifi ?? this.maxBitrateWifi,
      maxBitrateMobile: maxBitrateMobile ?? this.maxBitrateMobile,
      streamFormat: streamFormat ?? this.streamFormat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (maxBitrateWifi.present) {
      map['max_bitrate_wifi'] = Variable<int>(maxBitrateWifi.value);
    }
    if (maxBitrateMobile.present) {
      map['max_bitrate_mobile'] = Variable<int>(maxBitrateMobile.value);
    }
    if (streamFormat.present) {
      map['stream_format'] = Variable<String>(streamFormat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('maxBitrateWifi: $maxBitrateWifi, ')
          ..write('maxBitrateMobile: $maxBitrateMobile, ')
          ..write('streamFormat: $streamFormat')
          ..write(')'))
        .toString();
  }
}

class Sources extends Table with TableInfo<Sources, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sources(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL COLLATE NOCASE');
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  late final GeneratedColumnWithTypeConverter<Uri, String> address =
      GeneratedColumn<String>('address', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Uri>(Sources.$converteraddress);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'UNIQUE');
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, address, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(Insertable<Source> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_addressMeta, const VerificationResult.success());
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: Sources.$converteraddress.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  Sources createAlias(String alias) {
    return Sources(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converteraddress = const UriConverter();
  @override
  bool get dontWriteConstraints => true;
}

class Source extends DataClass implements Insertable<Source> {
  final int id;
  final String name;
  final Uri address;
  final bool? isActive;
  final DateTime createdAt;
  const Source(
      {required this.id,
      required this.name,
      required this.address,
      this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['address'] =
          Variable<String>(Sources.$converteraddress.toSql(address));
    }
    if (!nullToAbsent || isActive != null) {
      map['is_active'] = Variable<bool>(isActive);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      isActive: isActive == null && nullToAbsent
          ? const Value.absent()
          : Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Source.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<Uri>(json['address']),
      isActive: serializer.fromJson<bool?>(json['is_active']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<Uri>(address),
      'is_active': serializer.toJson<bool?>(isActive),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  Source copyWith(
          {int? id,
          String? name,
          Uri? address,
          Value<bool?> isActive = const Value.absent(),
          DateTime? createdAt}) =>
      Source(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        isActive: isActive.present ? isActive.value : this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, address, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<int> id;
  final Value<String> name;
  final Value<Uri> address;
  final Value<bool?> isActive;
  final Value<DateTime> createdAt;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SourcesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Uri address,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        address = Value(address);
  static Insertable<Source> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SourcesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<Uri>? address,
      Value<bool?>? isActive,
      Value<DateTime>? createdAt}) {
    return SourcesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] =
          Variable<String>(Sources.$converteraddress.toSql(address.value));
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SubsonicSources extends Table
    with TableInfo<SubsonicSources, SubsonicSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SubsonicSources(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _featuresMeta =
      const VerificationMeta('features');
  late final GeneratedColumnWithTypeConverter<IList<SubsonicFeature>, String>
      features = GeneratedColumn<String>('features', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<IList<SubsonicFeature>>(
              SubsonicSources.$converterfeatures);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _useTokenAuthMeta =
      const VerificationMeta('useTokenAuth');
  late final GeneratedColumn<bool> useTokenAuth = GeneratedColumn<bool>(
      'use_token_auth', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 1',
      defaultValue: const CustomExpression('1'));
  @override
  List<GeneratedColumn> get $columns =>
      [sourceId, features, username, password, useTokenAuth];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subsonic_sources';
  @override
  VerificationContext validateIntegrity(Insertable<SubsonicSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    context.handle(_featuresMeta, const VerificationResult.success());
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('use_token_auth')) {
      context.handle(
          _useTokenAuthMeta,
          useTokenAuth.isAcceptableOrUnknown(
              data['use_token_auth']!, _useTokenAuthMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  SubsonicSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubsonicSource(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      features: SubsonicSources.$converterfeatures.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}features'])!),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      useTokenAuth: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}use_token_auth'])!,
    );
  }

  @override
  SubsonicSources createAlias(String alias) {
    return SubsonicSources(attachedDatabase, alias);
  }

  static TypeConverter<IList<SubsonicFeature>, String> $converterfeatures =
      const SubsonicFeatureListConverter();
  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'];
  @override
  bool get dontWriteConstraints => true;
}

class SubsonicSource extends DataClass implements Insertable<SubsonicSource> {
  final int sourceId;
  final IList<SubsonicFeature> features;
  final String username;
  final String password;
  final bool useTokenAuth;
  const SubsonicSource(
      {required this.sourceId,
      required this.features,
      required this.username,
      required this.password,
      required this.useTokenAuth});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<int>(sourceId);
    {
      map['features'] =
          Variable<String>(SubsonicSources.$converterfeatures.toSql(features));
    }
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['use_token_auth'] = Variable<bool>(useTokenAuth);
    return map;
  }

  SubsonicSourcesCompanion toCompanion(bool nullToAbsent) {
    return SubsonicSourcesCompanion(
      sourceId: Value(sourceId),
      features: Value(features),
      username: Value(username),
      password: Value(password),
      useTokenAuth: Value(useTokenAuth),
    );
  }

  factory SubsonicSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubsonicSource(
      sourceId: serializer.fromJson<int>(json['source_id']),
      features: serializer.fromJson<IList<SubsonicFeature>>(json['features']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      useTokenAuth: serializer.fromJson<bool>(json['use_token_auth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<int>(sourceId),
      'features': serializer.toJson<IList<SubsonicFeature>>(features),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'use_token_auth': serializer.toJson<bool>(useTokenAuth),
    };
  }

  SubsonicSource copyWith(
          {int? sourceId,
          IList<SubsonicFeature>? features,
          String? username,
          String? password,
          bool? useTokenAuth}) =>
      SubsonicSource(
        sourceId: sourceId ?? this.sourceId,
        features: features ?? this.features,
        username: username ?? this.username,
        password: password ?? this.password,
        useTokenAuth: useTokenAuth ?? this.useTokenAuth,
      );
  @override
  String toString() {
    return (StringBuffer('SubsonicSource(')
          ..write('sourceId: $sourceId, ')
          ..write('features: $features, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('useTokenAuth: $useTokenAuth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, features, username, password, useTokenAuth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubsonicSource &&
          other.sourceId == this.sourceId &&
          other.features == this.features &&
          other.username == this.username &&
          other.password == this.password &&
          other.useTokenAuth == this.useTokenAuth);
}

class SubsonicSourcesCompanion extends UpdateCompanion<SubsonicSource> {
  final Value<int> sourceId;
  final Value<IList<SubsonicFeature>> features;
  final Value<String> username;
  final Value<String> password;
  final Value<bool> useTokenAuth;
  const SubsonicSourcesCompanion({
    this.sourceId = const Value.absent(),
    this.features = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.useTokenAuth = const Value.absent(),
  });
  SubsonicSourcesCompanion.insert({
    this.sourceId = const Value.absent(),
    required IList<SubsonicFeature> features,
    required String username,
    required String password,
    this.useTokenAuth = const Value.absent(),
  })  : features = Value(features),
        username = Value(username),
        password = Value(password);
  static Insertable<SubsonicSource> custom({
    Expression<int>? sourceId,
    Expression<String>? features,
    Expression<String>? username,
    Expression<String>? password,
    Expression<bool>? useTokenAuth,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (features != null) 'features': features,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (useTokenAuth != null) 'use_token_auth': useTokenAuth,
    });
  }

  SubsonicSourcesCompanion copyWith(
      {Value<int>? sourceId,
      Value<IList<SubsonicFeature>>? features,
      Value<String>? username,
      Value<String>? password,
      Value<bool>? useTokenAuth}) {
    return SubsonicSourcesCompanion(
      sourceId: sourceId ?? this.sourceId,
      features: features ?? this.features,
      username: username ?? this.username,
      password: password ?? this.password,
      useTokenAuth: useTokenAuth ?? this.useTokenAuth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (features.present) {
      map['features'] = Variable<String>(
          SubsonicSources.$converterfeatures.toSql(features.value));
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (useTokenAuth.present) {
      map['use_token_auth'] = Variable<bool>(useTokenAuth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubsonicSourcesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('features: $features, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('useTokenAuth: $useTokenAuth')
          ..write(')'))
        .toString();
  }
}

class Artists extends Table with TableInfo<Artists, Artist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Artists(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL COLLATE NOCASE');
  static const VerificationMeta _albumCountMeta =
      const VerificationMeta('albumCount');
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
      'album_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _starredMeta =
      const VerificationMeta('starred');
  late final GeneratedColumn<DateTime> starred = GeneratedColumn<DateTime>(
      'starred', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _updatedMeta =
      const VerificationMeta('updated');
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
      'updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns =>
      [sourceId, id, name, albumCount, starred, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists';
  @override
  VerificationContext validateIntegrity(Insertable<Artist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('album_count')) {
      context.handle(
          _albumCountMeta,
          albumCount.isAcceptableOrUnknown(
              data['album_count']!, _albumCountMeta));
    } else if (isInserting) {
      context.missing(_albumCountMeta);
    }
    if (data.containsKey('starred')) {
      context.handle(_starredMeta,
          starred.isAcceptableOrUnknown(data['starred']!, _starredMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  Artist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Artist(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      albumCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}album_count'])!,
      starred: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}starred']),
    );
  }

  @override
  Artists createAlias(String alias) {
    return Artists(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'PRIMARY KEY(source_id, id)',
        'FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class ArtistsCompanion extends UpdateCompanion<Artist> {
  final Value<int> sourceId;
  final Value<String> id;
  final Value<String> name;
  final Value<int> albumCount;
  final Value<DateTime?> starred;
  final Value<DateTime> updated;
  final Value<int> rowid;
  const ArtistsCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsCompanion.insert({
    required int sourceId,
    required String id,
    required String name,
    required int albumCount,
    this.starred = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        id = Value(id),
        name = Value(name),
        albumCount = Value(albumCount);
  static Insertable<Artist> custom({
    Expression<int>? sourceId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? albumCount,
    Expression<DateTime>? starred,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (albumCount != null) 'album_count': albumCount,
      if (starred != null) 'starred': starred,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsCompanion copyWith(
      {Value<int>? sourceId,
      Value<String>? id,
      Value<String>? name,
      Value<int>? albumCount,
      Value<DateTime?>? starred,
      Value<DateTime>? updated,
      Value<int>? rowid}) {
    return ArtistsCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      name: name ?? this.name,
      albumCount: albumCount ?? this.albumCount,
      starred: starred ?? this.starred,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<DateTime>(starred.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ArtistsFts extends Table
    with
        TableInfo<ArtistsFts, ArtistsFt>,
        VirtualTableInfo<ArtistsFts, ArtistsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ArtistsFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [sourceId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists_fts';
  @override
  VerificationContext validateIntegrity(Insertable<ArtistsFt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ArtistsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistsFt(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  ArtistsFts createAlias(String alias) {
    return ArtistsFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(source_id, name, content=artists, content_rowid=rowid)';
}

class ArtistsFt extends DataClass implements Insertable<ArtistsFt> {
  final String sourceId;
  final String name;
  const ArtistsFt({required this.sourceId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['name'] = Variable<String>(name);
    return map;
  }

  ArtistsFtsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsFtsCompanion(
      sourceId: Value(sourceId),
      name: Value(name),
    );
  }

  factory ArtistsFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistsFt(
      sourceId: serializer.fromJson<String>(json['source_id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<String>(sourceId),
      'name': serializer.toJson<String>(name),
    };
  }

  ArtistsFt copyWith({String? sourceId, String? name}) => ArtistsFt(
        sourceId: sourceId ?? this.sourceId,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('ArtistsFt(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistsFt &&
          other.sourceId == this.sourceId &&
          other.name == this.name);
}

class ArtistsFtsCompanion extends UpdateCompanion<ArtistsFt> {
  final Value<String> sourceId;
  final Value<String> name;
  final Value<int> rowid;
  const ArtistsFtsCompanion({
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsFtsCompanion.insert({
    required String sourceId,
    required String name,
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        name = Value(name);
  static Insertable<ArtistsFt> custom({
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsFtsCompanion copyWith(
      {Value<String>? sourceId, Value<String>? name, Value<int>? rowid}) {
    return ArtistsFtsCompanion(
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsFtsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Albums extends Table with TableInfo<Albums, Album> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Albums(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _artistIdMeta =
      const VerificationMeta('artistId');
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
      'artist_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL COLLATE NOCASE');
  static const VerificationMeta _albumArtistMeta =
      const VerificationMeta('albumArtist');
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
      'album_artist', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'COLLATE NOCASE');
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _coverArtMeta =
      const VerificationMeta('coverArt');
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
      'cover_art', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
      'genre', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _starredMeta =
      const VerificationMeta('starred');
  late final GeneratedColumn<DateTime> starred = GeneratedColumn<DateTime>(
      'starred', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _songCountMeta =
      const VerificationMeta('songCount');
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
      'song_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _frequentRankMeta =
      const VerificationMeta('frequentRank');
  late final GeneratedColumn<int> frequentRank = GeneratedColumn<int>(
      'frequent_rank', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _recentRankMeta =
      const VerificationMeta('recentRank');
  late final GeneratedColumn<int> recentRank = GeneratedColumn<int>(
      'recent_rank', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _updatedMeta =
      const VerificationMeta('updated');
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
      'updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns => [
        sourceId,
        id,
        artistId,
        name,
        albumArtist,
        created,
        coverArt,
        genre,
        year,
        starred,
        songCount,
        frequentRank,
        recentRank,
        isDeleted,
        updated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(Insertable<Album> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(_artistIdMeta,
          artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('album_artist')) {
      context.handle(
          _albumArtistMeta,
          albumArtist.isAcceptableOrUnknown(
              data['album_artist']!, _albumArtistMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('cover_art')) {
      context.handle(_coverArtMeta,
          coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta));
    }
    if (data.containsKey('genre')) {
      context.handle(
          _genreMeta, genre.isAcceptableOrUnknown(data['genre']!, _genreMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('starred')) {
      context.handle(_starredMeta,
          starred.isAcceptableOrUnknown(data['starred']!, _starredMeta));
    }
    if (data.containsKey('song_count')) {
      context.handle(_songCountMeta,
          songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta));
    } else if (isInserting) {
      context.missing(_songCountMeta);
    }
    if (data.containsKey('frequent_rank')) {
      context.handle(
          _frequentRankMeta,
          frequentRank.isAcceptableOrUnknown(
              data['frequent_rank']!, _frequentRankMeta));
    }
    if (data.containsKey('recent_rank')) {
      context.handle(
          _recentRankMeta,
          recentRank.isAcceptableOrUnknown(
              data['recent_rank']!, _recentRankMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  Album map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Album(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      artistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_id']),
      albumArtist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_artist']),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
      coverArt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_art']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      starred: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}starred']),
      genre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genre']),
      songCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_count'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      frequentRank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequent_rank']),
      recentRank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recent_rank']),
    );
  }

  @override
  Albums createAlias(String alias) {
    return Albums(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'PRIMARY KEY(source_id, id)',
        'FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<int> sourceId;
  final Value<String> id;
  final Value<String?> artistId;
  final Value<String> name;
  final Value<String?> albumArtist;
  final Value<DateTime> created;
  final Value<String?> coverArt;
  final Value<String?> genre;
  final Value<int?> year;
  final Value<DateTime?> starred;
  final Value<int> songCount;
  final Value<int?> frequentRank;
  final Value<int?> recentRank;
  final Value<bool> isDeleted;
  final Value<DateTime> updated;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.artistId = const Value.absent(),
    this.name = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.created = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.starred = const Value.absent(),
    this.songCount = const Value.absent(),
    this.frequentRank = const Value.absent(),
    this.recentRank = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required int sourceId,
    required String id,
    this.artistId = const Value.absent(),
    required String name,
    this.albumArtist = const Value.absent(),
    required DateTime created,
    this.coverArt = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.starred = const Value.absent(),
    required int songCount,
    this.frequentRank = const Value.absent(),
    this.recentRank = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        id = Value(id),
        name = Value(name),
        created = Value(created),
        songCount = Value(songCount);
  static Insertable<Album> custom({
    Expression<int>? sourceId,
    Expression<String>? id,
    Expression<String>? artistId,
    Expression<String>? name,
    Expression<String>? albumArtist,
    Expression<DateTime>? created,
    Expression<String>? coverArt,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<DateTime>? starred,
    Expression<int>? songCount,
    Expression<int>? frequentRank,
    Expression<int>? recentRank,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (artistId != null) 'artist_id': artistId,
      if (name != null) 'name': name,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (created != null) 'created': created,
      if (coverArt != null) 'cover_art': coverArt,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (starred != null) 'starred': starred,
      if (songCount != null) 'song_count': songCount,
      if (frequentRank != null) 'frequent_rank': frequentRank,
      if (recentRank != null) 'recent_rank': recentRank,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith(
      {Value<int>? sourceId,
      Value<String>? id,
      Value<String?>? artistId,
      Value<String>? name,
      Value<String?>? albumArtist,
      Value<DateTime>? created,
      Value<String?>? coverArt,
      Value<String?>? genre,
      Value<int?>? year,
      Value<DateTime?>? starred,
      Value<int>? songCount,
      Value<int?>? frequentRank,
      Value<int?>? recentRank,
      Value<bool>? isDeleted,
      Value<DateTime>? updated,
      Value<int>? rowid}) {
    return AlbumsCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      name: name ?? this.name,
      albumArtist: albumArtist ?? this.albumArtist,
      created: created ?? this.created,
      coverArt: coverArt ?? this.coverArt,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      starred: starred ?? this.starred,
      songCount: songCount ?? this.songCount,
      frequentRank: frequentRank ?? this.frequentRank,
      recentRank: recentRank ?? this.recentRank,
      isDeleted: isDeleted ?? this.isDeleted,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (starred.present) {
      map['starred'] = Variable<DateTime>(starred.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (frequentRank.present) {
      map['frequent_rank'] = Variable<int>(frequentRank.value);
    }
    if (recentRank.present) {
      map['recent_rank'] = Variable<int>(recentRank.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('artistId: $artistId, ')
          ..write('name: $name, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('created: $created, ')
          ..write('coverArt: $coverArt, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('starred: $starred, ')
          ..write('songCount: $songCount, ')
          ..write('frequentRank: $frequentRank, ')
          ..write('recentRank: $recentRank, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AlbumsFts extends Table
    with TableInfo<AlbumsFts, AlbumsFt>, VirtualTableInfo<AlbumsFts, AlbumsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AlbumsFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [sourceId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums_fts';
  @override
  VerificationContext validateIntegrity(Insertable<AlbumsFt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  AlbumsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumsFt(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  AlbumsFts createAlias(String alias) {
    return AlbumsFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(source_id, name, content=albums, content_rowid=rowid)';
}

class AlbumsFt extends DataClass implements Insertable<AlbumsFt> {
  final String sourceId;
  final String name;
  const AlbumsFt({required this.sourceId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['name'] = Variable<String>(name);
    return map;
  }

  AlbumsFtsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsFtsCompanion(
      sourceId: Value(sourceId),
      name: Value(name),
    );
  }

  factory AlbumsFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumsFt(
      sourceId: serializer.fromJson<String>(json['source_id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<String>(sourceId),
      'name': serializer.toJson<String>(name),
    };
  }

  AlbumsFt copyWith({String? sourceId, String? name}) => AlbumsFt(
        sourceId: sourceId ?? this.sourceId,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('AlbumsFt(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumsFt &&
          other.sourceId == this.sourceId &&
          other.name == this.name);
}

class AlbumsFtsCompanion extends UpdateCompanion<AlbumsFt> {
  final Value<String> sourceId;
  final Value<String> name;
  final Value<int> rowid;
  const AlbumsFtsCompanion({
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsFtsCompanion.insert({
    required String sourceId,
    required String name,
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        name = Value(name);
  static Insertable<AlbumsFt> custom({
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsFtsCompanion copyWith(
      {Value<String>? sourceId, Value<String>? name, Value<int>? rowid}) {
    return AlbumsFtsCompanion(
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsFtsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Playlists extends Table with TableInfo<Playlists, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Playlists(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL COLLATE NOCASE');
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'COLLATE NOCASE');
  static const VerificationMeta _coverArtMeta =
      const VerificationMeta('coverArt');
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
      'cover_art', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _songCountMeta =
      const VerificationMeta('songCount');
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
      'song_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
      'created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _updatedMeta =
      const VerificationMeta('updated');
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
      'updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns =>
      [sourceId, id, name, comment, coverArt, songCount, created, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('cover_art')) {
      context.handle(_coverArtMeta,
          coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta));
    }
    if (data.containsKey('song_count')) {
      context.handle(_songCountMeta,
          songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta));
    } else if (isInserting) {
      context.missing(_songCountMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      coverArt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_art']),
      songCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_count'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created'])!,
    );
  }

  @override
  Playlists createAlias(String alias) {
    return Playlists(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'PRIMARY KEY(source_id, id)',
        'FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> sourceId;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> comment;
  final Value<String?> coverArt;
  final Value<int> songCount;
  final Value<DateTime> created;
  final Value<DateTime> updated;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.comment = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required int sourceId,
    required String id,
    required String name,
    this.comment = const Value.absent(),
    this.coverArt = const Value.absent(),
    required int songCount,
    required DateTime created,
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        id = Value(id),
        name = Value(name),
        songCount = Value(songCount),
        created = Value(created);
  static Insertable<Playlist> custom({
    Expression<int>? sourceId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? comment,
    Expression<String>? coverArt,
    Expression<int>? songCount,
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (comment != null) 'comment': comment,
      if (coverArt != null) 'cover_art': coverArt,
      if (songCount != null) 'song_count': songCount,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<int>? sourceId,
      Value<String>? id,
      Value<String>? name,
      Value<String?>? comment,
      Value<String?>? coverArt,
      Value<int>? songCount,
      Value<DateTime>? created,
      Value<DateTime>? updated,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      name: name ?? this.name,
      comment: comment ?? this.comment,
      coverArt: coverArt ?? this.coverArt,
      songCount: songCount ?? this.songCount,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('comment: $comment, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlaylistSongs extends Table with TableInfo<PlaylistSongs, PlaylistSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlaylistSongs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
      'song_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _updatedMeta =
      const VerificationMeta('updated');
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
      'updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns =>
      [sourceId, playlistId, songId, position, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistSong> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, playlistId, position};
  @override
  PlaylistSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSong(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}song_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      updated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated'])!,
    );
  }

  @override
  PlaylistSongs createAlias(String alias) {
    return PlaylistSongs(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'PRIMARY KEY(source_id, playlist_id, position)',
        'FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class PlaylistSong extends DataClass implements Insertable<PlaylistSong> {
  final int sourceId;
  final String playlistId;
  final String songId;
  final int position;
  final DateTime updated;
  const PlaylistSong(
      {required this.sourceId,
      required this.playlistId,
      required this.songId,
      required this.position,
      required this.updated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<int>(sourceId);
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    map['updated'] = Variable<DateTime>(updated);
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      sourceId: Value(sourceId),
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
      updated: Value(updated),
    );
  }

  factory PlaylistSong.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSong(
      sourceId: serializer.fromJson<int>(json['source_id']),
      playlistId: serializer.fromJson<String>(json['playlist_id']),
      songId: serializer.fromJson<String>(json['song_id']),
      position: serializer.fromJson<int>(json['position']),
      updated: serializer.fromJson<DateTime>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<int>(sourceId),
      'playlist_id': serializer.toJson<String>(playlistId),
      'song_id': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
      'updated': serializer.toJson<DateTime>(updated),
    };
  }

  PlaylistSong copyWith(
          {int? sourceId,
          String? playlistId,
          String? songId,
          int? position,
          DateTime? updated}) =>
      PlaylistSong(
        sourceId: sourceId ?? this.sourceId,
        playlistId: playlistId ?? this.playlistId,
        songId: songId ?? this.songId,
        position: position ?? this.position,
        updated: updated ?? this.updated,
      );
  @override
  String toString() {
    return (StringBuffer('PlaylistSong(')
          ..write('sourceId: $sourceId, ')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, playlistId, songId, position, updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSong &&
          other.sourceId == this.sourceId &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position &&
          other.updated == this.updated);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSong> {
  final Value<int> sourceId;
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<DateTime> updated;
  final Value<int> rowid;
  const PlaylistSongsCompanion({
    this.sourceId = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    required int sourceId,
    required String playlistId,
    required String songId,
    required int position,
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        playlistId = Value(playlistId),
        songId = Value(songId),
        position = Value(position);
  static Insertable<PlaylistSong> custom({
    Expression<int>? sourceId,
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongsCompanion copyWith(
      {Value<int>? sourceId,
      Value<String>? playlistId,
      Value<String>? songId,
      Value<int>? position,
      Value<DateTime>? updated,
      Value<int>? rowid}) {
    return PlaylistSongsCompanion(
      sourceId: sourceId ?? this.sourceId,
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlaylistsFts extends Table
    with
        TableInfo<PlaylistsFts, PlaylistsFt>,
        VirtualTableInfo<PlaylistsFts, PlaylistsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlaylistsFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [sourceId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists_fts';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistsFt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PlaylistsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsFt(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  PlaylistsFts createAlias(String alias) {
    return PlaylistsFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(source_id, name, content=playlists, content_rowid=rowid)';
}

class PlaylistsFt extends DataClass implements Insertable<PlaylistsFt> {
  final String sourceId;
  final String name;
  const PlaylistsFt({required this.sourceId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['name'] = Variable<String>(name);
    return map;
  }

  PlaylistsFtsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsFtsCompanion(
      sourceId: Value(sourceId),
      name: Value(name),
    );
  }

  factory PlaylistsFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsFt(
      sourceId: serializer.fromJson<String>(json['source_id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<String>(sourceId),
      'name': serializer.toJson<String>(name),
    };
  }

  PlaylistsFt copyWith({String? sourceId, String? name}) => PlaylistsFt(
        sourceId: sourceId ?? this.sourceId,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('PlaylistsFt(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsFt &&
          other.sourceId == this.sourceId &&
          other.name == this.name);
}

class PlaylistsFtsCompanion extends UpdateCompanion<PlaylistsFt> {
  final Value<String> sourceId;
  final Value<String> name;
  final Value<int> rowid;
  const PlaylistsFtsCompanion({
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsFtsCompanion.insert({
    required String sourceId,
    required String name,
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        name = Value(name);
  static Insertable<PlaylistsFt> custom({
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsFtsCompanion copyWith(
      {Value<String>? sourceId, Value<String>? name, Value<int>? rowid}) {
    return PlaylistsFtsCompanion(
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsFtsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Songs extends Table with TableInfo<Songs, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Songs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _artistIdMeta =
      const VerificationMeta('artistId');
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
      'artist_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL COLLATE NOCASE');
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
      'album', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'COLLATE NOCASE');
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
      'artist', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'COLLATE NOCASE');
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  late final GeneratedColumnWithTypeConverter<Duration?, int> duration =
      GeneratedColumn<int>('duration', aliasedName, true,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              $customConstraints: '')
          .withConverter<Duration?>(Songs.$converterdurationn);
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  late final GeneratedColumn<int> track = GeneratedColumn<int>(
      'track', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _discMeta = const VerificationMeta('disc');
  late final GeneratedColumn<int> disc = GeneratedColumn<int>(
      'disc', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _starredMeta =
      const VerificationMeta('starred');
  late final GeneratedColumn<DateTime> starred = GeneratedColumn<DateTime>(
      'starred', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
      'genre', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _downloadTaskIdMeta =
      const VerificationMeta('downloadTaskId');
  late final GeneratedColumn<String> downloadTaskId = GeneratedColumn<String>(
      'download_task_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'UNIQUE');
  static const VerificationMeta _downloadFilePathMeta =
      const VerificationMeta('downloadFilePath');
  late final GeneratedColumn<String> downloadFilePath = GeneratedColumn<String>(
      'download_file_path', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'UNIQUE');
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _userRatingMeta =
      const VerificationMeta('userRating');
  late final GeneratedColumnWithTypeConverter<UserRating, String> userRating =
      GeneratedColumn<String>('user_rating', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: 'NOT NULL DEFAULT \'unrated\'',
              defaultValue: const CustomExpression('\'unrated\''))
          .withConverter<UserRating>(Songs.$converteruserRating);
  static const VerificationMeta _thumbsUpCountMeta =
      const VerificationMeta('thumbsUpCount');
  late final GeneratedColumn<int> thumbsUpCount = GeneratedColumn<int>(
      'thumbs_up_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _thumbsDownCountMeta =
      const VerificationMeta('thumbsDownCount');
  late final GeneratedColumn<int> thumbsDownCount = GeneratedColumn<int>(
      'thumbs_down_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _updatedMeta =
      const VerificationMeta('updated');
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
      'updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns => [
        sourceId,
        id,
        albumId,
        artistId,
        title,
        album,
        artist,
        duration,
        track,
        disc,
        starred,
        genre,
        downloadTaskId,
        downloadFilePath,
        isDeleted,
        userRating,
        thumbsUpCount,
        thumbsDownCount,
        updated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(Insertable<Song> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    }
    if (data.containsKey('artist_id')) {
      context.handle(_artistIdMeta,
          artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    context.handle(_durationMeta, const VerificationResult.success());
    if (data.containsKey('track')) {
      context.handle(
          _trackMeta, track.isAcceptableOrUnknown(data['track']!, _trackMeta));
    }
    if (data.containsKey('disc')) {
      context.handle(
          _discMeta, disc.isAcceptableOrUnknown(data['disc']!, _discMeta));
    }
    if (data.containsKey('starred')) {
      context.handle(_starredMeta,
          starred.isAcceptableOrUnknown(data['starred']!, _starredMeta));
    }
    if (data.containsKey('genre')) {
      context.handle(
          _genreMeta, genre.isAcceptableOrUnknown(data['genre']!, _genreMeta));
    }
    if (data.containsKey('download_task_id')) {
      context.handle(
          _downloadTaskIdMeta,
          downloadTaskId.isAcceptableOrUnknown(
              data['download_task_id']!, _downloadTaskIdMeta));
    }
    if (data.containsKey('download_file_path')) {
      context.handle(
          _downloadFilePathMeta,
          downloadFilePath.isAcceptableOrUnknown(
              data['download_file_path']!, _downloadFilePathMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    context.handle(_userRatingMeta, const VerificationResult.success());
    if (data.containsKey('thumbs_up_count')) {
      context.handle(
          _thumbsUpCountMeta,
          thumbsUpCount.isAcceptableOrUnknown(
              data['thumbs_up_count']!, _thumbsUpCountMeta));
    }
    if (data.containsKey('thumbs_down_count')) {
      context.handle(
          _thumbsDownCountMeta,
          thumbsDownCount.isAcceptableOrUnknown(
              data['thumbs_down_count']!, _thumbsDownCountMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id']),
      artistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist']),
      album: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album']),
      duration: Songs.$converterdurationn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])),
      track: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track']),
      disc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}disc']),
      starred: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}starred']),
      genre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genre']),
      downloadTaskId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}download_task_id']),
      downloadFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}download_file_path']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      userRating: Songs.$converteruserRating.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_rating'])!),
      thumbsUpCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}thumbs_up_count'])!,
      thumbsDownCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}thumbs_down_count'])!,
    );
  }

  @override
  Songs createAlias(String alias) {
    return Songs(attachedDatabase, alias);
  }

  static TypeConverter<Duration, int> $converterduration =
      const DurationSecondsConverter();
  static TypeConverter<Duration?, int?> $converterdurationn =
      NullAwareTypeConverter.wrap($converterduration);
  static TypeConverter<UserRating, String> $converteruserRating =
      const UserRatingConverter();
  @override
  List<String> get customConstraints => const [
        'PRIMARY KEY(source_id, id)',
        'FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> sourceId;
  final Value<String> id;
  final Value<String?> albumId;
  final Value<String?> artistId;
  final Value<String> title;
  final Value<String?> album;
  final Value<String?> artist;
  final Value<Duration?> duration;
  final Value<int?> track;
  final Value<int?> disc;
  final Value<DateTime?> starred;
  final Value<String?> genre;
  final Value<String?> downloadTaskId;
  final Value<String?> downloadFilePath;
  final Value<bool> isDeleted;
  final Value<UserRating> userRating;
  final Value<int> thumbsUpCount;
  final Value<int> thumbsDownCount;
  final Value<DateTime> updated;
  final Value<int> rowid;
  const SongsCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.track = const Value.absent(),
    this.disc = const Value.absent(),
    this.starred = const Value.absent(),
    this.genre = const Value.absent(),
    this.downloadTaskId = const Value.absent(),
    this.downloadFilePath = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.userRating = const Value.absent(),
    this.thumbsUpCount = const Value.absent(),
    this.thumbsDownCount = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required int sourceId,
    required String id,
    this.albumId = const Value.absent(),
    this.artistId = const Value.absent(),
    required String title,
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.track = const Value.absent(),
    this.disc = const Value.absent(),
    this.starred = const Value.absent(),
    this.genre = const Value.absent(),
    this.downloadTaskId = const Value.absent(),
    this.downloadFilePath = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.userRating = const Value.absent(),
    this.thumbsUpCount = const Value.absent(),
    this.thumbsDownCount = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        id = Value(id),
        title = Value(title);
  static Insertable<Song> custom({
    Expression<int>? sourceId,
    Expression<String>? id,
    Expression<String>? albumId,
    Expression<String>? artistId,
    Expression<String>? title,
    Expression<String>? album,
    Expression<String>? artist,
    Expression<int>? duration,
    Expression<int>? track,
    Expression<int>? disc,
    Expression<DateTime>? starred,
    Expression<String>? genre,
    Expression<String>? downloadTaskId,
    Expression<String>? downloadFilePath,
    Expression<bool>? isDeleted,
    Expression<String>? userRating,
    Expression<int>? thumbsUpCount,
    Expression<int>? thumbsDownCount,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (artistId != null) 'artist_id': artistId,
      if (title != null) 'title': title,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
      if (duration != null) 'duration': duration,
      if (track != null) 'track': track,
      if (disc != null) 'disc': disc,
      if (starred != null) 'starred': starred,
      if (genre != null) 'genre': genre,
      if (downloadTaskId != null) 'download_task_id': downloadTaskId,
      if (downloadFilePath != null) 'download_file_path': downloadFilePath,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (userRating != null) 'user_rating': userRating,
      if (thumbsUpCount != null) 'thumbs_up_count': thumbsUpCount,
      if (thumbsDownCount != null) 'thumbs_down_count': thumbsDownCount,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith(
      {Value<int>? sourceId,
      Value<String>? id,
      Value<String?>? albumId,
      Value<String?>? artistId,
      Value<String>? title,
      Value<String?>? album,
      Value<String?>? artist,
      Value<Duration?>? duration,
      Value<int?>? track,
      Value<int?>? disc,
      Value<DateTime?>? starred,
      Value<String?>? genre,
      Value<String?>? downloadTaskId,
      Value<String?>? downloadFilePath,
      Value<bool>? isDeleted,
      Value<UserRating>? userRating,
      Value<int>? thumbsUpCount,
      Value<int>? thumbsDownCount,
      Value<DateTime>? updated,
      Value<int>? rowid}) {
    return SongsCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      title: title ?? this.title,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      track: track ?? this.track,
      disc: disc ?? this.disc,
      starred: starred ?? this.starred,
      genre: genre ?? this.genre,
      downloadTaskId: downloadTaskId ?? this.downloadTaskId,
      downloadFilePath: downloadFilePath ?? this.downloadFilePath,
      isDeleted: isDeleted ?? this.isDeleted,
      userRating: userRating ?? this.userRating,
      thumbsUpCount: thumbsUpCount ?? this.thumbsUpCount,
      thumbsDownCount: thumbsDownCount ?? this.thumbsDownCount,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (duration.present) {
      map['duration'] =
          Variable<int>(Songs.$converterdurationn.toSql(duration.value));
    }
    if (track.present) {
      map['track'] = Variable<int>(track.value);
    }
    if (disc.present) {
      map['disc'] = Variable<int>(disc.value);
    }
    if (starred.present) {
      map['starred'] = Variable<DateTime>(starred.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (downloadTaskId.present) {
      map['download_task_id'] = Variable<String>(downloadTaskId.value);
    }
    if (downloadFilePath.present) {
      map['download_file_path'] = Variable<String>(downloadFilePath.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (userRating.present) {
      map['user_rating'] =
          Variable<String>(Songs.$converteruserRating.toSql(userRating.value));
    }
    if (thumbsUpCount.present) {
      map['thumbs_up_count'] = Variable<int>(thumbsUpCount.value);
    }
    if (thumbsDownCount.present) {
      map['thumbs_down_count'] = Variable<int>(thumbsDownCount.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('artistId: $artistId, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('track: $track, ')
          ..write('disc: $disc, ')
          ..write('starred: $starred, ')
          ..write('genre: $genre, ')
          ..write('downloadTaskId: $downloadTaskId, ')
          ..write('downloadFilePath: $downloadFilePath, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('userRating: $userRating, ')
          ..write('thumbsUpCount: $thumbsUpCount, ')
          ..write('thumbsDownCount: $thumbsDownCount, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SongsFts extends Table
    with TableInfo<SongsFts, SongsFt>, VirtualTableInfo<SongsFts, SongsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SongsFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [sourceId, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs_fts';
  @override
  VerificationContext validateIntegrity(Insertable<SongsFt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SongsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongsFt(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
    );
  }

  @override
  SongsFts createAlias(String alias) {
    return SongsFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(source_id, title, content=songs, content_rowid=rowid)';
}

class SongsFt extends DataClass implements Insertable<SongsFt> {
  final String sourceId;
  final String title;
  const SongsFt({required this.sourceId, required this.title});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    return map;
  }

  SongsFtsCompanion toCompanion(bool nullToAbsent) {
    return SongsFtsCompanion(
      sourceId: Value(sourceId),
      title: Value(title),
    );
  }

  factory SongsFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongsFt(
      sourceId: serializer.fromJson<String>(json['source_id']),
      title: serializer.fromJson<String>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
    };
  }

  SongsFt copyWith({String? sourceId, String? title}) => SongsFt(
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
      );
  @override
  String toString() {
    return (StringBuffer('SongsFt(')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongsFt &&
          other.sourceId == this.sourceId &&
          other.title == this.title);
}

class SongsFtsCompanion extends UpdateCompanion<SongsFt> {
  final Value<String> sourceId;
  final Value<String> title;
  final Value<int> rowid;
  const SongsFtsCompanion({
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsFtsCompanion.insert({
    required String sourceId,
    required String title,
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        title = Value(title);
  static Insertable<SongsFt> custom({
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsFtsCompanion copyWith(
      {Value<String>? sourceId, Value<String>? title, Value<int>? rowid}) {
    return SongsFtsCompanion(
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsFtsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DiscoverySessions extends Table
    with TableInfo<DiscoverySessions, DiscoverySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DiscoverySessions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _seedSongIdMeta =
      const VerificationMeta('seedSongId');
  late final GeneratedColumn<String> seedSongId = GeneratedColumn<String>(
      'seed_song_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _seedArtistMeta =
      const VerificationMeta('seedArtist');
  late final GeneratedColumn<String> seedArtist = GeneratedColumn<String>(
      'seed_artist', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _seedGenreMeta =
      const VerificationMeta('seedGenre');
  late final GeneratedColumn<String> seedGenre = GeneratedColumn<String>(
      'seed_genre', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _playlistSizeMeta =
      const VerificationMeta('playlistSize');
  late final GeneratedColumn<int> playlistSize = GeneratedColumn<int>(
      'playlist_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 50',
      defaultValue: const CustomExpression('50'));
  static const VerificationMeta _stationNameMeta =
      const VerificationMeta('stationName');
  late final GeneratedColumn<String> stationName = GeneratedColumn<String>(
      'station_name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lastPlayedAtMeta =
      const VerificationMeta('lastPlayedAt');
  late final GeneratedColumn<int> lastPlayedAt = GeneratedColumn<int>(
      'last_played_at', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _playCountMeta =
      const VerificationMeta('playCount');
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
      'play_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  late final GeneratedColumn<int> isFavorite = GeneratedColumn<int>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seedSongId,
        seedArtist,
        seedGenre,
        sourceId,
        mode,
        playlistSize,
        stationName,
        lastPlayedAt,
        playCount,
        isFavorite,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovery_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<DiscoverySession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('seed_song_id')) {
      context.handle(
          _seedSongIdMeta,
          seedSongId.isAcceptableOrUnknown(
              data['seed_song_id']!, _seedSongIdMeta));
    } else if (isInserting) {
      context.missing(_seedSongIdMeta);
    }
    if (data.containsKey('seed_artist')) {
      context.handle(
          _seedArtistMeta,
          seedArtist.isAcceptableOrUnknown(
              data['seed_artist']!, _seedArtistMeta));
    }
    if (data.containsKey('seed_genre')) {
      context.handle(_seedGenreMeta,
          seedGenre.isAcceptableOrUnknown(data['seed_genre']!, _seedGenreMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('playlist_size')) {
      context.handle(
          _playlistSizeMeta,
          playlistSize.isAcceptableOrUnknown(
              data['playlist_size']!, _playlistSizeMeta));
    }
    if (data.containsKey('station_name')) {
      context.handle(
          _stationNameMeta,
          stationName.isAcceptableOrUnknown(
              data['station_name']!, _stationNameMeta));
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
          _lastPlayedAtMeta,
          lastPlayedAt.isAcceptableOrUnknown(
              data['last_played_at']!, _lastPlayedAtMeta));
    }
    if (data.containsKey('play_count')) {
      context.handle(_playCountMeta,
          playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoverySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoverySession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seedSongId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seed_song_id'])!,
      seedArtist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seed_artist']),
      seedGenre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seed_genre']),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      playlistSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}playlist_size'])!,
      stationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}station_name']),
      lastPlayedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_played_at']),
      playCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}play_count'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  DiscoverySessions createAlias(String alias) {
    return DiscoverySessions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(source_id)REFERENCES sources(id)ON DELETE CASCADE'];
  @override
  bool get dontWriteConstraints => true;
}

class DiscoverySession extends DataClass
    implements Insertable<DiscoverySession> {
  final int id;
  final String seedSongId;
  final String? seedArtist;
  final String? seedGenre;
  final int sourceId;
  final String mode;

  /// 'online' or 'offline'
  final int playlistSize;
  final String? stationName;
  final int? lastPlayedAt;
  final int playCount;
  final int isFavorite;
  final int createdAt;
  const DiscoverySession(
      {required this.id,
      required this.seedSongId,
      this.seedArtist,
      this.seedGenre,
      required this.sourceId,
      required this.mode,
      required this.playlistSize,
      this.stationName,
      this.lastPlayedAt,
      required this.playCount,
      required this.isFavorite,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seed_song_id'] = Variable<String>(seedSongId);
    if (!nullToAbsent || seedArtist != null) {
      map['seed_artist'] = Variable<String>(seedArtist);
    }
    if (!nullToAbsent || seedGenre != null) {
      map['seed_genre'] = Variable<String>(seedGenre);
    }
    map['source_id'] = Variable<int>(sourceId);
    map['mode'] = Variable<String>(mode);
    map['playlist_size'] = Variable<int>(playlistSize);
    if (!nullToAbsent || stationName != null) {
      map['station_name'] = Variable<String>(stationName);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<int>(lastPlayedAt);
    }
    map['play_count'] = Variable<int>(playCount);
    map['is_favorite'] = Variable<int>(isFavorite);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DiscoverySessionsCompanion toCompanion(bool nullToAbsent) {
    return DiscoverySessionsCompanion(
      id: Value(id),
      seedSongId: Value(seedSongId),
      seedArtist: seedArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(seedArtist),
      seedGenre: seedGenre == null && nullToAbsent
          ? const Value.absent()
          : Value(seedGenre),
      sourceId: Value(sourceId),
      mode: Value(mode),
      playlistSize: Value(playlistSize),
      stationName: stationName == null && nullToAbsent
          ? const Value.absent()
          : Value(stationName),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      playCount: Value(playCount),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
    );
  }

  factory DiscoverySession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoverySession(
      id: serializer.fromJson<int>(json['id']),
      seedSongId: serializer.fromJson<String>(json['seed_song_id']),
      seedArtist: serializer.fromJson<String?>(json['seed_artist']),
      seedGenre: serializer.fromJson<String?>(json['seed_genre']),
      sourceId: serializer.fromJson<int>(json['source_id']),
      mode: serializer.fromJson<String>(json['mode']),
      playlistSize: serializer.fromJson<int>(json['playlist_size']),
      stationName: serializer.fromJson<String?>(json['station_name']),
      lastPlayedAt: serializer.fromJson<int?>(json['last_played_at']),
      playCount: serializer.fromJson<int>(json['play_count']),
      isFavorite: serializer.fromJson<int>(json['is_favorite']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seed_song_id': serializer.toJson<String>(seedSongId),
      'seed_artist': serializer.toJson<String?>(seedArtist),
      'seed_genre': serializer.toJson<String?>(seedGenre),
      'source_id': serializer.toJson<int>(sourceId),
      'mode': serializer.toJson<String>(mode),
      'playlist_size': serializer.toJson<int>(playlistSize),
      'station_name': serializer.toJson<String?>(stationName),
      'last_played_at': serializer.toJson<int?>(lastPlayedAt),
      'play_count': serializer.toJson<int>(playCount),
      'is_favorite': serializer.toJson<int>(isFavorite),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  DiscoverySession copyWith(
          {int? id,
          String? seedSongId,
          Value<String?> seedArtist = const Value.absent(),
          Value<String?> seedGenre = const Value.absent(),
          int? sourceId,
          String? mode,
          int? playlistSize,
          Value<String?> stationName = const Value.absent(),
          Value<int?> lastPlayedAt = const Value.absent(),
          int? playCount,
          int? isFavorite,
          int? createdAt}) =>
      DiscoverySession(
        id: id ?? this.id,
        seedSongId: seedSongId ?? this.seedSongId,
        seedArtist: seedArtist.present ? seedArtist.value : this.seedArtist,
        seedGenre: seedGenre.present ? seedGenre.value : this.seedGenre,
        sourceId: sourceId ?? this.sourceId,
        mode: mode ?? this.mode,
        playlistSize: playlistSize ?? this.playlistSize,
        stationName: stationName.present ? stationName.value : this.stationName,
        lastPlayedAt:
            lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
        playCount: playCount ?? this.playCount,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('DiscoverySession(')
          ..write('id: $id, ')
          ..write('seedSongId: $seedSongId, ')
          ..write('seedArtist: $seedArtist, ')
          ..write('seedGenre: $seedGenre, ')
          ..write('sourceId: $sourceId, ')
          ..write('mode: $mode, ')
          ..write('playlistSize: $playlistSize, ')
          ..write('stationName: $stationName, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      seedSongId,
      seedArtist,
      seedGenre,
      sourceId,
      mode,
      playlistSize,
      stationName,
      lastPlayedAt,
      playCount,
      isFavorite,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoverySession &&
          other.id == this.id &&
          other.seedSongId == this.seedSongId &&
          other.seedArtist == this.seedArtist &&
          other.seedGenre == this.seedGenre &&
          other.sourceId == this.sourceId &&
          other.mode == this.mode &&
          other.playlistSize == this.playlistSize &&
          other.stationName == this.stationName &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.playCount == this.playCount &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt);
}

class DiscoverySessionsCompanion extends UpdateCompanion<DiscoverySession> {
  final Value<int> id;
  final Value<String> seedSongId;
  final Value<String?> seedArtist;
  final Value<String?> seedGenre;
  final Value<int> sourceId;
  final Value<String> mode;
  final Value<int> playlistSize;
  final Value<String?> stationName;
  final Value<int?> lastPlayedAt;
  final Value<int> playCount;
  final Value<int> isFavorite;
  final Value<int> createdAt;
  const DiscoverySessionsCompanion({
    this.id = const Value.absent(),
    this.seedSongId = const Value.absent(),
    this.seedArtist = const Value.absent(),
    this.seedGenre = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.mode = const Value.absent(),
    this.playlistSize = const Value.absent(),
    this.stationName = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiscoverySessionsCompanion.insert({
    this.id = const Value.absent(),
    required String seedSongId,
    this.seedArtist = const Value.absent(),
    this.seedGenre = const Value.absent(),
    required int sourceId,
    required String mode,
    this.playlistSize = const Value.absent(),
    this.stationName = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : seedSongId = Value(seedSongId),
        sourceId = Value(sourceId),
        mode = Value(mode);
  static Insertable<DiscoverySession> custom({
    Expression<int>? id,
    Expression<String>? seedSongId,
    Expression<String>? seedArtist,
    Expression<String>? seedGenre,
    Expression<int>? sourceId,
    Expression<String>? mode,
    Expression<int>? playlistSize,
    Expression<String>? stationName,
    Expression<int>? lastPlayedAt,
    Expression<int>? playCount,
    Expression<int>? isFavorite,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seedSongId != null) 'seed_song_id': seedSongId,
      if (seedArtist != null) 'seed_artist': seedArtist,
      if (seedGenre != null) 'seed_genre': seedGenre,
      if (sourceId != null) 'source_id': sourceId,
      if (mode != null) 'mode': mode,
      if (playlistSize != null) 'playlist_size': playlistSize,
      if (stationName != null) 'station_name': stationName,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (playCount != null) 'play_count': playCount,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiscoverySessionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? seedSongId,
      Value<String?>? seedArtist,
      Value<String?>? seedGenre,
      Value<int>? sourceId,
      Value<String>? mode,
      Value<int>? playlistSize,
      Value<String?>? stationName,
      Value<int?>? lastPlayedAt,
      Value<int>? playCount,
      Value<int>? isFavorite,
      Value<int>? createdAt}) {
    return DiscoverySessionsCompanion(
      id: id ?? this.id,
      seedSongId: seedSongId ?? this.seedSongId,
      seedArtist: seedArtist ?? this.seedArtist,
      seedGenre: seedGenre ?? this.seedGenre,
      sourceId: sourceId ?? this.sourceId,
      mode: mode ?? this.mode,
      playlistSize: playlistSize ?? this.playlistSize,
      stationName: stationName ?? this.stationName,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seedSongId.present) {
      map['seed_song_id'] = Variable<String>(seedSongId.value);
    }
    if (seedArtist.present) {
      map['seed_artist'] = Variable<String>(seedArtist.value);
    }
    if (seedGenre.present) {
      map['seed_genre'] = Variable<String>(seedGenre.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (playlistSize.present) {
      map['playlist_size'] = Variable<int>(playlistSize.value);
    }
    if (stationName.present) {
      map['station_name'] = Variable<String>(stationName.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<int>(lastPlayedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<int>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoverySessionsCompanion(')
          ..write('id: $id, ')
          ..write('seedSongId: $seedSongId, ')
          ..write('seedArtist: $seedArtist, ')
          ..write('seedGenre: $seedGenre, ')
          ..write('sourceId: $sourceId, ')
          ..write('mode: $mode, ')
          ..write('playlistSize: $playlistSize, ')
          ..write('stationName: $stationName, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class DiscoveryInteractions extends Table
    with TableInfo<DiscoveryInteractions, DiscoveryInteraction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DiscoveryInteractions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
      'song_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _interactionTypeMeta =
      const VerificationMeta('interactionType');
  late final GeneratedColumn<String> interactionType = GeneratedColumn<String>(
      'interaction_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _positionInPlaylistMeta =
      const VerificationMeta('positionInPlaylist');
  late final GeneratedColumn<int> positionInPlaylist = GeneratedColumn<int>(
      'position_in_playlist', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _songDurationMsMeta =
      const VerificationMeta('songDurationMs');
  late final GeneratedColumn<int> songDurationMs = GeneratedColumn<int>(
      'song_duration_ms', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _playDurationMsMeta =
      const VerificationMeta('playDurationMs');
  late final GeneratedColumn<int> playDurationMs = GeneratedColumn<int>(
      'play_duration_ms', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT (strftime(\'%s\', CURRENT_TIMESTAMP))',
      defaultValue:
          const CustomExpression('strftime(\'%s\', CURRENT_TIMESTAMP)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        songId,
        interactionType,
        positionInPlaylist,
        songDurationMs,
        playDurationMs,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovery_interactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<DiscoveryInteraction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('interaction_type')) {
      context.handle(
          _interactionTypeMeta,
          interactionType.isAcceptableOrUnknown(
              data['interaction_type']!, _interactionTypeMeta));
    } else if (isInserting) {
      context.missing(_interactionTypeMeta);
    }
    if (data.containsKey('position_in_playlist')) {
      context.handle(
          _positionInPlaylistMeta,
          positionInPlaylist.isAcceptableOrUnknown(
              data['position_in_playlist']!, _positionInPlaylistMeta));
    } else if (isInserting) {
      context.missing(_positionInPlaylistMeta);
    }
    if (data.containsKey('song_duration_ms')) {
      context.handle(
          _songDurationMsMeta,
          songDurationMs.isAcceptableOrUnknown(
              data['song_duration_ms']!, _songDurationMsMeta));
    }
    if (data.containsKey('play_duration_ms')) {
      context.handle(
          _playDurationMsMeta,
          playDurationMs.isAcceptableOrUnknown(
              data['play_duration_ms']!, _playDurationMsMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoveryInteraction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveryInteraction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}song_id'])!,
      interactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}interaction_type'])!,
      positionInPlaylist: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}position_in_playlist'])!,
      songDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_duration_ms']),
      playDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}play_duration_ms']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  DiscoveryInteractions createAlias(String alias) {
    return DiscoveryInteractions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(session_id)REFERENCES discovery_sessions(id)ON DELETE CASCADE'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class DiscoveryInteraction extends DataClass
    implements Insertable<DiscoveryInteraction> {
  final int id;
  final int sessionId;
  final String songId;
  final String interactionType;

  /// 'played', 'skipped', 'thumbs_up', 'thumbs_down', 'completed'
  final int positionInPlaylist;
  final int? songDurationMs;
  final int? playDurationMs;

  /// How long the song was actually played
  final int timestamp;
  const DiscoveryInteraction(
      {required this.id,
      required this.sessionId,
      required this.songId,
      required this.interactionType,
      required this.positionInPlaylist,
      this.songDurationMs,
      this.playDurationMs,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['song_id'] = Variable<String>(songId);
    map['interaction_type'] = Variable<String>(interactionType);
    map['position_in_playlist'] = Variable<int>(positionInPlaylist);
    if (!nullToAbsent || songDurationMs != null) {
      map['song_duration_ms'] = Variable<int>(songDurationMs);
    }
    if (!nullToAbsent || playDurationMs != null) {
      map['play_duration_ms'] = Variable<int>(playDurationMs);
    }
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  DiscoveryInteractionsCompanion toCompanion(bool nullToAbsent) {
    return DiscoveryInteractionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      songId: Value(songId),
      interactionType: Value(interactionType),
      positionInPlaylist: Value(positionInPlaylist),
      songDurationMs: songDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(songDurationMs),
      playDurationMs: playDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(playDurationMs),
      timestamp: Value(timestamp),
    );
  }

  factory DiscoveryInteraction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveryInteraction(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['session_id']),
      songId: serializer.fromJson<String>(json['song_id']),
      interactionType: serializer.fromJson<String>(json['interaction_type']),
      positionInPlaylist:
          serializer.fromJson<int>(json['position_in_playlist']),
      songDurationMs: serializer.fromJson<int?>(json['song_duration_ms']),
      playDurationMs: serializer.fromJson<int?>(json['play_duration_ms']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'session_id': serializer.toJson<int>(sessionId),
      'song_id': serializer.toJson<String>(songId),
      'interaction_type': serializer.toJson<String>(interactionType),
      'position_in_playlist': serializer.toJson<int>(positionInPlaylist),
      'song_duration_ms': serializer.toJson<int?>(songDurationMs),
      'play_duration_ms': serializer.toJson<int?>(playDurationMs),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  DiscoveryInteraction copyWith(
          {int? id,
          int? sessionId,
          String? songId,
          String? interactionType,
          int? positionInPlaylist,
          Value<int?> songDurationMs = const Value.absent(),
          Value<int?> playDurationMs = const Value.absent(),
          int? timestamp}) =>
      DiscoveryInteraction(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        songId: songId ?? this.songId,
        interactionType: interactionType ?? this.interactionType,
        positionInPlaylist: positionInPlaylist ?? this.positionInPlaylist,
        songDurationMs:
            songDurationMs.present ? songDurationMs.value : this.songDurationMs,
        playDurationMs:
            playDurationMs.present ? playDurationMs.value : this.playDurationMs,
        timestamp: timestamp ?? this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('DiscoveryInteraction(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('songId: $songId, ')
          ..write('interactionType: $interactionType, ')
          ..write('positionInPlaylist: $positionInPlaylist, ')
          ..write('songDurationMs: $songDurationMs, ')
          ..write('playDurationMs: $playDurationMs, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, songId, interactionType,
      positionInPlaylist, songDurationMs, playDurationMs, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveryInteraction &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.songId == this.songId &&
          other.interactionType == this.interactionType &&
          other.positionInPlaylist == this.positionInPlaylist &&
          other.songDurationMs == this.songDurationMs &&
          other.playDurationMs == this.playDurationMs &&
          other.timestamp == this.timestamp);
}

class DiscoveryInteractionsCompanion
    extends UpdateCompanion<DiscoveryInteraction> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> songId;
  final Value<String> interactionType;
  final Value<int> positionInPlaylist;
  final Value<int?> songDurationMs;
  final Value<int?> playDurationMs;
  final Value<int> timestamp;
  const DiscoveryInteractionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.songId = const Value.absent(),
    this.interactionType = const Value.absent(),
    this.positionInPlaylist = const Value.absent(),
    this.songDurationMs = const Value.absent(),
    this.playDurationMs = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  DiscoveryInteractionsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String songId,
    required String interactionType,
    required int positionInPlaylist,
    this.songDurationMs = const Value.absent(),
    this.playDurationMs = const Value.absent(),
    this.timestamp = const Value.absent(),
  })  : sessionId = Value(sessionId),
        songId = Value(songId),
        interactionType = Value(interactionType),
        positionInPlaylist = Value(positionInPlaylist);
  static Insertable<DiscoveryInteraction> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? songId,
    Expression<String>? interactionType,
    Expression<int>? positionInPlaylist,
    Expression<int>? songDurationMs,
    Expression<int>? playDurationMs,
    Expression<int>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (songId != null) 'song_id': songId,
      if (interactionType != null) 'interaction_type': interactionType,
      if (positionInPlaylist != null)
        'position_in_playlist': positionInPlaylist,
      if (songDurationMs != null) 'song_duration_ms': songDurationMs,
      if (playDurationMs != null) 'play_duration_ms': playDurationMs,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  DiscoveryInteractionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<String>? songId,
      Value<String>? interactionType,
      Value<int>? positionInPlaylist,
      Value<int?>? songDurationMs,
      Value<int?>? playDurationMs,
      Value<int>? timestamp}) {
    return DiscoveryInteractionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      songId: songId ?? this.songId,
      interactionType: interactionType ?? this.interactionType,
      positionInPlaylist: positionInPlaylist ?? this.positionInPlaylist,
      songDurationMs: songDurationMs ?? this.songDurationMs,
      playDurationMs: playDurationMs ?? this.playDurationMs,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (interactionType.present) {
      map['interaction_type'] = Variable<String>(interactionType.value);
    }
    if (positionInPlaylist.present) {
      map['position_in_playlist'] = Variable<int>(positionInPlaylist.value);
    }
    if (songDurationMs.present) {
      map['song_duration_ms'] = Variable<int>(songDurationMs.value);
    }
    if (playDurationMs.present) {
      map['play_duration_ms'] = Variable<int>(playDurationMs.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryInteractionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('songId: $songId, ')
          ..write('interactionType: $interactionType, ')
          ..write('positionInPlaylist: $positionInPlaylist, ')
          ..write('songDurationMs: $songDurationMs, ')
          ..write('playDurationMs: $playDurationMs, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$SubtracksDatabase extends GeneratedDatabase {
  _$SubtracksDatabase(QueryExecutor e) : super(e);
  _$SubtracksDatabaseManager get managers => _$SubtracksDatabaseManager(this);
  late final Queue queue = Queue(this);
  late final Index queueIndex =
      Index('queue_index', 'CREATE INDEX queue_index ON queue ("index")');
  late final Index queueCurrentTrack = Index('queue_current_track',
      'CREATE INDEX queue_current_track ON queue (current_track)');
  late final LastAudioState lastAudioState = LastAudioState(this);
  late final LastBottomNavState lastBottomNavState = LastBottomNavState(this);
  late final LastLibraryState lastLibraryState = LastLibraryState(this);
  late final AppSettingsTable appSettings = AppSettingsTable(this);
  late final Sources sources = Sources(this);
  late final SubsonicSources subsonicSources = SubsonicSources(this);
  late final Artists artists = Artists(this);
  late final Index artistsSourceId = Index('artists_source_id',
      'CREATE INDEX artists_source_id ON artists (source_id)');
  late final ArtistsFts artistsFts = ArtistsFts(this);
  late final Trigger artistsAi = Trigger(
      'CREATE TRIGGER artists_ai AFTER INSERT ON artists BEGIN INSERT INTO artists_fts ("rowid", source_id, name) VALUES (new."rowid", new.source_id, new.name);END',
      'artists_ai');
  late final Trigger artistsAd = Trigger(
      'CREATE TRIGGER artists_ad AFTER DELETE ON artists BEGIN INSERT INTO artists_fts (artists_fts, "rowid", source_id, name) VALUES (\'delete\', old."rowid", old.source_id, old.name);END',
      'artists_ad');
  late final Trigger artistsAu = Trigger(
      'CREATE TRIGGER artists_au AFTER UPDATE ON artists BEGIN INSERT INTO artists_fts (artists_fts, "rowid", source_id, name) VALUES (\'delete\', old."rowid", old.source_id, old.name);INSERT INTO artists_fts ("rowid", source_id, name) VALUES (new."rowid", new.source_id, new.name);END',
      'artists_au');
  late final Albums albums = Albums(this);
  late final Index albumsSourceId = Index('albums_source_id',
      'CREATE INDEX albums_source_id ON albums (source_id)');
  late final Index albumsSourceIdArtistIdIdx = Index(
      'albums_source_id_artist_id_idx',
      'CREATE INDEX albums_source_id_artist_id_idx ON albums (source_id, artist_id)');
  late final AlbumsFts albumsFts = AlbumsFts(this);
  late final Trigger albumsAi = Trigger(
      'CREATE TRIGGER albums_ai AFTER INSERT ON albums BEGIN INSERT INTO albums_fts ("rowid", source_id, name) VALUES (new."rowid", new.source_id, new.name);END',
      'albums_ai');
  late final Trigger albumsAd = Trigger(
      'CREATE TRIGGER albums_ad AFTER DELETE ON albums BEGIN INSERT INTO albums_fts (albums_fts, "rowid", source_id, name) VALUES (\'delete\', old."rowid", old.source_id, old.name);END',
      'albums_ad');
  late final Trigger albumsAu = Trigger(
      'CREATE TRIGGER albums_au AFTER UPDATE ON albums BEGIN INSERT INTO albums_fts (albums_fts, "rowid", source_id, name) VALUES (\'delete\', old."rowid", old.source_id, old.name);INSERT INTO albums_fts ("rowid", source_id, name) VALUES (new."rowid", new.source_id, new.name);END',
      'albums_au');
  late final Playlists playlists = Playlists(this);
  late final Index playlistsSourceId = Index('playlists_source_id',
      'CREATE INDEX playlists_source_id ON playlists (source_id)');
  late final PlaylistSongs playlistSongs = PlaylistSongs(this);
  late final Index playlistSongsSourceIdPlaylistIdIdx = Index(
      'playlist_songs_source_id_playlist_id_idx',
      'CREATE INDEX playlist_songs_source_id_playlist_id_idx ON playlist_songs (source_id, playlist_id)');
  late final Index playlistSongsSourceIdSongIdIdx = Index(
      'playlist_songs_source_id_song_id_idx',
      'CREATE INDEX playlist_songs_source_id_song_id_idx ON playlist_songs (source_id, song_id)');
  late final PlaylistsFts playlistsFts = PlaylistsFts(this);
  late final Trigger playlistsAi = Trigger(
      'CREATE TRIGGER playlists_ai AFTER INSERT ON playlists BEGIN INSERT INTO playlists_fts ("rowid", source_id, name) VALUES (new."rowid", new.source_id, new.name);END',
      'playlists_ai');
  late final Trigger playlistsAd = Trigger(
      'CREATE TRIGGER playlists_ad AFTER DELETE ON playlists BEGIN INSERT INTO playlists_fts (playlists_fts, "rowid", source_id, name) VALUES (\'delete\', old."rowid", old.source_id, old.name);END',
      'playlists_ad');
  late final Trigger playlistsAu = Trigger(
      'CREATE TRIGGER playlists_au AFTER UPDATE ON playlists BEGIN INSERT INTO playlists_fts (playlists_fts, "rowid", source_id, name) VALUES (\'delete\', old."rowid", old.source_id, old.name);INSERT INTO playlists_fts ("rowid", source_id, name) VALUES (new."rowid", new.source_id, new.name);END',
      'playlists_au');
  late final Songs songs = Songs(this);
  late final Index songsSourceIdAlbumIdIdx = Index(
      'songs_source_id_album_id_idx',
      'CREATE INDEX songs_source_id_album_id_idx ON songs (source_id, album_id)');
  late final Index songsSourceIdArtistIdIdx = Index(
      'songs_source_id_artist_id_idx',
      'CREATE INDEX songs_source_id_artist_id_idx ON songs (source_id, artist_id)');
  late final Index songsDownloadTaskIdIdx = Index('songs_download_task_id_idx',
      'CREATE INDEX songs_download_task_id_idx ON songs (download_task_id)');
  late final SongsFts songsFts = SongsFts(this);
  late final Trigger songsAi = Trigger(
      'CREATE TRIGGER songs_ai AFTER INSERT ON songs BEGIN INSERT INTO songs_fts ("rowid", source_id, title) VALUES (new."rowid", new.source_id, new.title);END',
      'songs_ai');
  late final Trigger songsAd = Trigger(
      'CREATE TRIGGER songs_ad AFTER DELETE ON songs BEGIN INSERT INTO songs_fts (songs_fts, "rowid", source_id, title) VALUES (\'delete\', old."rowid", old.source_id, old.title);END',
      'songs_ad');
  late final Trigger songsAu = Trigger(
      'CREATE TRIGGER songs_au AFTER UPDATE ON songs BEGIN INSERT INTO songs_fts (songs_fts, "rowid", source_id, title) VALUES (\'delete\', old."rowid", old.source_id, old.title);INSERT INTO songs_fts ("rowid", source_id, title) VALUES (new."rowid", new.source_id, new.title);END',
      'songs_au');
  late final DiscoverySessions discoverySessions = DiscoverySessions(this);
  late final Index discoverySessionsSourceId = Index(
      'discovery_sessions_source_id',
      'CREATE INDEX discovery_sessions_source_id ON discovery_sessions (source_id)');
  late final Index discoverySessionsCreatedAt = Index(
      'discovery_sessions_created_at',
      'CREATE INDEX discovery_sessions_created_at ON discovery_sessions (created_at)');
  late final Index discoverySessionsLastPlayedAt = Index(
      'discovery_sessions_last_played_at',
      'CREATE INDEX discovery_sessions_last_played_at ON discovery_sessions (last_played_at)');
  late final Index discoverySessionsIsFavorite = Index(
      'discovery_sessions_is_favorite',
      'CREATE INDEX discovery_sessions_is_favorite ON discovery_sessions (is_favorite)');
  late final DiscoveryInteractions discoveryInteractions =
      DiscoveryInteractions(this);
  late final Index discoveryInteractionsSessionId = Index(
      'discovery_interactions_session_id',
      'CREATE INDEX discovery_interactions_session_id ON discovery_interactions (session_id)');
  late final Index discoveryInteractionsSongId = Index(
      'discovery_interactions_song_id',
      'CREATE INDEX discovery_interactions_song_id ON discovery_interactions (song_id)');
  late final Index discoveryInteractionsInteractionType = Index(
      'discovery_interactions_interaction_type',
      'CREATE INDEX discovery_interactions_interaction_type ON discovery_interactions (interaction_type)');
  Selectable<int> sourcesCount() {
    return customSelect('SELECT COUNT(*) AS _c0 FROM sources',
        variables: [],
        readsFrom: {
          sources,
        }).map((QueryRow row) => row.read<int>('_c0'));
  }

  Selectable<SubsonicSettings> allSubsonicSources() {
    return customSelect(
        'SELECT sources.id, sources.name, sources.address, sources.is_active, sources.created_at, subsonic_sources.features, subsonic_sources.username, subsonic_sources.password, subsonic_sources.use_token_auth FROM sources JOIN subsonic_sources ON subsonic_sources.source_id = sources.id',
        variables: [],
        readsFrom: {
          sources,
          subsonicSources,
        }).map((QueryRow row) => SubsonicSettings(
          id: row.read<int>('id'),
          features: SubsonicSources.$converterfeatures
              .fromSql(row.read<String>('features')),
          name: row.read<String>('name'),
          address:
              Sources.$converteraddress.fromSql(row.read<String>('address')),
          isActive: row.readNullable<bool>('is_active'),
          createdAt: row.read<DateTime>('created_at'),
          username: row.read<String>('username'),
          password: row.read<String>('password'),
          useTokenAuth: row.read<bool>('use_token_auth'),
        ));
  }

  Selectable<String> albumIdsWithDownloadStatus(int sourceId) {
    return customSelect(
        'SELECT albums.id FROM albums JOIN songs ON songs.source_id = albums.source_id AND songs.album_id = albums.id WHERE albums.source_id = ?1 AND(songs.download_file_path IS NOT NULL OR songs.download_task_id IS NOT NULL)GROUP BY albums.id',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          albums,
          songs,
        }).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<String> artistIdsWithDownloadStatus(int sourceId) {
    return customSelect(
        'SELECT artists.id FROM artists LEFT JOIN albums ON artists.source_id = albums.source_id AND artists.id = albums.artist_id LEFT JOIN songs ON albums.source_id = songs.source_id AND albums.id = songs.album_id WHERE artists.source_id = ?1 AND(songs.download_file_path IS NOT NULL OR songs.download_task_id IS NOT NULL)GROUP BY artists.id',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          artists,
          albums,
          songs,
        }).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<String> playlistIdsWithDownloadStatus(int sourceId) {
    return customSelect(
        'SELECT playlists.id FROM playlists LEFT JOIN playlist_songs ON playlist_songs.source_id = playlists.source_id AND playlist_songs.playlist_id = playlists.id LEFT JOIN songs ON playlist_songs.source_id = songs.source_id AND playlist_songs.song_id = songs.id WHERE playlists.source_id = ?1 AND(songs.download_file_path IS NOT NULL OR songs.download_task_id IS NOT NULL)GROUP BY playlists.id',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          playlists,
          playlistSongs,
          songs,
        }).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<int> searchArtists(String query, int limit, int offset) {
    return customSelect(
        'SELECT "rowid" FROM artists_fts WHERE artists_fts MATCH ?1 ORDER BY rank LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<String>(query),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          artistsFts,
        }).map((QueryRow row) => row.read<int>('rowid'));
  }

  Selectable<int> searchAlbums(String query, int limit, int offset) {
    return customSelect(
        'SELECT "rowid" FROM albums_fts WHERE albums_fts MATCH ?1 ORDER BY rank LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<String>(query),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          albumsFts,
        }).map((QueryRow row) => row.read<int>('rowid'));
  }

  Selectable<int> searchPlaylists(String query, int limit, int offset) {
    return customSelect(
        'SELECT "rowid" FROM playlists_fts WHERE playlists_fts MATCH ?1 ORDER BY rank LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<String>(query),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          playlistsFts,
        }).map((QueryRow row) => row.read<int>('rowid'));
  }

  Selectable<int> searchSongs(String query, int limit, int offset) {
    return customSelect(
        'SELECT "rowid" FROM songs_fts WHERE songs_fts MATCH ?1 ORDER BY rank LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<String>(query),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          songsFts,
        }).map((QueryRow row) => row.read<int>('rowid'));
  }

  Selectable<Artist> artistById(int sourceId, String id) {
    return customSelect(
        'SELECT * FROM artists WHERE source_id = ?1 AND id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          artists,
        }).asyncMap(artists.mapFromRow);
  }

  Selectable<Album> albumById(int sourceId, String id) {
    return customSelect('SELECT * FROM albums WHERE source_id = ?1 AND id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          albums,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Album> albumsByArtistId(int sourceId, String? artistId) {
    return customSelect(
        'SELECT * FROM albums WHERE source_id = ?1 AND artist_id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(artistId)
        ],
        readsFrom: {
          albums,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Album> albumsInIds(int sourceId, List<String> ids) {
    var $arrayStartIndex = 2;
    final expandedids = $expandVar($arrayStartIndex, ids.length);
    $arrayStartIndex += ids.length;
    return customSelect(
        'SELECT * FROM albums WHERE source_id = ?1 AND id IN ($expandedids)',
        variables: [
          Variable<int>(sourceId),
          for (var $ in ids) Variable<String>($)
        ],
        readsFrom: {
          albums,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Playlist> playlistById(int sourceId, String id) {
    return customSelect(
        'SELECT * FROM playlists WHERE source_id = ?1 AND id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          playlists,
        }).asyncMap(playlists.mapFromRow);
  }

  Selectable<Song> songById(int sourceId, String id) {
    return customSelect('SELECT * FROM songs WHERE source_id = ?1 AND id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<String?> albumGenres(int sourceId, int limit, int offset) {
    return customSelect(
        'SELECT genre FROM albums WHERE genre IS NOT NULL AND source_id = ?1 GROUP BY genre ORDER BY COUNT(genre) DESC LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          albums,
        }).map((QueryRow row) => row.readNullable<String>('genre'));
  }

  Selectable<Album> albumsByGenre(
      int sourceId, String? genre, int limit, int offset) {
    return customSelect(
        'SELECT albums.* FROM albums JOIN songs ON albums.source_id = songs.source_id AND albums.id = songs.album_id WHERE songs.source_id = ?1 AND songs.genre = ?2 GROUP BY albums.id ORDER BY albums.created DESC, albums.name LIMIT ?3 OFFSET ?4',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(genre),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          albums,
          songs,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Song> filterSongsByGenre(FilterSongsByGenre$predicate predicate,
      FilterSongsByGenre$order order, FilterSongsByGenre$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate = $write(predicate(this.songs, this.albums),
        hasMultipleTables: true, startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.songs, this.albums) ?? const OrderBy.nothing(),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit = $write(limit(this.songs, this.albums),
        hasMultipleTables: true, startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT songs.* FROM songs JOIN albums ON albums.source_id = songs.source_id AND albums.id = songs.album_id WHERE ${generatedpredicate.sql} ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          songs,
          albums,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<int> songsByGenreCount(int sourceId, String? genre) {
    return customSelect(
        'SELECT COUNT(*) AS _c0 FROM songs WHERE songs.source_id = ?1 AND songs.genre = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(genre)
        ],
        readsFrom: {
          songs,
        }).map((QueryRow row) => row.read<int>('_c0'));
  }

  Selectable<Song> songsWithDownloadTasks() {
    return customSelect(
        'SELECT * FROM songs WHERE download_task_id IS NOT NULL',
        variables: [],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Song> songByDownloadTask(String? taskId) {
    return customSelect('SELECT * FROM songs WHERE download_task_id = ?1',
        variables: [
          Variable<String>(taskId)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Future<int> clearSongDownloadTaskBySong(int sourceId, String id) {
    return customUpdate(
      'UPDATE songs SET download_task_id = NULL WHERE source_id = ?1 AND id = ?2',
      variables: [Variable<int>(sourceId), Variable<String>(id)],
      updates: {songs},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> completeSongDownload(String? filePath, String? taskId) {
    return customUpdate(
      'UPDATE songs SET download_task_id = NULL, download_file_path = ?1 WHERE download_task_id = ?2',
      variables: [Variable<String>(filePath), Variable<String>(taskId)],
      updates: {songs},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> clearSongDownloadTask(String? taskId) {
    return customUpdate(
      'UPDATE songs SET download_task_id = NULL, download_file_path = NULL WHERE download_task_id = ?1',
      variables: [Variable<String>(taskId)],
      updates: {songs},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> updateSongDownloadTask(String? taskId, int sourceId, String id) {
    return customUpdate(
      'UPDATE songs SET download_task_id = ?1 WHERE source_id = ?2 AND id = ?3',
      variables: [
        Variable<String>(taskId),
        Variable<int>(sourceId),
        Variable<String>(id)
      ],
      updates: {songs},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> deleteSongDownloadFile(int sourceId, String id) {
    return customUpdate(
      'UPDATE songs SET download_task_id = NULL, download_file_path = NULL WHERE source_id = ?1 AND id = ?2',
      variables: [Variable<int>(sourceId), Variable<String>(id)],
      updates: {songs},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<ListDownloadStatus> albumDownloadStatus(int sourceId, String id) {
    return customSelect(
        'SELECT COUNT(*) AS total, COUNT(CASE WHEN songs.download_file_path IS NOT NULL THEN songs.id ELSE NULL END) AS downloaded, COUNT(CASE WHEN songs.download_task_id IS NOT NULL THEN songs.id ELSE NULL END) AS downloading FROM albums JOIN songs ON albums.source_id = songs.source_id AND albums.id = songs.album_id WHERE albums.source_id = ?1 AND albums.id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          songs,
          albums,
        }).map((QueryRow row) => ListDownloadStatus(
          total: row.read<int>('total'),
          downloaded: row.read<int>('downloaded'),
          downloading: row.read<int>('downloading'),
        ));
  }

  Selectable<ListDownloadStatus> playlistDownloadStatus(
      int sourceId, String id) {
    return customSelect(
        'SELECT COUNT(DISTINCT songs.id) AS total, COUNT(DISTINCT CASE WHEN songs.download_file_path IS NOT NULL THEN songs.id ELSE NULL END) AS downloaded, COUNT(DISTINCT CASE WHEN songs.download_task_id IS NOT NULL THEN songs.id ELSE NULL END) AS downloading FROM playlists JOIN playlist_songs ON playlist_songs.source_id = playlists.source_id AND playlist_songs.playlist_id = playlists.id JOIN songs ON songs.source_id = playlist_songs.source_id AND songs.id = playlist_songs.song_id WHERE playlists.source_id = ?1 AND playlists.id = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          songs,
          playlists,
          playlistSongs,
        }).map((QueryRow row) => ListDownloadStatus(
          total: row.read<int>('total'),
          downloaded: row.read<int>('downloaded'),
          downloading: row.read<int>('downloading'),
        ));
  }

  Selectable<Album> filterAlbums(FilterAlbums$predicate predicate,
      FilterAlbums$order order, FilterAlbums$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate =
        $write(predicate(this.albums), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.albums) ?? const OrderBy.nothing(),
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit =
        $write(limit(this.albums), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT albums.* FROM albums WHERE ${generatedpredicate.sql} ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          albums,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Album> filterAlbumsDownloaded(
      FilterAlbumsDownloaded$predicate predicate,
      FilterAlbumsDownloaded$order order,
      FilterAlbumsDownloaded$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate = $write(predicate(this.albums, this.songs),
        hasMultipleTables: true, startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.albums, this.songs) ?? const OrderBy.nothing(),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit = $write(limit(this.albums, this.songs),
        hasMultipleTables: true, startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT albums.* FROM albums LEFT JOIN songs ON albums.source_id = songs.source_id AND albums.id = songs.album_id WHERE ${generatedpredicate.sql} GROUP BY albums.source_id, albums.id HAVING SUM(CASE WHEN songs.download_file_path IS NOT NULL THEN 1 ELSE 0 END) > 0 ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          albums,
          songs,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Artist> filterArtists(FilterArtists$predicate predicate,
      FilterArtists$order order, FilterArtists$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate =
        $write(predicate(this.artists), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.artists) ?? const OrderBy.nothing(),
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit =
        $write(limit(this.artists), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT artists.* FROM artists WHERE ${generatedpredicate.sql} ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          artists,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(artists.mapFromRow);
  }

  Selectable<Artist> filterArtistsDownloaded(
      FilterArtistsDownloaded$predicate predicate,
      FilterArtistsDownloaded$order order,
      FilterArtistsDownloaded$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate = $write(
        predicate(this.artists, this.albums, this.songs),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.artists, this.albums, this.songs) ??
            const OrderBy.nothing(),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit = $write(limit(this.artists, this.albums, this.songs),
        hasMultipleTables: true, startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT artists.*, COUNT(DISTINCT CASE WHEN songs.download_file_path IS NOT NULL THEN songs.album_id ELSE NULL END) AS album_count FROM artists LEFT JOIN albums ON artists.source_id = albums.source_id AND artists.id = albums.artist_id LEFT JOIN songs ON albums.source_id = songs.source_id AND albums.id = songs.album_id WHERE ${generatedpredicate.sql} GROUP BY artists.source_id, artists.id HAVING SUM(CASE WHEN songs.download_file_path IS NOT NULL THEN 1 ELSE 0 END) > 0 ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          songs,
          artists,
          albums,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).map((QueryRow row) => Artist(
          sourceId: row.read<int>('source_id'),
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          albumCount: row.read<int>('album_count'),
          starred: row.readNullable<DateTime>('starred'),
        ));
  }

  Selectable<Playlist> filterPlaylists(FilterPlaylists$predicate predicate,
      FilterPlaylists$order order, FilterPlaylists$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate =
        $write(predicate(this.playlists), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.playlists) ?? const OrderBy.nothing(),
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit =
        $write(limit(this.playlists), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT playlists.* FROM playlists WHERE ${generatedpredicate.sql} ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          playlists,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(playlists.mapFromRow);
  }

  Selectable<Playlist> filterPlaylistsDownloaded(
      FilterPlaylistsDownloaded$predicate predicate,
      FilterPlaylistsDownloaded$order order,
      FilterPlaylistsDownloaded$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate = $write(
        predicate(this.playlists, this.playlistSongs, this.songs),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.playlists, this.playlistSongs, this.songs) ??
            const OrderBy.nothing(),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit = $write(
        limit(this.playlists, this.playlistSongs, this.songs),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT playlists.*, COUNT(CASE WHEN songs.download_file_path IS NOT NULL THEN songs.id ELSE NULL END) AS song_count FROM playlists LEFT JOIN playlist_songs ON playlist_songs.source_id = playlists.source_id AND playlist_songs.playlist_id = playlists.id LEFT JOIN songs ON playlist_songs.source_id = songs.source_id AND playlist_songs.song_id = songs.id WHERE ${generatedpredicate.sql} GROUP BY playlists.source_id, playlists.id HAVING SUM(CASE WHEN songs.download_file_path IS NOT NULL THEN 1 ELSE 0 END) > 0 ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          songs,
          playlists,
          playlistSongs,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).map((QueryRow row) => Playlist(
          sourceId: row.read<int>('source_id'),
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          comment: row.readNullable<String>('comment'),
          coverArt: row.readNullable<String>('cover_art'),
          songCount: row.read<int>('song_count'),
          created: row.read<DateTime>('created'),
        ));
  }

  Selectable<Song> filterSongs(FilterSongs$predicate predicate,
      FilterSongs$order order, FilterSongs$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate =
        $write(predicate(this.songs), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.songs) ?? const OrderBy.nothing(),
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit =
        $write(limit(this.songs), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT songs.* FROM songs WHERE ${generatedpredicate.sql} ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          songs,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Song> filterSongsDownloaded(
      FilterSongsDownloaded$predicate predicate,
      FilterSongsDownloaded$order order,
      FilterSongsDownloaded$limit limit) {
    var $arrayStartIndex = 1;
    final generatedpredicate =
        $write(predicate(this.songs), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorder = $write(
        order?.call(this.songs) ?? const OrderBy.nothing(),
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorder.amountOfVariables;
    final generatedlimit =
        $write(limit(this.songs), startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT songs.* FROM songs WHERE ${generatedpredicate.sql} AND songs.download_file_path IS NOT NULL ${generatedorder.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorder.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          songs,
          ...generatedpredicate.watchedTables,
          ...generatedorder.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<bool> playlistIsDownloaded(int sourceId, String id) {
    return customSelect(
        'SELECT COUNT(*) = 0 AS _c0 FROM playlists JOIN playlist_songs ON playlist_songs.source_id = playlists.source_id AND playlist_songs.playlist_id = playlists.id JOIN songs ON songs.source_id = playlist_songs.source_id AND songs.id = playlist_songs.song_id WHERE playlists.source_id = ?1 AND playlists.id = ?2 AND songs.download_file_path IS NULL',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          playlists,
          playlistSongs,
          songs,
        }).map((QueryRow row) => row.read<bool>('_c0'));
  }

  Selectable<bool> playlistHasDownloadsInProgress(int sourceId, String id) {
    return customSelect(
        'SELECT COUNT(*) > 0 AS _c0 FROM playlists JOIN playlist_songs ON playlist_songs.source_id = playlists.source_id AND playlist_songs.playlist_id = playlists.id JOIN songs ON songs.source_id = playlist_songs.source_id AND songs.id = playlist_songs.song_id WHERE playlists.source_id = ?1 AND playlists.id = ?2 AND songs.download_task_id IS NOT NULL',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(id)
        ],
        readsFrom: {
          playlists,
          playlistSongs,
          songs,
        }).map((QueryRow row) => row.read<bool>('_c0'));
  }

  Selectable<Song> songsInIds(int sourceId, List<String> ids) {
    var $arrayStartIndex = 2;
    final expandedids = $expandVar($arrayStartIndex, ids.length);
    $arrayStartIndex += ids.length;
    return customSelect(
        'SELECT * FROM songs WHERE source_id = ?1 AND id IN ($expandedids)',
        variables: [
          Variable<int>(sourceId),
          for (var $ in ids) Variable<String>($)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Song> songsInRowIds(List<int> rowIds) {
    var $arrayStartIndex = 1;
    final expandedrowIds = $expandVar($arrayStartIndex, rowIds.length);
    $arrayStartIndex += rowIds.length;
    return customSelect(
        'SELECT * FROM songs WHERE "ROWID" IN ($expandedrowIds)',
        variables: [
          for (var $ in rowIds) Variable<int>($)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Album> albumsInRowIds(List<int> rowIds) {
    var $arrayStartIndex = 1;
    final expandedrowIds = $expandVar($arrayStartIndex, rowIds.length);
    $arrayStartIndex += rowIds.length;
    return customSelect(
        'SELECT * FROM albums WHERE "ROWID" IN ($expandedrowIds)',
        variables: [
          for (var $ in rowIds) Variable<int>($)
        ],
        readsFrom: {
          albums,
        }).asyncMap(albums.mapFromRow);
  }

  Selectable<Artist> artistsInRowIds(List<int> rowIds) {
    var $arrayStartIndex = 1;
    final expandedrowIds = $expandVar($arrayStartIndex, rowIds.length);
    $arrayStartIndex += rowIds.length;
    return customSelect(
        'SELECT * FROM artists WHERE "ROWID" IN ($expandedrowIds)',
        variables: [
          for (var $ in rowIds) Variable<int>($)
        ],
        readsFrom: {
          artists,
        }).asyncMap(artists.mapFromRow);
  }

  Selectable<Playlist> playlistsInRowIds(List<int> rowIds) {
    var $arrayStartIndex = 1;
    final expandedrowIds = $expandVar($arrayStartIndex, rowIds.length);
    $arrayStartIndex += rowIds.length;
    return customSelect(
        'SELECT * FROM playlists WHERE "ROWID" IN ($expandedrowIds)',
        variables: [
          for (var $ in rowIds) Variable<int>($)
        ],
        readsFrom: {
          playlists,
        }).asyncMap(playlists.mapFromRow);
  }

  Selectable<int> currentTrackIndex() {
    return customSelect(
        'SELECT queue."index" FROM queue WHERE queue.current_track = 1',
        variables: [],
        readsFrom: {
          queue,
        }).map((QueryRow row) => row.read<int>('index'));
  }

  Selectable<int> queueLength() {
    return customSelect('SELECT COUNT(*) AS _c0 FROM queue',
        variables: [],
        readsFrom: {
          queue,
        }).map((QueryRow row) => row.read<int>('_c0'));
  }

  Selectable<QueueData> queueInIndicies(List<int> indicies) {
    var $arrayStartIndex = 1;
    final expandedindicies = $expandVar($arrayStartIndex, indicies.length);
    $arrayStartIndex += indicies.length;
    return customSelect(
        'SELECT * FROM queue WHERE queue."index" IN ($expandedindicies)',
        variables: [
          for (var $ in indicies) Variable<int>($)
        ],
        readsFrom: {
          queue,
        }).asyncMap(queue.mapFromRow);
  }

  Selectable<QueueData> allQueueItems() {
    return customSelect('SELECT * FROM queue ORDER BY queue."index" ASC',
        variables: [],
        readsFrom: {
          queue,
        }).asyncMap(queue.mapFromRow);
  }

  Selectable<AppSettings> getAppSettings() {
    return customSelect('SELECT * FROM app_settings WHERE id = 1',
        variables: [],
        readsFrom: {
          appSettings,
        }).asyncMap(appSettings.mapFromRow);
  }

  Selectable<Song> songsWithRating(int sourceId, UserRating rating) {
    return customSelect(
        'SELECT * FROM songs WHERE source_id = ?1 AND user_rating = ?2',
        variables: [
          Variable<int>(sourceId),
          Variable<String>(Songs.$converteruserRating.toSql(rating))
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Song> likedSongs(int sourceId) {
    return customSelect(
        'SELECT * FROM songs WHERE source_id = ?1 AND user_rating = \'thumbsUp\' ORDER BY updated DESC',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Song> dislikedSongs(int sourceId) {
    return customSelect(
        'SELECT * FROM songs WHERE source_id = ?1 AND user_rating = \'thumbsDown\' ORDER BY updated DESC',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<RatingStatsResult> ratingStats(int sourceId) {
    return customSelect(
        'SELECT user_rating, COUNT(*) AS count FROM songs WHERE source_id = ?1 GROUP BY user_rating',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          songs,
        }).map((QueryRow row) => RatingStatsResult(
          userRating: Songs.$converteruserRating
              .fromSql(row.read<String>('user_rating')),
          count: row.read<int>('count'),
        ));
  }

  Selectable<DiscoverySession> discoverySessionsBySource(
      int sourceId, int limit, int offset) {
    return customSelect(
        'SELECT * FROM discovery_sessions WHERE source_id = ?1 ORDER BY created_at DESC LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          discoverySessions,
        }).asyncMap(discoverySessions.mapFromRow);
  }

  Selectable<DiscoveryInteraction> discoveryInteractionsBySession(
      int sessionId) {
    return customSelect(
        'SELECT * FROM discovery_interactions WHERE session_id = ?1 ORDER BY position_in_playlist ASC',
        variables: [
          Variable<int>(sessionId)
        ],
        readsFrom: {
          discoveryInteractions,
        }).asyncMap(discoveryInteractions.mapFromRow);
  }

  Selectable<DiscoverySession> discoveryRecentSessions(
      int sourceId, int sinceTimestamp) {
    return customSelect(
        'SELECT * FROM discovery_sessions WHERE source_id = ?1 AND created_at > ?2 ORDER BY created_at DESC',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(sinceTimestamp)
        ],
        readsFrom: {
          discoverySessions,
        }).asyncMap(discoverySessions.mapFromRow);
  }

  Selectable<DiscoveryPopularSongsResult> discoveryPopularSongs(
      int sourceId, int sinceTimestamp, int limit) {
    return customSelect(
        'SELECT di.song_id, COUNT(*) AS play_count, AVG(CASE WHEN di.play_duration_ms IS NOT NULL AND di.song_duration_ms > 0 THEN CAST(di.play_duration_ms AS REAL) / di.song_duration_ms ELSE 0 END) AS avg_completion_rate FROM discovery_interactions AS di JOIN discovery_sessions AS ds ON di.session_id = ds.id WHERE ds.source_id = ?1 AND di.interaction_type IN (\'played\', \'completed\') AND di.timestamp > ?2 GROUP BY di.song_id ORDER BY play_count DESC LIMIT ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(sinceTimestamp),
          Variable<int>(limit)
        ],
        readsFrom: {
          discoveryInteractions,
          discoverySessions,
        }).map((QueryRow row) => DiscoveryPopularSongsResult(
          songId: row.read<String>('song_id'),
          playCount: row.read<int>('play_count'),
          avgCompletionRate: row.read<double>('avg_completion_rate'),
        ));
  }

  Selectable<DiscoverySkippedSongsResult> discoverySkippedSongs(
      int sourceId, int sinceTimestamp, int limit) {
    return customSelect(
        'SELECT di.song_id, COUNT(*) AS skip_count FROM discovery_interactions AS di JOIN discovery_sessions AS ds ON di.session_id = ds.id WHERE ds.source_id = ?1 AND di.interaction_type = \'skipped\' AND di.timestamp > ?2 GROUP BY di.song_id ORDER BY skip_count DESC LIMIT ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(sinceTimestamp),
          Variable<int>(limit)
        ],
        readsFrom: {
          discoveryInteractions,
          discoverySessions,
        }).map((QueryRow row) => DiscoverySkippedSongsResult(
          songId: row.read<String>('song_id'),
          skipCount: row.read<int>('skip_count'),
        ));
  }

  Future<int> discoveryUpdateStationName(String? stationName, int sessionId) {
    return customUpdate(
      'UPDATE discovery_sessions SET station_name = ?1 WHERE id = ?2',
      variables: [Variable<String>(stationName), Variable<int>(sessionId)],
      updates: {discoverySessions},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> discoveryUpdateLastPlayed(int? timestamp, int sessionId) {
    return customUpdate(
      'UPDATE discovery_sessions SET last_played_at = ?1 WHERE id = ?2',
      variables: [Variable<int>(timestamp), Variable<int>(sessionId)],
      updates: {discoverySessions},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> discoveryIncrementPlayCount(int sessionId) {
    return customUpdate(
      'UPDATE discovery_sessions SET play_count = play_count + 1 WHERE id = ?1',
      variables: [Variable<int>(sessionId)],
      updates: {discoverySessions},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> discoveryToggleFavorite(int isFavorite, int sessionId) {
    return customUpdate(
      'UPDATE discovery_sessions SET is_favorite = ?1 WHERE id = ?2',
      variables: [Variable<int>(isFavorite), Variable<int>(sessionId)],
      updates: {discoverySessions},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<DiscoverySession> discoveryFavoriteStations(int sourceId) {
    return customSelect(
        'SELECT * FROM discovery_sessions WHERE source_id = ?1 AND is_favorite = 1 ORDER BY last_played_at DESC NULLS LAST, created_at DESC',
        variables: [
          Variable<int>(sourceId)
        ],
        readsFrom: {
          discoverySessions,
        }).asyncMap(discoverySessions.mapFromRow);
  }

  Selectable<DiscoverySession> discoveryStationsSortedByRecent(
      int sourceId, int limit, int offset) {
    return customSelect(
        'SELECT * FROM discovery_sessions WHERE source_id = ?1 ORDER BY last_played_at DESC NULLS LAST, created_at DESC LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          discoverySessions,
        }).asyncMap(discoverySessions.mapFromRow);
  }

  Selectable<DiscoverySession> discoveryStationsSortedByPlayCount(
      int sourceId, int limit, int offset) {
    return customSelect(
        'SELECT * FROM discovery_sessions WHERE source_id = ?1 ORDER BY play_count DESC, last_played_at DESC NULLS LAST LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          discoverySessions,
        }).asyncMap(discoverySessions.mapFromRow);
  }

  Selectable<String> discoveryThumbsUpSongsByStation(int sessionId) {
    return customSelect(
        'SELECT DISTINCT di.song_id FROM discovery_interactions AS di WHERE di.session_id = ?1 AND di.interaction_type = \'thumbs_up\'',
        variables: [
          Variable<int>(sessionId)
        ],
        readsFrom: {
          discoveryInteractions,
        }).map((QueryRow row) => row.read<String>('song_id'));
  }

  Selectable<String> discoveryThumbsDownSongsByStation(int sessionId) {
    return customSelect(
        'SELECT DISTINCT di.song_id FROM discovery_interactions AS di WHERE di.session_id = ?1 AND di.interaction_type = \'thumbs_down\'',
        variables: [
          Variable<int>(sessionId)
        ],
        readsFrom: {
          discoveryInteractions,
        }).map((QueryRow row) => row.read<String>('song_id'));
  }

  Selectable<DiscoverySkippedSongsByStationResult>
      discoverySkippedSongsByStation(int sessionId) {
    return customSelect(
        'SELECT di.song_id, COUNT(*) AS skip_count FROM discovery_interactions AS di WHERE di.session_id = ?1 AND di.interaction_type = \'skipped\' GROUP BY di.song_id HAVING skip_count >= 2 ORDER BY skip_count DESC',
        variables: [
          Variable<int>(sessionId)
        ],
        readsFrom: {
          discoveryInteractions,
        }).map((QueryRow row) => DiscoverySkippedSongsByStationResult(
          songId: row.read<String>('song_id'),
          skipCount: row.read<int>('skip_count'),
        ));
  }

  Selectable<String> discoveryCompletedSongsByStation(int sessionId) {
    return customSelect(
        'SELECT DISTINCT di.song_id FROM discovery_interactions AS di WHERE di.session_id = ?1 AND di.interaction_type = \'completed\'',
        variables: [
          Variable<int>(sessionId)
        ],
        readsFrom: {
          discoveryInteractions,
        }).map((QueryRow row) => row.read<String>('song_id'));
  }

  Selectable<Song> mostLovedSongs(int sourceId, int limit, int offset) {
    return customSelect(
        'SELECT * FROM songs WHERE source_id = ?1 AND thumbs_up_count > 0 ORDER BY thumbs_up_count DESC, title ASC LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  Selectable<Song> mostDislikedSongs(int sourceId, int limit, int offset) {
    return customSelect(
        'SELECT * FROM songs WHERE source_id = ?1 AND thumbs_down_count > 0 ORDER BY thumbs_down_count DESC, title ASC LIMIT ?2 OFFSET ?3',
        variables: [
          Variable<int>(sourceId),
          Variable<int>(limit),
          Variable<int>(offset)
        ],
        readsFrom: {
          songs,
        }).asyncMap(songs.mapFromRow);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        queue,
        queueIndex,
        queueCurrentTrack,
        lastAudioState,
        lastBottomNavState,
        lastLibraryState,
        appSettings,
        sources,
        subsonicSources,
        artists,
        artistsSourceId,
        artistsFts,
        artistsAi,
        artistsAd,
        artistsAu,
        albums,
        albumsSourceId,
        albumsSourceIdArtistIdIdx,
        albumsFts,
        albumsAi,
        albumsAd,
        albumsAu,
        playlists,
        playlistsSourceId,
        playlistSongs,
        playlistSongsSourceIdPlaylistIdIdx,
        playlistSongsSourceIdSongIdIdx,
        playlistsFts,
        playlistsAi,
        playlistsAd,
        playlistsAu,
        songs,
        songsSourceIdAlbumIdIdx,
        songsSourceIdArtistIdIdx,
        songsDownloadTaskIdIdx,
        songsFts,
        songsAi,
        songsAd,
        songsAu,
        discoverySessions,
        discoverySessionsSourceId,
        discoverySessionsCreatedAt,
        discoverySessionsLastPlayedAt,
        discoverySessionsIsFavorite,
        discoveryInteractions,
        discoveryInteractionsSessionId,
        discoveryInteractionsSongId,
        discoveryInteractionsInteractionType
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subsonic_sources', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('artists', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('artists',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('artists_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('artists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('artists_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('artists',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('artists_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('albums', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('albums',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('albums_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('albums',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('albums_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('albums',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('albums_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('playlists', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('playlist_songs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('playlists_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('playlists_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('playlists_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('songs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('songs',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('songs_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('songs',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('songs_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('songs',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('songs_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sources',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('discovery_sessions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('discovery_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('discovery_interactions', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $QueueInsertCompanionBuilder = QueueCompanion Function({
  Value<int> index,
  required int sourceId,
  required String id,
  required QueueContextType context,
  Value<String?> contextId,
  Value<bool?> currentTrack,
});
typedef $QueueUpdateCompanionBuilder = QueueCompanion Function({
  Value<int> index,
  Value<int> sourceId,
  Value<String> id,
  Value<QueueContextType> context,
  Value<String?> contextId,
  Value<bool?> currentTrack,
});

class $QueueTableManager extends RootTableManager<
    _$SubtracksDatabase,
    Queue,
    QueueData,
    $QueueFilterComposer,
    $QueueOrderingComposer,
    $QueueProcessedTableManager,
    $QueueInsertCompanionBuilder,
    $QueueUpdateCompanionBuilder> {
  $QueueTableManager(_$SubtracksDatabase db, Queue table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $QueueFilterComposer(ComposerState(db, table)),
          orderingComposer: $QueueOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $QueueProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> index = const Value.absent(),
            Value<int> sourceId = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<QueueContextType> context = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            Value<bool?> currentTrack = const Value.absent(),
          }) =>
              QueueCompanion(
            index: index,
            sourceId: sourceId,
            id: id,
            context: context,
            contextId: contextId,
            currentTrack: currentTrack,
          ),
          getInsertCompanionBuilder: ({
            Value<int> index = const Value.absent(),
            required int sourceId,
            required String id,
            required QueueContextType context,
            Value<String?> contextId = const Value.absent(),
            Value<bool?> currentTrack = const Value.absent(),
          }) =>
              QueueCompanion.insert(
            index: index,
            sourceId: sourceId,
            id: id,
            context: context,
            contextId: contextId,
            currentTrack: currentTrack,
          ),
        ));
}

class $QueueProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    Queue,
    QueueData,
    $QueueFilterComposer,
    $QueueOrderingComposer,
    $QueueProcessedTableManager,
    $QueueInsertCompanionBuilder,
    $QueueUpdateCompanionBuilder> {
  $QueueProcessedTableManager(super.$state);
}

class $QueueFilterComposer extends FilterComposer<_$SubtracksDatabase, Queue> {
  $QueueFilterComposer(super.$state);
  ColumnFilters<int> get index => $state.composableBuilder(
      column: $state.table.index,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<QueueContextType, QueueContextType, String>
      get context => $state.composableBuilder(
          column: $state.table.context,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get contextId => $state.composableBuilder(
      column: $state.table.contextId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get currentTrack => $state.composableBuilder(
      column: $state.table.currentTrack,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $QueueOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, Queue> {
  $QueueOrderingComposer(super.$state);
  ColumnOrderings<int> get index => $state.composableBuilder(
      column: $state.table.index,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get context => $state.composableBuilder(
      column: $state.table.context,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contextId => $state.composableBuilder(
      column: $state.table.contextId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get currentTrack => $state.composableBuilder(
      column: $state.table.currentTrack,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $LastAudioStateInsertCompanionBuilder = LastAudioStateCompanion
    Function({
  Value<int> id,
  required QueueMode queueMode,
  Value<IList<int>?> shuffleIndicies,
  required RepeatMode repeat,
});
typedef $LastAudioStateUpdateCompanionBuilder = LastAudioStateCompanion
    Function({
  Value<int> id,
  Value<QueueMode> queueMode,
  Value<IList<int>?> shuffleIndicies,
  Value<RepeatMode> repeat,
});

class $LastAudioStateTableManager extends RootTableManager<
    _$SubtracksDatabase,
    LastAudioState,
    LastAudioStateData,
    $LastAudioStateFilterComposer,
    $LastAudioStateOrderingComposer,
    $LastAudioStateProcessedTableManager,
    $LastAudioStateInsertCompanionBuilder,
    $LastAudioStateUpdateCompanionBuilder> {
  $LastAudioStateTableManager(_$SubtracksDatabase db, LastAudioState table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $LastAudioStateFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $LastAudioStateOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $LastAudioStateProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<QueueMode> queueMode = const Value.absent(),
            Value<IList<int>?> shuffleIndicies = const Value.absent(),
            Value<RepeatMode> repeat = const Value.absent(),
          }) =>
              LastAudioStateCompanion(
            id: id,
            queueMode: queueMode,
            shuffleIndicies: shuffleIndicies,
            repeat: repeat,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required QueueMode queueMode,
            Value<IList<int>?> shuffleIndicies = const Value.absent(),
            required RepeatMode repeat,
          }) =>
              LastAudioStateCompanion.insert(
            id: id,
            queueMode: queueMode,
            shuffleIndicies: shuffleIndicies,
            repeat: repeat,
          ),
        ));
}

class $LastAudioStateProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    LastAudioState,
    LastAudioStateData,
    $LastAudioStateFilterComposer,
    $LastAudioStateOrderingComposer,
    $LastAudioStateProcessedTableManager,
    $LastAudioStateInsertCompanionBuilder,
    $LastAudioStateUpdateCompanionBuilder> {
  $LastAudioStateProcessedTableManager(super.$state);
}

class $LastAudioStateFilterComposer
    extends FilterComposer<_$SubtracksDatabase, LastAudioState> {
  $LastAudioStateFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<QueueMode, QueueMode, int> get queueMode =>
      $state.composableBuilder(
          column: $state.table.queueMode,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<IList<int>?, IList<int>, String>
      get shuffleIndicies => $state.composableBuilder(
          column: $state.table.shuffleIndicies,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<RepeatMode, RepeatMode, int> get repeat =>
      $state.composableBuilder(
          column: $state.table.repeat,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $LastAudioStateOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, LastAudioState> {
  $LastAudioStateOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get queueMode => $state.composableBuilder(
      column: $state.table.queueMode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shuffleIndicies => $state.composableBuilder(
      column: $state.table.shuffleIndicies,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get repeat => $state.composableBuilder(
      column: $state.table.repeat,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $LastBottomNavStateInsertCompanionBuilder = LastBottomNavStateCompanion
    Function({
  Value<int> id,
  required String tab,
});
typedef $LastBottomNavStateUpdateCompanionBuilder = LastBottomNavStateCompanion
    Function({
  Value<int> id,
  Value<String> tab,
});

class $LastBottomNavStateTableManager extends RootTableManager<
    _$SubtracksDatabase,
    LastBottomNavState,
    LastBottomNavStateData,
    $LastBottomNavStateFilterComposer,
    $LastBottomNavStateOrderingComposer,
    $LastBottomNavStateProcessedTableManager,
    $LastBottomNavStateInsertCompanionBuilder,
    $LastBottomNavStateUpdateCompanionBuilder> {
  $LastBottomNavStateTableManager(
      _$SubtracksDatabase db, LastBottomNavState table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $LastBottomNavStateFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $LastBottomNavStateOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $LastBottomNavStateProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> tab = const Value.absent(),
          }) =>
              LastBottomNavStateCompanion(
            id: id,
            tab: tab,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String tab,
          }) =>
              LastBottomNavStateCompanion.insert(
            id: id,
            tab: tab,
          ),
        ));
}

class $LastBottomNavStateProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    LastBottomNavState,
    LastBottomNavStateData,
    $LastBottomNavStateFilterComposer,
    $LastBottomNavStateOrderingComposer,
    $LastBottomNavStateProcessedTableManager,
    $LastBottomNavStateInsertCompanionBuilder,
    $LastBottomNavStateUpdateCompanionBuilder> {
  $LastBottomNavStateProcessedTableManager(super.$state);
}

class $LastBottomNavStateFilterComposer
    extends FilterComposer<_$SubtracksDatabase, LastBottomNavState> {
  $LastBottomNavStateFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tab => $state.composableBuilder(
      column: $state.table.tab,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $LastBottomNavStateOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, LastBottomNavState> {
  $LastBottomNavStateOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tab => $state.composableBuilder(
      column: $state.table.tab,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $LastLibraryStateInsertCompanionBuilder = LastLibraryStateCompanion
    Function({
  Value<int> id,
  required String tab,
  required ListQuery albumsList,
  required ListQuery artistsList,
  required ListQuery playlistsList,
  required ListQuery songsList,
});
typedef $LastLibraryStateUpdateCompanionBuilder = LastLibraryStateCompanion
    Function({
  Value<int> id,
  Value<String> tab,
  Value<ListQuery> albumsList,
  Value<ListQuery> artistsList,
  Value<ListQuery> playlistsList,
  Value<ListQuery> songsList,
});

class $LastLibraryStateTableManager extends RootTableManager<
    _$SubtracksDatabase,
    LastLibraryState,
    LastLibraryStateData,
    $LastLibraryStateFilterComposer,
    $LastLibraryStateOrderingComposer,
    $LastLibraryStateProcessedTableManager,
    $LastLibraryStateInsertCompanionBuilder,
    $LastLibraryStateUpdateCompanionBuilder> {
  $LastLibraryStateTableManager(_$SubtracksDatabase db, LastLibraryState table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $LastLibraryStateFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $LastLibraryStateOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $LastLibraryStateProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> tab = const Value.absent(),
            Value<ListQuery> albumsList = const Value.absent(),
            Value<ListQuery> artistsList = const Value.absent(),
            Value<ListQuery> playlistsList = const Value.absent(),
            Value<ListQuery> songsList = const Value.absent(),
          }) =>
              LastLibraryStateCompanion(
            id: id,
            tab: tab,
            albumsList: albumsList,
            artistsList: artistsList,
            playlistsList: playlistsList,
            songsList: songsList,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String tab,
            required ListQuery albumsList,
            required ListQuery artistsList,
            required ListQuery playlistsList,
            required ListQuery songsList,
          }) =>
              LastLibraryStateCompanion.insert(
            id: id,
            tab: tab,
            albumsList: albumsList,
            artistsList: artistsList,
            playlistsList: playlistsList,
            songsList: songsList,
          ),
        ));
}

class $LastLibraryStateProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    LastLibraryState,
    LastLibraryStateData,
    $LastLibraryStateFilterComposer,
    $LastLibraryStateOrderingComposer,
    $LastLibraryStateProcessedTableManager,
    $LastLibraryStateInsertCompanionBuilder,
    $LastLibraryStateUpdateCompanionBuilder> {
  $LastLibraryStateProcessedTableManager(super.$state);
}

class $LastLibraryStateFilterComposer
    extends FilterComposer<_$SubtracksDatabase, LastLibraryState> {
  $LastLibraryStateFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tab => $state.composableBuilder(
      column: $state.table.tab,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<ListQuery, ListQuery, String> get albumsList =>
      $state.composableBuilder(
          column: $state.table.albumsList,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<ListQuery, ListQuery, String>
      get artistsList => $state.composableBuilder(
          column: $state.table.artistsList,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<ListQuery, ListQuery, String>
      get playlistsList => $state.composableBuilder(
          column: $state.table.playlistsList,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<ListQuery, ListQuery, String> get songsList =>
      $state.composableBuilder(
          column: $state.table.songsList,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $LastLibraryStateOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, LastLibraryState> {
  $LastLibraryStateOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tab => $state.composableBuilder(
      column: $state.table.tab,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get albumsList => $state.composableBuilder(
      column: $state.table.albumsList,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get artistsList => $state.composableBuilder(
      column: $state.table.artistsList,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get playlistsList => $state.composableBuilder(
      column: $state.table.playlistsList,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get songsList => $state.composableBuilder(
      column: $state.table.songsList,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $SourcesInsertCompanionBuilder = SourcesCompanion Function({
  Value<int> id,
  required String name,
  required Uri address,
  Value<bool?> isActive,
  Value<DateTime> createdAt,
});
typedef $SourcesUpdateCompanionBuilder = SourcesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<Uri> address,
  Value<bool?> isActive,
  Value<DateTime> createdAt,
});

class $SourcesTableManager extends RootTableManager<
    _$SubtracksDatabase,
    Sources,
    Source,
    $SourcesFilterComposer,
    $SourcesOrderingComposer,
    $SourcesProcessedTableManager,
    $SourcesInsertCompanionBuilder,
    $SourcesUpdateCompanionBuilder> {
  $SourcesTableManager(_$SubtracksDatabase db, Sources table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $SourcesFilterComposer(ComposerState(db, table)),
          orderingComposer: $SourcesOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $SourcesProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<Uri> address = const Value.absent(),
            Value<bool?> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SourcesCompanion(
            id: id,
            name: name,
            address: address,
            isActive: isActive,
            createdAt: createdAt,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String name,
            required Uri address,
            Value<bool?> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SourcesCompanion.insert(
            id: id,
            name: name,
            address: address,
            isActive: isActive,
            createdAt: createdAt,
          ),
        ));
}

class $SourcesProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    Sources,
    Source,
    $SourcesFilterComposer,
    $SourcesOrderingComposer,
    $SourcesProcessedTableManager,
    $SourcesInsertCompanionBuilder,
    $SourcesUpdateCompanionBuilder> {
  $SourcesProcessedTableManager(super.$state);
}

class $SourcesFilterComposer
    extends FilterComposer<_$SubtracksDatabase, Sources> {
  $SourcesFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Uri, Uri, String> get address =>
      $state.composableBuilder(
          column: $state.table.address,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $SourcesOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, Sources> {
  $SourcesOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get address => $state.composableBuilder(
      column: $state.table.address,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $SubsonicSourcesInsertCompanionBuilder = SubsonicSourcesCompanion
    Function({
  Value<int> sourceId,
  required IList<SubsonicFeature> features,
  required String username,
  required String password,
  Value<bool> useTokenAuth,
});
typedef $SubsonicSourcesUpdateCompanionBuilder = SubsonicSourcesCompanion
    Function({
  Value<int> sourceId,
  Value<IList<SubsonicFeature>> features,
  Value<String> username,
  Value<String> password,
  Value<bool> useTokenAuth,
});

class $SubsonicSourcesTableManager extends RootTableManager<
    _$SubtracksDatabase,
    SubsonicSources,
    SubsonicSource,
    $SubsonicSourcesFilterComposer,
    $SubsonicSourcesOrderingComposer,
    $SubsonicSourcesProcessedTableManager,
    $SubsonicSourcesInsertCompanionBuilder,
    $SubsonicSourcesUpdateCompanionBuilder> {
  $SubsonicSourcesTableManager(_$SubtracksDatabase db, SubsonicSources table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $SubsonicSourcesFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $SubsonicSourcesOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $SubsonicSourcesProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> sourceId = const Value.absent(),
            Value<IList<SubsonicFeature>> features = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<bool> useTokenAuth = const Value.absent(),
          }) =>
              SubsonicSourcesCompanion(
            sourceId: sourceId,
            features: features,
            username: username,
            password: password,
            useTokenAuth: useTokenAuth,
          ),
          getInsertCompanionBuilder: ({
            Value<int> sourceId = const Value.absent(),
            required IList<SubsonicFeature> features,
            required String username,
            required String password,
            Value<bool> useTokenAuth = const Value.absent(),
          }) =>
              SubsonicSourcesCompanion.insert(
            sourceId: sourceId,
            features: features,
            username: username,
            password: password,
            useTokenAuth: useTokenAuth,
          ),
        ));
}

class $SubsonicSourcesProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    SubsonicSources,
    SubsonicSource,
    $SubsonicSourcesFilterComposer,
    $SubsonicSourcesOrderingComposer,
    $SubsonicSourcesProcessedTableManager,
    $SubsonicSourcesInsertCompanionBuilder,
    $SubsonicSourcesUpdateCompanionBuilder> {
  $SubsonicSourcesProcessedTableManager(super.$state);
}

class $SubsonicSourcesFilterComposer
    extends FilterComposer<_$SubtracksDatabase, SubsonicSources> {
  $SubsonicSourcesFilterComposer(super.$state);
  ColumnFilters<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<IList<SubsonicFeature>, IList<SubsonicFeature>,
          String>
      get features => $state.composableBuilder(
          column: $state.table.features,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get username => $state.composableBuilder(
      column: $state.table.username,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get password => $state.composableBuilder(
      column: $state.table.password,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get useTokenAuth => $state.composableBuilder(
      column: $state.table.useTokenAuth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $SubsonicSourcesOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, SubsonicSources> {
  $SubsonicSourcesOrderingComposer(super.$state);
  ColumnOrderings<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get features => $state.composableBuilder(
      column: $state.table.features,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get username => $state.composableBuilder(
      column: $state.table.username,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get password => $state.composableBuilder(
      column: $state.table.password,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get useTokenAuth => $state.composableBuilder(
      column: $state.table.useTokenAuth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $ArtistsFtsInsertCompanionBuilder = ArtistsFtsCompanion Function({
  required String sourceId,
  required String name,
  Value<int> rowid,
});
typedef $ArtistsFtsUpdateCompanionBuilder = ArtistsFtsCompanion Function({
  Value<String> sourceId,
  Value<String> name,
  Value<int> rowid,
});

class $ArtistsFtsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    ArtistsFts,
    ArtistsFt,
    $ArtistsFtsFilterComposer,
    $ArtistsFtsOrderingComposer,
    $ArtistsFtsProcessedTableManager,
    $ArtistsFtsInsertCompanionBuilder,
    $ArtistsFtsUpdateCompanionBuilder> {
  $ArtistsFtsTableManager(_$SubtracksDatabase db, ArtistsFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $ArtistsFtsFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $ArtistsFtsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $ArtistsFtsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> sourceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ArtistsFtsCompanion(
            sourceId: sourceId,
            name: name,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String sourceId,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              ArtistsFtsCompanion.insert(
            sourceId: sourceId,
            name: name,
            rowid: rowid,
          ),
        ));
}

class $ArtistsFtsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    ArtistsFts,
    ArtistsFt,
    $ArtistsFtsFilterComposer,
    $ArtistsFtsOrderingComposer,
    $ArtistsFtsProcessedTableManager,
    $ArtistsFtsInsertCompanionBuilder,
    $ArtistsFtsUpdateCompanionBuilder> {
  $ArtistsFtsProcessedTableManager(super.$state);
}

class $ArtistsFtsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, ArtistsFts> {
  $ArtistsFtsFilterComposer(super.$state);
  ColumnFilters<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $ArtistsFtsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, ArtistsFts> {
  $ArtistsFtsOrderingComposer(super.$state);
  ColumnOrderings<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $AlbumsFtsInsertCompanionBuilder = AlbumsFtsCompanion Function({
  required String sourceId,
  required String name,
  Value<int> rowid,
});
typedef $AlbumsFtsUpdateCompanionBuilder = AlbumsFtsCompanion Function({
  Value<String> sourceId,
  Value<String> name,
  Value<int> rowid,
});

class $AlbumsFtsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    AlbumsFts,
    AlbumsFt,
    $AlbumsFtsFilterComposer,
    $AlbumsFtsOrderingComposer,
    $AlbumsFtsProcessedTableManager,
    $AlbumsFtsInsertCompanionBuilder,
    $AlbumsFtsUpdateCompanionBuilder> {
  $AlbumsFtsTableManager(_$SubtracksDatabase db, AlbumsFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $AlbumsFtsFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $AlbumsFtsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $AlbumsFtsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> sourceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlbumsFtsCompanion(
            sourceId: sourceId,
            name: name,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String sourceId,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              AlbumsFtsCompanion.insert(
            sourceId: sourceId,
            name: name,
            rowid: rowid,
          ),
        ));
}

class $AlbumsFtsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    AlbumsFts,
    AlbumsFt,
    $AlbumsFtsFilterComposer,
    $AlbumsFtsOrderingComposer,
    $AlbumsFtsProcessedTableManager,
    $AlbumsFtsInsertCompanionBuilder,
    $AlbumsFtsUpdateCompanionBuilder> {
  $AlbumsFtsProcessedTableManager(super.$state);
}

class $AlbumsFtsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, AlbumsFts> {
  $AlbumsFtsFilterComposer(super.$state);
  ColumnFilters<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $AlbumsFtsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, AlbumsFts> {
  $AlbumsFtsOrderingComposer(super.$state);
  ColumnOrderings<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $PlaylistSongsInsertCompanionBuilder = PlaylistSongsCompanion Function({
  required int sourceId,
  required String playlistId,
  required String songId,
  required int position,
  Value<DateTime> updated,
  Value<int> rowid,
});
typedef $PlaylistSongsUpdateCompanionBuilder = PlaylistSongsCompanion Function({
  Value<int> sourceId,
  Value<String> playlistId,
  Value<String> songId,
  Value<int> position,
  Value<DateTime> updated,
  Value<int> rowid,
});

class $PlaylistSongsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    PlaylistSongs,
    PlaylistSong,
    $PlaylistSongsFilterComposer,
    $PlaylistSongsOrderingComposer,
    $PlaylistSongsProcessedTableManager,
    $PlaylistSongsInsertCompanionBuilder,
    $PlaylistSongsUpdateCompanionBuilder> {
  $PlaylistSongsTableManager(_$SubtracksDatabase db, PlaylistSongs table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $PlaylistSongsFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $PlaylistSongsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $PlaylistSongsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> sourceId = const Value.absent(),
            Value<String> playlistId = const Value.absent(),
            Value<String> songId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> updated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistSongsCompanion(
            sourceId: sourceId,
            playlistId: playlistId,
            songId: songId,
            position: position,
            updated: updated,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required int sourceId,
            required String playlistId,
            required String songId,
            required int position,
            Value<DateTime> updated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistSongsCompanion.insert(
            sourceId: sourceId,
            playlistId: playlistId,
            songId: songId,
            position: position,
            updated: updated,
            rowid: rowid,
          ),
        ));
}

class $PlaylistSongsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    PlaylistSongs,
    PlaylistSong,
    $PlaylistSongsFilterComposer,
    $PlaylistSongsOrderingComposer,
    $PlaylistSongsProcessedTableManager,
    $PlaylistSongsInsertCompanionBuilder,
    $PlaylistSongsUpdateCompanionBuilder> {
  $PlaylistSongsProcessedTableManager(super.$state);
}

class $PlaylistSongsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, PlaylistSongs> {
  $PlaylistSongsFilterComposer(super.$state);
  ColumnFilters<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get playlistId => $state.composableBuilder(
      column: $state.table.playlistId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get songId => $state.composableBuilder(
      column: $state.table.songId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updated => $state.composableBuilder(
      column: $state.table.updated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $PlaylistSongsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, PlaylistSongs> {
  $PlaylistSongsOrderingComposer(super.$state);
  ColumnOrderings<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get playlistId => $state.composableBuilder(
      column: $state.table.playlistId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get songId => $state.composableBuilder(
      column: $state.table.songId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updated => $state.composableBuilder(
      column: $state.table.updated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $PlaylistsFtsInsertCompanionBuilder = PlaylistsFtsCompanion Function({
  required String sourceId,
  required String name,
  Value<int> rowid,
});
typedef $PlaylistsFtsUpdateCompanionBuilder = PlaylistsFtsCompanion Function({
  Value<String> sourceId,
  Value<String> name,
  Value<int> rowid,
});

class $PlaylistsFtsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    PlaylistsFts,
    PlaylistsFt,
    $PlaylistsFtsFilterComposer,
    $PlaylistsFtsOrderingComposer,
    $PlaylistsFtsProcessedTableManager,
    $PlaylistsFtsInsertCompanionBuilder,
    $PlaylistsFtsUpdateCompanionBuilder> {
  $PlaylistsFtsTableManager(_$SubtracksDatabase db, PlaylistsFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $PlaylistsFtsFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $PlaylistsFtsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $PlaylistsFtsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> sourceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsFtsCompanion(
            sourceId: sourceId,
            name: name,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String sourceId,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsFtsCompanion.insert(
            sourceId: sourceId,
            name: name,
            rowid: rowid,
          ),
        ));
}

class $PlaylistsFtsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    PlaylistsFts,
    PlaylistsFt,
    $PlaylistsFtsFilterComposer,
    $PlaylistsFtsOrderingComposer,
    $PlaylistsFtsProcessedTableManager,
    $PlaylistsFtsInsertCompanionBuilder,
    $PlaylistsFtsUpdateCompanionBuilder> {
  $PlaylistsFtsProcessedTableManager(super.$state);
}

class $PlaylistsFtsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, PlaylistsFts> {
  $PlaylistsFtsFilterComposer(super.$state);
  ColumnFilters<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $PlaylistsFtsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, PlaylistsFts> {
  $PlaylistsFtsOrderingComposer(super.$state);
  ColumnOrderings<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $SongsFtsInsertCompanionBuilder = SongsFtsCompanion Function({
  required String sourceId,
  required String title,
  Value<int> rowid,
});
typedef $SongsFtsUpdateCompanionBuilder = SongsFtsCompanion Function({
  Value<String> sourceId,
  Value<String> title,
  Value<int> rowid,
});

class $SongsFtsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    SongsFts,
    SongsFt,
    $SongsFtsFilterComposer,
    $SongsFtsOrderingComposer,
    $SongsFtsProcessedTableManager,
    $SongsFtsInsertCompanionBuilder,
    $SongsFtsUpdateCompanionBuilder> {
  $SongsFtsTableManager(_$SubtracksDatabase db, SongsFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $SongsFtsFilterComposer(ComposerState(db, table)),
          orderingComposer: $SongsFtsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $SongsFtsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> sourceId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SongsFtsCompanion(
            sourceId: sourceId,
            title: title,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String sourceId,
            required String title,
            Value<int> rowid = const Value.absent(),
          }) =>
              SongsFtsCompanion.insert(
            sourceId: sourceId,
            title: title,
            rowid: rowid,
          ),
        ));
}

class $SongsFtsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    SongsFts,
    SongsFt,
    $SongsFtsFilterComposer,
    $SongsFtsOrderingComposer,
    $SongsFtsProcessedTableManager,
    $SongsFtsInsertCompanionBuilder,
    $SongsFtsUpdateCompanionBuilder> {
  $SongsFtsProcessedTableManager(super.$state);
}

class $SongsFtsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, SongsFts> {
  $SongsFtsFilterComposer(super.$state);
  ColumnFilters<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $SongsFtsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, SongsFts> {
  $SongsFtsOrderingComposer(super.$state);
  ColumnOrderings<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $DiscoverySessionsInsertCompanionBuilder = DiscoverySessionsCompanion
    Function({
  Value<int> id,
  required String seedSongId,
  Value<String?> seedArtist,
  Value<String?> seedGenre,
  required int sourceId,
  required String mode,
  Value<int> playlistSize,
  Value<String?> stationName,
  Value<int?> lastPlayedAt,
  Value<int> playCount,
  Value<int> isFavorite,
  Value<int> createdAt,
});
typedef $DiscoverySessionsUpdateCompanionBuilder = DiscoverySessionsCompanion
    Function({
  Value<int> id,
  Value<String> seedSongId,
  Value<String?> seedArtist,
  Value<String?> seedGenre,
  Value<int> sourceId,
  Value<String> mode,
  Value<int> playlistSize,
  Value<String?> stationName,
  Value<int?> lastPlayedAt,
  Value<int> playCount,
  Value<int> isFavorite,
  Value<int> createdAt,
});

class $DiscoverySessionsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    DiscoverySessions,
    DiscoverySession,
    $DiscoverySessionsFilterComposer,
    $DiscoverySessionsOrderingComposer,
    $DiscoverySessionsProcessedTableManager,
    $DiscoverySessionsInsertCompanionBuilder,
    $DiscoverySessionsUpdateCompanionBuilder> {
  $DiscoverySessionsTableManager(
      _$SubtracksDatabase db, DiscoverySessions table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $DiscoverySessionsFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $DiscoverySessionsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $DiscoverySessionsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> seedSongId = const Value.absent(),
            Value<String?> seedArtist = const Value.absent(),
            Value<String?> seedGenre = const Value.absent(),
            Value<int> sourceId = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<int> playlistSize = const Value.absent(),
            Value<String?> stationName = const Value.absent(),
            Value<int?> lastPlayedAt = const Value.absent(),
            Value<int> playCount = const Value.absent(),
            Value<int> isFavorite = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              DiscoverySessionsCompanion(
            id: id,
            seedSongId: seedSongId,
            seedArtist: seedArtist,
            seedGenre: seedGenre,
            sourceId: sourceId,
            mode: mode,
            playlistSize: playlistSize,
            stationName: stationName,
            lastPlayedAt: lastPlayedAt,
            playCount: playCount,
            isFavorite: isFavorite,
            createdAt: createdAt,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String seedSongId,
            Value<String?> seedArtist = const Value.absent(),
            Value<String?> seedGenre = const Value.absent(),
            required int sourceId,
            required String mode,
            Value<int> playlistSize = const Value.absent(),
            Value<String?> stationName = const Value.absent(),
            Value<int?> lastPlayedAt = const Value.absent(),
            Value<int> playCount = const Value.absent(),
            Value<int> isFavorite = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              DiscoverySessionsCompanion.insert(
            id: id,
            seedSongId: seedSongId,
            seedArtist: seedArtist,
            seedGenre: seedGenre,
            sourceId: sourceId,
            mode: mode,
            playlistSize: playlistSize,
            stationName: stationName,
            lastPlayedAt: lastPlayedAt,
            playCount: playCount,
            isFavorite: isFavorite,
            createdAt: createdAt,
          ),
        ));
}

class $DiscoverySessionsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    DiscoverySessions,
    DiscoverySession,
    $DiscoverySessionsFilterComposer,
    $DiscoverySessionsOrderingComposer,
    $DiscoverySessionsProcessedTableManager,
    $DiscoverySessionsInsertCompanionBuilder,
    $DiscoverySessionsUpdateCompanionBuilder> {
  $DiscoverySessionsProcessedTableManager(super.$state);
}

class $DiscoverySessionsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, DiscoverySessions> {
  $DiscoverySessionsFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get seedSongId => $state.composableBuilder(
      column: $state.table.seedSongId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get seedArtist => $state.composableBuilder(
      column: $state.table.seedArtist,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get seedGenre => $state.composableBuilder(
      column: $state.table.seedGenre,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mode => $state.composableBuilder(
      column: $state.table.mode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get playlistSize => $state.composableBuilder(
      column: $state.table.playlistSize,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get stationName => $state.composableBuilder(
      column: $state.table.stationName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get lastPlayedAt => $state.composableBuilder(
      column: $state.table.lastPlayedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get playCount => $state.composableBuilder(
      column: $state.table.playCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $DiscoverySessionsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, DiscoverySessions> {
  $DiscoverySessionsOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get seedSongId => $state.composableBuilder(
      column: $state.table.seedSongId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get seedArtist => $state.composableBuilder(
      column: $state.table.seedArtist,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get seedGenre => $state.composableBuilder(
      column: $state.table.seedGenre,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mode => $state.composableBuilder(
      column: $state.table.mode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get playlistSize => $state.composableBuilder(
      column: $state.table.playlistSize,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get stationName => $state.composableBuilder(
      column: $state.table.stationName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get lastPlayedAt => $state.composableBuilder(
      column: $state.table.lastPlayedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get playCount => $state.composableBuilder(
      column: $state.table.playCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $DiscoveryInteractionsInsertCompanionBuilder
    = DiscoveryInteractionsCompanion Function({
  Value<int> id,
  required int sessionId,
  required String songId,
  required String interactionType,
  required int positionInPlaylist,
  Value<int?> songDurationMs,
  Value<int?> playDurationMs,
  Value<int> timestamp,
});
typedef $DiscoveryInteractionsUpdateCompanionBuilder
    = DiscoveryInteractionsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<String> songId,
  Value<String> interactionType,
  Value<int> positionInPlaylist,
  Value<int?> songDurationMs,
  Value<int?> playDurationMs,
  Value<int> timestamp,
});

class $DiscoveryInteractionsTableManager extends RootTableManager<
    _$SubtracksDatabase,
    DiscoveryInteractions,
    DiscoveryInteraction,
    $DiscoveryInteractionsFilterComposer,
    $DiscoveryInteractionsOrderingComposer,
    $DiscoveryInteractionsProcessedTableManager,
    $DiscoveryInteractionsInsertCompanionBuilder,
    $DiscoveryInteractionsUpdateCompanionBuilder> {
  $DiscoveryInteractionsTableManager(
      _$SubtracksDatabase db, DiscoveryInteractions table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $DiscoveryInteractionsFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $DiscoveryInteractionsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $DiscoveryInteractionsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<String> songId = const Value.absent(),
            Value<String> interactionType = const Value.absent(),
            Value<int> positionInPlaylist = const Value.absent(),
            Value<int?> songDurationMs = const Value.absent(),
            Value<int?> playDurationMs = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
          }) =>
              DiscoveryInteractionsCompanion(
            id: id,
            sessionId: sessionId,
            songId: songId,
            interactionType: interactionType,
            positionInPlaylist: positionInPlaylist,
            songDurationMs: songDurationMs,
            playDurationMs: playDurationMs,
            timestamp: timestamp,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required String songId,
            required String interactionType,
            required int positionInPlaylist,
            Value<int?> songDurationMs = const Value.absent(),
            Value<int?> playDurationMs = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
          }) =>
              DiscoveryInteractionsCompanion.insert(
            id: id,
            sessionId: sessionId,
            songId: songId,
            interactionType: interactionType,
            positionInPlaylist: positionInPlaylist,
            songDurationMs: songDurationMs,
            playDurationMs: playDurationMs,
            timestamp: timestamp,
          ),
        ));
}

class $DiscoveryInteractionsProcessedTableManager extends ProcessedTableManager<
    _$SubtracksDatabase,
    DiscoveryInteractions,
    DiscoveryInteraction,
    $DiscoveryInteractionsFilterComposer,
    $DiscoveryInteractionsOrderingComposer,
    $DiscoveryInteractionsProcessedTableManager,
    $DiscoveryInteractionsInsertCompanionBuilder,
    $DiscoveryInteractionsUpdateCompanionBuilder> {
  $DiscoveryInteractionsProcessedTableManager(super.$state);
}

class $DiscoveryInteractionsFilterComposer
    extends FilterComposer<_$SubtracksDatabase, DiscoveryInteractions> {
  $DiscoveryInteractionsFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get songId => $state.composableBuilder(
      column: $state.table.songId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get interactionType => $state.composableBuilder(
      column: $state.table.interactionType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get positionInPlaylist => $state.composableBuilder(
      column: $state.table.positionInPlaylist,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get songDurationMs => $state.composableBuilder(
      column: $state.table.songDurationMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get playDurationMs => $state.composableBuilder(
      column: $state.table.playDurationMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $DiscoveryInteractionsOrderingComposer
    extends OrderingComposer<_$SubtracksDatabase, DiscoveryInteractions> {
  $DiscoveryInteractionsOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get songId => $state.composableBuilder(
      column: $state.table.songId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get interactionType => $state.composableBuilder(
      column: $state.table.interactionType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get positionInPlaylist => $state.composableBuilder(
      column: $state.table.positionInPlaylist,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get songDurationMs => $state.composableBuilder(
      column: $state.table.songDurationMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get playDurationMs => $state.composableBuilder(
      column: $state.table.playDurationMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$SubtracksDatabaseManager {
  final _$SubtracksDatabase _db;
  _$SubtracksDatabaseManager(this._db);
  $QueueTableManager get queue => $QueueTableManager(_db, _db.queue);
  $LastAudioStateTableManager get lastAudioState =>
      $LastAudioStateTableManager(_db, _db.lastAudioState);
  $LastBottomNavStateTableManager get lastBottomNavState =>
      $LastBottomNavStateTableManager(_db, _db.lastBottomNavState);
  $LastLibraryStateTableManager get lastLibraryState =>
      $LastLibraryStateTableManager(_db, _db.lastLibraryState);
  $SourcesTableManager get sources => $SourcesTableManager(_db, _db.sources);
  $SubsonicSourcesTableManager get subsonicSources =>
      $SubsonicSourcesTableManager(_db, _db.subsonicSources);
  $ArtistsFtsTableManager get artistsFts =>
      $ArtistsFtsTableManager(_db, _db.artistsFts);
  $AlbumsFtsTableManager get albumsFts =>
      $AlbumsFtsTableManager(_db, _db.albumsFts);
  $PlaylistSongsTableManager get playlistSongs =>
      $PlaylistSongsTableManager(_db, _db.playlistSongs);
  $PlaylistsFtsTableManager get playlistsFts =>
      $PlaylistsFtsTableManager(_db, _db.playlistsFts);
  $SongsFtsTableManager get songsFts =>
      $SongsFtsTableManager(_db, _db.songsFts);
  $DiscoverySessionsTableManager get discoverySessions =>
      $DiscoverySessionsTableManager(_db, _db.discoverySessions);
  $DiscoveryInteractionsTableManager get discoveryInteractions =>
      $DiscoveryInteractionsTableManager(_db, _db.discoveryInteractions);
}

typedef FilterSongsByGenre$predicate = Expression<bool> Function(
    Songs songs, Albums albums);
typedef FilterSongsByGenre$order = OrderBy Function(Songs songs, Albums albums);
typedef FilterSongsByGenre$limit = Limit Function(Songs songs, Albums albums);
typedef FilterAlbums$predicate = Expression<bool> Function(Albums albums);
typedef FilterAlbums$order = OrderBy Function(Albums albums);
typedef FilterAlbums$limit = Limit Function(Albums albums);
typedef FilterAlbumsDownloaded$predicate = Expression<bool> Function(
    Albums albums, Songs songs);
typedef FilterAlbumsDownloaded$order = OrderBy Function(
    Albums albums, Songs songs);
typedef FilterAlbumsDownloaded$limit = Limit Function(
    Albums albums, Songs songs);
typedef FilterArtists$predicate = Expression<bool> Function(Artists artists);
typedef FilterArtists$order = OrderBy Function(Artists artists);
typedef FilterArtists$limit = Limit Function(Artists artists);
typedef FilterArtistsDownloaded$predicate = Expression<bool> Function(
    Artists artists, Albums albums, Songs songs);
typedef FilterArtistsDownloaded$order = OrderBy Function(
    Artists artists, Albums albums, Songs songs);
typedef FilterArtistsDownloaded$limit = Limit Function(
    Artists artists, Albums albums, Songs songs);
typedef FilterPlaylists$predicate = Expression<bool> Function(
    Playlists playlists);
typedef FilterPlaylists$order = OrderBy Function(Playlists playlists);
typedef FilterPlaylists$limit = Limit Function(Playlists playlists);
typedef FilterPlaylistsDownloaded$predicate = Expression<bool> Function(
    Playlists playlists, PlaylistSongs playlist_songs, Songs songs);
typedef FilterPlaylistsDownloaded$order = OrderBy Function(
    Playlists playlists, PlaylistSongs playlist_songs, Songs songs);
typedef FilterPlaylistsDownloaded$limit = Limit Function(
    Playlists playlists, PlaylistSongs playlist_songs, Songs songs);
typedef FilterSongs$predicate = Expression<bool> Function(Songs songs);
typedef FilterSongs$order = OrderBy Function(Songs songs);
typedef FilterSongs$limit = Limit Function(Songs songs);
typedef FilterSongsDownloaded$predicate = Expression<bool> Function(
    Songs songs);
typedef FilterSongsDownloaded$order = OrderBy Function(Songs songs);
typedef FilterSongsDownloaded$limit = Limit Function(Songs songs);

class RatingStatsResult {
  final UserRating userRating;
  final int count;
  RatingStatsResult({
    required this.userRating,
    required this.count,
  });
}

class DiscoveryPopularSongsResult {
  final String songId;
  final int playCount;
  final double avgCompletionRate;
  DiscoveryPopularSongsResult({
    required this.songId,
    required this.playCount,
    required this.avgCompletionRate,
  });
}

class DiscoverySkippedSongsResult {
  final String songId;
  final int skipCount;
  DiscoverySkippedSongsResult({
    required this.songId,
    required this.skipCount,
  });
}

class DiscoverySkippedSongsByStationResult {
  final String songId;
  final int skipCount;
  DiscoverySkippedSongsByStationResult({
    required this.songId,
    required this.skipCount,
  });
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'04ae05f49039a6c77afa45892f4e5e0fad7d20c6';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<SubtracksDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DatabaseRef = ProviderRef<SubtracksDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
