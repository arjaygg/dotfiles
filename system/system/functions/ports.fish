<<<<<<<< HEAD:system/system/functions/ports.fish
function ports -d "manage processes by the ports they are using"
	switch $argv[1]
		case ls
			lsof -i -n -P
		case show
			lsof -i :"$argv[2]" | tail -n 1
		case pid
			ports show "$argv[2]" | awk '{ print $2; }'
		case kill
			kill -9 (ports pid "$argv[2]")
		case '*'
			echo "NAME:
========
#!/bin/bash
# manage processes by the ports they are using
case "$1" in
ls)
  lsof -i -n -P
  ;;
show)
  lsof -i :"$2" | tail -n 1
  ;;
pid)
  ports show "$2" | awk '{ print $2; }'
  ;;
kill)
  kill -9 "$(ports pid "$2")"
  ;;
*)
  echo "NAME:
>>>>>>>> upstream/main:bin/ports
  ports - a tool to easily see what's happening on your computer's ports
USAGE:
  ports [global options] command [command options] [arguments...]
COMMANDS:
  ls                list all open ports and the processes running in them
  show <port>       shows which process is running on a given port
  pid <port>        same as show, but prints only the PID
  kill <port>       kill the process is running in the given port with kill -9
GLOBAL OPTIONS:
  --help,-h         show help"
	end
end
