# Helbing's social force model adapted to an ABM

using LinearAlgebra
using Plots


mutable struct Agent
    r   :: Vector{Int}
    vₒ  :: Vector{Int}
    v   :: Vector{Float64}

    # Constructor
    function Agent(Lx :: Int,Ly :: Int)
        r = [rand(1:Lx),rand(1:Ly)]
        vₒ = [rand() > 0.5 ? 1 : -1, 0]
        v = [0.0, 0.0]

        return new(r,vₒ,v)
    end
end

mutable struct Crowd
    N               :: Int
    population      :: Vector{Agent}
    Lx              :: Int
    Ly              :: Int
    σ               :: Float64
    τ               :: Float64
    β               :: Float64
    Neighborhood    :: Vector{Vector{Int64}}

    # Constructor
    function Crowd(N :: Int, Lx :: Int, Ly :: Int)
        C = [Agent(Lx,Ly) for _ in 1:N]
        σ = 0.3
        τ = 0.5
        β = 3.0
        Neighborhood = [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]

        return new(N,C,Lx,Ly,σ,τ,β,Neighborhood)
    end
end


# Sample from a set with certain probabilities
function sample(elements, probabilities)
    r = rand()
    cumsum = 0.0

    for (element,probability) in zip(elements,probabilities)
        cumsum += probability
        if r ≤ cumsum
            return element
        end
    end
    return elements[end]
end

# Update Helbing's ABM
function update!(C :: Crowd)
    for agent1 in C.population
        # Interaction force
        fᵢ = [0.0,0.0]
        for (n,agent2) in enumerate(C.population)
            if agent1 ≠ agent2
                d = agent1.r - agent2.r
                dn = norm(d)
                if dn ≠ 0
                    fᵢ += exp((2-dn)/C.σ)*normalize(d)/(C.N*exp(2))
                end
            end
        end

        fᵢ = normalize(fᵢ)

        # Motivational force
        fᵣ = normalize((agent1.vₒ - agent1.v)/C.τ)

        # Update velocity
        agent1.v += 0.1*normalize(fᵢ + fᵣ)
        scores = [agent1.v⋅dir for dir in C.Neighborhood]

        # Softmax probability
        s_max = maximum(scores)
        exp_scores = exp.(C.β .* (scores .- s_max))
        P = exp_scores/sum(exp_scores)
        next_direction = sample(C.Neighborhood,P)

        # Move agent
        x = mod1(agent1.r[1] + next_direction[1],Lx)
        y = agent1.r[2] + next_direction[2]
        if y < 1
            y = 1
        elseif y > C.Ly
            y = C.Ly
        end

        # Update agent position
        flag = false
        for agent2 in C.population
            if agent2.r == [x,y]
                flag = true
            end
        end

        if flag == false
            agent1.r = [x,y]
        end
    end
end

# Display grid with agents
function showGrid(C :: Crowd)
    grid = zeros(C.Lx, C.Ly)

    for agent in C.population
        if agent.v[1] > 0
            grid[agent.r[1],agent.r[2]] = 1
        else
            grid[agent.r[1],agent.r[2]] = 2
        end
    end

    heatmap(grid')#,ratio=3*C.Ly/C.Lx)
end


# Main
NAgents = 350
Ly = 20
Lx = 50

C = Crowd(NAgents,Lx,Ly)

anim = @animate for _ in 1:200
    update!(C)
    showGrid(C)
end

gif(anim,"test.gif",fps=10)



