function PruneNQueens2!(E)::Bool
    !PruneNQueens!(E) && return false
    @inbounds begin
        for i = 1:length(E-1) #Pour toutes les variables
            if length(E[i]) == 2 #
                for j = i+1:length(E) #Pour toutes les variables j > i
                    if j != i && E[i] == E[j]
                        for k = 1:length(E)
                            if k != i && k!=j
                                #Retirer ces valeurs des autres domaines
                                filter!(vk -> vk!=E[i][1] && vk!=E[i][2], E[k])
                            end
                        end
                    end
                end
            end
        end
    end
    return BackTrackNQueens(E)
end

function PruneNQueens3!(E)::Bool
    !PruneNQueens2!(E) && return false
    @inbounds begin
        for i = 1:length(E-1) #Pour toutes les variables
            if length(E[i]) == 3 #
                for j = i+1:length(E-1) #Pour toutes les variables j > i
                    if E[i] == E[j]
                        for k = j+1:length(E)
                            if E[j] == E[k]
                                for l = 1:length(E)
                                    if l!= i && l!=j && l!=k
                                        #Retirer ces valeurs des autres domaines
                                        filter!(vl -> vl!=E[i][1] && vl!=E[i][2] && vl!=E[i][3], E[l])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return BackTrackNQueens(E)
end