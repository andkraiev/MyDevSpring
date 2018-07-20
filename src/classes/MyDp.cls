/*
Sortable Data Grid
Example implementation
*/
global with sharing class mydp implements sortablegrid.sdgIDataProvider {
    //Whether to show this class in the AppBuilder.
    //Usually set to true.  Set to false if you intend to inherit this class and you don't want this class to be visible.
    global static Boolean isUserSelectable()
    {
        return true;
    }
    //Method to retrieve data:
    //SDG object - which is usually irrelevant in the case of custom Apex data providers
    //SDGRequest - provides the details of what's being requested:
    //  String ParentRecordID: recordId of the page
    //  Integer Pagesize: how many records the client is requesting
    //  Integer PageId: Number of the page of data (note this is 1 based)
    //  String SortColumn:  Id of column that's being searched for (Id from the SDGField created in LoadSDG)
    //  String SortOrder: A or D
    //  List<sortablegrid.SDGFilter> Filters: list of filters
    //      String FilterValue: value provided in UI for filtering
    //      String FilterOperator: value provided as operator ie GT greater than, = equals, etc
    //Note there are other fields available in the request, but they're for routing to other data providers - in this case, you can ignore them.
    //
    global static sortablegrid.SDGResult getData(sortablegrid.SDG coreSDG,  sortablegrid.SDGRequest request)
    {
        sortablegrid.SDGResult result = new sortablegrid.SDGResult();
        try
        {
            integer dataoffset = (request.pageid-1) * request.pagesize;
            integer datalimit = request.PageSize;
            List<String> filters = new List<String>();
            //EXAMPLE FILTER - not complete!
            if (request.Filters!=null)
            {
                for(sortablegrid.SDGFilter filter: request.filters)
                {
                    String  fo = filter.FilterOperator;
                    String fv = String.escapeSingleQuotes(filter.FilterValue.trim());
                    String fid = filter.SDGFieldID;
                    if (fid == '1') //this maps to the SDGField with ID=1 => field is 'Name'
                    {
                        if  (String.isNotBlank(fv))
                        {
                            if (fo == '=')
                            {
                                filters.add('name = ' + fv);
                            }
                            if(fo=='CONTAINS')
                            {
                                filters.add('name like \'%' + fv + '%\'');
                            }
                            if (fo=='STARTS')
                            {
                                filters.add('name like \'' + fv + '%\'');
                            }
//                            if (fo=='STARTS')
//                            {
//                                filters.add('name like \'' + fv + '%\'');
//                            }
                            //ETC ETC
                        }
                    }
                }
            }
            String filterstring = String.join(filters, ' AND ');
            if (!String.isblank(filterstring))
            {
                filterstring = 'WHERE ' + filterstring;
            }
            String sSortClause = '';
            if (String.isNotBlank(request.SortColumn))
            {
                if (request.sortOrder == 'A')
                    sSortClause = ' ORDER BY name ASC NULLS FIRST';
                else
                        sSortClause = ' ORDER BY name DESC NULLS LAST';
            }
            string query = 'select Account_Name__c,CurrencyISOCode, Actual__c, Impact__c , Potential__c, Last_Touched_Date__c , Potential_Contacts__c, Product_Transitions__c from account ' + filterstring + ' ' + sSortClause + ' limit :datalimit offset :dataoffset';
            result.data = database.query(query);
            result.query=query; //Only used for the debug log
            result.FullQueryCount = 0;
            if (result.data!=null)
            {
                result.FullQueryCount = result.data.size();
            }
            result.pagecount = 1;
            result.isError = false;
            result.ErrorMessage = '';
        }
        catch (Exception ex)
        {
            result.isError = true;
            result.ErrorMessage = ex.getMessage();
        }
        return result;
    }
    //Entry point to get the configuration.
    //Implement this to return a full SDG of fields and actions
    global   sortablegrid.SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        system.debug('CustomDataProviderExample:LoadSDG');
        sortablegrid.SDG CoreSDG = new sortablegrid.SDG( 'CustomDataProviderExample' );
        CoreSDG.SDGActions = getActions();
        CoreSDG.SDGFields = getFields();
        return CoreSDG;
    }
    //Specify the actions available on the grid:
    //String Id: unique identifier
    //String Label: for the link
    //String Event: Lightning Event to raise
    //String Type: Render as a 'List Button', 'Row Button', 'Row', 'List', 'Multi List'
    //String Payload: payload for the event - can be parameterised with #delimited# values
    //String Icon: Icon to render
    //Integer actionorder: Order of buttons/menuitems
    private List<sortablegrid.SDGAction> GetActions()
    {
        List<sortablegrid.SDGAction> actions = new List<sortablegrid.SDGAction>();
        actions.add(new sortablegrid.SDGAction('1', 'New', 'e.force:createRecord', 'List Button', '{"entityApiName": "Account"}', 'utility:new', 1));
//        actions.add(new sortablegrid.SDGAction('2', 'Edit', 'e.force:editRecord', 'Row Button', '{"recordId": "#Id#"}', 'utility:edit', 2));
//        actions.add(new sortablegrid.SDGAction('3', 'Edit Creator', 'e.force:editRecord', 'Row Button', '{"recordId": "#CreatedBy.Id#"}', 'utility:edit',3 ));
        return actions;
    }
    //Specify the behaviour of the grid - ie which fields to display on the page:
    //String ID - used to key filters back to the request
    //String Label: Column Header text
    //String ColumnName: Name within the SOQL - used by the LC to retrieve the value from the query results
    //String FieldType: STRING, NUMBER, DATE etc - determines rendering
    //String FieldStyle: Custom Renderer options:  Summarize:Total, Age etc
    //Boolean canSort: Make the columns click to sort (does not actually perform sorting)
    //Boolean canFilter: Renders a filter component (does not actually perform filtering)
    //Boolean isHTMLFormatted: Do you want to render the output as raw unescaped html.  Usually false.
    //List<sortablegrid.AuraSelectOption> options: List of piclist options for dropdowns for filters
    //Integer FieldOrder: order on the page
    private List<sortablegrid.SDGField> GetFields()
    {
        List<sortablegrid.SDGField> fields = new List<sortablegrid.SDGField>();
        fields.add( new sortablegrid.SDGField('1', 'Account Name', 'Account_Name__c', 'STRING', '', true, true, true, null, 1));
        fields.add( new sortablegrid.SDGField('2', 'Actual', 'Actual__c', 'CURRENCY', '', true, true, false, null, 2));
        fields.add( new sortablegrid.SDGField('3', 'Impact', 'Impact__c', 'CURRENCY', '', true, true, false, null, 3));
        fields.add( new sortablegrid.SDGField('4', 'Potential', 'Potential__c', 'CURRENCY', '', true, true, false, null, 4));
        fields.add( new sortablegrid.SDGField('5', 'Last Touched Date', 'Last_Touched_Date__c', 'DATE', '', true, true, false, null, 5));
        fields.add( new sortablegrid.SDGField('6', 'Potential Contacts', 'Potential_Contacts__c', 'INTEGER', '', true, true, false, null, 6));
        fields.add( new sortablegrid.SDGField('7', 'Product Transitions', 'Product_Transitions__c', 'INTEGER', '', true, true, false, null, 7));
        return fields;
    }
}