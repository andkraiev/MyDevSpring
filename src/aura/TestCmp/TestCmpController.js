({
    onsuccess : function(component, event, helper) {
        component.set('v.isCreated',true);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Everything went well!",
            "type": "success"
        });
        toastEvent.fire();


	},
    onsubmit : function (component, event, helper) {
       var nameField = component.find('recordName');
       debugger;
    },
    onerror : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "error!",
            "message": "Please review all errors mentioned above",
            "type": "error"
        });
        toastEvent.fire();
        debugger;
    }
})