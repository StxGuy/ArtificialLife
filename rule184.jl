using PyPlot

function simulate(L::Int, p::Float64)
    road = rand(L) .< p
    total_cars = sum(road)
    NumInt = 1000
    avg_speed = 0.0

    for _ in 1:NumInt
        speed = 0
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

            if (B && ~C)
                speed += 1
            end
        end
        road = copy(nroad)
        avg_speed += speed/total_cars
    end
    return avg_speed/NumInt
end

# Function to run simulation for different densities
function run_simulation(L::Int, densities::Vector{Float64})
    speeds = []
    for p in densities
        avg_speed = simulate(L, p)
        push!(speeds, avg_speed)
    end
    return speeds
end

# Run the simulation
L = 1000  # Road length
densities = Vector(0.0:0.05:1.0)
speeds = run_simulation(L, densities)

# Plotting the results
plot(densities, speeds, "o")
xlabel("Density")
ylabel("Average Speed")
title("Traffic Jam Transition")
show()
