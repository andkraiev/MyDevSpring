/**
 * Created by Andrii on 2/14/2018.
 */

public with sharing class OpportunityCloneController {
    @auraenabled
    public static SObject getAllFields(Id apId) {

        DescribeSObjectResult describeResult = apId.getSObjectType().getDescribe();

        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());

        String query =
                ' SELECT ' +
                        String.join(fieldNames, ',') +
                        ' FROM ' +
                        describeResult.getName() +
                        ' WHERE ' +
                        ' id = :apId ' +
                        ' LIMIT 1 '
        ;
        List<SObject> records = Database.query(query);
        return records[0];
    }
}