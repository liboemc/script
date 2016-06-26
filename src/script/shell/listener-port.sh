#!/bin/sh

#监听端口并且报警脚本
#通过crontab实现监听
#检查端口 netstat -anp|grep LISTEN|grep $1|wc -l
#检查进程 num=`ps -ef | grep $proc_name | grep -v grep | wc -l`
# 启动jar nohup java -jar jar-name.jar >>/dev/null 2>&1 &

# 日志文件
file_name="listener-port.log"
PORT_PATH_NAME=/tmp/listener-limit;


#监控端口列表数组
post_list=(12300,12301)

#邮件报警通知
alert_send_email(){
	 echo $1"端口异常，发送报警邮件开始..."
	 top_info_t=`top -b -d 1 -n 1`
	 ip_address_t=`ifconfig|grep Bcast`
	 port_t=$1

	 title='title:\n\n'
	 service_name='service-name: xxxx.jar\n\n'
	  port='port: '${port_t}'\n\n'
	  host_name='host_name: '${HOSTNAME}'\n\n'
	 current_time='current_time: '`date +%Y-%m-%d_%H:%M:%S`'\n\n'
	 ip_address='ip_address: \n'${ip_address_t}'\n\n'
	 top_info='top_info: \n'${top_info_t:0:368}'\n\n'
	 mail_body=${title}${service_name}${port}${current_time}${host_name}${ip_address}${top_info}

	 echo -e ${mail_body}|mail -s 'restart complete' xxx@xx.com
}

#重启端口
restart(){
    alert_send_email $1
    echo `date +%Y-%m-%d_%H:%M:%S`, 'restart   start ....port='$1 >>$file_name
    echo $HOSTNAME >>$file_name
    netstat -anp|grep java >>$file_name
    echo $1"端口异常，重启此端口的进程开始..."
    service service-name stop port=$1;
    service service-name start port=$1
    echo $1"端口异常，重启此端口的进程结束..."

   #记录日志
	top -b -d 1 -n 1 >>$host_dir$file_name                               #记录系统负载
	echo `date +%Y-%m-%d_%H:%M:%S`, 'restart  end ....port='$1 >>$file_name
}

#检查端口是否可用
check_port(){
   port_result=`netstat -anp|grep LISTEN|grep $1|wc -l`
    if [ $port_result -eq 0 ];
    then
       restart $1
    else
      echo "端口正常..."$1
    fi
}

#检查端口是否参与定时器监控
effective_port(){
PORT_PATH_NAME_EFFECTIVE=$PORT_PATH_NAME'-port='$1
    if [ -f $PORT_PATH_NAME_EFFECTIVE ];
    then
         return 100;
    else
         return 101;
    fi
}

#限制端口是否参与定时器
limit_port(){
PORT_PATH_NAME_LIMIT=$PORT_PATH_NAME"-"$2
    if [ "$1" = "start" ];
    then
        if [ ! -f $PORT_PATH_NAME_LIMIT ];
        then
            echo "${PORT_PATH_NAME_LIMIT}">${PORT_PATH_NAME_LIMIT}
            echo $2"端口从定时监控移除开始"
            echo `date +%Y-%m-%d_%H:%M:%S`, $2"端口从定时监控移除开始" >>$file_name
        fi
    elif [ "$1" = "stop" ];
    then
        if [  -f $PORT_PATH_NAME_LIMIT ];
        then

            rm -f $PORT_PATH_NAME_LIMIT
            echo $2"端口新增到定时监控开始"
             echo `date +%Y-%m-%d_%H:%M:%S`, $2"端口新增到定时监控开始" >>$file_name
        fi
    else
         echo $"Usage: $0 {start|stop}"
   fi
}




    #定时脚本入口

     #根据是否有参数，开始处理端口 ，
     # 1 传入参数 start|stop port=123001，决定端口是否加入定时监控任务
     # 2 不传入参数，表示定时监控端口服务
    if [ -n "$1" ] && [ -n "$2" ];
    then
        limit_port $1 $2
    else
       for port in ${post_list[*]}  #遍历检查端口
        do
            effective_port $port
            result=$?
            if [ "${result}" -ne 100 ];
            then
                echo '开始遍历端口'$port
                check_port $port
            else
                echo $port"端口对应的进程暂时不参与定时监控"
            fi
        done
    fi