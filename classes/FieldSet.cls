public class FieldSet {
	@AuraEnabled
	public String description {get; set;}

	@AuraEnabled
	public String label {get; set;}

	@AuraEnabled
	public String name {get; set;}

	@AuraEnabled
	public String nameSpace {get; set;}

	@AuraEnabled
	public String sObjectType {get; set;}

	@AuraEnabled
	public List<FieldSetMember> fields {get; set;}

	public FieldSet(Schema.FieldSet fs) {
		this.label = fs.getLabel();
		this.name = fs.getName();
		this.description = fs.getDescription();
		this.nameSpace = fs.getNameSpace();
		this.sObjectType = fs.getSObjectType().getDescribe().getName();
		this.fields = new List<FieldSetMember>();

		for (Schema.FieldSetMember f: fs.getFields()) {
            this.fields.add(new FieldSetMember(f));
        }
	}

	@TestVisible
	private FieldSet(String label
				, String name
				, String description
				, String nameSpace
				, String sObjectType
				, List<FieldSetMember> fields){
		this.label = label;
		this.name = name;
		this.description = description;
		this.nameSpace = nameSpace;
		this.sObjectType = sObjectType;
		this.fields = fields;
	}

}