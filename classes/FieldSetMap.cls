public class FieldSetMap {
	private Map<String, FieldSet> fieldSetMap {get; set;}

	public FieldSetMap(String sObjectName){
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        this.fieldSetMap = new Map<String, FieldSet>();
        for(Schema.FieldSet fs: describe.fieldSets.getMap().values()){
        	this.fieldSetMap.put(fs.getName(), new FieldSet(fs));
        }

		if(Test.isRunningTest()){
			this.fieldSetMap = UnitTestHelper.getMockFieldSet(sObjectName);
		}
        
	}

	public FieldSet getFieldSet(String name){

		return fieldSetMap.get(name);
	}
}