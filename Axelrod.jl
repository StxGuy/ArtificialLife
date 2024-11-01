using Plots
using Colors


mutable struct Feature
    traits  :: BitVector
    
    function Feature(num_traits :: Int)
        new(BitVector(rand(Bool,num_traits)))
    end
end

mutable struct Agent
    features    :: Vector{Feature}
    
    function Agent(num_features::Int, num_traits::Int)
        new([Feature(num_traits) for _ in 1:num_features])
    end        
end

function population(Lx,Ly)
    return [Agent(3,2) for _ in 1:Lx, _ in 1:Ly]
end

function neighbor(P,i,j)
    Lx,Ly = size(P)
    
    r = rand(1:4)
    
    if r == 1
        return P[mod1(i - 1, Lx), j]
    elseif r == 2
        return P[mod1(i + 1, Lx), j]
    elseif r == 3
        return P[i, mod1(j - 1, Ly)]
    else
        return P[i, mod1(j + 1, Ly)]
    end
end 
    
function interaction_prob(P::Agent,Q::Agent)
    total_traits = length(P.features)*length(P.features[1].traits)
    common_traits = 0
    
    for i in 1:length(P.features)
        common_traits += sum(P.features[i].traits .== Q.features[i].traits)
    end
    
    return common_traits/total_traits
end
    
function update_grid!(G::Array{Agent,2},iterations_per_frame::Int)
    Lx,Ly = size(G)
        
    for _ in 1:iterations_per_frame
        i,j = rand(1:Lx), rand(1:Ly)
                
        P = G[i,j]    
        Q = neighbor(G,i,j)

        p = interaction_prob(P,Q)

        differing_indices = []
        for i in 1:length(P.features)
            for j in 1:length(P.features[i].traits)
                if P.features[i].traits[j] != Q.features[i].traits[j]
                    push!(differing_indices,(i,j))
                end
            end
        end

        if !isempty(differing_indices)
            f_idx, t_idx = rand(differing_indices)
            P.features[f_idx].traits[t_idx] = Q.features[f_idx].traits[t_idx]
        end
    end
end


const feature_colors = Dict(
    1 => RGB(1,0,0),
    2 => RGB(0,1,0),
    3 => RGB(0,0,1),
)

function agent_to_color(A::Agent)
    color = RGB(0,0,0)
    
    for (i,feature) in enumerate(A.features)
        base_color = feature_colors[i]
        
        intensity = sum(feature.traits)/length(feature.traits)
        
        color += base_color*intensity
    end
    
    return color
end

function plot_population(G::Array{Agent,2})
    Lx,Ly = size(G)
    
    img_data = [agent_to_color(G[i,j]) for i in 1:Lx, j in 1:Ly]
        
    heatmap(img_data)
end
   
G = population(50,50)
   
anim = @animate for _ in 1:1000
    update_grid!(G,500)
    plot_population(G)
end

gif(anim,"Axelrod.gif",fps=10)


