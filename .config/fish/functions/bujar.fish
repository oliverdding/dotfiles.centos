function bujar --description 'assembly jar file of QAPM/emr'
    set -q QAPM_HOME; and fish -c "cd $QAPM_HOME/emr/spark/scala/QAPMSparkProject; sbt assembly"; or echo " Cannot find environment variable QAPM_HOME. Have you clone the repository?"
    if test $status = 0
        echo " build finished!"
    else
        echo " build failed!"
    end
end
