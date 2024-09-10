using PyPlot

# Create a matrix where each pixel is filled with probability p
function create(Lx,Ly,p)
    M = zeros(Lx,Ly)

    for i in 1:Lx, j in 1:Ly
        if rand() <= p
            M[i,j] = 1
        end
    end

    return M
end

# Standard flood fill algorithm
function flood!(M,visited,x,y,val=nothing)
    Lx,Ly = size(M)

    if x < 1 || x > Lx || y < 1 || y > Ly || visited[x,y] || M[x,y] == 0
        return 0
    end

    visited[x,y] = true
    cluster_size = 1

    if val != nothing
        M[x,y] = val
    end

    for (dx,dy) in [(1,0),(-1,0),(0,1),(0,-1)]
        cluster_size += flood!(M,visited,x+dx,y+dy,val)
    end

    return cluster_size
end

# Find largest connected component
function find_lcc!(M)
    Lx,Ly = size(M)

    visited = falses(Lx,Ly)
    largest = 0
    coords = (1,1)

    for x in 1:Lx, y in 1:Ly
        if M[x,y] == 1 && !visited[x,y]
            cluster_size = flood!(M,visited,x,y)

            if cluster_size > largest
                largest = cluster_size
                coords = (x,y)
            end
        end
    end

    flood!(M,falses(Lx,Ly),coords[1],coords[2],2)
end

# MAIN
M = create(100,100,0.659274621)
find_lcc!(M)
imshow(M)
show()
