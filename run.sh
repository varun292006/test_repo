#/bin/bash

get_hive_ddls() {
  for filename in $(ls *.txt)
    do
      echo $filename
    done
}

execute_hive(){
  echo "Executing hive DDLs"
  get_hive_ddls
}

exeucte_spark(){
  echo "Executing spark job"
}

case "$1" in
'execute_test')
echo "Inside execute_test"
execute_hive
exeucte_spark
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
