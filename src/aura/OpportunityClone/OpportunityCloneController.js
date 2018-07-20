/**
 * Created by Andrii on 2/14/2018.
 */
({
    doInit: function (component, event, helper) {
        helper.getData(component, 'c.getAllFields', 'v.mydata', {'apId': component.get('v.recordId')}, function () {
            var oppObjectToClone = component.get('v.mydata');
            //fields to replace
            //examples of filed replacement
            delete oppObjectToClone.Id;
            oppObjectToClone.Amount = 1234;
            var createAcountContactEvent = $A.get("e.force:createRecord");
            createAcountContactEvent.setParams({
                "entityApiName": "Opportunity",
                "defaultFieldValues": oppObjectToClone
            });

            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();

            createAcountContactEvent.fire();
        }, false);
    }
})