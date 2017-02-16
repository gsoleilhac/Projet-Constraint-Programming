function BranchAndPrune(Prune!,D::Array{Array{Int64,1},1})::Void
	L = [D]::Vector{Vector{Vector{Int64}}}
	while !isempty(L)
		E = pop!(L)::Vector{Vector{Int64}}
        if Prune!(E) #Renvoie true si le noeud est faisable, 
                     #Convention Julia : le "!" indique que certains des arguments de la fonction seront modifiés
                     #Ce sera le cas si on utilise une fonction de pruning au lieu de la fonction de backtrack.
			if isSolution(E) #true si tous les domaines sont de taille 1
				process(E) #affiche la solution (si décommenté) et incrémente le compteur
			else
				#x_i = indice du plus petit domaine de taille >= 2
                x_i = indmin(map(elt -> length(elt) <= 1 ? typemax(Int) : length(elt), E))::Int
				for v in E[x_i] #Pour chaque valeur v dans le domaine de la variable
					F = deepcopy(E) #On fait une copie des domaines (F)
					F[x_i] = [v] #Et on fixe la variable x_i à la valeur v
					push!(L,F) #On ajoute F à la liste des noeuds à explorer (L)
				end
			end
        end
	end
    return
end

function process(F)::Void
	# println(map(x -> x[1],F))
    global cpt += 1
    return
end

#Teste deux à deux toutes les variables fixées, renvoie false si conflit
function BackTrackNQueens(E)::Bool
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
    return true
end

function PruneNQueens!(E)::Bool
    stop = false
    while !stop
        stop = true
        for i = 1:length(E) #Pour toutes les variables
            if length(E[i]) == 1 #Si une variable i est fixée...
                vi = E[i][1]
                for j = 1:length(E) #Pour toutes les variables j != i
                    if j != i 
                        #Retirer toutes les valeurs incompatibles du domaine
                        # filter!(vj -> vj!=vi && abs(vi-vj)!=abs(j-i) , E[j])
                        incompatibles = find(vj -> vj==vi || abs(vi-vj)==abs(j-i) ,E[j])
                        if !isempty(incompatibles)
                            stop = false
                            deleteat!(E[j], incompatibles)
                        end
                    end
                end
            end
        end
    end
    return all(x -> length(x) >= 1, E)
end

isSolution(E) = all(x->length(x)==1, E)



### MAIN ENTRY POINT ###

if length(ARGS) >= 1
    nb_queens = eval(parse(ARGS[1])) #Permet de passer un entier en paramètre ou un range (1:10)
else
    nb_queens = 4
end

cpt=0
for n = nb_queens
    println("###### $n queens ######")
    const D = [[i for i=1:n] for j = 1:n] #Génération des domaines initiaux des variables

    cpt=0
    println("Backtrack : ")
    @time BranchAndPrune(BackTrackNQueens, D)
    println("$cpt solutions trouvées\n")

    cpt = 0
    println("Prune! : ")
    @time BranchAndPrune(PruneNQueens!, D)
    println("$cpt solutions trouvées\n")
end
