/**
 * @description test coverage for LightningTableController
 * @author      M Rainboldt
 * @created     AUG 2018
 */
@isTest(isParallel=false)
private class LightningTableControllerTest {
    /**
     * @description create manager and 2 users
     */
    @TestSetup
    static void setup(){
        User manager = UserTestDataFactory.generateTestUser();
        manager.Alias = 'Manager';
        insert manager;

        User user1 = UserTestDataFactory.generateTestUser();
        user1.Username = user1.Username + '1';
        user1.ManagerId = manager.Id;

        User user2 = UserTestDataFactory.generateTestUser();
        user2.Username = user2.Username + '2';
        user2.ManagerId = manager.Id;

        insert new List<User>{user1, user2};
    }
    /**
     * @description test general functionality
     */
    @isTest static void general()
    {
        //ARRANGE
        User sourceRecord = [SELECT Id, ManagerId 
                                FROM User 
                                WHERE Manager.Alias = 'Manager'
                                LIMIT 1];
        String recordId = sourceRecord.ManagerId;
        String relatedObject = 'User';
        String relatedField = 'ManagerId';
        String fieldSet = 'TEST';
        String whereClause = '';
        Integer recLimit = 1;

        //ACT
        Test.startTest();
        TableWrapper result = LightningTableController.initTable(recordId
                                                                , relatedField
                                                                , relatedObject
                                                                , fieldSet
                                                                , whereClause
                                                                , recLimit
                                                                , null
                                                                , null);
        List<SObject> allResult = LightningTableController.loadAllRecords(result.fieldSOQL, result.sObjectType, result.whereClause);
        Test.stopTest();

        //ASSERT
        System.assert(!result.records.isEmpty(), 'Records should not be empty.');
        System.assert(result.rowCount > 0, 'RowCount should be greater than 1.');
        System.assert(result.totalRowCount > result.rowCount, 'Total row count should be greater than row count.');
        System.assertEquals(result.totalRowCount, allResult.size());
        System.assertNotEquals(null, result.columns);
    }

    /**
     * @description test where clause functionality
     */
    @isTest static void test_WhereClause()
    {
        //ARRANGE

        User sourceRecord = [SELECT Id
                            , ManagerId
                            , Name 
                            FROM User 
                            WHERE Manager.Alias = 'Manager'
                            LIMIT 1];
        
        String recordId = sourceRecord.ManagerId;
        String relatedObject = 'User';
        String relatedField = 'ManagerId';
        String fieldSet = 'TEST';
        Integer recLimit = 1;
        String whereClause = 'Name != \'' + sourceRecord.Name + '\'';

        //ACT
        Test.startTest();
        TableWrapper result = LightningTableController.initTable(recordId, relatedField, relatedObject, fieldSet, whereClause , recLimit, null, null);
        Test.stopTest();

        //ASSERT
        System.assertEquals(0, result.rowCount);
        System.assertNotEquals(null, result.columns);
        System.assert(result.records.isEmpty());
    }
}