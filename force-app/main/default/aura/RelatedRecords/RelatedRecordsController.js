({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);
	},

	handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
             console.log(eventParams);
             console.log("Record is loaded successfully.");
            if(component.get('v.sourceRecord') != null && component.get('v.columns').length != 0){
            	helper.getRelatedRecords(component, event);
            }
           // record is loaded (render other component which needs record data value)
            
        } else if(eventParams.changeType === "CHANGED") {
            console.log("Changed: " + eventParams);
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
             console.log("Error: " + eventParams);
            // there’s an error while loading, saving, or deleting the record
        }
    },

    waiting: function(component, event, helper) {
		document.getElementById("spinner").style.display = "";
	},
	 
	doneWaiting: function(component, event, helper) {
		document.getElementById("spinner").style.display = "none";
	},    
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    }
})