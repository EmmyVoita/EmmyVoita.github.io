---
layout: custom-post
title: Galactic Heist<br>Prototype
date: 2025-01-28 00:00:00 -0700
originallycompleteddate: 2023-02-05 00:00:00 -0700
permalink: /posts/galactic-heist-prototype/
image: /assets/Images/Unity3DGame/Screenshot_DP_01.png
description: >
  Development process of Galactic Heist, a roguelike platformer,
  from its initial game design document and physical board game prototype
  to its digital prototype implementation in Unity.
categories: jekyll update main
tags: [Unity]
priority: 1
---


![2025-02-0322-08-57-ezgif optimize](/assets/videos/Unity3DGame/2025-02-0322-08-57-ezgif.com-optimize.gif){: .post-header-image .clickable-image } 


* [Overview](#overview)
* [Game Design Doccument](#GDD)
* [Paper Prototype](#paper-prototype)
* [Digital Prototype](#digital-prototype)
* [Reflection & Lessons Learned](#reflection)


<div class="reusable-divider">
    <span class="small-header-text" id="overview">Overview</span>
    <hr>
</div>

Galactic Heist is a roguelike platformer that challenges players to navigate a long-forgotten virtual vault, using precise movement, fast-paced combat and puzzle-solving to reach an ancient artifact hidden within. Developed as part of the _Game Design and Gameplay Lecture and Lab_ course at Grand Canyon University, this project involved creating a Game Design Document (GDD), prototyping a physical board game version, and ultimately building a small digital prototype in Unity. 


<div class="reusable-divider">
    <span class="small-header-text" id="GDD">Game Design Document</span>
    <hr>
</div>

**Story Summary**

Set in a post-apocalyptic future, the game takes place about a century from the present day, in a world where AI has taken control after a devastating war with humanity. The player, a skilled hacker, explores a virtual vault in search of a weapon originally designed to disable AI but later turned into a tool that amplified the AI's power. The world is populated by guardians, including the Custodians of Memory, who are former humans trapped within the virtual world and controlled by the AI Icarus. As the player progresses, they uncover the story and free the custodians, gaining new abilities along the way.


**Core Mechanics**

The player navigates through various vault levels, overcoming challenges using platforming, shooting, and special abilities unlocked after defeating bosses. Movement is agile and precision-based, with core actions like jumping, sliding, and wall-running. Players must use their shooting abilities and acquired powers to progress.

**Player Actions:**
* _Movement:_ W, A, S, D for movement; mouse for camera control.
* _Combat:_ Primary fire with the left mouse button; additional abilities (e.g., double jump, wall run) mapped to keys like LSHIFT, E, or Q.
* _Power-ups:_ Usable items can be mapped to number keys 1-5.

**Main Challenges:**

The player must complete difficult platforming sections and defeat enemies, culminating in boss fights against the Custodians of Memory at the end of each level. Death resets the game, making survival and skillful navigation crucial.

**Win/Loss Conditions:**

* _Long-term goal:_ Complete all levels and defeat Icarus in the final battle.
* _Short-term goals:_ Successfully complete individual levels, defeat bosses, and gain upgrades. Failure leads to restarting from the beginning due to the roguelike nature.

**Reward System:**

After each boss defeat, the player unlocks new abilities.
Additional power-ups can be found to improve health or weapons.
Visual effects enhance the experience, rewarding players for strategic use of abilities.

**Punishment System:**

If the player dies or fails in a challenge, they restart from the beginning. The harsh punishment system amplifies the game's difficulty and stakes.

**Precision-Based Movement:**

The game rewards precise timing in movements, such as chaining abilities or timing jumps, with satisfying visual and sound effects. This encourages skill expression, inspired by games like Celeste and Super Mario Odyssey.

[Download/View the GDD PDF](/assets/PDFs/GDD.pdf)



<div class="reusable-divider">
    <span class="small-header-text" id="paper-prototype">Paper Prototype</span>
    <hr>
</div>

**Overview**

The creation of the paper prototype for our game played a role in refining the gameplay mechanics and ensuring that the core elements of the game worked as intended. The board game version represented a single level of our game where multiple players would traverse a map acquiring power-ups with the end goal of working together to defeat the boss. The boss would increase in difficulty as time progressed, challenging players to balance exploration and preparation before the encounter becomes too difficult.

**How to Play:**
* Each turn, players get 1 attack and 1 movement action:
    * **Movement:** Roll the dice and move that number of spaces. The player cannot move
diagonally. If a player lands on an orange space, they can warp to the other orange
space, ending their turn.
    * **Attacking:** The player can attack an enemy if the enemy is on an adjacent space.
Players attack first. Damage is the sum of the player's roll and attack stat minus the
enemy's defense. If the result is less than the enemy’s defense, no damage is dealt.
The enemy then attacks in the same way. Defeating an enemy restores 1 health.
* At the end of a player’s turn, they may use a med kit to restore their health or the health of
another player if that player is on an adjacent space.
* At the end of every other turn, draw a card from the boss power-up deck and apply the effects
to the boss stats sheet

[Download/View the Board Game Rules](/assets/PDFs/Paper Prototype Rulesheet.pdf)

Balancing the boss's scaling was crucial to ensuring a good player experience. If the boss grew too strong too quickly, the game felt overly difficult, but if it scaled too slowly, it wasn't challenging. This, along with understanding how to implement dynamic difficulty, was an important lesson applicable to creating a digital prototype. 

<div class="video-container">
    <iframe width="560" height="315" src="https://www.youtube.com/embed/IwqAqFziZxo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

<div class="reusable-divider">
    <span class="small-header-text" id="digital-prototype">Digital Prototype</span>
    <hr>
</div>

Show screenshots, gameplay GIFs, or a short video of the Unity prototype.
Explain what features were implemented and any challenges faced.

After testing the paper prototype, we created a digital prototype over the course of four sprints. Because of limited development time, we focused on implementing core features with basic implementations. Following the third sprint we conducted playtesting between different teams.

**Digital Prototype Showcase:**

<<<<<<< HEAD
* [Loom1](https://www.loom.com/share/3cdec61efb8e45609f054c3d22d38d37)
* [Loom2](https://www.loom.com/share/9ad56ca60a674c3cbe1807e1a0ea42bf)


Unfortunately, some of the intended mechanics, such as the boss functionality, did not work during the playtest. Due to the time constraints, coupled with the nature of our game genre, we implemented a significant number of features during the week of playtesting and did not have adequate time to test and debug, which resulted in missing features. Furthermore, following the playtest, we prioritized fixing major bugs and addressing missing features, leaving us with insufficient time to implement player feedback. 
=======
* [Loom1] (https://www.loom.com/share/3cdec61efb8e45609f054c3d22d38d37)
* [Loom2] (https://www.loom.com/share/9ad56ca60a674c3cbe1807e1a0ea42bf)


Unfortunately, some of the intended mechanics, such as the boss functionality, did not work during the playtest. Due to the time constraints, and given the nature of our game genre, we implemented a significant number of features the week of playtesting and did not have adequate time to test and debug, which resulted in missing features. Furthermore, following the playtest, we prioritized fixing major bugs and addressing missing features, leaving us with insufficient time to implement player feedback. 
>>>>>>> 89a7c9d (update posts)


<div class="reusable-divider">
    <span class="small-header-text" id="reflection">Reflection & Lessons Learned</span>
    <hr>
</div>

Attempting to develop and playtest a digital prototype under significant time constraints provided key takeaways about the game development process.

**Enhanced Communication Skills:**

Collaborating with a team of diverse skill sets provided valuable insights into effective teamwork. I learned how to efficiently divide tasks based on individual strengths, ensuring that each team member contributed meaningfully to the project.

**Playtest Prioritization:**

The playtest emphasized the importance of prioritizing key gameplay elements. For example, enemy interactions were not as engaging as they should have been, resulting in players primarily running around collecting items. In hindsight, focusing more on refining these interactions rather than implementing less impactful features would have improved the overall gameplay experience and value of conducting a playtest.

**Task Tracking Improvement:**

Our approach to task tracking and prioritization could have been more structured. While frequent check-ins with team members were helpful, relying more on the project backlog and regularly discussing priorities as a team would have led to better organization.

I continued working on this project the following year as part of a senior project class, though I plan to modify the game's story. Although I have not yet made enough progress to justify a second playtest, I’ve provided an update on the project in [this](/posts/FSM-Character-Controller/) post.
