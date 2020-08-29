import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo} from 'lightning/uiObjectInfoApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { refreshApex } from '@salesforce/apex';
import initTable from '@salesforce/apex/LightningTableController.initTable';
import loadAllRecords from '@salesforce/apex/LightningTableController.loadAllRecords';
import no_records from '@salesforce/label/c.RelatedRecords_Table_No_Records_Message';
import lblClose from '@salesforce/label/c.Close';
import lblCancel from '@salesforce/label/c.Cancel';
import lblNext from '@salesforce/label/c.Next';
import lblNew from '@salesforce/label/c.New';
import lblSelectRecordType from '@salesforce/label/c.Select_a_record_type';
import lblViewAll from '@salesforce/label/c.View_All';

const actions = [{label: 'View', name:'viewRecord'}];
export default class RelatedRecords extends NavigationMixin(LightningElement)
{
    //API
    @api relatedObject;
    @api label;
    @api recordId;
    @api relatedField;
    @api icon;
    @api fieldSet;
    @api where_clause = '';
    @api sortDirection;
    @api sortedBy;
    @api soqlLimit;
    @api objectApiName;
    @api inlineEdit = false;
    @api colAction = false;
    @api enableNew;
    labels = {
        no_records
        , lblClose
        , lblCancel
        , lblNext
        , lblNew
        , lblSelectRecordType
        , lblViewAll
    };

    //TRACK
    @track columns;
    @track records;
    @track loadMoreStatus;
    @track isLoading;
    @track isLoadingForm;
    @track showNew;
    @track totalNumberOfRows = 0;
    @track table;
    @track rowCount;
    @track hasMore;
    @track relatedObjectInfo;
    @track canCreateNew;
    @track relatedObjectLabel;
    @track newRecordApiName;
    @track recordTypes;
    @track selectedRecordType

    @wire(getObjectInfo, { objectApiName: '$relatedObject' })
    wiredRelatedObjectInfo({error, data})
    {
        if(data){
            this.relatedObjectInfo = data;
            this.canCreateNew = this.relatedObjectInfo.createable && this.enableNew;
            this.relatedObjectLabel = this.relatedObjectInfo.label;
            this.newRecordApiName = this.relatedObjectInfo.apiName;
            this.recordTypes = [];
            for(var attr in data.recordTypeInfos){
                var item = data.recordTypeInfos[attr];
                if(item.available !== true
                    || item.master === true) continue;
                let rtOption = {};
                rtOption.value = item.recordTypeId;
                rtOption.label = item.name;
                this.recordTypes.push(rtOption);
                if(item.defaultRecordTypeMapping === true)
                {
                    this.selectedRecordType = rtOption.value;
                }
            }
        }
    }
    
    @wire(initTable, { recordId: '$recordId'
                        , relatedField: '$relatedField'
                        , relatedObject: '$relatedObject'
                        , fieldSetName: '$fieldSet'
                        , whereClause: '$where_clause'
                        , recLimit : '$soqlLimit'
                        , sortBy : '$sortedBy'
                        , sortDirection : '$sortDirection'
                        }
        )
        wiredTable({error, data})
        {
            var sortedData;
            this.isLoading = true;
            if(data)
            {
                this.table = JSON.parse(JSON.stringify(data));
                this.rowCount = 0;
                //this.records = this.table && this.table.rowCount > 0 ? JSON.parse(JSON.stringify(this.table.records)) : undefined;
                if(this.table && this.table.rowCount > 0 )
                {
                    sortedData = this.sortData(this.sortedBy, this.sortDirection, this.table.records);
                    this.records = JSON.parse(JSON.stringify(sortedData));
                }
                if(this.table.totalRowCount > this.table.rowCount)
                {
                    this.rowCount = this.table.rowCount + '+';
                    this.hasMore = true;
                }
                else
                {
                    this.rowCount = this.table.rowCount;
                    this.hasMore = false;
                }
                this.totalNumberOfRows = this.table ? this.table.rowCount : 0;
                this.columns = this.table.columns;
                this.columns.push({ type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'right' } });
                
                this.isLoading = false;
            }
            else
            {
                this.table = undefined;
                this.totalNumberOfRows = 0;
                console.log(error);
            }
            
        }

    getRefreshRecords(event)
    {
        // this.isLoading = true;
        // refreshApex(initTable());
        // this.isLoading = false;
    }

    getSelectedName(event) {
        // var selectedRows = event.detail.selectedRows;
        // var recordIds=[];
        // if(selectedRows.length > 0) {
        //     for(var i =0 ; i< selectedRows.length; i++) {
        //         recordIds.push(selectedRows[i].Id);
        //     }
            
        //    const selectedEvent = new CustomEvent('selected', { detail: {recordIds}, });
        //    // Dispatches the event.
        //    this.dispatchEvent(selectedEvent);
        // }
        
    }
    loadAllData(event) {
        //Display a spinner to signal that data is being loaded
        //Display "Loading" when more data is being loaded
        this.isLoading = true;
        loadAllRecords({fieldSOQL: this.table.fieldSOQL
                        , sObjectType: this.table.sObjectType
                        , whereClause: this.table.whereClause})
        .then(result => {
            this.records = result; 
            this.table.records = this.records;
            this.hasMore = false;
            this.rowCount = this.records.length;
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.showErrorToast('Error loading more Data', error);
        });
    }
        loadMoreData(event) {
            //Display a spinner to signal that data is being loaded
            //Display "Loading" when more data is being loaded
            // var tableJson;
            // this.isLoading = true;
            // tableJson = JSON.stringify(this.table);
            // loadMoreRecords({tableJson: tableJson})
            // .then(result => {
            //     const currentData = result;
            //     //Appends new data to the end of the table
            //     const newData = this.records.concat(currentData);

            //     this.records = newData; 
            //     this.table.records = newData;
            //     if (this.records.length >= this.totalNumberOfRows) {
            //         this.isLoading = false;
            //     } else {
            //         this.isLoading = false;
            //     }
            // })
            // .catch(error => {
            //     this.isLoading = false;
            //     this.showErrorToast('Error loading more Data', error);
            // });
        }

        handleRowAction(event) {
            const actionName = event.detail.action.name;
            const row = event.detail.row;
            switch (actionName) {
            // case 'edit':
            //     this.editRecord(row);
            //     break;
            // case 'view':
            //     this.viewRecord(row);
            //     break;
            // case 'delete':
            //     this.deleteRecord(row);
            //     break;
            default:
                this.viewRecord(row);
                break;
            }
        }
    
		//currently we are doing client side delete, we can call apex tp delete server side
        deleteRecord(row) {
            // const { id } = row;
            // const index = this.findRowIndexById(id);
            // if (index !== -1) {
            //     this.records = this.records
            //         .slice(0, index)
            //         .concat(this.records.slice(index + 1));
            // }
        }
    
        findRowIndexById(id) {
            // let ret = -1;
            // this.records.some((row, index) => {
            //     if (row.id === id) {
            //         ret = index;
            //         return true;
            //     }
            //     return false;
            // });
            // return ret;
        }
    

        editRecord(row) {
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: row.Id,
            //         actionName: 'edit',
            //     },
            // });
        }
        
        viewRecord(row) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    actionName: 'view',
                },
            });
        }

		//When save method get called from inlineEdit
        handleSave(event) {

            // var draftValuesStr = JSON.stringify(event.detail.draftValues);
            // updateRecords({ sobList: this.records, updateObjStr: draftValuesStr, objectName: this.relatedObject })
            // .then(result => {
                
            //     this.dispatchEvent(
            //         new ShowToastEvent({
            //             title: 'Success',
            //             message: 'Records updated',
            //             variant: 'success'
            //         })
            //     );
            //     // Clear all draft values
            //     this.draftValues = [];
            //     return refreshApex(this.wiredsObjectData);
            // })
            // .catch(error => {
            //     console.log('-------error-------------'+error);
            //     console.log(error);
            // });

        }

        // The method will be called on sort click
        updateColumnSorting(event) {
            this.sortedBy = event.detail.fieldName;
            this.sortDirection = event.detail.sortDirection; 
            //this.records = this.sortData(this.sortedBy, this.sortDirection, this.records); 
            const data = this.sortData(this.sortedBy, this.sortDirection, this.records);
            this.records = JSON.parse(JSON.stringify(data));
       }

       sortData = function(sortBy, sortDirection, data)
       {
            var key, reverse;
            if(!sortBy || !sortDirection)
            {
                return data;
            }

            //function to return the value stored in the field
            key = function(a) { return a[sortBy]; }
            reverse = sortDirection === 'asc' ? 1: -1;
            data.sort(function(a,b){ 
                var a = key(a) ? key(a) : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            });
            return data;
       }
    handleNew(){
        //this.showNew = true;
        if(this.recordTypes 
            && this.recordTypes.length > 0)
        {
            this.showNew = true;
        }
        else{
            this.showCreate(null);
        }
    }

    setRecordType(event){
        this.selectedRecordType = event.detail.value;
    }

    showCreate(event){
        var defaults = {};
        defaults[this.relatedField] = this.recordId;
        const defaultValues = encodeDefaultFieldValues(defaults);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.relatedObject,
                actionName: 'new'
            }
            ,
            state: {
                recordTypeId: this.selectedRecordType
                , defaultFieldValues: defaultValues
            }
        });
    }

    handleCloseNew(){
        this.showNew = false;
    }

    showErrorToast(title, error)
    {
        var stackTrace;
        if (error && error.body && Array.isArray(error.body)) {
            error = error.body.map(e => e.message).join(', ');
        } else if (error && error.body && typeof error.body.message === 'string') {
            stackTrace = error.body.stackTrace;
            error = error.body.message;
            if(stackTrace)
            {
                error = error + ' (' + stackTrace + ')';
            }
        }
        else if(error && typeof error.message === 'string')
        {
            error = error.message;
            if(error.stackTrace)
            {
                error = error + '(' + error.stackTrace + ')';
            }
        }
        
        error = error ? error : 'error occurred';
        this.showToast(title, error, 'error');
    }

    showToast(title, message, variant)
    {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }
}