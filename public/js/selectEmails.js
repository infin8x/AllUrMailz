YUI({skin: 'night'}).use('datatable','datasource','json-parse', function (Y) {
    var myDataSource = new Y.DataSource.IO({
        source: dataUrl
    });
    var myCallback = {
        success: function(e){
            alert(e.response);
        },
        failure: function(e){
            alert("failed: " + e.error.message);
        }
    };
    
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
    
    var table = new Y.DataTable({
        columns: [
        {   key: 'fromName', 
            label: 'Sender'
        },
        {   key: 'subject', 
            label: 'Subject'
        },
        {   key: 'timeSent',
            label: 'Time'
        },
        {   key: 'hashId',
            label: 'Body',
            allowHTML:  true,
            formatter: function(o) {
                var value = Y.Escape.html(o.value);
                return '<a href="' + emailBaseUrl + value + '" target="_blank">Email body' + '</a>';
            }
        }]
    });
    
    table.plug(Y.Plugin.DataTableDataSource, {
        datasource: myDataSource
    });
    
    table.render("#emailListDataTable").showMessage('loadingMessage');
    table.datasource.load();
});