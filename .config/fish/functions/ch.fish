function ch -a target_cluster
    switch $target_cluster
        case 'gr'
            set -f HOST '10.16.0.85'
        case 'gd'
            set -f HOST '10.16.30.14'
        case 'br'
            set -f HOST '10.90.0.15'
        case '*'
            echo " Unknown target cluster '$target_cluster', only support 'gr', 'gd' and 'br' now."
            return 1
    end
    ssh -t mixed-main-22 "exec clickhouse-client -h $HOST -u default -m $argv[2..-1]"
end
