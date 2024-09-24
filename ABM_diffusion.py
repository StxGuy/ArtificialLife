import random as rd
import matplotlib.pyplot as plt
import matplotlib.animation as anim
import numpy as np

# Class for a single agent
class Agent:
    def __init__(self,x,y):
        self.x = x
        self.y = y

    def move(self,grid_size):
        self.x = (self.x + rd.choice([-1,0,1])) % grid_size
        self.y = (self.y + rd.choice([-1,0,1])) % grid_size

# Class for the diffusion ABM
class Model:
    def __init__(self,grid_size,num_agents):
        self.grid_size = grid_size
        self.agents = [Agent(grid_size>>1,grid_size>>1) for _ in range(num_agents)]

    def step(self):
        for agent in self.agents:
            agent.move(self.grid_size)

    def get_grid(self):
        grid = np.zeros((self.grid_size,self.grid_size))
        for agent in self.agents:
            grid[agent.x,agent.y] += 1
        return grid

# Set up model
model = Model(grid_size=50, num_agents=1500)
for _ in range(10):
    model.step()

# Set up the plot
fig,ax = plt.subplots()
grid = model.get_grid()
img = ax.imshow(grid,interpolation='nearest')
plt.colorbar(img)

# Animation update function
def update(frame):
    model.step()
    grid = model.get_grid()
    img.set_array(grid)
    return [img]

# Create animation
anim = anim.FuncAnimation(fig,update,frames=200,interval=50,blit=True)
plt.show()
