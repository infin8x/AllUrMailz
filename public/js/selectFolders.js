YUI({skin: 'night'}).use('datatable', 'event', 'io', 'json-stringify','gallery-datatable-checkbox-select', function (Y) {
    // A table from data with keys that work fine as column names
    var table = new Y.DataTable({
        columns: [
        {   key: 'folder', 
            label: 'Folder Name',
            width: '400px',
            primaryKey: true
        }],
        data: data,
        checkboxSelectMode: true
    });
    table.render("#folderDataTable");
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
            sync: true
        };
        var request = Y.io(uri, config);
    });
});
