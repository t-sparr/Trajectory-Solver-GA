import random
import socket
import json
from deap import base, creator, tools, algorithms


#DEAP Setup

creator.create("FitnessMax", base.Fitness, weights=(1.0,))
creator.create("Individual", list, fitness=creator.FitnessMax)

toolbox = base.Toolbox()

toolbox.register("attr_angle", random.uniform, -90, 0)
toolbox.register("attr_power", random.uniform,0,100)
toolbox.register("individual", tools.initCycle, creator.Individual, 
                 (toolbox.attr_angle, toolbox.attr_power), n=1)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)




# def main():
#     pop = toolbox.population(n=10)
#     print(pop)



