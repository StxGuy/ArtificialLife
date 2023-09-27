using Plots
using LinearAlgebra

# T. Vicsek, A. Czirok, E. B. -Jacob, I. Cohen, O. Shochet
# Phys. Rev. Lett. 75 (1995) 1226.

#---------- STRUCTURES ----------
mutable struct Agent
    θ   :: Float64
    r   :: Vector{Float64}
end

mutable struct Population
    agents  :: Vector{Agent}
    count   :: Int64
    L       :: Int64
end

# Agent constructor
function Agent(L)
    x = -L + 2L*rand()
    y = -L + 2L*rand()
    θ = 2π*rand()
    return Agent(θ,[x,y])
end

# Population constructor
function Population(N,L)
    p = [Agent(L) for i in 1:N]
    return Population(p,N,L)
end


#---------- FUNCTIONS -----------

# update population
function update_population(P :: Population)
    v = 1

    for p₁ in P.agents
        θ = 0
        n = 0
        for p₂ in P.agents
            d = norm(p₁.r - p₂.r)
            if (d < 5 && p₁ ≠ p₂)
                θ += p₂.θ
                n += 1
            end
        end
        # align
        if n > 0
            p₁.θ = θ/n + π*rand()/10
        end
        # move
        p₁.r += v*[cos(p₁.θ),sin(p₁.θ)]

        # Periodic boundary conditions
        if p₁.r[1] > P.L
            p₁.r[1] = -P.L
        elseif p₁.r[1] < -P.L
            p₁.r[1] = P.L
        end

        if p₁.r[2] > P.L
            p₁.r[2] = -P.L
        elseif p₁.r[2] < -P.L
            p₁.r[2] = P.L
        end
    end
end

# Draw population
function draw_population(P :: Population)
    x = zeros(P.count)
    y = zeros(P.count)
    for i in 1:P.count
        x[i] = P.agents[i].r[1]
        y[i] = P.agents[i].r[2]
    end

    scatter(x,y,legend=false,marker=:circle,xlims=(-P.L,P.L),ylims=(-P.L,P.L))
end


#==================================================================================#
# MAIN
#==================================================================================#

P = Population(10,100)

anim = @animate for it in 1:1000
    draw_population(P)
    update_population(P)
end

gif(anim,"test.gif",fps=30)



