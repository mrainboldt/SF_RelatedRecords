/**
 * LightningControllerTest test coverage for LightningController
 * @author M Rainboldt
 * @created August 2019
 */
@isTest
private class LightningControllerTest
{
	public static String testFieldSetName = 'TEST';
	
	/**
	 * @description test that the querySObject methods work both for single object and list of object
	 */
	@isTest static void test_QuerySObject()
	{
		//Arrange
		User user = UnitTestHelper.createUser('querySObject');
		insert user;

		String query = 'SELECT Id FROM User WHERE Id = \'' + user.Id + '\'';

		//Act
		test.startTest();
		SObject result = LightningController.querySObject(query);
		SObject[] results = LightningController.querySObjects(query);		
		test.stopTest();

		//Assert
		System.assertNotEquals(null, result);
		System.assertEquals(user.Id, result.Id);
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals(user.Id, results[0].Id);
	}
	
	/**
	 * @description test both that the getColumns&DefaultValues and the getFieldSoql work as expected
	 */
	@isTest static void test_GetColumns_FieldSOQL()
	{
		//Arrange

		//Act
		Test.startTest();
		List<Column> results = LightningController.getColumnsAndDefaultValues('User', testFieldSetName, null);
		String soqlResult = LightningController.getFieldSOQL(results);
		Test.stopTest();

		//Assert
		System.assertEquals(1, results.size());
		System.assert(soqlResult.containsIgnoreCase(results[0].fieldName));
	}
	
	/**
	 * @description test that getColumns throws an exception
	 */
	@isTest static void test_GetColumnsException()
	{
		//Arrange
		Boolean exceptionThrown = false;
		String message = '';
		String sObjectName = 'User';
		String fieldSetName = 'fail';

		//Act
		test.startTest();
		try{
			LightningController.getColumnsAndDefaultValues(sObjectName, fieldSetName, null);
		}catch(LightningController.LightningException e){
			exceptionThrown = true;
			message = e.getMessage();
		}
		test.stopTest();

		//Assert
		System.assertEquals(true, exceptionThrown);
		System.assert(message.contains(sObjectName));
		System.assert(message.contains(fieldSetName));
	}
	
	/**
	 * @description test getIcon & getIcons functionality
	 */
	@isTest
	static void getIcon(){
		//ARRANGE
		Icon__mdt icon = [SELECT Id
								, DeveloperName 
						FROM Icon__mdt 
						LIMIT 1];

		//ACT
		Test.startTest();
		Icon__mdt result = LightningController.getIcon(icon.DeveloperName);
		Test.stopTest();

		//ASSERT
		System.assertEquals(icon.Id, result.Id);
	}
}