// main.js

var $ws = null;
var $auto_scroll = true;
var dialog = null;
var dialog_timeout = null;

function open_dialog(msg, timeout = 0) {
    console.log("msg=" + msg);
    $("#msg_text").html(msg);
    d = $("#msg_dialog").dialog({
        modal: true
        , show: "slide"         //表示時のアニメーション
        , hide: "slide"       //閉じた時のアニメーション
        , title: "Message"   //ダイアログのタイトル
        , width: 500            //ダイアログの横幅
        , height: 300           //ダイアログの高さ
        , resizable: true      //リサイズ可
        , closeOnEscape: false  //[ESC]キーで閉じられなくする
        , draggable: true      //ダイアログの移動を可に
        , buttons: {
            "OK": function () {  //Cancelボタン
                if (dialog_timeout != null) {
                    clearTimeout(dialog_timeout);
                }
                $(this).dialog("close");
            }
        }
    });
    if (timeout != 0) {
        dialog_timeout = setTimeout(function () {
            d.dialog("close");
        }, timeout);
    }
}

function open_dialog_org(msg) {
    var top = window.screenTop + 10;
    var left = window.screenLeft + 10;
    if (dialog != null) {
        dialog.close();
    }
    var dialog = window.open(
        "/open_dialog?msg=" + msg,
        "pop",
        "width=300, height=100, left=" + left + ", top=" + top
    );
    console.log("open dialog dialog=" + dialog);
    if (dialog == null) {
        console.log("open dialog retry");
        setTimeout(function () {
            open_dialog(msg);
        }, 1000);
    } else {
        dialog.focus();
    }
}

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
        }
        else if (evt.data.match(/^app_end:normal/)) {
            open_dialog("終了しました");
        }
        else if (evt.data.match(/^app_end:stop/)) {
            open_dialog("中止しました");
        }
        else if (evt.data.match(/^app_end:error/)) {
            open_dialog("<font color='red'>エラーが発生しました</font>");
        }
        else if (evt.data.match(/^popup:/)) {
            open_dialog(evt.data.replace(/^popup:/, ""), 3000);
        } else {
            var log = "<li>" + evt.data + "</li>";
            $('#log').append(log);
            if ($auto_scroll) {
                $('.outarea').scrollTop($('.outarea').get(0).scrollHeight);
            }
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

function autocomp(id, file_kind) {
    $("#" + id).autocomplete({
        autoFocus: true,
        minLength: 0,
        delay: 0,
        select: function (event, ui) {
            //console.log(ui.item.value);
            jQuery("#" + id).val(ui.item.value);
            //jQuery(this).autocomplete("search", "");
            $(this).keydown();
        },
        source: function (req, resp) {
            $.ajax({
                url: "http://localhost:55757/search?path=" + $("#" + id).val() + "&kind=" + file_kind,
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
        //jQuery(this).autocomplete("search", "");
        $(this).keydown();
    });
}

function autocomp_history(id, file_name) {
    $("#" + id).autocomplete({
        autoFocus: true,
        minLength: 0,
        delay: 0,
        select: function (event, ui) {
            jQuery("#" + id).val(ui.item.value);
            $(this).keydown();
        },
        source: function (req, resp) {
            $.ajax({
                url: "http://localhost:55757/history/" + file_name,
                type: "POST",
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
        $(this).keydown();
    });
}

function select_file_dialog(search_id, file_kind, dialog_id, select_file, file_name) {
    $("#" + select_file).click(function () {
        autocomp(search_id, file_kind);
        $(".ui-autocomplete").css("z-index", 1000);
        console.log("name=" + $("#" + file_name).val());
        $("#" + search_id).val($("#" + file_name).val());
        $("#" + dialog_id).dialog({
            modal: true
            , show: "slide"         //表示時のアニメーション
            , hide: "explode"       //閉じた時のアニメーション
            , title: "Select File"   //ダイアログのタイトル
            , width: 580            //ダイアログの横幅
            , height: 400           //ダイアログの高さ
            , resizable: true      //リサイズ可
            , closeOnEscape: false  //[ESC]キーで閉じられなくする
            , draggable: true      //ダイアログの移動を可に
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

function setting_dialog(open_id, dialog_id, json_file) {
    $("#" + open_id).click(function () {
        $("#" + dialog_id).val = $(function () {
            $("dl#wrap").empty();
            $.getJSON(json_file, function (s) {
                for (var i in s) {
                    if (s[i].type == "input") {
                        var h = "<table><tr>"
                            + "<td class='setting_name'>" + s[i].description + "</td>"
                            + "<td><input class='setting_value' type='text' " + "id=" + s[i].name + "_value " + "value=" + "'" + s[i].value + "'" + ">"
                            + "</td></tr></table>"
                        $("dl#wrap").append(h);
                    } else if (s[i].type == "checkbox") {
                        var h = "<table><tr>";
                        h += "<td class='setting_name'>" + s[i].description + "</td>";
                        if (s[i].value == true) {
                            h += "<td><input class='setting_checkbox'  type='checkbox' " + "id=" + s[i].name + "_value checked ></td>";
                        } else {
                            h += "<td><input class='setting_checkbox'  type='checkbox' " + "id=" + s[i].name + "_value ></td>";
                        }
                        h += "</tr></table>";
                        $("dl#wrap").append(h);
                    } else if (s[i].type == "select") {
                        var h = "<table><tr>";
                        h += "<td class='setting_name'>" + s[i].description + "</td>";
                        h += "<td> <select class='setting_value'  id=" + s[i].name + "_value " + ">";
                        s[i].select.forEach(e => {
                            if (e == s[i].value) {
                                h += "<option value=" + e + " selected >" + e + "</option>";
                            } else {
                                h += "<option value=" + e + ">" + e + "</option>";
                            }
                        });
                        h += "</select></td>";
                        h += "</tr></table>";
                        $("dl#wrap").append(h);
                    } else {
                        //console.log("type=" + s[i].type);
                    }
                }
            });
        });
        $("#" + dialog_id).dialog({
            modal: true
            , show: "slide"         //表示時のアニメーション
            , hide: "explode"       //閉じた時のアニメーション
            , title: "Setting"   //ダイアログのタイトル
            , width: 580            //ダイアログの横幅
            , height: 400           //ダイアログの高さ
            , resizable: true      //リサイズ可
            , closeOnEscape: false  //[ESC]キーで閉じられなくする
            , draggable: true      //ダイアログの移動を可に
            , buttons: {
                "OK": function () {  //OKボタン
                    var json_data = []
                    $.getJSON(json_file, function (s) {
                        for (var i in s) {
                            //console.log(s[i].name);
                            if (s[i].type == "input") {
                                var data = {};
                                data["name"] = s[i].name;
                                data["value"] = $("#" + s[i].name + "_value").val();
                                data["type"] = s[i].type;
                                data["select"] = s[i].select;
                                data["description"] = s[i].description;
                                json_data.push(data);
                            }
                            else if (s[i].type == "checkbox") {
                                var data = {};
                                data["name"] = s[i].name;
                                if ($("#" + s[i].name + "_value:checked").val() == "on") {
                                    data["value"] = true;
                                } else {
                                    data["value"] = false;
                                }
                                data["type"] = s[i].type;
                                data["select"] = s[i].select;
                                data["description"] = s[i].description;
                                json_data.push(data);
                            } else if (s[i].type == "select") {
                                var data = {};
                                data["name"] = s[i].name;
                                data["value"] = $("#" + s[i].name + "_value" + " option:selected").val();
                                data["type"] = s[i].type;
                                data["select"] = s[i].select;
                                data["description"] = s[i].description;
                                json_data.push(data);
                            } else {
                                //console.log("type=" + s[i].type);
                            }
                        }
                        $ws.send("setting:" + JSON.stringify(json_data));
                    });
                    $(this).dialog("close");
                },
                "Cancel": function () {  //Cancelボタン
                    $(this).dialog("close");
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

function openFile(file) {
    $ws.send("openfile:" + file);
}

// 起動時の処理
$(document).ready(function () {

    window.onload = function (e) {
        console.log("onload");
        // サーバに接続
        server_connect("ws://localhost:55757/wsserver")
    }

    // ウインドウサイズ
    var width = 800;
    var height = 600;
    $(window).resize(function () {
        $(".outarea").height($(window).height() - 220);
    });
    // ウインドウの位置
    $(function () {
        window.resizeTo(width, height);
        window.moveTo((window.screen.width / 2) - (width / 2), (screen.height / 2) - (height / 2));
        //window.moveTo(0,0);
        $(".outarea").height($(window).height() - 220);
    });

    $('.outarea').scroll(function () {
        var h = $('.outarea').get(0).scrollHeight - $('.outarea').innerHeight();
        //console.log("scrollEnd=" + Math.abs($('.outarea').scrollTop() - h));
        if (Math.abs($('.outarea').scrollTop() - h) < 30) {
            // 最後までスクロールしている
            // 自動スクロールON
            $auto_scroll = true;
        } else {
            // 自動スクロールOFF
            $auto_scroll = false;
        }
        //console.log("auto_scroll=" + $auto_scroll);
    });

    // ハンドラ登録
    $("#stop").click(function () {
        send_message("stop");
    });

    $("#exec").click(function () {
        $('#log').empty();
        send_message("exec:" + $("#upFile").val());
    });

    select_file_dialog("search_str", "file", "dialog1", "select_file", "upFile");

    select_file_dialog("search_str2", "dir", "dialog2", "select_dir", "upDir");

    setting_dialog("setting", "setting_dialog", "config/setting.json");

    autocomp_history("upFile", "history.json")

});

