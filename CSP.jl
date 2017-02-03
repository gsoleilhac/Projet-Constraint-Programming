function BranchAndPrune(Prune,D::Array{Array{Int64,1},1})::Void
	L = [D]::Array{Array{Array{Int64,1},1},1}
	while !isempty(L)
		E = pop!(L)::Array{Array{Int64,1},1}
		F,feasible = Prune(E)::Tuple{Array{Array{Int64,1},1}, Bool}
        if feasible && all(x -> length(x) >= 1, F)
			if isSolution(F) #true si tous les domaines sont de taille 1
				process(F)
			else
				#x_i = indice du plus petit domaine de taille >= 2
                x_i = indmin(map(elt -> length(elt) <= 1 ? typemax(Int) : length(elt), F))::Int
				for v in F[x_i]
					G = copy(F)
					G[x_i] = [v]
					push!(L,G)
				end
			end
		end
	end
end

function process(F)::Void
	#println(map(x -> x[1],F))
    global cpt += 1
    nothing
end

function PruneNQueens(E)::Tuple{Array{Array{Int64,1},1}, Bool}
    for i = 1:length(E - 1)
        if length(E[i]) == 1
            vi= E[i][1]
            for j = i+1:length(E)
                if length(E[j]) == 1 
                    vj=E[j][1]
                    vi==vj && return (E,false)
                    abs(vi-vj) == j-i && return (E,false)
                end
            end
        end
    end
	E,true
end

function isSolution(F)
	all(x->length(x)==1, F)
end

cpt = 0
for n = 3:13
    cpt=0
    const D = [[j for j=1:n] for i = 1:n]
    println("$n queens")
    @time BranchAndPrune(PruneNQueens, D)
    println("$cpt solutions trouvées\n")
end