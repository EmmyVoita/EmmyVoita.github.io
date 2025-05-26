---
layout: custom-post
title: FSM Character<br>Controller
date: 2025-01-24 00:00:00 -0700
originallycompleteddate: 2024-04-01 00:00:00 -0700
permalink: /posts/FSM-Character-Controller/
image: /assets/Images/Unity3DGame/post_picture_unitygame.PNG
description: >
  Examines the role of finite state machines in game development
  through an implementation of a character movement system.
categories: jekyll update main
tags: [Unity]
priority: 1
---

![2025-01-2720-09-36-ezgif optimize](/assets/videos/Unity3DGame/2025-01-2720-09-36-ezgif.com-optimize.gif){: .post-header-image-with-description .clickable-image} 
<div class="custom-image-description">
Showcases a character controller navigating a test scene, demonstrating movement mechanics controller by a finite state machine.
</div>

* [Overview](#overview)
* [Implementation](#implementation)
* [Resources](#links)


<div class="reusable-divider">
    <span class="small-header-text" id="overview">Overview</span>
    <hr>
</div>

Finite state machines (FSMs) are an important tool in game development, offering a structured way to manage complex behaviors. In my 3D game project, FSMs are central to managing character movement, the core mechanic of the game, making the system easier to manage and extend.

As explained in the article by Georges Lteif **[1](#FSMIntroduction)**, an FSM is a mathematical model used to describe the dynamic behavior of systems through a finite number of states, transitions between these states, and actions associated with these transitions. As discussed in the article _What Is The Difference Between DFA And NFA?_ **[2](#DifferenceDFANFA)**, FSMs can be categorized into two main types: non-deterministic finite automata (NFA) and deterministic finite automata (DFA).

A NFA allows for the machine to exist in multiple states simultaneously, allowing for multiple possible transitions from a given input. 

* The machine can be in multiple states at the same time.
* It’s not always clear what the next state is, as multiple valid transitions may exist.

A DFA, on the other hand, requires that there is exactly one possible state transition for a given state and input. This ensures:

* The machine is always in a single, well-defined state.
* There is no ambiguity in determining the next state.

**The Role of FSMs in Game Development**

As outlined in the video _How to Program in Unity: State Machines Explained_ **[4](#ProgramStateMachine)**, an FSM offers an important solution to manage a game and its components as they become more complex, being a structured and efficent way to manage the behavior and interactions of dynamic elements. 

A state can be thought of as the current condition of an object or system. For example, when designing a character controller, you might break down the character's actions into individual states such as:

* Idle
* Running
* Walking
* Jumping
* Falling
* Climbing
* Sliding
* Swimming

Similarly, we can break down a weapon's states:

* Attacking
* Ready
* Cooldown
* Reloading
* Disabled

Each state represents a specific behavior of an object or system. For instance, if a player is in the Running state, you might apply a speed multiplier to their movement. Whereas, if the player is in the Falling state, you would instead apply gravity.

* **Managing Complex Behaviors:** The state pattern allows for a clear separation of behaviors within code. By implementing a state pattern, we can eliminate unnecessary dependencies between states, allowing us to modify the behavior of an object or system for a state without affecting other states, which makes the system easier to manage, extend, and debug. 

* **Efficiency and Performance:** Without FSMs, managing states would require numerous conditionals checked repeatedly even when irrelevant. FSMs improve this by focusing only on the current state and its specific logic, which reduces unnecessary checks. For example, if we wanted to determine whether the player should walk, we no longer need to manually check whether the player is not falling or in any other state that prevents walking.

In the context of game design, it's important to organize states in a way that creates a minimal DFA, where we ensure that each state transition is clearly defined and does not lead to ambiguity. Structuring the states in this way helps to reduce unnecessary complexity. To give a practical example of minimizing a DFA, I originally came up with three states when implementing a slide mechanic for my player. At this time, I was also considering how to make sure that the player's movement worked for slopes, and I wanted to implement some custom logic for when the player would slide down a slope. 

* **Sliding:** handle basic sliding logic
* **SlidingOnSlope:** handle sliding logic when the player is on a slope
* **SlidingOnSlopeGravityAccel:** extend the player's slide so long as they are oriented down the slope. 

While these states made sense at first, this approach quickly became unmanageable as following the same logic, I would need equivalent states for other movement types, such as running, walking, and jumping:

* RunningOnSlope
* WalkingOnSlope
* JumpingOnSlope

These additional states would introduce redundancy as they would share essentially the same transitions and only slightly differ in their behavior (calculating the same movement just for a slope). This demonstrates how quickly the number of states can grow to represent every possible scenario.

Instead of defining individual states for each situation, I refactored the design by abstracting the "OnSlope" behavior into a  separate system. Thereby, separating the logic for slopes from the movement states and treating it as its own concern. This resulted in a secondary FSM for processing and applying the player's movement. For my current implementation, I need two states to represent this FSM: Normal and OnSlope.

<!--
 Since I only have two states, I did not necessarily need to implement a full state pattern, which is why I just use a conditional. However, if I had more complex scenario, I could extend this approach by introducing a second FSM specifically for handling movement calculations.
-->

<div class="reusable-divider">
    <span class="small-header-text" id="implementation">Implementation</span>
    <hr>
</div>

To implement an FSM to control my character's movement actions, the main class _FSMPlayer_ is passed around to each state. This is part of the "Context" that is described in the aforementioned video **[3](#ProgramStateMachine)**. To represent each state in a way that enhances scalability, I also created an abstract class as a framework for different states. To implement automatic handling of state transitions, I created a _StateTransition_ class that contains all of the data needed for evaluating transition conditions, and a _PlayerStateCondition_ which serves as a framework for defining and updating dynamic data which the transition depends on (e.g., grounded check).

In the _PlayerState_ class's _OnUpdate_ function, I call all dependency conditions (e.g., the grounded check) to ensure they contain the most up-to-date information before the _OnFixedUpdate_ function is called. Then, I run any logic in the overrideable _Execute_ function. The _OnFixedUpdate_ function loops through each transition condition to determine whether a state change should occur. If no transition occurs, the overridable _FixedExecute_ function is called. 

I found that transition conditions must be evaluated in FixedUpdate to ensure that physics-based calculations in FixedExecute, such as jumping and falling mechanics, remain frame-rate independent.


<!-- 
 In addition to separating dynamic data into its own classes, I also created an abstract class as a framework for different states and started converting states over to utilize that, which is the "PlayerState" class in the code below. This makes creating new states significantly easier to manage, and significantly simplifies my main script for character movement. 
-->

<div class="padded-code-block">
{% highlight C# %}

namespace PlayerStates
{
    [System.Serializable]
    public abstract class PlayerStateCondition
    {
        private int lastCheckedFrame = -1;

        public void OnUpdate(FSMPlayer context)
        {
            if (Time.frameCount != lastCheckedFrame)  // Only update if we're on a new frame
            {
                lastCheckedFrame = Time.frameCount;
                CheckCondition(context);  // Re-evaluate the condition
            }
        }
        public abstract void CheckCondition(FSMPlayer context);
        public virtual void OnDrawDebugGizmos(FSMPlayer context) {}
    }


    public class StateTransition
    {
        public Func<bool> Condition;
        public PlayerState NextState;
        public Action<FSMPlayer> OnExit { get; }
        public Action<FSMPlayer, PlayerState> OverrideSwitchState { get; } // Custom state-switching function
        public List<PlayerStateCondition> DependencyConditions { get; }  // List of conditions that must be met for this transition to occur
        

        public StateTransition(Func<bool> condition, 
                               PlayerState nextState, 
                               Action<FSMPlayer> onExit = null, 
                               Action<FSMPlayer, PlayerState> overrideSwitchState = null, 
                               List<PlayerStateCondition> dependencyConditions = null)
        {
            Condition = condition;
            NextState = nextState;
            OnExit = onExit;
            OverrideSwitchState = overrideSwitchState;
            DependencyConditions = dependencyConditions ?? new List<PlayerStateCondition>();
        }
    }
    
    [System.Serializable]
    public abstract class PlayerState 
    {
        public Action<FSMPlayer> onExitAnyCallback;
        protected List<StateTransition> transitions = new List<StateTransition>();
        

        public PlayerState() {}

        public void AddTransition(Func<bool> condition, 
                                  PlayerState nextState, 
                                  Action<FSMPlayer> onExit = null, 
                                  Action<FSMPlayer, PlayerState> overrideSwitchState = null, 
                                  List<PlayerStateCondition> dependencyConditions = null)
        {
            transitions.Add(new StateTransition(condition, nextState, onExit, overrideSwitchState, dependencyConditions));
        }

        public void OnUpdate(FSMPlayer context)
        {
            // Update condition values in Update to ensure they are fresh
            foreach (var transition in transitions)
            {
                foreach (var condition in transition.DependencyConditions)
                {
                    condition.OnUpdate(context);
                }
            }

            Execute(context);
        }

        public void OnFixedUpdate(FSMPlayer context)
        {
            bool transitionOccurred = false;

            foreach (var transition in transitions)
            {
                if (transition.Condition.Invoke()) 
                {
                    transition.OnExit?.Invoke(context);  // Exit action for current state
                    onExitAnyCallback?.Invoke(context);  // Exit action for all states

                    if (transition.OverrideSwitchState != null)
                    {
                        transition.OverrideSwitchState.Invoke(context, transition.NextState);
                    }
                    else
                    {
                        context.SwitchState(transition.NextState);
                    }

                    transitionOccurred = true;
                    break;  // Exit loop on first valid transition
                }
            }

            if (!transitionOccurred)
            {
                FixedExecute(context);  // Continue executing state behavior
            }
        }

        public virtual void Execute(FSMPlayer context) {}
        public virtual void FixedExecute(FSMPlayer context) {}


        public virtual void ConfigureTransitions(FSMPlayer context) {}
        public virtual void OnEnter(FSMPlayer context) {}
    }
}
{% endhighlight %}
</div>

<!-- 
Here is an example player state class. I set the onExitAnyCallback to set the players vertical velocity to 0, which i want to do idependent of what state gets transitioned to. In the _ConfigureTransitions_ function I define all of the transition conditions, through defining what data each transition relys on, a bool function for the transition condition, and an optional _onExit_ callback. In the _Execute_ function I update the appropriate animator variable for falling, and manage the players rotation. Then, in the _FixedExecute_ function, I update the players vertical and horizontal velocity.
-->

Here is an example implementation of the _PlayerState_ class. I set the _onExitAnyCallback_ to reset the player's vertical velocity to 0, ensuring this happens regardless of which state the player transitions to.

In the _ConfigureTransitions_ function, I define all transition conditions by specifying the data each transition relies on, a boolean function for the transition condition, and an optional _onExit_ callback.

In the _Execute_ function, I update the appropriate animator variable for falling and manage the player's rotation. Then, in the _FixedExecute_ function, I update the player's vertical and horizontal velocity.


<div class="padded-code-block">
{% highlight C# %}
namespace PlayerStates
{
    public class FallingState : PlayerState
    {
      
        public FallingState()
        {
            onExitAnyCallback = (context) => 
            { 
                context.verticalVelocity = 0.0f;
            };
        }
        
        public override void ConfigureTransitions(FSMPlayer context)
        {
            var player = context.playerData;

            // Define Dependency Conditions
            List<PlayerStateCondition> isIdleConditions = new List<PlayerStateCondition>
            {
                context.groundCheck
            };

            List<PlayerStateCondition> isEdgeHoldConditions = new List<PlayerStateCondition>
            {
               context.edgeHoldCheck
            };


            bool IsIdle() =>
                context.groundCheck.playerGrounded;

            bool IsEdgeHold() =>
                context.edgeHoldCheck.edgeHoldState;


            void OnExitIdle(FSMPlayer ctx)
            {
                var animationController = context.playerAnimationController;

                foreach(VisualEffectStruct vfx in context.onLandVFX)
                {
                    VFXEventController.Instance.SpawnSimpleVFXGeneral(vfx, context.playerRoot.transform);
                }

                if (animationController._hasAnimator) animationController.animator.SetBool(animationController.GetAnimatorIDFreeFall(), false);
            }


            AddTransition(IsIdle, context.idleState, OnExitIdle, dependencyConditions: isIdleConditions);
            AddTransition(IsEdgeHold, context.edgeHoldState, dependencyConditions: isEdgeHoldConditions);
        }
       
        public override void Execute(FSMPlayer context)
        {
            var jumpAndFallData = context.jumpAndFallingData;
            var animationController = context.playerAnimationController;

            // Update animator 
            if (animationController._hasAnimator) animationController.animator.SetBool(animationController.GetAnimatorIDFreeFall(), true);

            // Push the rotation to the stack
            context.playerRotationManager.scheduledRotations.Push(new RotationData(jumpAndFallData.rotationSmoothTime));
        }

        public override void FixedExecute(FSMPlayer context)
        {
            PlayerMovementHelpers.UpdateVerticalVelocity(context);
            PlayerMovementHelpers.UpdateHorizontalVelocityInAir(context);  
        }

        public override void OnEnter(FSMPlayer context)
        {
            context.playerDataManager.EdgeJumpModifier = 0.0f;
            context.playerDataManager.BaseJumpModifier = 0.0f;
        }
    }
}
{% endhighlight %}
</div>

The following class defines the main controller for the FSM. It declares each player state and player state condition, then calls the current state's _OnUpdate_ and _OnFixedUpdate_ within the update loop. After updating the player's current movement state FSM, the class applies the same update and fixed update process to the player movement processing FSM, which handles moving the character controller.

<div class="padded-code-block">
{% highlight C# %}
namespace PlayerStates
{
    public class FSMPlayer : MonoBehaviour
    {
        [Header("References")]
        public PlayerDataManager playerDataManager;
        public PlayerRotationManager playerRotationManager;
        public PlayerAnimationController playerAnimationController;
        public PlayerResources playerResources;
        public PlayerWeaponContainer playerWeaponContainer; 
        public GameObject playerRoot;
        public LayerMask groundLayers;
        public CharacterController characterController;
        

        [Header("Debug Options")]
        [SerializeField] private bool logStateTransitions = false; 
        [SerializeField] private bool logJumpSpeedChange = false;

        
        [Header("VFX")]
        public List<VisualEffectStruct> onLandVFX = new List<VisualEffectStruct>();
        public List<VisualEffectStruct> onPivotVFX = new List<VisualEffectStruct>();
        public List<VisualEffectStruct> onSlideVFX = new List<VisualEffectStruct>();
        public List<VisualEffectStruct> onWalkVFX = new List<VisualEffectStruct>();
        public List<VisualEffectStruct> onJumpVFX = new List<VisualEffectStruct>();
        
        
        [Header("State Data")]
        public JumpAndFallingData jumpAndFallingData;
        public SlideActionData slideActionData; 
        public WalkActionData walkActionData; 
        public IdleActionData idleActionData;
        public DirectionalPivotData directionalPivotData;


        [Header("State Checks")]
        [SerializeReference] public GroundCheck groundCheck = new GroundCheck();
        [SerializeReference] public CeilingCheck ceilingCheck = new CeilingCheck();
        [SerializeReference] public SlopeCheck slopeCheck = new SlopeCheck();
        [SerializeReference] public EdgeHoldCheck edgeHoldCheck = new EdgeHoldCheck();
        [SerializeReference] public CoyoteTimeCheck coyoteTimeCheck = new CoyoteTimeCheck();
        
        // Pivot
        [SerializeReference] public PivotCheck pivotCheck = new PivotCheck();
        public ExtendPivotCheck extendPivotCheck = new ExtendPivotCheck();
        
        // Jumping
        public JumpCooldown jumpCooldown = new JumpCooldown();
        public ExtendJumpCheck extendJumpCheck = new ExtendJumpCheck();

        // Sliding
        public SlideCooldown slideCooldown = new SlideCooldown();
        public ExtendSlideCheck extendSlideCheck = new ExtendSlideCheck();
        public LockInputSlideCheck lockInputSlideCheck = new LockInputSlideCheck();


        // Movement States
        public IdleState idleState = new IdleState();
        public WalkState walkState = new WalkState();
        public JumpingState jumpingState = new JumpingState();
        public FallingState fallingState = new FallingState();
        public SlideState slidingState = new SlideState();
        public EdgeHoldState edgeHoldState = new EdgeHoldState(); 
        public DirectionalPivotState directionalPivotState = new DirectionalPivotState(); 

        // Movment Processing States
        public NormalMovementState normalMovementState = new NormalMovementState(); 
        public SlopeAdjustmentState slopeAdjustmentState = new SlopeAdjustmentState();




        [Header("Dynamic")]
        public Vector3 targetPosition;
        public Vector3 previousPosition;
        public Vector3 playerVelocity;
        public float verticalVelocity;
        public float horizontalSpeed;
        public PlayerState currentPlayerState;
        public PlayerState currentMovementProcessingState;
       

        void Awake()
        {
            idleState.ConfigureTransitions(this);
            walkState.ConfigureTransitions(this);
            jumpingState.ConfigureTransitions(this);
            fallingState.ConfigureTransitions(this);
            slidingState.ConfigureTransitions(this);
            edgeHoldState.ConfigureTransitions(this);
            directionalPivotState.ConfigureTransitions(this);
            normalMovementState.ConfigureTransitions(this);
            slopeAdjustmentState.ConfigureTransitions(this);
        }
        

        void Start()
        {
            currentPlayerState = idleState;
            currentMovementProcessingState = normalMovementState;
            
            currentPlayerState.OnEnter(this);
            currentMovementProcessingState.OnEnter(this);
        }

        public void SwitchState(PlayerState state)
        {
            if(logStateTransitions) Debug.Log("Player Movement State:" + currentPlayerState + " -> " + state);
            currentPlayerState = state;
            state.OnEnter(this);
        }

        public void SwitchMovementProcessingState(PlayerState state)
        {
            if(logStateTransitions) Debug.Log("Player Movement Processing State:" + currentMovementProcessingState + " -> " + state);
            currentMovementProcessingState = state;
            state.OnEnter(this);
        } 

        void Update()
        {
            if(playerData == null)
            {
                Debug.LogError("Player Data Management not found!");
            }

            currentPlayerState.OnUpdate(this);
            currentMovementProcessingState.OnUpdate(this);
        }

        void FixedUpdate()
        {
            currentPlayerState.OnFixedUpdate(this);
            currentMovementProcessingState.OnFixedUpdate(this);

            // Consume Input
            playerData.ConsumeInput();
        }

        void OnDrawGizmosSelected()
        {
            groundCheck.OnDrawDebugGizmos(this);
            slopeCheck.OnDrawDebugGizmos(this);
            edgeHoldCheck.OnDrawDebugGizmos(this);
            ceilingCheck.OnDrawDebugGizmos(this);
        }
    }
}
{% endhighlight %}
</div>

<!-- 
To implement a FSM to control my character's movement actions, I created several runtime data classes to hold dynamic data related to each state and a central runtime data class to pass around to be able to access everything. This is part of the "Context" that is described in the aforemention video **[3](#ProgramStateMachine)**. In addition to separating dynamic data into its own classes, I also created an abstract class as a framework for different states and started converting states over to utilize that, which is the "PlayerState" class in the code below. This makes creating new states significantly easier to manage, and significantly simplifies my main script for character movement. 


<div class="padded-code-block">
{% highlight C# %}
namespace PlayerStates
{
    public abstract class PlayerState 
    {
        public bool doExecute;
        public bool onEnterLock;

        public Action onExitCallback;
        public Action onEnterCallback;

        public PlayerState()
        {
            onExitCallback = () => 
            {  
                doExecute = false;
                onEnterLock = false;
            };

            onEnterCallback = () => 
            {  
                onEnterLock = true;
            };
        }


        public virtual void CheckTransitions(PlayerRuntimeData playerDataManagement) {}
        public virtual void Execute(PlayerRuntimeData playerDataManagement) {}
        public virtual void OnEnter(PlayerRuntimeData playerDataManagement)
        {
            Action callback = onEnterCallback;
            callback();
        }

        public virtual void OnExit(PlayerRuntimeData playerDataManagement, Action action)
        {
            Action callback = onExitCallback;
            callback();
        }
    }
}
{% endhighlight %}
</div>

* **OnEnter():** When the player enters a state, the OnEnter function serves as an overridable function that is only called once. This function is important, as there may be some logic that must be run only once on entering a new state, rather than being continuously called in the OnExecute function. 

* **CheckTransitions():** After calling the OnEnter function, the CheckTransitions function for the current state is called. This is an overridable function where the user defines transition conditions to alternative states that are defined in order of priority. Order is important, since each condition is evaluated using a series of if else-if statements, if multiple conditions were to evaluate to true, the condition highest in the list would be returned. We also define here a callback function for when exiting the state that can be used to call some logic once on exit. For example, instantiating a VFX dust cloud on landing on the ground. We only want to call this on transitioning from the falling state to the idle state, rather than calling it whenever we enter the idle state. 


![2025-01-2418-08-03-ezgif optimize](/assets/videos/Unity3DGame/2025-01-2418-08-03-ezgif.com-optimize.gif){: .default-image .clickable-image} 

* **OnExit():** By default the OnExit function resets the lock for the OnEnter function, but can be overrided for something like running some logic independent of what state is transitioned to next. 

* **Execute():** If no transition conditions are met, then the actual logic for the state is run by overriding the Execute function.


Here is an example player state class. The "Coyote Time Start Transition" and "Coyote Time Active Transition" transitions within the CheckTransitions function are probably confusing without more context. It’s just a way of implementing coyote time without requiring another separate state. However, this logic could likely be added to the previously mentioned secondary FSM for calculating player movement, as it falls under a similar scenario to the slope situation.

<div class="padded-code-block">
{% highlight C# %}
namespace PlayerStates
{
    [System.Serializable]
    public class FallingState : PlayerState
    {
        public FallingState() 
        { 
            doExecute = false; 
            onEnterLock = false;
        }

        public override void CheckTransitions(PlayerRuntimeData data)
        {
            /// Summary
            /// State Transitions: Falling State -> Idle || EdgeHold || GroundSlam || CoyoteTime
            /// State Transition Priority: CoyoteTime > EdgeHold > Idle > GroundSlam 
            ///
            /// Transition Conditions:
            ///     
            ///    1.   If the player can start coyote time or is activley in coyote time go back to idle state
            ///    2.   If the player passed the edge hold check, transition to the edge hold state.
            ///    3.   If player is on the ground to transition back to idle state.
            ///    
    
            data.playerData.UnLockInputBuffer();

            // Coyote Time Start Transition -> Go back to Idle state:
            if (data.jumpAndFallingRuntimeData.state_CanStartCoyoteTime == true)
            {
                data.jumpAndFallingRuntimeData.SetState_CoyoteTimeActive(true);
                data.currentState = MovementState.Idle;
                OnExit(data, () => { });
            }

            // Coyote Time Active Transition -> Go back to Idle state:
            else if (data.jumpAndFallingRuntimeData.GetState_CoyoteTimeActive())
            {
                data.jumpAndFallingRuntimeData.TickAndUpdate_CoyoteTime();
                if (data.jumpAndFallingRuntimeData.GetState_CoyoteTimeActive() == false)
                {
                    // Reset timer
                    data.jumpAndFallingRuntimeData.ResetTimer_CoyoteTime();
                }
                else
                {
                    data.currentState = MovementState.Idle;
                    OnExit(data, () => { });
                }
            }

            // EdgeHold Transition:
            else if (data.playerData.edgeHoldCheck.edgeHoldState)
            {
                data.jumpAndFallingRuntimeData.state_CanStartCoyoteTime = true;
      
                data.currentState = MovementState.EdgeHold;
                OnExit(data, () => 
                { 
                    //doExecute = false;
                    data.jumpAndFallingRuntimeData.SetCanJump(true);
                });
            }

            // Idle Transition:
            else if (data.playerData.groundCheck.playerGrounded)
            {
                data.currentState = MovementState.Idle;

                OnExit(data, () => 
                {
                    data.verticalVelocity = 0.0f;
                    data.jumpAndFallingRuntimeData.state_CanStartCoyoteTime = true;
                    data.jumpAndFallingRuntimeData.HandleOnLandEvents( data.generalData.playerRoot.transform);
                    data.playerData.edgeHoldCheck.shouldCheckEdgeHold = false;

                    foreach(VisualEffectStruct vfx in data.playerData.onLandVFX)
                    {
                        VFXEventController.Instance.SpawnSimpleVFXGeneral(vfx, data.generalData.playerRoot.transform, data.generalData.playerRoot.transform);
                    }
                });
            }

            // Ground Slam Transition:
            else if(data.playerData.groundSlam == 1 && data.GroundSlam_resourceRuntimeData.TryUseResource(data.playerData.GSDData.groundSlamResourceCost))
            {
                data.currentState = MovementState.GroundSlam;
                OnExit(data, () => {});
            }

            // Else Falling State
            else
            {
                doExecute = true;
            }
        }

        public override void Execute(PlayerRuntimeData data)
        {
            JumpAndFallingData jumpAndFallData = data.playerData.JAFData;
            
            // Update animator 
            if (data.animatorData._hasAnimator) data.animatorData.animator.SetBool(data.animatorData.GetAnimatorIDFreeFall(), true);
            
            // Handle the falling Logic
            data.verticalVelocity = data.jumpAndFallingRuntimeData.HandleFallingLogic(data.verticalVelocity);

            // Push the rotation to the stack
            data.scheduledRotations.Push(new RotationData(jumpAndFallData.rotationSmoothTime));


            if (jumpAndFallData.updateSpeedWhileInAir)
            {
                Vector3 playerAdjustedHorizontalVelocity = data.generalData.playerRoot.transform.forward * data._speed;
                if (data.playerData.slopeCheck.playerOnSlope)  playerAdjustedHorizontalVelocity = data.playerData.slopeCheck.AdjustVelocityToSlope(playerAdjustedHorizontalVelocity);

                // If the player is not holding horizontal input, don't add additional velocity
                if (data.playerData.inputVector.magnitude >= 0.01f)
                {
                    // If the player is jumping from standstill, accelerate to the movement speed
                    if (playerAdjustedHorizontalVelocity.magnitude <= jumpAndFallData.targetSpeed )
                    {
                        MovementHelpers.UpdateSpeed(ref data._speed, jumpAndFallData.speedUpdateMethod_Accelerate, jumpAndFallData.targetSpeed , jumpAndFallData.speedOffset,  playerAdjustedHorizontalVelocity.magnitude, jumpAndFallData.speedChangeRate_Accelerate);
                    }
                    else
                    {
                        // If the player's movement speed is greater than the target speed, slow down
                        MovementHelpers.UpdateSpeed(ref data._speed, jumpAndFallData.speedUpdateMethod_Decelerate, jumpAndFallData.targetSpeed , jumpAndFallData.speedOffset,  playerAdjustedHorizontalVelocity.magnitude, jumpAndFallData.speedChangeRate_Decelerate);
                    }
                }
            }
            doExecute = false;
        }

        public override void OnEnter(PlayerRuntimeData data)
        {
            
            base.OnEnter(data);
            data.edgeJumpModifier = 0.0f;
            data.baseJumpModifier = 0.0f;
        }

        public override void OnExit(PlayerRuntimeData data, Action action)
        {
            base.OnExit(data, () => {});
            if (data.animatorData._hasAnimator) data.animatorData.animator.SetBool(data.animatorData.GetAnimatorIDFreeFall(), false);
            action();
        }

    }
}
{% endhighlight %}
</div>


The following class defines the main controller for the FSM. I define an enum for the different possible states, declare each of the player states, and then in the update loop use a switch statement for each of the possible states.  The "playerData.playerRuntimeData" is passed to each of the player states which may modify the player's "verticalVelocity" or "_speed". At the end of the loop I calculate the players velocity and distance they should move and apply that to the character controller.

<div class="padded-code-block">
{% highlight C# %}

namespace PlayerStates
{
    public enum MovementState
    {
        Idle,
        Walking,
        Jumping,
        Sliding,
        SlidingOnSlope,
        SlidingOnSlopeGravityAccel,
        Falling, 
        DirectionalPivot,
        EdgeHold,
        GroundSlam,
        GroundSlamDecision,
    }


    public class FSMPlayer : MonoBehaviour
    {
        
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public IdleState idleState = new IdleState();
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public WalkState walkState = new WalkState();
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public JumpingState jumpingState = new JumpingState();
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public FallingState fallingState = new FallingState();
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public SlideState slidingState = new SlideState();
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public GroundSlamState groundSlamState = new GroundSlamState();  
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public GroundSlamDecisionState groundSlamDecisionState = new GroundSlamDecisionState(); 
        [TabGroup("fsm/Inscribed/SubTabGroup", "Player State")] public EdgeHoldState edgeHoldState = new EdgeHoldState(); 

        public PlayerDataManagement playerData;
        public Vector3 targetPosition;
        public Vector3 previousPosition;
        public Vector3 playerVelocity;




        //Debug Options
        [TabGroup("fsm", "Debug", TextColor = "orange")]
        [TabGroup("fsm", "Debug")] [SerializeField] bool logStateTransitions = false; 
        [TabGroup("fsm", "Debug")] [SerializeField] bool logJumpSpeedChange = false;


        // Inscribed General Player Data
        [TabGroup("fsm", "Inscribed", TextColor = "green")]
        [TabGroup("fsm/Inscribed/SubTabGroup", "General", TextColor = "green")] [SerializeField] PlayerWeaponContainer playerWeaponContainer; 

        void Start()
        {
            if(playerData == null)
            {
                Debug.LogError("Player Data Management not found!");
            }
        }


        void UpdateDynamicVars()
        {
            playerData.playerRuntimeData.OnUpdateDynamicVariables();
            playerData.playerRuntimeData.animatorData.OnUpdateDynamicVariables();
        }


        void Update()
        {
            UpdateDynamicVars();

            switch (playerData.playerRuntimeData.currentState)
            {
                case MovementState.Idle:
                    if(!idleState.onEnterLock) idleState.OnEnter(playerData.playerRuntimeData);
                    idleState.CheckTransitions(playerData.playerRuntimeData);
                    if(idleState.doExecute) idleState.Execute(playerData.playerRuntimeData);
                    break;
                case MovementState.Walking:
                    if(!walkState.onEnterLock) walkState.OnEnter(playerData.playerRuntimeData);
                    walkState.CheckTransitions(playerData.playerRuntimeData);
                    if(walkState.doExecute) walkState.Execute(playerData.playerRuntimeData);
                    break;
              
                case MovementState.Falling:
                    if(!fallingState.onEnterLock) fallingState.OnEnter(playerData.playerRuntimeData);
                    fallingState.CheckTransitions(playerData.playerRuntimeData);
                    if(fallingState.doExecute) fallingState.Execute(playerData.playerRuntimeData);
                    break;
                case MovementState.Jumping:
                    if(!jumpingState.onEnterLock) jumpingState.OnEnter(playerData.playerRuntimeData);
                    jumpingState.CheckTransitions(playerData.playerRuntimeData);
                    if(jumpingState.doExecute) jumpingState.Execute(playerData.playerRuntimeData);
                    break;
               
                case MovementState.Sliding:
                    if(!slidingState.onEnterLock) slidingState.OnEnter(playerData.playerRuntimeData);
                    slidingState.CheckTransitions(playerData.playerRuntimeData);
                    if(slidingState.doExecute) slidingState.Execute(playerData.playerRuntimeData);
                    break;
                case MovementState.GroundSlam:
                    if(!groundSlamState.onEnterLock) groundSlamState.OnEnter(playerData.playerRuntimeData);
                    groundSlamState.CheckTransitions(playerData.playerRuntimeData);
                    if(groundSlamState.doExecute) groundSlamState.Execute(playerData.playerRuntimeData);
                    break;
                case MovementState.GroundSlamDecision:
                    if(!groundSlamDecisionState.onEnterLock) groundSlamDecisionState.OnEnter(playerData.playerRuntimeData);
                    groundSlamDecisionState.CheckTransitions(playerData.playerRuntimeData);
                    if(groundSlamDecisionState.doExecute) groundSlamDecisionState.Execute(playerData.playerRuntimeData);
                    break;
                 case MovementState.EdgeHold:
                    if(!edgeHoldState.onEnterLock) edgeHoldState.OnEnter(playerData.playerRuntimeData);
                    edgeHoldState.CheckTransitions(playerData.playerRuntimeData);
                    if(edgeHoldState.doExecute) edgeHoldState.Execute(playerData.playerRuntimeData);
                    break;
            }
            

            if (!playerData.playerRuntimeData.rotationLock) playerData.playerRuntimeData.ApplyRotations();

            Vector3 verticalVelocity = new Vector3(0.0f, playerData.playerRuntimeData.verticalVelocity, 0.0f);
            Debug.DrawRay(playerData.playerRuntimeData.generalData.playerRoot.transform.position, verticalVelocity, Color.magenta);

            playerVelocity = playerData.playerRuntimeData.generalData.playerRoot.transform.forward * playerData.playerRuntimeData._speed;
            
            if (playerData.slopeCheck.playerOnSlope)
            {
                playerVelocity = playerData.slopeCheck.AdjustVelocityToSlope(playerVelocity);
            }
            

            if(playerData.slopeCheck.slopeAngle > playerData.slopeCheck.max_SlopeAngle)
            {
                playerVelocity += playerData.slopeCheck.AdjustVelocityToSlopeVertical(verticalVelocity);
            }
            else
            {
                playerVelocity += verticalVelocity;
            }
            

            Debug.DrawRay(playerData.playerRuntimeData.generalData.playerRoot.transform.position, playerVelocity, Color.cyan);

            // Calculate the distance the player should move in this frame
            Vector3 moveDistance = playerVelocity * Time.deltaTime;

            playerData.playerRuntimeData.generalData.characterController.Move(moveDistance);
        }
    }
}
{% endhighlight %}
</div>
-->

<!-- 
<div class="reusable-divider">
    <span class="small-header-text" id="nextsteps">Next Steps</span>
    <hr>
</div>

It is important to note that I do need to go back and refactor my code that I show above. I currently manage switching states using an enum to that corresponds to each state, and pass the context without including the reference to the different player states. This is not the best way to manage the system, as it requires managing a lock for the OnEnter function for each state, since I cannot directly reference the OnEnter function of the next state during a state transition. Here is what implementing those changes would look like:


<div class="padded-code-block">
{% highlight C# %}

    // REQUIRED MODIFICATIONS

    // Instead of passing a reference to my "PlayerRuntimeData", 
    // I would pass a reference to "FSMPlayer", which contains a reference to "PlayerRuntimeData"
    
    // For example, the PlayerState class function
    public virtual void CheckTransitions(PlayerRuntimeData playerDataManagement) {}

    // Would instead become 
    public virtual void CheckTransitions(FSMPlayer context) {}

    // ------------------------------------------------------------------------------- //

    // Instead of calling the following for updating the state:
    data.currentState = MovementState.Idle;
    OnExit(data, () => { });

    // I would call
    context.SwitchState(context.idleState);
    OnExit(data, () => { });

    // ------------------------------------------------------------------------------- //

    // Where the FSMPlayer script would have the function 
    public void SwitchState(PlayerState newState)
    {
        currentState = newState;
        newState.OnEnter(this);
    }

{% endhighlight %}
</div>
-->



<div class="reusable-divider">
    <span class="small-header-text" id="links">LINKS</span>
    <hr>
</div>
1. [Finite State Machines: An Introduction to FSMs and their Role in Computer Science](https://softwaredominos.com/home/software-engineering-and-computer-science/finite-state-machines-an-introduction-to-fsms-and-their-role-in-computer-science/){: #FSMIntroduction}
2. [What Is The Difference Between DFA And NFA?](https://unstop.com/blog/difference-between-dfa-and-nfa){: #DifferenceDFANFA}
3. [How to Program in Unity: State Machines Explained](https://www.youtube.com/watch?v=Vt8aZDPzRjI){: #ProgramStateMachine}



[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
