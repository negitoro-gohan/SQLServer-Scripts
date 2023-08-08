-- �������鐔�l����͂���(���l�܂��̓��C���h�J�[�h�œ��͂���)
DECLARE @TextToFind NVARCHAR(100) = N'[0-9][0-9][0-9][0-9]%';
--DECLARE @TextToFind NVARCHAR(100) = N'123%';

-- ����
IF OBJECT_ID(N'tempdb..#SearchResult', N'U') IS NOT NULL
    DROP TABLE #SearchResult;

CREATE TABLE #SearchResult (
    SchemaName NVARCHAR(128)
    , TableName NVARCHAR(128)
    , ColumnName NVARCHAR(128)
    , ColumnValue NVARCHAR(MAX)
    );

DECLARE @SchemaName NVARCHAR(128)
    , @TableName NVARCHAR(128)
    , @ColumnName NVARCHAR(128)
    , @Sql NVARCHAR(MAX);

DECLARE crSearch CURSOR LOCAL FAST_FORWARD
FOR
    SELECT s.name
        , T.name
        , C.name
    FROM sys.schemas AS S
    INNER JOIN sys.tables AS T
        ON S.schema_id = T.schema_id
    INNER JOIN sys.columns AS C
        ON T.object_id = C.object_id
    INNER JOIN sys.types AS TP
        ON C.user_type_id = TP.user_type_id
    WHERE TP.name IN ('bigint', 'int', 'smallint', 'tinyint', 'decimal', 'numeric', 'money', 'smallmoney ')
	--�Ώۂ̐��l�^�͏�LWHERE��Œ�`����
    ORDER BY s.name
        , T.name
        , C.name;

OPEN crSearch;

FETCH NEXT
FROM crSearch
INTO @SchemaName
    , @TableName
    , @ColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = 'SELECT ''' + @SchemaName + ''', ''' + @TableName + ''', ''' + @ColumnName + ''', CAST([' + @ColumnName + '] AS NVARCHAR(MAX)) ' 
        + ' FROM [' + @SchemaName + '].[' + @TableName + '] WITH (NOLOCK)' 
        + ' WHERE [' + @ColumnName + '] LIKE N''' + @TextToFind + '''';

    SELECT @Sql

    INSERT INTO #SearchResult
    EXEC sp_executesql @Sql;

    FETCH NEXT
    FROM crSearch
    INTO @SchemaName
        , @TableName
        , @ColumnName;
END

CLOSE crSearch;

DEALLOCATE crSearch;

-- ���ʂ̕\��
SELECT *
FROM #SearchResult
ORDER BY SchemaName
    , TableName
    , ColumnName;
