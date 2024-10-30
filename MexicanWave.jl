using Plots

mutable struct Agent
    threshold   :: Float64
    state       :: Bool
    previous    :: Bool
    
    # Constructor
    function Agent()
        return new(0,false,false)
    end        
end


function update!(P,N)
    L = length(P)
    new_states = [agent.state for agent in P]
        
    for n in 1:length(P)
        if P[n].state == true 
            new_states[n] = false
        else
            nb_sum = sum([a.state for a in P[max(1,n-N):n]])
            if  nb_sum > P[n].threshold
                new_states[n] = true
            end
        end
    end
            
    for n in 1:L
        P[n].previous = P[n].state
        P[n].state = new_states[n]
    end
end

function showGrid(P)
    L = length(P)
    G = zeros(L)
    
    G = [P[n].state ? 1 : 0 for n in 1:L]
    
    return bar(G)
end

Population = [Agent() for n in 1:100]
Population[1].state = true


anim = @animate for _ in 1:100
    update!(Population,1)    
    showGrid(Population)
end

gif(anim,"test.gif",fps=5)
