# LXZE's 2022 Advent of Code solutions

This repository was established to be a dedicated archive of my solutions for problems in [Advent of Code 2022](https://adventofcode.com/2022).  
Each day's solutions (1 for the first part, 2 for the second part, obviously) and input files (test.txt for the test case, input.txt for the actual one) are separated into a folder named with its released date.  

Read it at your own risk.  

## Note 

### Keyword for googling 
- Day 7: tree traversal
- Day 12: Dijkstra algorithm, Breadth-first search
- Day 15: linear algebra
- Day 16: weighted graph traversal, multiple search actor, time-limited graph search
- Day 17: state cycle detection
- Day 18: 3D surface calculation
- Day 19: greedy search in state space
- Day 20: index manipulation, cycle linked list

### Note for further year (!! spoiler alert !!)
- Day 16: (With the help from reddit advent of code)
    - Input: graph information and node value
    - Problem:
        - Find the best traversal path that return the most value
        - within limited timeframe
        - and by 2 search actors
    - Solution:
        1. Filter the interesting nodes (leaf node or yield a value)
        2. calculate required time to traverse to every nodes
        3. Create a map to store the required time from A to B
        4. Initiate state and add to queue, then calculate until queue is empty
        5. For multiple actors, calculate each actor's best result, and then find the result from each actor that don't intersect with each other
- Day 17:
    - Input: a line of input
    - Problem: Simulate tetris but the block is manipulated by each character of input (also in cycle) and find the height of tetris (after 1 trillion loop)
    - Solution:
        1. Simulate and create a state to track that when will the simulation become a cycle
        2. calculate (trillion - state at the start of cycle) divided by (state at the end of cycle - state at the start of cycle) = amount of cycle
        3. amount of cycle multiply by height of each cycle, add by height before cycle has started
        4. if there are remain round to simulate then proceed (if result at step 2 is not divisible)
- Day 18:
    - Input: 3D position for each cubelet
    - Problem:
        1. Find surface area of connected cube
        2. Find surface area for inside surface only
    - Solution
        1. Reduce each cubelet's surface value if it's connected
        2. Flood object to find the remain air cubelets then calculate surface
- Day 19:
    - Input: requirement for creating each robot
    - Problem: Find the best way to create robots, which generate the result, in given timeframe
    - Solution:
        - Greedily create the robots that yield the desire result
        - If not, then find the best choice that could lead to create the aforementioned robots, by try all choices and find the max one
- Day 20:
    - Input: list of integers
    - Problem: Calculate the new position of the list of int, order by time its appearance in the initial list (which is also in circular)
    - Solution: Create another array that contains only index of int list, then use this array to calculate the next index, based on its current index
- Day 21:
    - Input: list of variable and its value or equation
    - Problem: find the value that make the given equation become truthy
    - Solution: Using eval if possible, then solve the equation accordingly
- Day 22:
    - Input: 2D Map and command
    - Problem: traverse the map normally, but when it goes to the empty zone
        Part 1: cursor go to another end of axis
        Part 2: cursor go to another edge of square (treat map as cube)
    - Solution: Cut a paper and create a cube then observe its x, y value on the edge
- Day 23:
    - Input: 2D Map
    - Problem: Find the amount of step that everything in map is stop
    - Solution: calculate the new position of an elem in the map straightforwardly
- Day 24:
    - Input: 2D Map
    - Problem: Go from point a to point b but the map is always changed in each step.
    - Solution: Traverse through the map by expanding possible steps and reduce possible steps by constrain, then loop until valid point is appeared in the steps.
- Day 25:
    - Input: list of data
    - Problem: Convert data to number and convert number back to other base but base number start at negative value (in this case, -2..2)
    - Solution: mod number with range of value (% 5), but need to add value for next loop of calculation by amount of negative number (for -2, -1 respectively, 3 -> add 2, 4 add 1)