using Plots
using LinearAlgebra

# C. W. Reynolds, "Flocks, Herds, and Schools: A Distributed Behavioral Model", Computer Graphics 21-4 (1987) 25--34.
# I. D. Couzin, J. Krause, R. James, G. D. Ruxton, N. R. Franks,
# "Collective memory and spatial sorting in animal groups", 218-1 (2002) 1--11.

# Boids: self-propelled polar particles

#---------- STRUCTURES ----------
mutable struct Boid
    velocity    :: Vector{Float64}
    position    :: Vector{Float64}
end

mutable struct Boids
    agents      :: Vector{Boid}
    count       :: Int64
    L           :: Int64
end

# Boid constructor
function Boid()
    L = 100
    V = 5

    v = [V*(rand()-0.5),V*(rand()-0.5)]
    p = [L*(rand()-0.5),L*(rand()-0.5)]
    return Boid(v,p)
end

# Boids constructor
function Boids(N :: Int)
    a = [Boid() for i in 1:N]
    return Boids(a,N,40)
end

#---------- FUNCTIONS -----------

# Try to fly towards the center of mass of neighboring boids
function rule1(b :: Boid, B :: Boids)
    p = [0.0,0.0]
    for other_b in B.agents
        if other_b ≠ b
            p += other_b.position
        end
    end

    p = p/(B.count-1)

    # Move 1% towards center of mass
    return (p-b.position)/100
end

# Boids try to keep a small distance away from other objects
function rule2(b :: Boid, B :: Boids)
    c = [0.0,0.0]
    for other_b in B.agents
        if other_b ≠ b
            Δ = other_b.position - b.position
            if norm(Δ) < 10
                c -= Δ
            end
        end
    end

    return c
end

# Boids try to match their velocity with near boids
function rule3(b :: Boid, B :: Boids)
    v = [0.0,0.0]
    for other_b in B.agents
        if (other_b ≠ b)
            v += other_b.velocity
        end
    end

    v /= (B.count-1)

    return (v - b.velocity)/8
end

# Move boids with limited velocity and bounded position
function move_boids(B :: Boids)
    vlim = 5.0
    xmin = -B.L
    xmax = B.L
    ymin = -B.L
    ymax = B.L

    for b in B.agents
        v1 = rule1(b,B)
        v2 = rule2(b,B)
        v3 = rule3(b,B)

        b.velocity += v1 + v2 + v3

        # Limit velocity
        n = norm(b.velocity)
        if n > vlim
            b.velocity = (b.velocity/n)*vlim
        end

        b.position += b.velocity

        # Bound the position
        if b.position[1] < xmin
            b.velocity[1] = 10
        elseif b.position[1] > xmax
            b.velocity[1] = -10
        end

        if b.position[2] < ymin
            b.velocity[2] = 10
        elseif b.position[2] > ymax
            b.velocity[2] = -10
        end

    end
end

# Draw boids
function draw_boids(B :: Boids)
    x = zeros(B.count)
    y = zeros(B.count)
    for i in 1:B.count
        x[i] = B.agents[i].position[1]
        y[i] = B.agents[i].position[2]
    end

    scatter(x,y,legend=false,marker=:circle,xlims=(-B.L,B.L),ylims=(-B.L,B.L))
end



#==================================================================================#
# MAIN
#==================================================================================#

B = Boids(10)

anim = @animate for it in 1:100
    draw_boids(B)
    move_boids(B)
end

gif(anim,"test.gif",fps=10)


