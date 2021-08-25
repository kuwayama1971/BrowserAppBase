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
        autoFocus: true,
        minLength: 0,
        delay: 0,
        select: function (event, ui) {
            console.log(ui.item.value);
            jQuery("#" + id).val(ui.item.value);
            //jQuery(this).autocomplete("search", "");
            $(this).keydown();
        },
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
    }).focus(function () {
        console.log("forcus");
        //jQuery(this).autocomplete("search", "");
        $(this).keydown();
    });
}

function select_file_dialog(search_id, url, dialog_id, select_file, file_name) {
    console.log( "select_file_dialog select_file=" + select_file);
    $("#" + select_file).click(function () {
        autocomp(search_id, url);
        console.log("open dialog dialog_id=", dialog_id);
        $(".ui-autocomplete").css("z-index", 1000);
        $("#" + search_id).val("/");
        $("#" + dialog_id).dialog({
            modal: true
            , show: "slide"         //表示時のアニメーション
            , hide: "explode"       //閉じた時のアニメーション
            , title: "Select File"   //ダイアログのタイトル
            , width: 580            //ダイアログの横幅
            , height: 400           //ダイアログの高さ
            , resizable: false      //リサイズ不可
            , closeOnEscape: false  //[ESC]キーで閉じられなくする
            , draggable: false      //ダイアログの移動を不可に
            , buttons: {
                "OK": function () {  //OKボタン
                    $("#" + file_name).val($("#" + search_id).val());
                    $(this).dialog("close");
                    $("#" + search_id).autocomplete("destroy");
                },
                "Cancel": function () {  //Cancelボタン
                    $(this).dialog("close");
                    $("#" + search_id).autocomplete("destroy");
                }
            }
        });
    });
}

function get_dirname(path) {
    var result = path.replace(/\\/g, '/').replace(/\/[^\/]*$/, '');
    if (result.match(/^[^\/]*\.[^\/\.]*$/)) {
        result = '';
    }
    return result.replace(/\//g, "\\");
}

function dispFile() {
    var fName = $("#upFile").val();
    alert('選択したファイルの値は' + fName + 'です');
}

// 起動時の処理
$(document).ready(function () {
    // サーバに接続
    server_connect("ws://localhost:61611/wsserver")
    // ウインドウサイズ
    var width = 800;
    var height = 600;
    // ウインドウの位置
    $(function () {
        window.resizeTo(width, height);
        window.moveTo((window.screen.width / 2) - (width / 2), (screen.height / 2) - (height / 2));
        //window.moveTo(0,0);
    });

    // オートコンプリート設定
    var getUrl = function () {
        var url = "http://localhost:61611/search?path=" + $("#search_str").val();
        return url;
    };

    // ハンドラ登録
    $("#stop").click(function () {
        send_message("stop");
    });

    $("#exec").click(function () {
        send_message("exec:" + $("#upFile").val());
    });

    select_file_dialog("search_str", getUrl, "dialog1", "select_file", "upFile");

});

