#/bin/bash

#set -e

get_hive_ddls() {
  for filename in $(ls *.txt)
    do
      echo $filename
    done
}

execute_hive(){
  echo "Executing SQL DDLs"
#  get_hive_ddls
  mysql -u root -p'Pas$worc!' mysql < fail.sql
  ret_value=`echo $?`
  return $ret_value
}

exeucte_spark(){
  echo "Executing spark job"
}

case "$1" in
'execute_test')
  echo "Inside execute_test"
  execute_hive
  echo "Return value after execution - $ret_value"
  if [ $ret_value -eq 0 ]; then
    exeucte_spark
  else
    echo "Terminating...due to SQL exection failure"
    exit 1
  fi
;;
'execute')
echo "Inside execute"
;;
'execute_dev')
echo "Inside execute_dev"
;;
*)
echo "Usage: $0 [execute_dev |execute_test | execute]"
;;
esac
