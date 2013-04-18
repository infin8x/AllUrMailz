YUI({skin: 'night'}).use('datatable', 'datatable-scroll', 'datasource', 'event', 'json-stringify', function (Y) {
    var heightToWorkWith = document.height - document.getElementById('navbar').clientHeight - 30;
    
    document.getElementById('messageFrame').height = heightToWorkWith / 2;

    var accountDataSource = new Y.DataSource.IO({
        source: '/data/accounts'
    }).plug(Y.Plugin.DataSourceJSONSchema, {
        schema: {
            resultFields: ['account']
        }
    });
        
    var accountTable = new Y.DataTable({
        scrollable: "y",
        height: ((heightToWorkWith / 4) - 10) + "px",
        columns: [
        {   key: 'account', 
            label: 'Email account'
        }],
        data: [{}]
    });
    
    var folderTable = new Y.DataTable({
        scrollable: "y",
        height: ((heightToWorkWith / 4) - 10) + "px",
        columns: [
        {   key: 'folder', 
            label: 'Email folder',
            primaryKey: true
        }],
        data: [{}]
    });
    
    var emailTable = new Y.DataTable({
        scrollable: "y",
        height: (heightToWorkWith / 2) + "px",
        columns: [
        {   key: 'fromName', 
            label: 'Sender'
        },
        {   key: 'subject', 
            label: 'Subject'
        },
        {   key: 'timeSent',
            label: 'Time'
        }],
        data: [{}]
    });
    
    accountTable.addAttr("selectedRow", { value: null });
    accountTable.delegate('click', function (e) {
        this.set('selectedRow', e.currentTarget);
    }, '.yui3-datatable-data tr', accountTable);
    
    folderTable.addAttr("selectedRow", { value: null });
    folderTable.delegate('click', function (e) {
        this.set('selectedRow', e.currentTarget);
    }, '.yui3-datatable-data tr', folderTable);
    
    emailTable.addAttr("selectedRow", { value: null });
    emailTable.delegate('click', function (e) {
        this.set('selectedRow', e.currentTarget);
    }, '.yui3-datatable-data tr', emailTable);

    accountTable.after('selectedRowChange', function (e) {
        var tr = e.newVal,           
            last_tr = e.prevVal,     
            rec = this.getRecord(tr);

        if ( !last_tr ) {} else {
            last_tr.removeClass("hl");
        }
        tr.addClass("hl");
        
        selectedAccount = rec.get('account')
        var folderDataSource = new Y.DataSource.IO({
            source: '/data/' + rec.get('account')
        }).plug(Y.Plugin.DataSourceJSONSchema, {
            schema: {
                resultFields: ['folder']
            }
        });
        
        folderTable.plug(Y.Plugin.DataTableDataSource, {
            datasource: folderDataSource
        });
        folderTable.showMessage('loadingMessage');
        folderTable.datasource.load();
    });
    
    folderTable.after('selectedRowChange', function (e) {
        var tr = e.newVal,           
            last_tr = e.prevVal,     
            rec = this.getRecord(tr);

        if ( !last_tr ) {} else {
            last_tr.removeClass("hl");
        }
        tr.addClass("hl");
        
        selectedFolder = rec.get('folder')
        var emailDataSource = new Y.DataSource.IO({
            source: '/data/' + selectedAccount + '/' + rec.get('folder')
        }).plug(Y.Plugin.DataSourceJSONSchema, {
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
        });
        
        emailTable.plug(Y.Plugin.DataTableDataSource, {
            datasource: emailDataSource
        });
        emailTable.showMessage('loadingMessage');
        emailTable.datasource.load();
    });
    
    emailTable.after('selectedRowChange', function (e) {
        var tr = e.newVal,           
            last_tr = e.prevVal,     
            rec = this.getRecord(tr);

        if ( !last_tr ) {} else {
            last_tr.removeClass("hl");
        }
        tr.addClass("hl");
        
        document.getElementById('messageFrame').src = '/read/' + selectedAccount + '/' + selectedFolder + '/' + rec.get('hashId')
    });    
    
    
    accountTable.plug(Y.Plugin.DataTableDataSource, {
        datasource: accountDataSource
    });
    
    accountTable.render("#accountList").showMessage('loadingMessage');
    folderTable.render("#folderList").showMessage('Select an account to list folders');
    emailTable.render("#emailList").showMessage('Select a folder to list emails');
    accountTable.datasource.load();
    accountTable.detach('*:change');

});
