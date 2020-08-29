/**
 * LigtningController general helper controller for lightning components
 * @author M Rainboldt
 * @created August 2019
 */
public with sharing class LightningController 
{
    /**
     * @description executes soql for a single record
     * @param  query query soql to execute
     * @return       return a single record
     */
    @AuraEnabled
    public static SObject querySObject(String query){
        return Database.query(query);
    }

    /**
     * @description executes soql and returns a list of records
     * @param  query query soql to execute
     * @return       return a 1 or more records
     */
    @AuraEnabled
    public static List<SObject> querySObjects(String query){
        System.debug(query);
        return Database.query(query);
    }

    
    /**
     * @description wraps all the fields in a field set to be used by ui components
     * @param  sObjectName    sObjectName api name of sobject fieldset associated to
     * @param  fieldSetString fieldSetString api name of field set
     * @return                return list of columns with the fields from the fieldset
     */
    @AuraEnabled
    public static List<Column> getColumns(String sObjectName, String fieldSetString)
    {
        FieldSetMap fsMap = new FieldSetMap(sObjectName);
        List<Column> columns = new List<Column>();

        FieldSet fieldSet = fsMap.getFieldSet(fieldSetString);

        if(fieldSet == null) 
            throw new LightningException('Could not find fieldset \"' + fieldSetString + '\" on ' + sObjectName + '.');

        columns = fieldSet.fields;
        return columns;
    }

    /**
     * @description creates a soql for the fields wrapped in the column class
     * @param  fields    fields list of fields wrapped in the column class
     * @return                return string that can be used to execute a soql
     */
    @AuraEnabled
    public static String getFieldSOQL(List<Column> fields)
    {
        String fieldSOQL = '';
        for(Column fs: fields)
        {
            fieldSOQL += ', ' + fs.fieldName;
            // if(fs.isReferenceField)
            // {
            //     String relatedField = fs.fieldName.replace('__c', '__r') + '.Name';
            //     relatedField = relatedField.replace('Id.', '.');
            //     fieldSOQL += ', ' + relatedField;
            // }
        }
        System.debug(fieldSOQL);

        return fieldSOQL;
    }

    /**
     * @description         get an icon from Icon__mdt
     * @param  iconApiName DeveloperName of the Icon__mdt that you want to retrieve
     * @return             a single Icon__mdt
     */
    @AuraEnabled(cacheable=true)
    public static Icon__mdt getIcon(String iconApiName){
        return getIcons(new List<String>{iconApiName})[0];
    }

    /**
     * @description         get a list of icon__mdt by their DeveloperName
     * @param  iconApiNames all the DeveloperNames for icons you want to query for
     * @return              a list of Icon__mdt
     */
    @AuraEnabled(cacheable=true)
    public static List<Icon__mdt> getIcons(List<String> iconApiNames){
        return (List<Icon__mdt>)Database.query(SObjectHelper.generateQueryStringByObjectName('Icon__mdt', false)
                            + ' WHERE DeveloperName in :iconApiNames');
    }

    public class LightningException extends Exception{}
}