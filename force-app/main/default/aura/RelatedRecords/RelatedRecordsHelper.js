({
	doInit : function(component, event) {
		this.validateRequiredInputs(component, event);
		
	},

	getFields : function(component, event){
		var action = component.get("c.getFields");
        action.setParams({
            "sObjectName": component.get('v.targetObject'),
            "fieldSetString": component.get('v.fieldSet')
        });
    	action.setCallback(this,function(response) {
    		var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
        		//component.set("v.relatedRecord", response.getReturnValue()); 
        		component.set("v.columns", response.getReturnValue());
        		var fieldset = response.getReturnValue()[0];
        		var columns = [];
        		for(var i = 0; i < fieldset.fields.length; i++){
        			var field = fieldset.fields[i];
        			var col = {};
        			col.label = field.label;
        			col.fieldName = field.fieldPath;
                    col.sortable = true;
                    col.type = field.type;
                    /*if(field.type === 'DATETIME'
                        || field.type === 'DATE'){
                        col.type = 'date';
                    }else if(field.type === 'PICKLIST'
                            || field.type === 'TEXT'){
                        col.type = 'text';
                    }else if(field.type === 'PHONE'){
                        col.type = 'phone';
                    }else if(field.type === 'URL'){
                        col.type = 'url';
                    }else if(field.type === 'EMAIL'){
                        col.type = 'email';
                    }else{
                        col.type = 'text';
                    }*/
        			columns.push(col);
        		}
        		component.set("v.columns", columns);
        		if(component.get('v.sourceRecord') != null && component.get('v.relatedRecords').length == 0){
        			this.getRelatedRecords(component, event);
        		}
        	}else{
        		this.handleErrors(component, "Error: ",response);
        		console.log(response);
        	}
		});
    	$A.enqueueAction(action);
	},
	
	getRelatedRecords : function(component, event) {
		var matchId = component.get('v.sourceRecord').fields[component.get('v.sourceField')].value
		var fields = component.get('v.columns');
		var columns = '';
        var sObject = component.get('v.targetObject');
        var name = sObject.endsWith('x') ? 'Name__c' : 'Name';
        var hasId = false;
		for(var i =  0; i < fields.length; i++){
            var fieldName = fields[i].fieldName;
            if(fieldName.toLowerCase() == 'Id'.toLowerCase()){
                hasId = true;
            }
			columns +=  fieldName + ',';
            if(fields[i].type === 'REFERENCE'){
                var fieldName = fields[i].fieldName;
                if(fieldName.toLowerCase().endsWith("id")){
                    columns += fieldName.slice(0, fieldName.length-2) + '.' + name + ',';
                }else if(fieldName.toLowerCase().endsWith("__c")){
                    columns += fieldName.slice(0, fieldName.length-1) + 'r.' + name + ',';
                }                
            }
		}
		columns = columns.slice(0,-1);
        columns += hasId ? '' : ',Id';
		var query = 'SELECT ' + columns + ' FROM ' + component.get('v.targetObject') 
					+ ' WHERE ' + component.get('v.targetField')
					+ ' = \'' + matchId + '\''
					+ ' AND Id != \'' + component.get('v.recordId') + '\'';
		var action = component.get("c.querySObjects");
        action.setParams({
            "query": query
        });
    	action.setCallback(this,function(response) {
            debugger;
    		var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
        		component.set("v.relatedRecords", response.getReturnValue());
                //this.sortData(component, component.get('v.sortedBy'), component.get('v.sortedDirection'));
        	}else{
        		this.handleErrors(component, "Error: ",response);
        		console.log(response);
        	}
		});
    	$A.enqueueAction(action);
	},

	sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.relatedRecords");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.relatedRecords", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

	validateRequiredInputs : function(component, event){
		var relObjectName = component.get('v.targetObject');
		var sourceField = component.get('v.sourceField');
        var targetField = component.get('v.targetField');
		var fieldSets = component.get('v.fieldSet');
		if(relObjectName == null || relObjectName == undefined){
            this.generateMessage(component
		                        , 'Initialization Error'
		                        , 'Contact your System Administrator and have them define a SObject in the App Builder.'
		                        ,'error'
		                        , false);
		}else if(sourceField == null || sourceField == undefined){
            this.generateMessage(component
		                        , 'Initialization Error'
		                        , 'Contact your System Administrator and have them define a field on the current object in the App Builder.'
		                        ,'error'
		                        , false);
		}else if(targetField == null || targetField == undefined){
            this.generateMessage(component
            					, 'Initialization Error'
		                        , 'Contact your System Administrator and have them define a field on the related object in the App Builder.'
		                        ,'error'
		                        ,false);
		}else if(fieldSets == null || fieldSets == undefined){
            this.generateMessage(component
		                        , 'Initialization Error'
		                        , 'Contact your System Administrator and have them define 1 or more field sets to display in the App Builder.'
		                        ,'error'
		                        , false);
        }else{
        	this.getFields(component, event);
        }
	},

	handleErrors : function(component, title, response){
        console.log(response.getError());
        for(var key in response.getError()[0].fieldErrors){
            this.generateMessage(component
            					, 'Field Error'
            					, response.getError()[0].fieldErrors[key][0].message
            					, 'error'
            					, false);  
        }
        for(var key in response.getError()[0].pageErrors){
        	this.generateMessage(component
            					, 'Page Error'
            					, response.getError()[0].pageErrors[key][0].message
            					, 'error'
            					, false); 
        }
    },

    showToast: function(component, title, message,type){
        if(typeof(message) === "string"){
            this.generateToast(component, title, message, type);	
        }else if(typeof(message) === "object"){
            for(var key in  message){
                this.generateToast(component, title, message[key], type);
            }
        }
        
	},
    generateToast: function(component, title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "sticky"
        });
        toastEvent.fire();	
    },
    generateMessage : function(component, title, text, severity, closable){
    	var messages = component.get('v.messages');
    	var message = {};
    	message.title = title;
    	message.severity = severity;
    	message.message = text;
    	message.closable = closable;
    	messages.push(message);
    	component.set('v.messages', messages);
    }
})