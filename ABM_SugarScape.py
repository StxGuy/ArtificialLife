import random as rd
import matplotlib.pyplot as plt
import matplotlib.animation as anim
import numpy as np

# Class for a single agent
class Agent:
    def __init__(self,x,y,vision,metabolism):
        self.x = x
        self.y = y
        self.sugar = rd.randint(5,25)
        self.metabolism = metabolism
        self.vision = vision

    def move(self,grid):
        best_cell = (self.x,self.y)
        best_sugar = grid[self.x,self.y]

        for dx in range(-self.vision, self.vision+1):
            for dy in range(-self.vision, self.vision+1):
                new_x = (self.x + dx)%grid.shape[0]
                new_y = (self.y + dy)%grid.shape[1]
                if grid[new_x,new_y] > best_sugar:
                    best_cell = (new_x,new_y)
                    best_sugar = grid[new_x,new_y]

        self.x, self.y = best_cell
        self.sugar += grid[self.x,self.y]-self.metabolism
        grid[self.x,self.y] = 0

        return self.sugar > 0

# Class for the SugarScape model
class SugarScape:
    def __init__(self,width,height,num_agents):
        self.width = width
        self.height = height
        self.sugar = np.random.randint(0,5,(width,height))
        self.max_sugar = np.random.randint(1,5,(width,height))
        self.agents = [Agent(width>>1,
                             height>>1,
                             rd.randint(1,6),
                             rd.randint(1,4))
                        for _ in range(num_agents)]

    def step(self):
        # Sugar growth
        self.sugar = np.minimum(self.sugar+1,self.max_sugar)

        # Move agents
        self.agents = [agent for agent in self.agents if agent.move(self.sugar)]

    def get_grid(self):
        grid = self.sugar.copy()
        for agent in self.agents:
            grid[agent.x,agent.y] = 10
        return grid

# Set up model
model = SugarScape(300,300, num_agents=100)

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
    ax.set_title(f'Step: {frame}, Agents: {len(model.agents)}')
    return [img]

# Create animation
anim = anim.FuncAnimation(fig,update,frames=200,interval=50,blit=False)
plt.show()
