/**
 *1.安装node
 *2.安装npm
 *3.npm install --save ws
 *
 */
var websocketClient=function(){
//和服务器通信
    this.chatWebsocket=function(wsURL){
        var WebSocket = require('ws');
        var ws=new WebSocket(wsURL);
        var ListenerMsg={action: "system-keep-alive",data:{test:"test"},};
        var ListenerObj = JSON.stringify(ListenerMsg);

        ws.onopen = function() {
			console.log("connection success");
        };

        ws.onmessage = function (msg) {
			 ws.send(msg);
        };

        ws.onclose = function() {
			console.log("connection close");
			
           // setTimeout(function(){
               
            //    }
            //},1000*3);



        };

        ws.onerror = function(err) {
			console.log("connection err="+err);
        };
    };










};


 var client=new websocketClient();
    client.chatWebsocket("ws://127.0.0.1:19005");

