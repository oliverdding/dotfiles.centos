function upjar -a cluster
    if not set -q QAPM_HOME
        echo "Cannot find environment variable QAPM_HOME. Have you clone the repository?"
        return 1
    end

    function upjar_deploy -a target_path
        set -l CLIENT_POD $(kubectl -n default get pods | rg 'kdl-client' | head -1 | awk '{print $1}')
        if not set -q CLIENT_POD
            echo "Cannot get client pod, is it running?"
            return 1
        end
        kubectl -n default cp $QAPM_HOME/emr/spark/scala/QAPMSparkProject/target/scala-2.11/QAPMSparkProject-assembly-6.1.jar $CLIENT_POD:/tmp/qapm-jar-by-oliverdding
        kubectl -n default exec $CLIENT_POD -- bash -c "hdfs --config /etc/hadoop-custom-conf/ dfs -mkdir -p $(dirname $target_path)"
        kubectl -n default exec $CLIENT_POD -- bash -c "hdfs --config /etc/hadoop-custom-conf/ dfs -rm -f $target_path"
        kubectl -n default exec $CLIENT_POD -- bash -c "hdfs --config /etc/hadoop-custom-conf/ dfs -put /tmp/qapm-jar-by-oliverdding $target_path"
        functions -e upjar_deploy
    end

    switch $cluster
        case 'tencent'
            upjar_deploy '/bin/tdem/tencent_public/spark/QAPMSparkProject-assembly-6.1.jar'
        case 'public'
            upjar_deploy '/bin/tdem/cloud_public/spark/QAPMSparkProject-assembly-6.1.jar'
        case 'qq'
            upjar_deploy '/bin/tdem/tencent_qq/spark/QAPMSparkProject-assembly-6.1.jar'
        case 'gray'
            upjar_deploy '/bin/tdem/gray/spark/QAPMSparkProject-assembly-6.1.jar'
        case 'test'
            upjar_deploy '/bin/tdem/test/spark/QAPMSparkProject-assembly-6.1.jar'
        case '*'
            echo " Unknown target cluster '$cluster', only support 'tencent', 'public', 'qq', 'gray' and 'test' now."
            return 1
    end
    if test $status = 0
        echo " Upload finished!"
    else
        echo " Upload failed!"
    end
end
