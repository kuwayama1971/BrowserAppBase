// main.js

var $ws = null;

function server_connect(url) {
    var ws = new WebSocket(url);
    ws.onopen = function () {
        // Web Socket is connected. You can send data by send() method.
        ws.send("message to send");
    };
    ws.onmessage = function (evt) {
        //alert(evt.data);
        if (evt.data.match(/^startup:/)) {
            file_name = evt.data.replace(/^startup:/, "");
            //alert(file_name);
            var fs = new ActiveXObject("Scripting.FileSystemObject");
            var file = fs.CreateTextFile(file_name);
            file.Close();
        } else {
            var log = $('#log').val() + evt.data + "\n";
            $('#log').val(log);
            var psconsole = $('#log');
            psconsole.scrollTop(
                psconsole[0].scrollHeight - psconsole.height()
            );
        }
        
    };
    ws.onclose = function () {
        alert("アプリケーションが終了しました!!");
        $(window).unbind("beforeunload");
        //window.open('about:blank','_self').close();
        window.close();
    };
    $ws = ws;
}

function send_message(msg) {
    if ($ws != null) {
        $ws.send(msg);
    }
}

function autocomp(id, url) {
    $("#" + id).autocomplete({
        source: function (req, resp) {
            $.ajax({
                url: url(),
                type: "GET",
                cache: false,
                dataType: "json",
                data: {
                    param1: req.term
                },
                success: function (o) {
                    resp(o);
                },
                error: function (xhr, ts, err) {
                    resp(['']);
                }
            });

        }
    });
}

function get_dirname(path) {
    var result = path.replace(/\\/g, '/').replace(/\/[^\/]*$/, '');
    if (result.match(/^[^\/]*\.[^\/\.]*$/)) {
        result = '';
    }
    return result.replace(/\//g, "\\");
}

function select_file(id) {
    var file = $("#" + id).val();
    var dir = get_dirname(file);
    if (dir != "") {
        dir = dir + "\\*.*";
    } else {
        dir = "c:\\*.*";
    }
    var path = "";
    //alert(dir);
    //path = HtmlDlgHelper.openfiledlg(dir,"*.db","database(*.db)|*.db|all(*.*)|*.*|Text file(*.txt)|*.txt|");
    path = HtmlDlgHelper.openfiledlg(dir, "", "all(*.*)|*.*|Text file(*.txt)|*.txt|");
    $("#" + id).val(path);
    return (path);
}

function dispFile() {
    var fName = $("#upFile").val();
    alert('選択したファイルの値は' + fName + 'です');
}

// 起動時の処理
$(document).ready(function () {
    // サーバに接続
    server_connect("ws://localhost:61820/wsserver")
    // ウインドウサイズ
    var width = 600;
    var height = 700;
    // ウインドウの位置
    $(function () {
        window.resizeTo(width, height);
        window.moveTo((window.screen.width / 2) - (width / 2), (screen.height / 2) - (height / 2));
        //window.moveTo(0,0);
    });

    // オートコンプリート設定
    var getUrl = function () {
        var url = "http://localhost:61820/search?path=" + $("#search_str").val();
        return url;
    };
    autocomp("search_str", getUrl);

    // ハンドラ登録
    $("#file").click(function () {
        select_file("search_str");
    });
    $("#exec").click(function () {
        send_message("exec:" + $("#upFile").val());
    });
    $("#stop").click(function () {
        send_message("stop");
    });

});

