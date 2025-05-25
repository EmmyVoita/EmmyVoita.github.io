---
layout: custom-post
title: Markov Decision Process<br> & QLearning
date: 2025-01-04 00:00:00 -0700
originallycompleteddate: 2023-02-05 00:00:00 -0700
permalink: /posts/Q-Learning/
image: /assets/Images/QLearning/QLearning_04.PNG
description: >
    Explores a simple implementation of Q-Learning
categories: jekyll update main
tags: [Unity]
---


![2025-01-2820-40-41-ezgif com-optimize](/assets/videos/QLearning/2025-01-2820-40-41-ezgif.com-optimize.gif){: .post-header-image-with-description .clickable-image } 

<div class="custom-image-description">
The agent follows the optimal policy after training to maximize rewards. The visualization shows different starting positions for the agent within the same episode.
</div>


* [Overview Part1](#overview_p1)
    * [Mathmatical Concepts](#mathmatical-concepts)
    * [Implementation Approach](#implementation-approach)
* [Overview Part2](#overview_p2)
    * [Q-Learning](#q-learning)
    * [Implementation Approach](#implementation-approach-p2)
    * [Future Work](#future-work)
* [Resources](#links)

<div class="reusable-divider">
    <span class="small-header-text" id="overview_p1">Overview</span>
    <hr>
</div>

Reinforcement learning is a framework for teaching agents to make decisions in complex environments. At the core of this approach is the idea of a Markov Decision Process (MDP), which is a way of describing situations where an agent makes decisions in an environment that’s a mix of chance and control. One of the most well-known algorithms for solving MDPs is Q-Learning, a model-free method that enables agents to learn optimal actions through trial and error, without requiring a full model of the environment. 

This post covers a two-part project. In the first part, I implemented a simulation where an agent navigates a grid-world environment, aiming to reach a goal state while avoiding obstacles. In the grid-world, the agent can move up, down, left, and right. Each move in any direction will inccur a cost, and the objective of the agent is to minimize the total cost while reaching the goal. 

The agent will move using an algorithm that utilizes the Bellman equation, value iteration algorithm, and Markov decision process (MDP). These concepts enable the simulation of the agent’s traversal. A reward system is defined by assigning a cost of -1 per move and a reward of +100 for reaching the goal. The total cost is the sum of these rewards, which is optimized using value iteration.

<div class="reusable-divider">
    <span class="small-header-text" id="mathmatical-concepts">Mathmatical Concepts</span>
    <hr>
</div>


The Bellman equation is used to compute the optimal value function for each state in the MDP:

<!-- V(s) = max_a(R(s, a) + γ * sum_s'(T(s, a, s') * V(s'))) -->

$$
V(s) = \max_a \left( R(s, a) + \gamma \sum_{s'} T(s, a, s') \cdot V(s') \right)
$$

**Where:**
* $$ V(s) $$ is the value function for state s, which represents the expected total cost of reaching the goal state from that state.
* $$ \max_a $$ is the maximum over all possible actions a in state s (the optimal policy).
* $$ R(s, a) $$ is the immediate reward received for taking action a in state s.
* $$ \gamma $$ is the discount factor, which determines the importance of future rewards relative to immediate rewards. This can be set to a relatively high value ~0.9 in order to encourage the agent to reach the goal state as efficiently and quickly as possible.
* $$ \sum_{s'} T(s, a, s') \cdot V(s') $$ is the expected discounted value of the future rewards (next state)

<!-- sum_s'(T(s, a, s') * V(s')) -->

By computing the optimal value function using the Bellman equation, we can determine the optimal policy (i.e., the optimal sequence of moves) for the agent to reach the goal state with the lowest possible total cost. The agent can follow this policy to navigate the grid-world environment and reach the goal state while avoiding obstacles.

<div class="reusable-divider">
    <span class="small-header-text" id="implementation-approach">Implementation Approach</span>
    <hr>
</div>

A grid-world environment is created using a custom grid system with sprites, where each cell represents a state in the Markov decision process (MDP) and is labeled with an ID or coordinate. The object's action options (moving up, down, left, or right) on the grid correspond to the actions in the MDP and can be represented by integers.

Transition probabilities from one state to another depend on the grid's structure and obstacles, and will be defined using a transition function that takes the current state and action as input, returning the next state and its probability. The reward function determines the immediate reward for each action, and will be defined using a function that takes the current state and action as input and returns the corresponding reward.

To implement the value iteration algorithm, an MDP script includes a function to compute the optimal value function and policy for each state in the MDP. The value function will be initialized to 0 and will be updated at each iteration using the Bellman equation. Once the value iteration algorithm converges, the optimal value function can be used to determine the optimal policy for each state in the MDP. Then, we can control an object's movement using the policy. 

**FlowChart:**

![QLearning_01](/assets/Images/QLearning/QLearning_01.png){: .default-image .clickable-image}


<!-- 
The simulation involves an agent navigating a grid-world environment to reach a goal state while avoiding obstacles. The agent can move up, down, left, or right, with each move incurring a cost. The objective is to minimize the total cost while reaching the goal.

The simulation which we are going to create is an agent that traverses a grid-world environment. The agent will need to reach the set goal state while avoiding obstacles. In the grid-world, the agent can move up, down, left, and right. Each move in any direction will have a cost, and it is the agent’s goal to reach the goal state at the lowest possible cost. 

-->



 
<!-- 
**How are the concepts listed above relevant and its purpose? (one paragraph)**

The agent will move using an algorithm that utilizes the Bellman equation, value iteration algorithm, and Markov decision process (MDP). These are the listed concepts relative to Topic 4, and they will be used as the driving factor in simulating the agent’s traversal throughout the generated grid-world and obstacles. Additionally, we will need to define a reward system for the agent’s traversal in order to apply the value iteration algorithm. This reward system can simply be setup by assigning a cost of -1 to each move by the agent, and some reward such as +100 to the agent reaching the end goal. The sum of these rewards will be the total cost. 

**Which search method will be used? (one paragraph and bullet points outline)**

	The search method that we use will be applied using the Bellman equation and value iteration algorithm. More specifically, it can be modeled using a Markov decision process for each state. The following Bellman equation can be used to compute the optimal value function for each state in the MDP:

V(s) = max_a(R(s, a) + γ * sum_s'(T(s, a, s') * V(s'))) 

Where:
* V(s) is the value function for state s, which represents the expected total cost of reaching the goal state from that state.
* max_a is the maximum over all possible actions a in state s (the optimal policy).
* R(s, a) is the immediate reward received for taking action a in state s.
* γ is the discount factor, which determines the importance of future rewards relative to immediate rewards. This can be set to a relatively high value ~0.9 in order to encourage the agent to reach the goal state as efficiently and quickly as possible.
* sum_s'(T(s, a, s') * V(s')) is the expected discounted value of the future rewards (next state)

By computing the optimal value function using the Bellman equation, we can determine the optimal policy (i.e., the optimal sequence of moves) for the agent to reach the goal state with the lowest possible total cost. The agent can follow this policy to navigate the grid-world environment and reach the goal state while avoiding obstacles.
-->


<!-- 
**Outline your approach to implementation and integration in your project (list of steps)**



**How will you overcome unforeseen obstacles during implementation? What is your 'plan B'? (one paragraph or list of steps)**

If issues arise while trying to implement the above, we can look for resources online that have successfully implemented the MDP. 

**How is the project aligned with the current topic objectives? (two-column table listing the objectives and how each is met by the proposed project)**

Topic 4 Objectives
Relevancy
Explain the techniques of value iterations and policy iterations.
The value iteration algorithm will be used in our simulation in order to calculate the cost of the agent’s movement by using a reward function and discount factor.
Implement the Bellman equation in a value iterative process.
The Bellman equation is used to compute the optimal value function for each state in the MDP.
Demonstrate that a Markov process converges towards a decision.
Using the Bellman equation and a Markov decision process, the goal of our simulation  is to find the set of states (agent’s final path) which the MDP converges toward.


**What will appear on the screen: animation, user interactions, information dashboards, UI elements, etc. (a mock screen depicting all elements, followed by brief descriptions)**
Generated grid-world area with labeled obstacles and goal state
Agent + agent path which is computed and displayed
Mock screen:


**List the platform and software tools you plan on using (bulleted list)**
* Unity as the game engine

<div class="reusable-divider">
    <span class="small-header-text" id="overview">Implementation</span>
    <hr>
</div>



**A flowchart detailing the logic of the algorithm(s) you implemented.**

The entire code that was implemented for this project. 
Uploaded to Padlet: https://padlet.com/RylanCasanova/50f91x3bk6bp8ond
A screencast demonstrating the execution of the code. If the screencast file is too large to upload, upload it only to BitBucket. (video file)
Uploaded to Padlet: https://www.loom.com/share/2d6b2abc72fa44acb37ed9d1ebdb9274
A list of references you used in your implementation, including code libraries and code snippets you adapted and incorporated. Acknowledge that you are familiar with copyright laws and regulations and that all external code use is permissible. (list of sources with links to their usage agreements)
https://padlet.com/ricardo_citro/cst-415-principles-of-artificial-intelligent-goemhcrupula2h8x/wish/2498707314
https://www.geeksforgeeks.org/markov-decision-process/?ref=lbp
https://medium.com/mlearning-ai/a-crash-course-in-markov-decision-processes-the-bellman-equation-and-dynamic-programming-e80182207e85
-->


<div class="reusable-divider">
    <span class="small-header-text" id="overview_p2">Part2 Overview</span>
    <hr>
</div>


The goal of the second part of this project was to adapt the previous program, which solves an MDP using value iteration, to instead incorporate machine learning techniques. To do so, the following steps would be taken:

* **Choose a learning algorithm:** Choose a learning algorithm that can learn from the MDP. This may involve selecting a reinforcement learning algorithm, such as Q-learning or SARSA.
* **Train the model:** Train the model by repeatedly simulating the MDP and updating the policy based on the observed rewards. This involves running the learning algorithm on the MDP until the policy converges.
* **Tune the parameters:** The parameters of the model, such as the learning rate or discount factor, can be modified to make the agent behave as desired. For example, using a small discount factor will cause the agent’s optimal policy to converge towards immediate rewards. 


<div class="reusable-divider">
    <span class="small-header-text" id="q-learning">Q-Learning</span>
    <hr>
</div>

Machine Learning algorithms like Q-Learning enable an agent to learn and adapt to an environment without requiring prior knowledge. This capability makes Q-learning widley applicable to real-world scenarioes like games, robotics, and autonomous vehicle navigation.

Q-learning is a model-free reinforcement learning algorithm that trains an agent in an MDP environment. It is a type of adaptive dynamic programming, which is a category of machine learning algorithms that are used to solve optimization problems in dynamic environments. The agent starts with no prior knowledge of the MDP's transition or reward functions and learns an optimal policy that maximizes the expected cumulative reward over time through exploring the environment. 

![QLearning_02](/assets/Images/QLearning/QLearning_02.PNG){: .default-image .clickable-image}

At each time step, the agent observes the current state of the environment, chooses an action, and receives feedback from the environment in the form of a reward and a new state. Over time, the agent updates its understanding of state-action pairs using the Q-values, which represent the expected cumulative reward of taking a specific action in a given state while following the optimal policy thereafter. The updates rely on the Bellman equation, which calculates the Q-value as the immediate reward plus the discounted maximum Q-value of the following state-action pair. The Q-values are refined interatively through exploration and converge to optimal values. The agent then selects actions based on the Q-values of the current state, following a policy that is greedy with respect to the learned Q-values.


<!--

Over time, the agent updates its understanding of state-action pairs using the Q-values, which represent the expected cumulative reward of taking a specific action in a given state while following the optimal policy thereafter. The updates rely on the Bellman equation, which calculates the Q-value as the immediate reward plus the discounted maximum Q-value of the subsequent state-action pair. The Q-values are refined iteratively through exploration and converge to optimal values, allowing the agent to follow a policy that maximizes rewards.
-- >

<!-- 
Q-learning is a machine learning algorithm that trains an agent in an MDP environment. It is a model-free algorithm, which means that the agent has no prior knowledge of the MDP’s transition or reward function. The goal of the agent in Q-learning is to learn optimal policy that maximizes reward gained over time by updating Q-values of state-action pairs through exploration.

Q-learning achieves this by learning the Q-values of state-action pairs, where Q-values represent the expected cumulative reward of taking a particular action in a particular state and following the optimal policy thereafter. The Q-value of a state-action pair is updated using the Bellman equation, which states that the optimal Q-value of a state-action pair is equal to the immediate reward received plus the discounted maximum Q-value of the next state-action pair.

The Q-learning algorithm repeatedly updates the Q-values using the Bellman equation until they converge to the optimal values. The agent then selects actions based on the Q-values of the current state, following a policy that is greedy with respect to the learned Q-values.
-->






<div class="reusable-divider">
    <span class="small-header-text" id="implementation-approach-p2">Implementation Approach</span>
    <hr>
</div>

The MDP implementation in the fist part of this project uses a predefined transition and rewards function. To modify the program to use Q-learning, I need to implement a Q-learning algorithm, which will update the Q-values based on the observed rewards and choose actions based on the highest Q-values. Using this approach, the agent should learn an optimal policy without complete knowledge of the entire environment.

![QLearning_03](/assets/Images/QLearning/QLearning_03.PNG){: .default-image .clickable-image}

<!-- 
**Implementation steps:**
* 

**Define a function that:**
* Initializes all Q-values for action-state pairs to 0 for initial trial.
* The agent chooses an action based on the exploration algorithm.
* The agent moves to the next state based on the action, observes the reward and updates the Q-value action-state pair.
-->

Here is the main loop for interatively refining the Q-values. We let the agent have a lifetime of x amount of moves to represent an episode. With each episode, the agent uses the updated Q-values for action-state pairs from the previous trial to explore the environment. 

<div class="padded-code-block">
{% highlight C# %}
public void QLearning(int numEpisodes, int maxIterations, int getPolicyOnEpisode)
{
    for (int episode = 0; episode < numEpisodes; episode++)
    {
        int state = UnityEngine.Random.Range(0, numStates);

        while(IsObstacleState(state))
        {
            state = UnityEngine.Random.Range(0, numStates);
        }

        if (episode % getPolicyOnEpisode == 0)
        {
            startingStateList.Add(state);
        }

        int count = 0;
        while (count < maxIterations)
        {
            int action = ChooseAction(state);

            (int nextState, float reward) = GetNextStateAndReward(state, action);

            float maxQValue = GetMaxQValue(nextState);

            //update qValue using temporal difference error

            //qValues[state,action] is the current estimate of Q-values
            //alpha is learning rate
            //reward is the reward obtained by taking action in that state
            //gamma is the discount factor (imporatance of future rewards vs immediate rewards)
            //maxQValue is the maximum QValue amoung all possible actions in the next state.
            qValues[state, action] = qValues[state, action] + alpha * (reward + gamma * maxQValue - qValues[state, action]);

            state = nextState;

            if(reward == obstacleReward)
            {
                break;
            }

            count++;
        }

        // Every xth episode, add the current policy to the list
        if (episode % getPolicyOnEpisode == 0)
        {
            int[] policy = GetOptimalPolicy();
            policyList.Add(policy);
        }

    }
}
{% endhighlight %}
</div>    

At each step, the agent selects an action using an ε-greedy strategy. Either the agent explores with probability ε, or exploits by selecting the action with the highest Q-value. The ε property helps the agent to balance between exploration and exploitation, which ensures that the agent discovers better strategies while still using what it has already learned.


<div class="padded-code-block">
{% highlight C# %}
private int ChooseAction(int state)
{
    // Choose a random action with probability epsilon
    // else choose the action with the highest Q-value for the current state with probability 1-epsilon

    if (UnityEngine.Random.Range(0.0f, 1.0f) < epsilon)
    {
        // Choose a random action (exploration)
        return UnityEngine.Random.Range(0, numActions);
    }
    else
    {
        // Choose the action with the highest Q-value for the current state (exploitation)
        float[] qValuesForState = new float[numActions];
        for (int i = 0; i < numActions; i++)
        {
            qValuesForState[i] = qValues[state, i];
        }
        return Array.IndexOf(qValuesForState, qValuesForState.Max());
    }
}
{% endhighlight %}
</div>    

Once an action is chosen, the reward for that state and chosen action is aquired through a lookup in the predefined reward table. A check is also done to ensure the next state is valid.

<div class="padded-code-block">
{% highlight C# %}
private (int, float) GetNextStateAndReward(int state, int action)
{
    int nextState = GetNextState(state, action);

    if (nextState == -1)
    {
        Debug.Log("nextState = -1");
        return (state, obstacleReward);
    }
    else
    {
        // Retrieve the reward from the predefined reward table
        float reward = rewards[state, action, nextState];
        return (GetNextState(state, action), reward);
    }
}
{% endhighlight %}
</div>  

To update Q-values, the agent needs to estimate the best possible future reward from a given state. This function retrieves the maximum Q-value, through another lookup, among all available actions for the specified state.

<div class="padded-code-block">
{% highlight C# %}
private float GetMaxQValue(int state)
{
    // Finds the maximum Q-value among all possible actions in a given state.
    // This helps estimate the best future reward possible from the state.

    float maxQValue = float.MinValue;
    for (int i = 0; i < numActions; i++)
    {
        if (qValues[state, i] > maxQValue)
        {
            maxQValue = qValues[state, i];
        }
    }
    return maxQValue;
}
{% endhighlight %}
</div>  

<!-- 
We then set the q value for the current state and action using the previously mentioned function and move to the next state. In my implementation I return the optimal policy every 20th episode by default so that I can better show progression. The opitmal polocy funtion selects the action with the highest Q-value for each state,  The agent then uses the policy table to lookup where to move for its current position. 
-->

Once we decide that learning is complete, we can get the optimal policy by selecting the action with the highest Q-value for each state. This function returns an array where each index represents a state and its corresponding value is the best action to take.

<div class="padded-code-block">
{% highlight C# %}
public int[] GetOptimalPolicy()
{
    int[] policy = new int[GetNumStates()];

    // For each state, choose the action with the highest Q-value
    for (int state = 0; state < GetNumStates(); state++)
    {
        float maxQValue = float.MinValue;
        int maxAction = -1;

        // Iterate through all actions and select the one with the highest Q-value
        for (int action = 0; action < GetNumActions(); action++)
        {
            if (qValues[state, action] > maxQValue)
            {
                maxQValue = qValues[state, action];
                maxAction = action;
            }
        }

        policy[state] = maxAction;
    }

    return policy;
}
{% endhighlight %}
</div>  

Then when deciding how to move the agent, the direction from the optimal policy is sampled using the agents current position. You can see how after training the agent always uses the most optimal strategy, which is to move back and forth to the state with the highest reward. 

![2025-01-2820-40-41-ezgif com-optimize](/assets/videos/QLearning/2025-01-2820-40-41-ezgif.com-optimize.gif){: .default-image .clickable-image } 

<div class="reusable-divider">
    <span class="small-header-text" id="#future-work">Future Work</span>
    <hr>
</div>

I think it would be interesting to try and implement reinforcement learning to control enemy AI in a game. I don't think it would be practical, because it would be difficult to try and enusre that the AI behaves in predictable or balanced way to ensure a good player experience, but I think it would be a good learning experience. 

To do this, a 2D world would probably be an ideal starting point, since it would simplify the action space and state representation. Given the need for more structured and predictable behaviour, I imagine that it would be ideal to use a finite state machine to represent the agents different possible actions and states. This would allow for more controlled decision-making, while still enabling some degree of adaptability in enemy behavior that could be trained. For example, using a finite state machine to represent different enemy attacks, and training the agent to know when to use a specific attack in a specific scenario. 



<!-- 
Overcoming Unforeseen Obstacles During Implementation:


If issues arise with implementing Q-learning I could try implementing another machine learning algorithm. If there are issues with implementing multiple trails, I could have the agent run continuously. 


Current topic objectives: 


Objective: Implement reinforcement learning algorithms.


This project implements reinforcement learning. As the agent moves around the environment, it updates the optimal policy based on rewards. As highlighted in the image below, the reward is included in the target estimate of the TD error component. 



Objective: Demonstrate the use of adaptive dynamic programming.


Adaptive dynamic programming (ADP) is a category of machine learning algorithms that are used to solve optimization problems in dynamic environments. Q-learning falls into the category of ADP.


Objective: Explain the use of temporal-difference (TD) in learning algorithms.

Temporal-difference (TD) is a method used in machine learning that involves updating the transition probabilities for states based on observations made when an agent interacts with its environment. This project incorporates TD as the reward and transition probability tables used in the MDP are determined and updated by agent exploration. 


Mock Screen:
Here is what the scene might end up looking like, which is taken from project 4. 

Tools Used:
Unity
Flow Chart:
-->


<div class="reusable-divider">
    <span class="small-header-text" id="links">LINKS</span>
    <hr>
</div>

1. [Markov Decision Process](https://www.geeksforgeeks.org/markov-decision-process/?ref=lbp)
2. [A Crash Course in Markov Decision Processes, the Bellman Equation, and Dynamic Programming](https://medium.com/mlearning-ai/a-crash-course-in-markov-decision-processes-the-bellman-equation-and-dynamic-programming-e80182207e85)
