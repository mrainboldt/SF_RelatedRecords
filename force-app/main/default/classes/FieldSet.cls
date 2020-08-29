/**
 * @description wrapper class for fieldsets
 * @author 		M Rainboldt
 * @created 	AUG 2019
 */
public class FieldSet {
	/**
	 * @description description of the field set
	 */
	@AuraEnabled
	public String description {get; set;}

	/**
	 * @description display label of the field set
	 */
	@AuraEnabled
	public String label {get; set;}

	/**
	 * @description api name of the field set
	 */
	@AuraEnabled
	public String fieldName {get; set;}

	/**
	 * @description name space of the field set
	 */
	@AuraEnabled
	public String nameSpace {get; set;}

	/**
	 * @description name of object field set is from
	 */
	@AuraEnabled
	public String type {get; set;}

	/**
	 * @descriptions fields from fieldset ready to be used in a table or front end
	 */
	@AuraEnabled
	public List<Column> fields {get; set;}

	/**
	 * @description constructor using a fieldset
	 * @param  fs 	fieldset to establish wrapper
	 */
	public FieldSet(Schema.FieldSet fs) {
		this.label = fs.getLabel();
		this.fieldName = fs.getName();
		this.description = fs.getDescription();
		this.nameSpace = fs.getNameSpace();
		this.type = fs.getSObjectType().getDescribe().getName();
		this.fields = new List<Column>();

		for (Schema.FieldSetMember f: fs.getFields()) {
            this.fields.add(new Column(f));
        }
	}

	/**
	 * @description 		create wrapper for testing
	 * @param  label       	label for fieldset
	 * @param  name        	developer name of fieldset
	 * @param  description 	description of fieldset
	 * @param  nameSpace   	namespace fieldset exists in
	 * @param  sObjectType 	object fieldset resides on
	 * @param  fields      	fields within fieldset
	 */
	@TestVisible
	private FieldSet(String label, String name, String description, String nameSpace, String sObjectType, List<Column> fields){
		this.label = label;
		this.fieldName = name;
		this.description = description;
		this.nameSpace = nameSpace;
		this.type = sObjectType;
		this.fields = fields;
	}

}