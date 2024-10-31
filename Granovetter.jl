using Random, LightGraphs
using PyPlot

# Define the number of agents and probability of connection (for random graph)
n_agents = 500
p_connection = 0.95

# Initialize the graph (Erdős-Rényi random graph)
graph = erdos_renyi(n_agents, p_connection)

# Initialize thresholds for each agent
# Thresholds are between 0 and 1, determining how susceptible each agent is to adopt
thresholds = rand(n_agents)

# Initial behavior adoption (1 means adopted, 0 means not adopted)
# We can start with one random agent adopting the behavior
adopted = zeros(Int, n_agents)
adopted[rand(1:n_agents,20)] .= 1  

# Function to simulate one step of the spread process
function spread_step!(graph, adopted, thresholds)
    new_adopted = copy(adopted)
    for i in 1:nv(graph)  # For each agent in the graph
        if adopted[i] == 0  # Check only non-adopters
            neighbors = LightGraphs.neighbors(graph, i)
            adopted_neighbors = sum(adopted[neighbors]) / length(neighbors)
            if adopted_neighbors >= thresholds[i]
                new_adopted[i] = 1  # Agent adopts behavior
            end
        end
    end
    return new_adopted
end

# Run the spread process until no more adoptions occur
function run_simulation!(graph, adopted, thresholds)
    y = []
    while true
        new_adopted = spread_step!(graph, adopted, thresholds)
        if new_adopted == adopted  # Stop if no change
            break
        end
        adopted .= new_adopted
        push!(y,100*sum(adopted)/n_agents)
    end
    
    plot(y)
    xlabel("Time")
    ylabel("Adoption [%]")
    axis([0,length(y)-1,0,100])
    show()
end

# Run the simulation
run_simulation!(graph, adopted, thresholds)

# Result: Number of agents who adopted the behavior
println("Total adopted:", sum(adopted))
