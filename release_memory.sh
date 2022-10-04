#! /bin/bash

echo "***"
echo "Memory cleaning in progress"
echo "***"

die() {
	echo $* >&2
	exit 1
}

maybe_kill_pid(){
  PID=$1
  COMMAND_NAME=$2
  MEM_USAGE=$3
  CPU_USAGE=$4

	test -z $PID && die "no pid passed to maybe_kill_pid()"
	test -z $COMMAND_NAME && die "no command name passed to maybe_kill_pid()"
	test -z $MEM_USAGE && die "no memory usage info passed to maybe_kill_pid()"
	test -z $CPU_USAGE && die "no cpu usage info passed to maybe_kill_pid()"
  while true; do
    read -p "Do you wish to kill process $COMMAND_NAME. $PID It memory and cpu usage are $MEM_USAGE and $CPU_USAGE?" yn
      case $yn in
          [Yy]* ) kill $PID; break;;
          [Nn]* ) echo "Did not delete process $COMMAND_NAME";;
          [Cc]* ) die "aborting...";;
          * ) echo "Please answer yes(y) or no.(n)";;
      esac
  done
}

processes=()

while IFS=' ' read -r col1 col2 col3 col4 col5; do
    if [ "$(echo " $col4 > 1.0 " | bc -l )" == 1 ]; then
      # echo "process pid=$col2, user is $col1 and cpu=$col3 and mem=$col4"
      processes+=($col1)
      processes+=($col2)
      processes+=($col3)
      processes+=($col4)
    fi
done < <(ps auxww -m | head -n 10 | sed "s/%//g"  | sed 's/  */ /g' | sed 's/ \{1,\}/ /g' | tr -s ' ')

# echo "legth is ${#processes[@]}"

current_index=0
TOTAL_PROCESSES=${#processes[@]}/4-1

for ((i=0;i<=TOTAL_PROCESSES;i++)); do
    # echo $i

    pid_i=$((current_index + 1))
    cpu_i=$((current_index + 2))
    mem_i=$((current_index + 3))

    user=${processes[$current_index]}
    pid=${processes[$pid_i]}
    cpu=${processes[$cpu_i]}
    mem=${processes[$mem_i]}


    # echo "process pid=$pid, user is $user and cpu=$cpu and mem=$mem"

    maybe_kill_pid $pid "command name" $mem $cpu

    ((current_index=current_index+4))
    # echo current_index: $current_index
done
