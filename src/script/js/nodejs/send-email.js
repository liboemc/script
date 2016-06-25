/**
 *1.安装node
 *2.安装npm
 *3.npm install nodemailer@0.7.1
 */
var email=function(){
//发送报警邮件
    this.sendMail=function(subjectMsg,htmlMsg){
        var nodemailer = require("nodemailer");
        var handler=this;
        var transport = nodemailer.createTransport("SMTP", {
            host: "smtp.qq.com",
            secureConnection: true, // use SSL
            port: 465, // port for secure SMTP
            auth: {
                user: "xxx@qq.com",
                pass: "xxxxxxxxxx"
            }
        });

        transport.sendMail({
            from : "xxx@qq.com",
            to : "xxx@qq.com;xx@qq.com",
            subject: subjectMsg,
            generateTextFromHTML : true,
            html : htmlMsg
        }, function(error, response){
            if(error){
                console.log(error);
            }else{
                handler.appendFileLog("给xxx发送邮件成功");
            }
            transport.close();
        });

    };


//写入日志文件
    this.appendFileLog=function(msg){
        var fs = require('fs');
        var message=this.getNowFormatDate()+this.logMsgHead+msg+"\r\n";
        console.log("写入日志文件内容="+message);
        fs.appendFile("log.log", message, 'utf-8', function(err){
            if (err) {
                console.log('The "data to append" was appended to file!');
                throw err;
            }
        });
    };


//获取格式化当前时间
    this.getNowFormatDate=function(){
        var nowDate = new Date();
        //初始化时间
        var Year= nowDate.getFullYear();//ie火狐下都可以
        var Month= nowDate.getMonth()+1;
        var Day = nowDate.getDate();
        var Hour = nowDate.getHours();
        var Minute = nowDate.getMinutes();
        var Second = nowDate.getSeconds();
        var Milliseconds=nowDate.getMilliseconds();
        var CurrentDate = "";
        CurrentDate += Year + "-";
        if (Month >= 10 ){
            CurrentDate += Month + "-";
        }else{
            CurrentDate += "0" + Month + "-";
        }
        if (Day >= 10){
            CurrentDate += Day ;
        }else {
            CurrentDate += "0" + Day ;
        }
        if (Hour >= 10){
            CurrentDate += (" "+Hour) ;
        }else {
            CurrentDate += " 0" + Hour ;
        }
        if (Minute >= 10){
            CurrentDate += ":"+Minute ;
        }else {
            CurrentDate += ":0" + Minute ;
        }
        if (Second >= 10){
            CurrentDate += ":"+Second ;
        }else {
            CurrentDate += ":0" + Second ;
        }
        CurrentDate +=":"+Milliseconds;

        return CurrentDate;
    };

};

    var mail=new email();
	mail.sendMail("subjectMsg","htmlMsg");

