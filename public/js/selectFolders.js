YUI({skin: 'night'}).use('datatable', 'datasource', 'event', 'io', 'json-stringify','gallery-datatable-checkbox-select', function (Y) {
    var myDataSource = new Y.DataSource.IO({
        source: dataUrl
    });
    
    myDataSource.plug(Y.Plugin.DataSourceJSONSchema, {
        schema: {
            resultFields: ['folder']
        }
    }).plug(Y.Plugin.DataSourceCache, {
        max: 3
    });
    
    var table = new Y.DataTable({
        columns: [
        {   key: 'folder', 
            label: 'Folder Name',
            width: '400px',
            primaryKey: true
        }],
        data: [{folder:""}],
        checkboxSelectMode: true
    });
    
    table.plug(Y.Plugin.DataTableDataSource, {
        datasource: myDataSource
    });
    
    table.render("#folderDataTable").showMessage('loadingMessage');
    table.datasource.load();
    table.detach('*:change');

    var button = Y.one("#submitBtn");
    button.on("click", function (e) {
        var uri = "/selectFolders";
        var ml  = table.get('checkboxSelected');
        var toReturn = [];
        var j = 0;
        Y.Array.each(ml, function (item) {
            if (item.tr) {
                var data = item.record.getAttrs(['select','folder']);
                toReturn[j] = data.folder;
                j++;
            }
        });

        var config = {
            method: 'POST',
            data: Y.JSON.stringify(toReturn),
            headers: { 'Content-Type': 'application/json' },
            sync: true,
            on: {
                complete: function () { window.location = '/'; }
            }
        };
        var request = Y.io(uri, config);
    });
});
