@isTest
private class LightningControllerTest {

	@testSetup static void testSetup(){
		UnitTestHelper.addMockFieldSet(new FieldSet('Detail','Detail__c', 'Description', 'Detail', 'Account', new List<FieldSetMember>{new FieldSetMember(Account.Name)}));
	}
	
	@isTest static void test_QuerySObject() {
		//Arrange
		Account account = UnitTestHelper.createAccount('querySObject', '1');
		insert account;

		String query = 'SELECT Id FROM Account WHERE Id = \'' + account.Id + '\'';

		//Act
		test.startTest();
		SObject result = LightningController.querySObject(query);
		SObject[] results = LightningController.querySObjects(query);		
		test.stopTest();

		//Assert
		System.assertNotEquals(null, result);
		System.assertEquals(account.Id, result.Id);
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals(account.Id, results[0].Id);
	}
	
	@isTest static void test_GetFields() {
		//Arrange
		UnitTestHelper.addMockFieldSet(new FieldSet('Detail','Detail__c', 'Description', 'Detail', 'Account', new List<FieldSetMember>{new FieldSetMember(Account.Name)}));
		//Act
		test.startTest();
		List<FieldSet> results = LightningController.getFields('Account', 'Detail__c');
		test.stopTest();

		//Assert
		System.assertEquals(1, results.size());
	}

	@isTest static void test_GetFieldsException() {
		//Arrange
		Boolean exceptionThrown = false;
		String message = '';
		String sObjectName = 'Account';
		String fieldsets = 'test';
		UnitTestHelper.addMockFieldSet(new FieldSet('Detail','Detail__c', 'Description', 'Detail', 'Account', new List<FieldSetMember>{new FieldSetMember(Account.Name)}));

		//Act
		test.startTest();
		try{
			LightningController.getFields(sObjectName, fieldsets);
		}catch(LightningController.LightningException e){
			exceptionThrown = true;
			message = e.getMessage();
		}
		test.stopTest();

		//Assert
		System.assertEquals(true, exceptionThrown);
		System.assert(message.contains(sObjectName));
		System.assert(message.contains(fieldsets));
	}
	
}