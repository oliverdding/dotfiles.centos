function client
    kubectl -n default exec -it deploy/kdl-client -- bash "$argv"
end
