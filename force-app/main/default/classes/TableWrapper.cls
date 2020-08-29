/**
 * @description     wrapper class to help with custom form or table components
 * @author          M Rainboldt
 * @created         July 2019
 */
public class TableWrapper {
    /**
     * @description records to be displayed in table
     */
    @AuraEnabled
    public List<SObject> records;

    /**
     * @description context record
     */
    @AuraEnabled
    public SObject record;

    /**
     * @description fields to be displayed in table
     */
    @AuraEnabled
    public List<Column> columns;

    /**
     * @description number of records
     */
    @AuraEnabled
    public Integer rowCount;

    /**
     * @description field api names concatenated together by comma, 
     *              ready to be used in soql
     */
    @AuraEnabled
    public String fieldSOQL;

    /**
     * @description where clause for the soql
     */
    @AuraEnabled
    public String whereClause;

    /**
     * @description api name for the object to be queried
     */
    @AuraEnabled
    public String sObjectType;

    /**
     * @description limit for records to be queried
     */
    private Integer soqlLimit;

    /**
     * @description number of records that satisfy where clause
     */
    @AuraEnabled
    public Integer totalRowCount;

    /**
     * @description api name for field to default sort by
     */
    @AuraEnabled
    public String sortBy;

    /**
     * @description sort direction, should be asc, desc or null
     */
    @AuraEnabled
    public String sortDirection;

    public TableWrapper(){}


    /**
     * @description          initializes all the data needed to render a table
     * @param  recordId      Id of the context record
     * @param  relatedField  field that the relates the object being queried to the record id
     * @param  relatedObject api name of the related object to be queried
     * @param  fieldSetName  name of the fieldset to be used
     * @param  whereClause   how the soql should be filtered
     * @param  recLimit      the number of records to be queried
     * @param  sortBy        what field to sort by, should be api name
     * @param  sortDirection the direction to be sorted, should be asc, desc, null
     */
    public TableWrapper(String recordId, String relatedField, String relatedObject, String fieldSetName, String whereClause, Integer recLimit, String sortBy, String sortDirection)
    {
        this.soqlLimit = recLimit;
        this.sObjectType = relatedObject;
        this.columns = LightningController.getColumns(relatedObject
                                                        , fieldSetName);
        this.fieldSOQL = LightningController.getFieldSOQL(columns);
        this.whereClause = String.isBlank(whereClause) ? ' WHERE ' : ' WHERE ' + whereClause + ' AND '; 
        this.whereClause += relatedField + ' = \'' + recordId + '\'';
        this.sortBy = sortBy;
        this.sortDirection = String.isBlank(sortDirection) ? 'desc' : sortDirection;
        //only order the query if sortBy & sortDirection are completed
        if(!String.isBlank(this.sortBy)
            && !String.isBlank(this.sortDirection))
        {
            this.whereClause += ' ORDER BY ' + this.sortBy + ' ' + this.sortDirection;
        }
        this.whereClause += ' LIMIT ' + soqlLimit;
        this.totalRowCount = this.getCount();
        this.records = this.refreshRecords();
        this.rowCount = this.records != null && !this.records.isEmpty() ? this.records.size() : 0;
    }

    /**
     * @description     get the string to be used in executing the soql
     * @return   a soql string
     */
    public String getQuery()
    {
        return TableWrapper.getQuery(this.fieldSOQL
                                    , this.sObjectType
                                    , this.whereClause);

    }

    /**
     * @description        assembles the soql string
     * @param  fieldSOQL   fields to be queried
     * @param  sObjectType the api name of the object to be queried
     * @param  whereClause how the soql will be filtered
     * @return             a soql string
     */
    public static String getQuery(String fieldSOQL, String sObjectType, String whereClause)
    {
        String query = 'SELECT Id';
        query += fieldSOQL;
        query +=' FROM ' + sObjectType;
        query += whereClause;

        return query;
    }

    /**
     * @description     gets the number of records that can be returned by the soql
     * @return          number of records that can be returned
     */
    public Integer getCount()
    {
        String soql = 'SELECT count() FROM ';
        String whereClause = this.whereClause.containsIgnoreCase('ORDER') ?
                                this.whereClause.split('ORDER')[0] :
                                this.whereClause.split('LIMIT')[0];
        soql = soql + this.sObjectType + whereClause;
        System.debug(LoggingLevel.INFO, 'Count soql: ' + soql);
       return Integer.valueOf(Database.countQuery(soql));
    }

    /**
     * @description     re queries the records
     * @return          the most recent version of the records
     */
    public List<SObject> refreshRecords()
    {
        return LightningController.querySObjects(this.getQuery());
    }

    /**
     * @description     gets more records based on the soql
     * @return          updated list of records
     */
    public List<SObject> loadMoreRecords()
    {
        return LightningController.querySObjects(this.getQuery());
    }
}