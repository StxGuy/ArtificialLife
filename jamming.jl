using PyPlot

function simulate(L::Int, p::Float64)
    # Initialize the road
    road = rand(L) .< p
    NumIt = 1000
    total = sum(road)

    avg_speed = 0.0
    for _ in 1:NumIt
        # Simulate the road movement
        mv = 0
        new_road = copy(road)  # Create a copy of the road for simultaneous updates
        for n in 1:L
            if road[n] == 1
                m = mod1(n+1, L)  # Look ahead
                if new_road[m] == 0   # There's an empty space ahead
                    new_road[m] = 1
                    new_road[n] = 0
                    mv += 1
                end
            end
        end
        road = new_road
        avg_speed += mv / total
    end
    return avg_speed / NumIt
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
