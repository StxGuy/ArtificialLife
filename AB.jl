using Plots

function xx(P, i, j)
    Lx,Ly = size(P)
    
    neighbors = [
        P[mod1(i - 1, Lx), j],  # above
        P[mod1(i + 1, Lx), j],  # below
        P[i, mod1(j - 1, Ly)],  # left
        P[i, mod1(j + 1, Ly)]   # right
        ]
    xa = sum(neighbors .== 1) / length(neighbors)  # proportion of standing neighbors
    xb = sum(neighbors .== 2) / length(neighbors)  # proportion of standing neighbors
    
    return xa, xb
end

function initialize_grid(xa,xb,Lx,Ly)
    G = zeros(Lx,Ly)
    
    for i in 1:Lx, j in 1:Ly
        r = rand()
        
        if r <= xa
            G[i,j] = 1
        elseif r <= xa+xb
            G[i,j] = 2
        else
            G[i,j] = 3
        end
    end
    
    return G
end

function update_grid!(P,iterations_per_frame)
    Lx,Ly = size(P)
    
    
    for _ in 1:iterations_per_frame
        i,j = rand(1:Lx), rand(1:Ly)
                
        xa,xb = xx(P,i,j)
            
        if P[i,j] == 1
            if rand() <= 0.5*xb
                P[i,j] = 3
            end
        elseif P[i,j] == 2
            if rand() <= 0.5*xa
                P[i,j] = 3
            end
        else
            p_to_A = 0.5*(1-xb)
            p_to_B = 0.5*(1-xa)
                
            r = rand()
                
            if r <= p_to_A
                P[i,j] = 1
            elseif r  <= p_to_A + p_to_B
                P[i,j] = 2
            end
        end    
    end
end
   
P = initialize_grid(0.3,0.3,50,50)
   
anim = @animate for _ in 1:1000
    update_grid!(P,500)
    heatmap(P, c = ["red", "blue", "magenta"])
end

gif(anim,"AB.gif",fps=10)


