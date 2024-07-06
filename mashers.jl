# Based on: 
# J. L. Silverberg, M. Bierbaum, J. P. Sethna, and I. Cohen
# "Collective Motion of Humans in Mosh and Circle Pits at Heavy Metal Concerts"
# Phys. Rrev. Lett. 110 (2013) 228701.

using Plots
using LinearAlgebra

mutable struct Masher
    r   :: Vector{Float64}
    v   :: Vector{Float64}
    vₒ  :: Float64
    rₘ  :: Vector{Float64}
end

function Masher(L :: Float64)
    r = [rand()*L,rand()*L]
    v = [randn(), randn()]
    vₒ = rand() ≤ 0.3 ? 1.0 : 0.0
    rₘ = copy(r)
    
    return Masher(r,v,vₒ,rₘ)
end    

mutable struct Mosh
    a   :: Vector{Masher}
    N   :: Int
    ϵ   :: Float64
    rₒ  :: Float64
    μ   :: Float64
    α   :: Float64
    L   :: Float64
end

function Mosh(N :: Int)
    α = 0.2
    ϵ = 25.0
    μ = 1.0
    rₒ = 1.0
    
    L = 1.03*sqrt(π*rₒ^2*N)
    
    a = [Masher(L) for _ in 1:N]
    
    return Mosh(a,N,ϵ,rₒ,μ,α,L)
end
    
function disp(m :: Mosh)
    scatter([a.r[1] for a in m.a],[a.r[2] for a in m.a],xlim=(0,m.L),ylim=(0,m.L))
end
    
function update!(m :: Mosh)
    Δt = 0.1
    
    for a in m.a
        Fᵣ  = [0.0, 0.0]
        Fₚ  = [0.0, 0.0]
        Fₗⁿ = [0.0, 0.0]
        Fₗᵈ = 0.0
        
        for b in m.a
            if a ≠ b
                # Repulsion
                r = a.r - b.r
                rᵢⱼ = norm(r)
                if rᵢⱼ ≤ 2m.rₒ
                    rₕ = r/rᵢⱼ
                    Fᵣ += m.ϵ*((1-rᵢⱼ/(2m.rₒ))^1.5)*rₕ
                else
                    Fᵣ += [0.0,0.0]
                end
                
                # Propulsion
                v = norm(a.v)
                Fₚ = m.μ*(a.vₒ - v)*a.v/v
                
                # Flocking
                if rᵢⱼ ≤ 4m.rₒ
                    Fₗⁿ += b.v
                    Fₗᵈ += norm(b.v)
                end
            end
        end
            
        # Flocking
        Fₗ = Fₗᵈ ≠ 0 ? Fₗⁿ/Fₗᵈ : [0.0,0.0]
        
        # Total force
        F = Fᵣ + Fₚ + Fₗ
        
        # Verlet
        rₜ = a.r
        a.r += a.v*Δt + 0.5*F*Δt^2
        
        # Periodic boundary conditions
        a.r[1] = mod(a.r[1],m.L)
        a.r[2] = mod(a.r[2],m.L)
                        
        a.v += 0.5*F*Δt
        a.rₘ = rₜ
    end
end

m = Mosh(500)

anim = @animate for _ in 1:1000
    update!(m)
    disp(m)
end

gif(anim,"mosh.gif",fps=10)
