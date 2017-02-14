function BranchAndPrune(Prune!,D::Array{Array{Int64,1},1})::Void
	L = [D]::Array{Array{Array{Int64,1},1},1}
	while !isempty(L)
		E = pop!(L)::Array{Array{Int64,1},1}
        if Prune!(E)
			if isSolution(E) #true si tous les domaines sont de taille 1
                !BackTrackNQueens(E) && println("!backtrack but isolution : ",E)
				process(E)
			else
				#indice du plus petit domaine de taille >= 2
                x_i = indmin(map(elt -> length(elt) <= 1 ? typemax(Int) : length(elt), E))::Int
				for v in E[x_i]
					F = deepcopy(E)
					F[x_i] = [v]
					push!(L,F)
				end
			end
        end
	end
    return nothing
end

function process(F)::Void
	# println(map(x -> x[1],F))
    global cpt += 1
    return nothing
end

function BackTrackNQueens(E)::Bool
    @inbounds begin
        #Pour toutes les variables i < j fixées
        for i = 1:length(E - 1)
            if length(E[i]) == 1
                vi= E[i][1]
                for j = i+1:length(E)
                    if length(E[j]) == 1 
                        vj=E[j][1] #
                        #Si conflit , return false
                        vi==vj && return false
                        abs(vi-vj) == j-i && return false
                    end
                end
            end
        end
    end
    return all(x -> length(x) >= 1, E)
end

function PruneNQueens!(E)::Bool
    if !BackTrackNQueens(E) #Gain de temps
        return false
    end
    @inbounds begin
        for i = 1:length(E) #Pour toutes les variables
            if length(E[i]) == 1 #Si une variable i est fixée...
                vi = E[i][1]
                for j = 1:length(E) #Pour toutes les variables j != i
                    if j != i 
                        #Retirer toutes les valeurs incompatibles du domaine
                        filter!(vj -> vj!=vi && abs(vi-vj)!=abs(j-i) , E[j])
                    end
                end
            end
        end
    end
    return BackTrackNQueens(E)
end

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

function isSolution(E)
	all(x->length(x)==1, E)
end


cpt = 0
for n = 11:12
    println("###### $n queens ######")
    const D = [[j for j=1:n] for i = 1:n]

    cpt=0
    println("Backtrack : ")
    @time BranchAndPrune(BackTrackNQueens, D)
    println("$cpt solutions trouvées\n")

    cpt = 0
    println("Prune! : ")
    @time BranchAndPrune(PruneNQueens!, D)
    println("$cpt solutions trouvées\n")

    cpt = 0
    println("Prune! + 2x2: ")
    @time BranchAndPrune(PruneNQueens2!, D)
    println("$cpt solutions trouvées\n")

    cpt = 0
    println("Prune! +2x2 + 3x3x3: ")
    @time BranchAndPrune(PruneNQueens3!, D)
    println("$cpt solutions trouvées\n")
end
