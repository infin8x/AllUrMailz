YUI({skin: 'night'}).use('dataemailTable','datasource','json-parse', function (Y) {
    var myDataSource = new Y.DataSource.IO({
        source: dataUrl
    });
    
    myDataSource.plug(Y.Plugin.DataSourceJSONSchema, {
        schema: {
            resultFields: [
                'fromName',
                'fromEmail',
                'to',
                'subject',
                'timeSent',
                'hashId'
            ]
        }
    }).plug(Y.Plugin.DataSourceCache, {
        max: 3
    });
    
    emailTable.plug(Y.Plugin.DataTableDataSource, {
        datasource: myDataSource
    });
    
    emailTable.render("#emailListDataTable").showMessage('loadingMessage');
    emailTable.datasource.load();
});