public with sharing class LightningController {

    @AuraEnabled
    public static SObject querySObject(String query){
        return Database.query(query);
    }

    @AuraEnabled
    public static List<SObject> querySObjects(String query){
        return Database.query(query);
    }

    @AuraEnabled
    public static List<FieldSet> getFields(String sObjectName, String fieldSetString){
        FieldSetMap fsMap = new FieldSetMap(sObjectName);
        List<FieldSet> fset = new List<FieldSet>();
        List<String> fieldSets = fieldSetString.split(';');
        for (String fieldSet: fieldSets) {
            FieldSet fs = fsMap.getFieldSet(fieldSet);
            if(fs == null) 
                throw new LightningException('Could not find fieldset \"' + fieldset + '\" on ' + sObjectName + '.');

            fset.add(fs);
        }
        return fset;
    }

    public class LightningException extends Exception{}
}