/**
 * @description creates a map of fieldset developer name to the field set for a given object
 * @author M Rainboldt
 * @created AUG 2019
 */
public class FieldSetMap {
	private Map<String, FieldSet> fieldSetMap {get; set;}

	/**
	 * @description construct map of fieldsets for given object name
	 * @param  sObjectName api name of object to create fieldset map
	 */
	public FieldSetMap(String sObjectName){
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        this.fieldSetMap = new Map<String, FieldSet>();
        for(Schema.FieldSet fs: describe.fieldSets.getMap().values()){
        	this.fieldSetMap.put(fs.getName(), new FieldSet(fs));
        }

		if(Test.isRunningTest()){
			//this.fieldSetMap = UnitTestHelper.getMockFieldSet(sObjectName);
		}
        
	}

	/**
	 * @description get the field set with the given name
	 * @param  name api name of field set to return
	 * @return      fieldset wrapper class, null if fieldset does not exist
	 */
	public FieldSet getFieldSet(String name){

		return fieldSetMap.get(name);
	}
}