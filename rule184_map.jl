using PyPlot

function simulate(L::Int, p::Float64)
    road = rand(L) .< p
    map = zeros(L,L)

    for k in 1:L
        map[k,:] = road
        nroad = copy(road)
        for n in 1:L
            nl = mod1(n-1,L)
            nr = mod1(n+1,L)

            A = road[nl]
            B = road[n]
            C = road[nr]

            if (B && C) || (A && ~B)
                nroad[n] = 1
            else
                nroad[n] = 0
            end
        end
        road = copy(nroad)
    end
    return map
end

# Run the simulation
M = simulate(300, 0.5)

# Plotting the results
imshow(M)
show()
