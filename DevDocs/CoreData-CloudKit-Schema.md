下述内容是披萨小助手 v5 所使用的 CloudKit Schema。

注：因 SwiftData 默认行为所致，PZProfileMO 的 `game` 和 `server` 都是 `[FieldName: RawValue]` 这个 NSDictionary 的形式（只有一对 key value pair）经过 NSKeyedArchiver 压缩厚的形态。相关的 Codec 已经放在 PZCoreDataKit 内了。这也是为什么披萨小助手 v5.5 提供 iOS 16 向下支持时将本地帐号的 CoreData SQLite 资料库放在另外的地方存放的原因（这俩 field 在本地变成了 bytes blob；而 SwiftData 的话会将这俩 field 在本地以 string 存储）。

```
DEFINE SCHEMA

    RECORD TYPE CD_AccountConfiguration (
        CD_allowNotification INT64 QUERYABLE SORTABLE,
        CD_cookie            STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_deviceFingerPrint STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_entityName        STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_name              STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_priority          INT64 QUERYABLE SORTABLE,
        CD_sTokenV2          STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_serverRawValue    STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_uid               STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_uuid              STRING QUERYABLE SEARCHABLE SORTABLE,
        "___createTime"      TIMESTAMP,
        "___createdBy"       REFERENCE,
        "___etag"            STRING,
        "___modTime"         TIMESTAMP,
        "___modifiedBy"      REFERENCE,
        "___recordID"        REFERENCE,
        GRANT WRITE TO "_creator",
        GRANT CREATE TO "_icloud",
        GRANT READ TO "_world"
    );

    RECORD TYPE CD_PZGachaEntryMO (
        CD_count        STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_entityName   STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_gachaID      STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_gachaType    STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_game         STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_id           STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_itemID       STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_itemType     STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_lang         STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_name         STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_rankType     STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_time         STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_uid          STRING QUERYABLE SEARCHABLE SORTABLE,
        "___createTime" TIMESTAMP,
        "___createdBy"  REFERENCE,
        "___etag"       STRING,
        "___modTime"    TIMESTAMP,
        "___modifiedBy" REFERENCE,
        "___recordID"   REFERENCE,
        GRANT WRITE TO "_creator",
        GRANT CREATE TO "_icloud",
        GRANT READ TO "_world"
    );

    RECORD TYPE CD_PZGachaProfileMO (
        CD_entityName   STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_game         BYTES QUERYABLE SORTABLE,
        CD_gameRAW      STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_uid          STRING QUERYABLE SEARCHABLE SORTABLE,
        "___createTime" TIMESTAMP,
        "___createdBy"  REFERENCE,
        "___etag"       STRING,
        "___modTime"    TIMESTAMP,
        "___modifiedBy" REFERENCE,
        "___recordID"   REFERENCE,
        GRANT WRITE TO "_creator",
        GRANT CREATE TO "_icloud",
        GRANT READ TO "_world"
    );

    RECORD TYPE CD_PZProfileMO (
        CD_allowNotification INT64 QUERYABLE SORTABLE,
        CD_cookie            STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_deviceFingerPrint STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_deviceID          STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_entityName        STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_game              BYTES QUERYABLE SORTABLE,
        CD_name              STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_priority          INT64 QUERYABLE SORTABLE,
        CD_sTokenV2          STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_server            BYTES QUERYABLE SORTABLE,
        CD_serverRawValue    STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_uid               STRING QUERYABLE SEARCHABLE SORTABLE,
        CD_uuid              STRING QUERYABLE SEARCHABLE SORTABLE,
        "___createTime"      TIMESTAMP,
        "___createdBy"       REFERENCE,
        "___etag"            STRING,
        "___modTime"         TIMESTAMP,
        "___modifiedBy"      REFERENCE,
        "___recordID"        REFERENCE,
        GRANT WRITE TO "_creator",
        GRANT CREATE TO "_icloud",
        GRANT READ TO "_world"
    );

    RECORD TYPE Users (
        "___createTime" TIMESTAMP,
        "___createdBy"  REFERENCE,
        "___etag"       STRING,
        "___modTime"    TIMESTAMP,
        "___modifiedBy" REFERENCE,
        "___recordID"   REFERENCE,
        roles           LIST<INT64>,
        GRANT WRITE TO "_creator",
        GRANT READ TO "_world"
    );

```