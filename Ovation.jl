using Random
using PyPlot

# Parameters
n_rows, n_cols = 100, 100          # Audience grid size (10x10 for 100 people)
quality = 0.5                      # Perceived quality of the performance (0 to 1 scale)
initial_standing_proportion = 0.01  # Proportion of people who initially stand

# Create a grid of thresholds for each individual in the audience
# Thresholds determine how likely they are to stand up independently
thresholds = rand(n_rows, n_cols)  # Each threshold is between 0 and 1

# Initialize the standing status (1 = standing, 0 = sitting)
standing = zeros(Int, n_rows, n_cols)

# Set initial random individuals to standing based on initial proportion
for i in 1:round(Int, initial_standing_proportion * n_rows * n_cols)
    standing[rand(1:n_rows), rand(1:n_cols)] = 1
end

# Define the function to calculate social influence (neighbors' standing status)
function social_influence(standing, i, j)
    neighbors = [
        standing[mod1(i - 1, n_rows), j],  # above
        standing[mod1(i + 1, n_rows), j],  # below
        standing[i, mod1(j - 1, n_cols)],  # left
        standing[i, mod1(j + 1, n_cols)]   # right
    ]
    return sum(neighbors) / length(neighbors)  # proportion of standing neighbors
end

# One simulation step where each individual decides to stand or sit
function update_standing!(standing, thresholds, quality)
    next_standing = copy(standing)
    z = 0
    for i in 1:n_rows, j in 1:n_cols
        if standing[i, j] == 0  # Only update for those currently sitting
            influence = social_influence(standing, i, j)
            if quality >= thresholds[i, j] || influence >= 0.5
                next_standing[i, j] = 1  # The person decides to stand
                z += 1
            end
        end
    end
    
    standing .= next_standing
    
    return 100*z/(n_rows*n_cols)
end


# Run the model until standing stabilizes (no more changes in the grid)
function run_simulation!(standing, thresholds, quality)
    y1 = []
    y2 = []
    prev_standing = copy(standing)
    while true
        k = update_standing!(standing, thresholds, quality)
        if standing == prev_standing
            break
        end
        push!(y1,100*sum(standing)/(n_rows*n_cols))
        push!(y2,k)
        prev_standing .= standing
    end
    
    plot(y1)
    plot(y2)
    axis([0,length(y1)-1,0,100])
    xlabel("Time")
    ylabel("Percentage")
    legend(["Ovation","Discomfort"])
    show()
end

# Execute the simulation
run_simulation!(standing, thresholds, quality)
