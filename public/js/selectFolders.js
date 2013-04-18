YUI({skin: 'night'}).use('datatable','datatable-scroll', 'datasource', 'event', 'io-form', 'json-stringify','gallery-datatable-checkbox-select', function (Y) {
    var heightToWorkWith = document.height - document.getElementById('navbar').clientHeight - 30;
    
    var table = new Y.DataTable({
        scrollable: "y",
        height: ((heightToWorkWith) - 60) + "px",
        columns: [
        {   key: 'folder', 
            label: 'Folder Name',
            width: '90%',
            primaryKey: true
        }],
        data: [{folder:""}],
        checkboxSelectMode: true
    });
    
    table.render("#folderDataTable").showMessage('Enter your credentials to load the folder list');
    table.detach('*:change');
    
    var button = Y.one("#loadFoldersBtn");
    button.on("click", function (e) {
        var request = Y.io("https://" + window.location.hostname + "/getEmail", {
            method: 'POST',
            form: {id: "credsForm"},
            sync: true
        });
        
        var myDataSource = new Y.DataSource.IO({
            source: '/data/selectFolders'
        }).plug(Y.Plugin.DataSourceJSONSchema, {
            schema: {
                resultFields: ['folder']
            }
        });
    
        table.plug(Y.Plugin.DataTableDataSource, {
            datasource: myDataSource
        });
        
        table.datasource.load();
    });

    var button = Y.one("#submitBtn");
    button.on("click", function (e) {
        var ml  = table.get('checkboxSelected');
        var toReturn = [];
        var j = 0;
        Y.Array.each(ml, function (item) {
            if (item.tr) {
                var data = item.record.getAttrs(['select','folder']);
                toReturn[j] = encodeURI(data.folder);
                j++;
            }
        });

        $('#theModal').modal('show'); 
        
        var request = Y.io("/selectFolders", {
            method: 'POST',
            data: Y.JSON.stringify(toReturn),
            headers: { 'Content-Type': 'application/json' },
            on: {complete: function () { window.location = '/viewEmail'; }}
        });
    });
});
