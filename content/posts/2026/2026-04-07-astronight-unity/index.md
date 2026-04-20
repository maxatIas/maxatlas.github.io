---
title: "AstroNight - Unity Development"
date: 2026-04-07
series: ["astronight"]
episode: 2
tags: ["game", "c#", "unity"]
---

Following up on [my previous AstroNight post]({{< ref "posts/2026/2026-04-06-astronight-gameplay" >}}), here's a behind-the-scenes look at Unity!

{{< video src="astronight-unity.mp4" >}}

This video shows the obstacle spawning and management system. Here's how it works:

On each spawn, my `GameManager` randomly selects one of three sizes, along with a sprite associated with the obstacle.

Once created, the obstacle automatically registers itself in a list managed by the `GravityManager`.

On each `FixedUpdate`, the `GravityManager` computes and applies the gravitational pull of each obstacle on all other physics objects in the scene.

Finally, when an obstacle moves out of the camera's view, it destroys itself automatically to keep performance in check.

I know this approach has room for improvement — and that's exactly what keeps me motivated to push further! If you have any advice on code architecture, physics handling, or Unity best practices, I'm all ears!