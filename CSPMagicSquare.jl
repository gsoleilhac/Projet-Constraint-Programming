
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
    N = Int(sqrt(length(F)))
    F = reshape(F, N, N)
    for i = 1:N
        for j = 1:N
            print(F[i,j][1], " ")
        end
        println()
    end
    println()
    global cpt += 1
    return
end

isSolution(E) = all(x->length(x)==1, E)


function PruningMagicSquare!(E)
    N = Int(sqrt(length(E)))
    E = reshape(E, N, N)
    S = div(N*(N*N+1),2)

    stop = false
    while !stop
        stop = true

        #Symmetry breaking
    
        while !isempty(E[N]) && E[1][1] > E[N][1]
            shift!(E[N])
            stop = false
        end
        isempty(E[N]) && return false
        while !isempty(E[N*N]) && E[1][1] > E[N*N][1]
            shift!(E[N*N])
            stop = false
        end
        isempty(E[N*N]) && return false

        while !isempty(E[N*(N-1)+1]) && E[N][1] > E[N*(N-1)+1][1]
            shift!(E[N*(N-1)+1])
            stop = false
        end
        isempty(E[N*(N-1)+1]) && return false

        #pruning for each row
        for i = 1:N
            summin = sum(map(x -> x[1], E[i,:]))
            summax = sum(map(x -> x[end], E[i,:]))
            summin > S || summax < S && return false

            for j = 1:N
                while !isempty(E[i,j]) && summin - E[i,j][1] + E[i,j][end] > S
                    pop!(E[i,j])
                    stop = false
                end
                while !isempty(E[i,j]) && summax - E[i,j][end] + E[i,j][1] < S
                    shift!(E[i,j])
                    stop = false
                end
                isempty(E[i,j]) && return false
            end
        end

        #pruning for each column
        for i = 1:N
            summin = sum(map(x -> x[1], E[:,i]))
            summax = sum(map(x -> x[end], E[:,i]))
            summin > S || summax < S && return false

            for j = 1:N
                while !isempty(E[j,i]) && summin - E[j,i][1] + E[j,i][end] > S
                    pop!(E[j,i])
                    stop = false
                end
                while !isempty(E[j,i]) && summax - E[j,i][end] + E[j,i][1] < S
                    shift!(E[j,i])
                    stop = false
                end
                isempty(E[j,i]) && return false
            end
        end

        #pruning for first diagonal
        summin = sum([E[i,i][1] for i = 1:N])
        summax = sum([E[i,i][end] for i = 1:N])
        summin > S || summax < S && return false
        for i = 1:N
            while !isempty(E[i,i]) && summin - E[i,i][1] + E[i,i][end] > S
                pop!(E[i,i])
                stop = false
            end
            while !isempty(E[i,i]) && summax - E[i,i][end] + E[i,i][1] < S
                shift!(E[i,i])
                stop = false
            end
            isempty(E[i,i]) && return false
        end

        #pruning for second diagonal
        summin = sum([E[N-i+1,i][1] for i = 1:N])
        summax = sum([E[N-i+1,i][end] for i = 1:N])
        summin > S || summax < S && return false
        for i = 1:N
            while !isempty(E[N-i+1,i]) && summin - E[N-i+1,i][1] + E[N-i+1,i][end] > S
                pop!(E[N-i+1,i])
                stop = false
            end
            while !isempty(E[N-i+1,i]) && summax - E[N-i+1,i][end] + E[N-i+1,i][1] < S
                shift!(E[N-i+1,i])
                stop = false
            end
            isempty(E[N-i+1,i]) && return false
        end

    end #while !stop


    for i = 1:length(E - 1)
        if length(E[i]) == 1
            vi= E[i][1]
            for j = i+1:length(E)
                if length(E[j]) == 1 
                    vj=E[j][1]
                    #Si conflit , return false
                    vi==vj && return false
                end
            end
        end
    end

    return true

end


function AllDiffMagicSquare!(E::Vector{Vector{Int64}})::Bool
    @inbounds begin
        N = length(E)
        for i = 1:N
            for j = i:N
                I = i:j
                SI = []
                for k = 1:N
                    if E[k][1] >= i && E[k][end] <= j
                        push!(SI, k)
                    end
                end

                #If I is a Hall Interval
                if length(SI) == j-i+1  
                    for k = 1:N
                        if !(k in SI)
                            while !isempty(E[k]) && E[k][1] in I
                                shift!(E[k])
                            end

                            while !isempty(E[k]) && E[k][end] in I
                                pop!(E[k])
                            end

                            isempty(E[k]) && return false
                        end
                    end
                end
            end
        end
    end
    @inbounds return PruningMagicSquare!(E)
end


if length(ARGS) == 1
    N = parse(ARGS[1]) #Permet de passer un entier en paramètre ou un range (1:10)
else
    N = 3
end


const D = [[i for i=1:N*N] for j = 1:N*N]

cpt=0
println("Pruning : ")
@time BranchAndPrune(AllDiffMagicSquare!, D)
println("$cpt solutions trouvées\n")

