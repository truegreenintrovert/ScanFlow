// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trashedMeta = const VerificationMeta(
    'trashed',
  );
  @override
  late final GeneratedColumn<bool> trashed = GeneratedColumn<bool>(
    'trashed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("trashed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pdfPathMeta = const VerificationMeta(
    'pdfPath',
  );
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
    'pdf_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    modifiedAt,
    favorite,
    trashed,
    pdfPath,
    ocrText,
    folder,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('trashed')) {
      context.handle(
        _trashedMeta,
        trashed.isAcceptableOrUnknown(data['trashed']!, _trashedMeta),
      );
    }
    if (data.containsKey('pdf_path')) {
      context.handle(
        _pdfPathMeta,
        pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      trashed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}trashed'],
      )!,
      pdfPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_path'],
      ),
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool favorite;
  final bool trashed;
  final String? pdfPath;
  final String ocrText;
  final String? folder;
  final String tags;
  const Document({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.modifiedAt,
    required this.favorite,
    required this.trashed,
    this.pdfPath,
    required this.ocrText,
    this.folder,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    map['favorite'] = Variable<bool>(favorite);
    map['trashed'] = Variable<bool>(trashed);
    if (!nullToAbsent || pdfPath != null) {
      map['pdf_path'] = Variable<String>(pdfPath);
    }
    map['ocr_text'] = Variable<String>(ocrText);
    if (!nullToAbsent || folder != null) {
      map['folder'] = Variable<String>(folder);
    }
    map['tags'] = Variable<String>(tags);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      favorite: Value(favorite),
      trashed: Value(trashed),
      pdfPath: pdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfPath),
      ocrText: Value(ocrText),
      folder: folder == null && nullToAbsent
          ? const Value.absent()
          : Value(folder),
      tags: Value(tags),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      trashed: serializer.fromJson<bool>(json['trashed']),
      pdfPath: serializer.fromJson<String?>(json['pdfPath']),
      ocrText: serializer.fromJson<String>(json['ocrText']),
      folder: serializer.fromJson<String?>(json['folder']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'favorite': serializer.toJson<bool>(favorite),
      'trashed': serializer.toJson<bool>(trashed),
      'pdfPath': serializer.toJson<String?>(pdfPath),
      'ocrText': serializer.toJson<String>(ocrText),
      'folder': serializer.toJson<String?>(folder),
      'tags': serializer.toJson<String>(tags),
    };
  }

  Document copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? favorite,
    bool? trashed,
    Value<String?> pdfPath = const Value.absent(),
    String? ocrText,
    Value<String?> folder = const Value.absent(),
    String? tags,
  }) => Document(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    favorite: favorite ?? this.favorite,
    trashed: trashed ?? this.trashed,
    pdfPath: pdfPath.present ? pdfPath.value : this.pdfPath,
    ocrText: ocrText ?? this.ocrText,
    folder: folder.present ? folder.value : this.folder,
    tags: tags ?? this.tags,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      trashed: data.trashed.present ? data.trashed.value : this.trashed,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      folder: data.folder.present ? data.folder.value : this.folder,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('favorite: $favorite, ')
          ..write('trashed: $trashed, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('ocrText: $ocrText, ')
          ..write('folder: $folder, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    createdAt,
    modifiedAt,
    favorite,
    trashed,
    pdfPath,
    ocrText,
    folder,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.favorite == this.favorite &&
          other.trashed == this.trashed &&
          other.pdfPath == this.pdfPath &&
          other.ocrText == this.ocrText &&
          other.folder == this.folder &&
          other.tags == this.tags);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<bool> favorite;
  final Value<bool> trashed;
  final Value<String?> pdfPath;
  final Value<String> ocrText;
  final Value<String?> folder;
  final Value<String> tags;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.favorite = const Value.absent(),
    this.trashed = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.folder = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime modifiedAt,
    this.favorite = const Value.absent(),
    this.trashed = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.folder = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       modifiedAt = Value(modifiedAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<bool>? favorite,
    Expression<bool>? trashed,
    Expression<String>? pdfPath,
    Expression<String>? ocrText,
    Expression<String>? folder,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (favorite != null) 'favorite': favorite,
      if (trashed != null) 'trashed': trashed,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (ocrText != null) 'ocr_text': ocrText,
      if (folder != null) 'folder': folder,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? modifiedAt,
    Value<bool>? favorite,
    Value<bool>? trashed,
    Value<String?>? pdfPath,
    Value<String>? ocrText,
    Value<String?>? folder,
    Value<String>? tags,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      favorite: favorite ?? this.favorite,
      trashed: trashed ?? this.trashed,
      pdfPath: pdfPath ?? this.pdfPath,
      ocrText: ocrText ?? this.ocrText,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (trashed.present) {
      map['trashed'] = Variable<bool>(trashed.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('favorite: $favorite, ')
          ..write('trashed: $trashed, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('ocrText: $ocrText, ')
          ..write('folder: $folder, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanPagesTable extends ScanPages
    with TableInfo<$ScanPagesTable, ScanPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropPathMeta = const VerificationMeta(
    'cropPath',
  );
  @override
  late final GeneratedColumn<String> cropPath = GeneratedColumn<String>(
    'crop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotationMeta = const VerificationMeta(
    'rotation',
  );
  @override
  late final GeneratedColumn<int> rotation = GeneratedColumn<int>(
    'rotation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _filterMeta = const VerificationMeta('filter');
  @override
  late final GeneratedColumn<String> filter = GeneratedColumn<String>(
    'filter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('original'),
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ocrBoxesMeta = const VerificationMeta(
    'ocrBoxes',
  );
  @override
  late final GeneratedColumn<String> ocrBoxes = GeneratedColumn<String>(
    'ocr_boxes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    imagePath,
    cropPath,
    pageIndex,
    rotation,
    filter,
    ocrText,
    ocrBoxes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('crop_path')) {
      context.handle(
        _cropPathMeta,
        cropPath.isAcceptableOrUnknown(data['crop_path']!, _cropPathMeta),
      );
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('rotation')) {
      context.handle(
        _rotationMeta,
        rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta),
      );
    }
    if (data.containsKey('filter')) {
      context.handle(
        _filterMeta,
        filter.isAcceptableOrUnknown(data['filter']!, _filterMeta),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('ocr_boxes')) {
      context.handle(
        _ocrBoxesMeta,
        ocrBoxes.isAcceptableOrUnknown(data['ocr_boxes']!, _ocrBoxesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      cropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_path'],
      ),
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      rotation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation'],
      )!,
      filter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter'],
      )!,
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      )!,
      ocrBoxes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_boxes'],
      )!,
    );
  }

  @override
  $ScanPagesTable createAlias(String alias) {
    return $ScanPagesTable(attachedDatabase, alias);
  }
}

class ScanPage extends DataClass implements Insertable<ScanPage> {
  final String id;
  final String documentId;
  final String imagePath;
  final String? cropPath;
  final int pageIndex;
  final int rotation;
  final String filter;
  final String ocrText;
  final String ocrBoxes;
  const ScanPage({
    required this.id,
    required this.documentId,
    required this.imagePath,
    this.cropPath,
    required this.pageIndex,
    required this.rotation,
    required this.filter,
    required this.ocrText,
    required this.ocrBoxes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || cropPath != null) {
      map['crop_path'] = Variable<String>(cropPath);
    }
    map['page_index'] = Variable<int>(pageIndex);
    map['rotation'] = Variable<int>(rotation);
    map['filter'] = Variable<String>(filter);
    map['ocr_text'] = Variable<String>(ocrText);
    map['ocr_boxes'] = Variable<String>(ocrBoxes);
    return map;
  }

  ScanPagesCompanion toCompanion(bool nullToAbsent) {
    return ScanPagesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      imagePath: Value(imagePath),
      cropPath: cropPath == null && nullToAbsent
          ? const Value.absent()
          : Value(cropPath),
      pageIndex: Value(pageIndex),
      rotation: Value(rotation),
      filter: Value(filter),
      ocrText: Value(ocrText),
      ocrBoxes: Value(ocrBoxes),
    );
  }

  factory ScanPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanPage(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      cropPath: serializer.fromJson<String?>(json['cropPath']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      rotation: serializer.fromJson<int>(json['rotation']),
      filter: serializer.fromJson<String>(json['filter']),
      ocrText: serializer.fromJson<String>(json['ocrText']),
      ocrBoxes: serializer.fromJson<String>(json['ocrBoxes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'imagePath': serializer.toJson<String>(imagePath),
      'cropPath': serializer.toJson<String?>(cropPath),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'rotation': serializer.toJson<int>(rotation),
      'filter': serializer.toJson<String>(filter),
      'ocrText': serializer.toJson<String>(ocrText),
      'ocrBoxes': serializer.toJson<String>(ocrBoxes),
    };
  }

  ScanPage copyWith({
    String? id,
    String? documentId,
    String? imagePath,
    Value<String?> cropPath = const Value.absent(),
    int? pageIndex,
    int? rotation,
    String? filter,
    String? ocrText,
    String? ocrBoxes,
  }) => ScanPage(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    imagePath: imagePath ?? this.imagePath,
    cropPath: cropPath.present ? cropPath.value : this.cropPath,
    pageIndex: pageIndex ?? this.pageIndex,
    rotation: rotation ?? this.rotation,
    filter: filter ?? this.filter,
    ocrText: ocrText ?? this.ocrText,
    ocrBoxes: ocrBoxes ?? this.ocrBoxes,
  );
  ScanPage copyWithCompanion(ScanPagesCompanion data) {
    return ScanPage(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      cropPath: data.cropPath.present ? data.cropPath.value : this.cropPath,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      filter: data.filter.present ? data.filter.value : this.filter,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      ocrBoxes: data.ocrBoxes.present ? data.ocrBoxes.value : this.ocrBoxes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanPage(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('imagePath: $imagePath, ')
          ..write('cropPath: $cropPath, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('rotation: $rotation, ')
          ..write('filter: $filter, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrBoxes: $ocrBoxes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    imagePath,
    cropPath,
    pageIndex,
    rotation,
    filter,
    ocrText,
    ocrBoxes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanPage &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.imagePath == this.imagePath &&
          other.cropPath == this.cropPath &&
          other.pageIndex == this.pageIndex &&
          other.rotation == this.rotation &&
          other.filter == this.filter &&
          other.ocrText == this.ocrText &&
          other.ocrBoxes == this.ocrBoxes);
}

class ScanPagesCompanion extends UpdateCompanion<ScanPage> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> imagePath;
  final Value<String?> cropPath;
  final Value<int> pageIndex;
  final Value<int> rotation;
  final Value<String> filter;
  final Value<String> ocrText;
  final Value<String> ocrBoxes;
  final Value<int> rowid;
  const ScanPagesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.cropPath = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.rotation = const Value.absent(),
    this.filter = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrBoxes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanPagesCompanion.insert({
    required String id,
    required String documentId,
    required String imagePath,
    this.cropPath = const Value.absent(),
    required int pageIndex,
    this.rotation = const Value.absent(),
    this.filter = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrBoxes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       imagePath = Value(imagePath),
       pageIndex = Value(pageIndex);
  static Insertable<ScanPage> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? imagePath,
    Expression<String>? cropPath,
    Expression<int>? pageIndex,
    Expression<int>? rotation,
    Expression<String>? filter,
    Expression<String>? ocrText,
    Expression<String>? ocrBoxes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (imagePath != null) 'image_path': imagePath,
      if (cropPath != null) 'crop_path': cropPath,
      if (pageIndex != null) 'page_index': pageIndex,
      if (rotation != null) 'rotation': rotation,
      if (filter != null) 'filter': filter,
      if (ocrText != null) 'ocr_text': ocrText,
      if (ocrBoxes != null) 'ocr_boxes': ocrBoxes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanPagesCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? imagePath,
    Value<String?>? cropPath,
    Value<int>? pageIndex,
    Value<int>? rotation,
    Value<String>? filter,
    Value<String>? ocrText,
    Value<String>? ocrBoxes,
    Value<int>? rowid,
  }) {
    return ScanPagesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      imagePath: imagePath ?? this.imagePath,
      cropPath: cropPath ?? this.cropPath,
      pageIndex: pageIndex ?? this.pageIndex,
      rotation: rotation ?? this.rotation,
      filter: filter ?? this.filter,
      ocrText: ocrText ?? this.ocrText,
      ocrBoxes: ocrBoxes ?? this.ocrBoxes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (cropPath.present) {
      map['crop_path'] = Variable<String>(cropPath.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<int>(rotation.value);
    }
    if (filter.present) {
      map['filter'] = Variable<String>(filter.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (ocrBoxes.present) {
      map['ocr_boxes'] = Variable<String>(ocrBoxes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanPagesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('imagePath: $imagePath, ')
          ..write('cropPath: $cropPath, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('rotation: $rotation, ')
          ..write('filter: $filter, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrBoxes: $ocrBoxes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $ScanPagesTable scanPages = $ScanPagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [documents, scanPages];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_pages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required String title,
  required DateTime createdAt,
  required DateTime modifiedAt,
  Value<bool> favorite,
  Value<bool> trashed,
  Value<String?> pdfPath,
  Value<String> ocrText,
  Value<String?> folder,
  Value<String> tags,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<bool> favorite,
  Value<bool> trashed,
  Value<String?> pdfPath,
  Value<String> ocrText,
  Value<String?> folder,
  Value<String> tags,
  Value<int> rowid,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScanPagesTable, List<ScanPage>>
  _scanPagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanPages,
    aliasName: 'documents__id__scan_pages__document_id',
  );

  $$ScanPagesTableProcessedTableManager get scanPagesRefs {
    final manager = $$ScanPagesTableTableManager(
      $_db,
      $_db.scanPages,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanPagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trashed => $composableBuilder(
    column: $table.trashed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scanPagesRefs(
    Expression<bool> Function($$ScanPagesTableFilterComposer f) f,
  ) {
    final $$ScanPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanPages,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanPagesTableFilterComposer(
            $db: $db,
            $table: $db.scanPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trashed => $composableBuilder(
    column: $table.trashed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<bool> get trashed =>
      $composableBuilder(column: $table.trashed, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> scanPagesRefs<T extends Object>(
    Expression<T> Function($$ScanPagesTableAnnotationComposer a) f,
  ) {
    final $$ScanPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanPages,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.scanPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, $$DocumentsTableReferences),
          Document,
          PrefetchHooks Function({bool scanPagesRefs})
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> trashed = const Value.absent(),
                Value<String?> pdfPath = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String?> folder = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                favorite: favorite,
                trashed: trashed,
                pdfPath: pdfPath,
                ocrText: ocrText,
                folder: folder,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime createdAt,
                required DateTime modifiedAt,
                Value<bool> favorite = const Value.absent(),
                Value<bool> trashed = const Value.absent(),
                Value<String?> pdfPath = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String?> folder = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                favorite: favorite,
                trashed: trashed,
                pdfPath: pdfPath,
                ocrText: ocrText,
                folder: folder,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, Document>(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanPagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scanPagesRefs) db.scanPages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scanPagesRefs)
                    await $_getPrefetchedData<
                      Document,
                      $DocumentsTable,
                      ScanPage
                    >(
                      currentTable: table,
                      referencedTable: $$DocumentsTableReferences
                          ._scanPagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DocumentsTableReferences(
                            db,
                            table,
                            p0,
                          ).scanPagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.documentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, $$DocumentsTableReferences),
      Document,
      PrefetchHooks Function({bool scanPagesRefs})
    >;
typedef $$ScanPagesTableCreateCompanionBuilder = ScanPagesCompanion Function({
  required String id,
  required String documentId,
  required String imagePath,
  Value<String?> cropPath,
  required int pageIndex,
  Value<int> rotation,
  Value<String> filter,
  Value<String> ocrText,
  Value<String> ocrBoxes,
  Value<int> rowid,
});
typedef $$ScanPagesTableUpdateCompanionBuilder = ScanPagesCompanion Function({
  Value<String> id,
  Value<String> documentId,
  Value<String> imagePath,
  Value<String?> cropPath,
  Value<int> pageIndex,
  Value<int> rotation,
  Value<String> filter,
  Value<String> ocrText,
  Value<String> ocrBoxes,
  Value<int> rowid,
});

final class $$ScanPagesTableReferences
    extends BaseReferences<_$AppDatabase, $ScanPagesTable, ScanPage> {
  $$ScanPagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('scan_pages__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanPagesTableFilterComposer
    extends Composer<_$AppDatabase, $ScanPagesTable> {
  $$ScanPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropPath => $composableBuilder(
    column: $table.cropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filter => $composableBuilder(
    column: $table.filter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrBoxes => $composableBuilder(
    column: $table.ocrBoxes,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanPagesTable> {
  $$ScanPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropPath => $composableBuilder(
    column: $table.cropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filter => $composableBuilder(
    column: $table.filter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrBoxes => $composableBuilder(
    column: $table.ocrBoxes,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanPagesTable> {
  $$ScanPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get cropPath =>
      $composableBuilder(column: $table.cropPath, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<String> get filter =>
      $composableBuilder(column: $table.filter, builder: (column) => column);

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get ocrBoxes =>
      $composableBuilder(column: $table.ocrBoxes, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanPagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanPagesTable,
          ScanPage,
          $$ScanPagesTableFilterComposer,
          $$ScanPagesTableOrderingComposer,
          $$ScanPagesTableAnnotationComposer,
          $$ScanPagesTableCreateCompanionBuilder,
          $$ScanPagesTableUpdateCompanionBuilder,
          (ScanPage, $$ScanPagesTableReferences),
          ScanPage,
          PrefetchHooks Function({bool documentId})
        > {
  $$ScanPagesTableTableManager(_$AppDatabase db, $ScanPagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String?> cropPath = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<int> rotation = const Value.absent(),
                Value<String> filter = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String> ocrBoxes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanPagesCompanion(
                id: id,
                documentId: documentId,
                imagePath: imagePath,
                cropPath: cropPath,
                pageIndex: pageIndex,
                rotation: rotation,
                filter: filter,
                ocrText: ocrText,
                ocrBoxes: ocrBoxes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String imagePath,
                Value<String?> cropPath = const Value.absent(),
                required int pageIndex,
                Value<int> rotation = const Value.absent(),
                Value<String> filter = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String> ocrBoxes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanPagesCompanion.insert(
                id: id,
                documentId: documentId,
                imagePath: imagePath,
                cropPath: cropPath,
                pageIndex: pageIndex,
                rotation: rotation,
                filter: filter,
                ocrText: ocrText,
                ocrBoxes: ocrBoxes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanPagesTable, ScanPage>(table),
                  $$ScanPagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$ScanPagesTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$ScanPagesTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanPagesTable,
      ScanPage,
      $$ScanPagesTableFilterComposer,
      $$ScanPagesTableOrderingComposer,
      $$ScanPagesTableAnnotationComposer,
      $$ScanPagesTableCreateCompanionBuilder,
      $$ScanPagesTableUpdateCompanionBuilder,
      (ScanPage, $$ScanPagesTableReferences),
      ScanPage,
      PrefetchHooks Function({bool documentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$ScanPagesTableTableManager get scanPages =>
      $$ScanPagesTableTableManager(_db, _db.scanPages);
}
