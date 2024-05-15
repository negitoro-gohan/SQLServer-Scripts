CREATE PROCEDURE GetColumnValueCounts
    @ColumnName NVARCHAR(100)
AS
BEGIN
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @TableName NVARCHAR(100);

    -- 全てのテーブルから指定された列名が存在するテーブルを取得
    DECLARE TableCursor CURSOR FOR
    SELECT t.name AS TableName
    FROM sys.columns c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    WHERE c.name = @ColumnName;

    OPEN TableCursor;
    FETCH NEXT FROM TableCursor INTO @TableName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DynamicSQL = '
        SELECT 
            ''' + @TableName + ''' AS TableName,
            ''' + @ColumnName + ''' AS ColumnName,
            CAST(' + QUOTENAME(@ColumnName) + ' AS NVARCHAR(100)) AS ColumnValue,
            COUNT(*) AS ValueCount
        FROM 
            ' + QUOTENAME(@TableName) + '
	    GROUP BY 
			CAST(' + QUOTENAME(@ColumnName) + ' AS NVARCHAR(100))
		ORDER BY 
			CAST(' + QUOTENAME(@ColumnName) + ' AS NVARCHAR(100));';

        EXEC sp_executesql @DynamicSQL;

        FETCH NEXT FROM TableCursor INTO @TableName;
    END

    CLOSE TableCursor;
    DEALLOCATE TableCursor;
END
