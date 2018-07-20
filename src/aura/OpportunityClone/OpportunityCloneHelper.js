/**
 * Created by Andrii on 2/14/2018.
 */
({getData: function (cmp, methodName, varName, params, onFinish, isStorable) {
    var action = cmp.get(methodName); // Define the server side controller
    if (params) {
        action.setParams(params);
    }

    if (isStorable) {
        action.setStorable();
    }

    action.setCallback(this, function (response) {
        debugger;
        var state = response.getState(); // Make sure function exist.
        if (state === "SUCCESS") { //proceed when the function exist only
            if (varName != null) {
                cmp.set(varName, response.getReturnValue());
            }
            if (onFinish) {
                // Run additional code optionally
                onFinish(response.getReturnValue());
            }
        }
    });

    $A.enqueueAction(action); // Actual Asynchronous call to Server
}})