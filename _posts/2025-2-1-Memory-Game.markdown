---
layout: custom-post
title: Garden<br>Recall
date: 2025-01-28 00:00:00 -0700
originallycompleteddate: 2023-02-05 00:00:00 -0700
permalink: /posts/Garden-Recall/
image: /assets/Images/GardenRecall/GardenRecall_01.png
description: >
  A Unity-based memory game developed as part of a research project.
  This project served as a case study for evaluating the effectiveness of AI in software development.
categories: jekyll update main
tags: [Unity]
priority: 3
---




![2024-12-1210-12-06-ezgif com-optimize](/assets/videos/GardenRecall/2024-12-1210-12-06-ezgif.com-cut.gif){: .post-header-image-with-description .clickable-image} 
<div class="custom-image-description">
The GIF showcases a single round of the game Garden Recall, where the player briefly observes object placements before they are hidden, then taps the correct locations to reveal them.
</div>

* [Overview](#overview)
* [Game Development Process](#game-development-process)
* [AI Research Process](#ai-research-findings)
* [Project Showcase](#project-showcase)

<div class="reusable-divider">
    <span class="small-header-text" id="overview">Overview</span>
    <hr>
</div>

As part of the _Current Trends in Computer Science_ course at Grand Canyon University, I developed a Unity-based mobile memory app. The course aims to provide students with a comprehensive understanding of current trends and practices in computer science through practical experiences. It incorporates Scrum practices to guide a term project assisted by AI, which serves as a basis for analyzing the effectiveness of AI in software development with the goal of producing a publishable paper. 


<div class="reusable-divider">
    <span class="small-header-text" id="game-development-process">Game Development Process</span>
    <hr>
</div>

I developed _Garden Recall_, a visual memory game that challenges the user to recall object locations. The user is briefly shown a set of objects before they are hidden. To progress, they must tap where the objects were previously located. As the game advances, the number of objects to remember increases, gradually raising the difficulty.  


**Game Instructions:**
* **Memorize the Positions:** A set of outlined objects will appear on the screen. You have limited time before the objects disappear. Focus and memorize their locations before the timer hits zero!
* **Find the Hidden Objects:** Once the objects vanish, click on the spots where you remember them being. Be precise!
* **Lives:** You have 3 lives per round. If you miss an object’s location, you lose a life. Don’t worry, you can try again!
* **Progression:** Each round adds an extra object to challenge your memory. Keep going to see how many rounds you can complete!

**Development Process:**

The class followed an agile methodology, working in two-week sprints to implement core game mechanics while working with AI assistants. Each sprint ended with a stand-up meeting and a retrospective to assess progress and plan improvements.

We didn't create a full game design document for this project. Instead, the game's development started with developing and refining a concept for the game to meet the project requirements using a user persona and then developing a UI Flow diagram. Game development concluded with a playtest, and combining individual projects into a single game app.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://embed.figma.com/board/AxyiHiWrTQ8Due62nq1AGO/Garden-Recall-UI?node-id=0-1&embed-host=share" allowfullscreen></iframe>

**PROJECT TIMELINE:**

<iframe src="/assets/PDFs/Project Timeline.pdf" width="100%" height="600px"></iframe>
[Alternative Link to View the Project Timeline](/assets/PDFs/Project Timeline.pdf/)

<div class="reusable-divider">
    <span class="small-header-text" id="ai-research-findings">AI Research Findings</span>
    <hr>
</div>

**DATA COLLECTION METHODS:**

Throughout the project, students had the option to use AI assistance, but were required to do so at least four times per sprint. To evaluate overall and indiviual AI performance, the same query was asked to both AI assistants; while both AIs received the same initial question, follow-up interactions varied, leading to differing response lengths.

To ensure consistency in evaluating AI performance, the class collaboratively developed a Likert scale assessing AI response quality, ranging from 1 (the response was completely unusable) to 5 (exceeded expectations). In addition to rating responses, students documented the date, initial prompt, and notable response characteristics. This data was later analyzed to compare AI effectiveness in software development tasks.

**DATA ANALYSIS PROCEDURES:**

After the project concluded, AI interactions were analyzed based on multiple qualitative factors, which were then sorted and analyzed quantitatively. These factors included code quality, explanation clarity, complexity, time saved, and usage type. AI usage trends were also examined over time, with data collected over eight sprints (spanning three months) divided into two halves: the first half (Sprint 1-4) and the later half (Sprint 5-8) of project development. 

**RESULTS AND DISCUSSION:**

<iframe src="/assets/PDFs/AI Analysis.pdf" width="100%" height="600px"></iframe>
[Alternative Link to View the Results PDF](/assets/PDFs/AI Analysis.pdf)

After completing individual analyses, our findings were combined to evaluate the overall effectiveness of AI in software development. Key insights from the group analysis included:

* Non-IDE AI assistants performed better than IDE-integrated tools across most tasks.
* Paid and free AI models performed similarly, with minimal differences in effectiveness.
* AI was most useful for debugging and code completion but struggled with more complex, creative tasks.
* This research highlighted both the strengths and limitations of AI in real-world software development, reinforcing the need for human oversight and problem-solving.

<div class="reusable-divider">
    <span class="small-header-text" id="project-showcase">Project Showcase</span>
    <hr>
</div>

**Gameplay Demonstration**

<div class="video-container">
    <iframe width="560" height="315" src="https://www.youtube.com/embed/7vN4SvLiPkw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>
