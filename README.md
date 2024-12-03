# Ergonomic Physical Model-based Keyboard Layout Analyzer
It's en exciting time to be a keyboard layout enthusiast, because the technologies to reconfigure and test new layout ideas are fast, easy, and accessible. New alternative layouts to Qwerty are made in good fun, and it's interesting (at least for me) to study new rationales for letter placements. As en enthusiast myself, this project represents the culmination of many years spent playing with layouts and keyboards.

My goal was to create a layout that’s both easy to learn and efficient to type on — two qualities often seen as tradeoffs. Many optimized layouts significantly deviate from QWERTY, requiring years to master. Lacking the patience for that, I approached the problem differently.

This tool models finger kinematics and uses a job shop scheduling algorithm to simulate typing on an ortholinear keyboard. By keeping the model’s typing speed constant, I can objectively assess the efficiency of different layouts and iterate quickly.

## Background

To type, your fingers must move to a key and press it. An ergonomic model quantifies the difficulty of these actions, inspired by the Colemak Mod-DH methodology, which uses finger strength, resting position, and angle of approach to assign penalty scores for key positions.

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/iso_angle_approach.png) |
|:---------------------------:|
| *Figure 1: From the colemak mod-dh website* |

Colemak Mod-DH's key insight is the "angle-of-approach" argument: with a standard keyboard centered at your midline, your hands approach the home row at a radial angle, not vertically. This makes keys like ‘C’ and ‘M’ easier to reach for the index fingers, which naturally curl inward. The model adjusts resting points based on this angle and calculates penalties for movement, with lateral motions penalized more than vertical ones.

However, this model doesn’t fully account for kinematic finger motion types — abduction/adduction (ABD) and flexion/extension (FLEX). Since fingers flex/extend faster than they spread, by extension of Mod-DH's angle-of-approach argument, I propose calculating movement penalties relative to each finger's angle of approach, not the keyboard's orientation. Keys requiring more movement in slower, less flexible muscle groups will naturally take longer to press.

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/finger_movements.png) |
|:---------------------------:|
| *Figure 2: This graphic is taken from Baker's 2006 replication study on finger and hand movement angles while typing on QWERTY* |

## Mathematical Model for Kinematic Finger Motion

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/aoa.png) |
|:---------------------------:|
| *Figure 3: individual angles of approach* |

This is what I'm using to calculate the individual angles of approach for all my fingers (based on a birds-eye image taken of my outstretched fingers over a grid-style keyboard). Resting coordinates for my fingers are the red dots, the black lines are the angles of approach, the black dots are the key center coordinates on an ortholinear keyboard.

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/abstract_angle_of_approach.png) |
|:---------------------------:|
| *Figure 4: differing movement ratios on the aoa* |

The black dots represent key centers on a simplified keyboard, while the red dot marks the index finger's adjusted resting position based on Colemak Mod-DH. The black line shows the index finger's angle of approach, the red line indicates abduction/adduction movement, and the blue line represents flexion/extension. Comparing line lengths from the resting point under 'J' highlights the differing ratios of these movements.

To derive a penalty score for abduction/adduction (ABD) and flexion/extension (FLEX) based on each finger's angle of approach (AOA), I calculate the distance to a key from the AOA. Movement parallel to the AOA measures FLEX, while movement perpendicular to it measures ABD.

Instead of arbitrarily scaling lateral movement by a difficulty factor (as in Colemak Mod-DH), a more precise approach uses angular velocity data from Baker et al.’s study on finger kinematics. This provides measurable difficulty factors for scoring these motions:

| Finger          | Mean PIP FLEX angular velocity V<sub>flex</sub> (deg/sec) | Mean PIP FLEX angular acceleration A<sub>flex</sub> (deg/sec²) | Mean MCP ABD angular velocity V<sub>abd</sub> (deg/sec) | Mean MCP ABD angular acceleration A<sub>abd</sub> (deg/sec²) |
|------------------|-----------------------------------------|-----------------------------------------------|----------------------------------------|-----------------------------------------------|
| Pinky           | [34, 31]                                | [370, 300]                                    | [20, 19]                               | [620, 580]                                    |
| Ring            | [32, 38]                                | [210, 270]                                    | [12, 14]                               | [590, 640]                                    |
| Middle          | [35, 36]                                | [250, 250]                                    | [14, 18]                               | [590, 590]                                    |
| Index           | [33, 34]                                | [350, 400]                                    | [21, 25]                               | [570, 600]                                    |
| Thumb           | [19, 32]                                | [300, 610]                                    | [20, 36]                               | [210, 610]                                    |

Your fingers travel at different speeds when they flex or extend vs when they abduct or adduct. I'm predicting this will have an effect on typing speed for bigrams that are either placed in parallel or perpendicular to each finger's AOA. To find the amount of angular displacement as each finger moves from an initial to a target position along the FLEX and ABD axes I can use the law of cosines. For simplicity, I'm going to use a radius of 50mm on both the FLEX and ABD axes for all fingers which is roughly the measurement of both my middle + distal and my proximal phalanx (finger segments):

![Equation](https://latex.codecogs.com/png.latex?\theta_{abd}=\cos^{-1}\left(\frac{5000-D_{abd}^2}{10000}\right))

Where 'D' is the calculated abduction distance from initial to target. Then I use a quadratic equation derived from the displacement formula to determine time based on the accelleration, velocity, and angular displacement:

![Equation](https://latex.codecogs.com/png.latex?t_{abd}=\frac{-V_{abd}+\sqrt{V_{abd}^2+2A_{abd}\theta_{abd}}}{A_{abd}})

This behaviour is encapsulated in the move_time function of the script.

## Typing Algorithm

Typing is a coordinated process involving finger preparation, movement times, idle times, and keypress durations. For example, when typing configuration on a staggered QWERTY keyboard, the left middle finger moves to the ‘c’ while the right ring finger prepares to press the ‘o.’ However, the right finger must wait (idle time) for the left to complete its press before it can proceed.

Finger preparation, where a finger moves to its next position while others are still active, highlights the overlapping nature of these actions. Key distances and layout design significantly influence the balance between movement time and idle time, ultimately affecting typing efficiency. The figure below serves as a starting point for analyzing these dynamics.

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/configuration.png) |
|:---------------------------:|
| *Figure 5: 'configuration on a staggered qwerty keyboard'* |

Algorithmically speaking, I formulated the task of typing as a job-shop scheduling problem with n machines (fingers) that must complete an ordered set of jobs (keypresses) with calculated processing times (movement of fingers) with the added flexibility that processes can happen simultaneously.

From this basic definition, I have to control for our other variables. In our example I modeled simultaneous movement of the fingers as finger preparation time.

Fingers don't normally travel along the most efficient route between keys. There is also the fact that fingers are tethered together via your hands, which means that movement in one finger will affect the position of your neighbouring fingers.

Because of the complexity in modelling the effect of one finger's movement on the others, I've chosen not to model any of this extra movement. Instead, the algorithm assumes that fingers will take the shortest path between two keys and will move completely independently of other fingers. For those reasons, it's the model types faster then the wpms observed in these studies. 

Other variables that slow down real world typing compared to my model include error rates and word initiation effects, which are not modeled here. 

## Testing the Script

Based on the kinemtic values in my research, I'm predicting that if I put my model through the similar testing regimen as these studies, it should type on a staggered QWERTY layout at average wpm speeds above the mid fifties. This would also be considered faster than what would be observed since I don't fully account for all types of finger movements or slowdown effects in the algorithm.

For my test, I sampled 30 different 1K character sets among the top 100 most downloaded books of the Guttenberg project (this is also one of the text bases used in the Colemak Mod DH analysis). The results have an average of 80 wpm which is admittedly quite a bit faster than what was observed in the studies. I assume that my analysis misses some important context of measuring typing speed in the real world; it's a start toward potentially a more accurate model in the future.

While recognizing there is a significant amount of movement time which is unaccounted for in the model, I think my results are still within an acceptable range for typing speed and so I feel comfortable in saying the model captures and reproduces enough of the physical experience of typing that it can be useful to make predictions about real life scenarios.

## Comparing QWERTY to COLEMAK-DH using my Algorithm

The Qwerty speed is used as a baseline to validate the model. By holding finger velocities and other parameters constant, I can isolate the impact of layout changes on typing speed. Faster layouts achieve this by minimizing movement time and maximizing overlap between finger movements (preparation).

This modeling approach eliminates the confounding variable of unfamiliarity with layouts. Simulating a typist with consistent finger speed shows that differences in WPM reflect the efficiency of the layout design, objectively demonstrating that some layouts are faster and require less movement without relying on arbitrary penalty scores.

| Layout         | Simulated WPM Average |
|----------------|-----------------------|
| Qwerty         | 80                    |
| Colemak-ModDH  | 89                    |

Colemak is a more efficient design by a significant margin, and this analysis provides a little more mathematical rigour to that assertion.

## Can I do Better? (the answer is yes obviously)

Remember that my goal was to create a new layout that was more efficient to type but easy to learn. Colemak is certainly more efficient to type, but all potential speed gains are nullified because it takes years to rebuild your muscle memory and reach speed where you surpass Qwerty. And so I had to find a way to preserve the same Qwerty layout and make overall finger movement more efficient at the same time. 

Imagine if you could expand the possible pathways to type, that you had more choices of keys to press instead of the usual 26 letters. The more unfortunate assumption that layout designers make when designing is that one letter can only map to one key on the keyboard. What would happen if one letter appeared in two different places on the keyboard, or if two places on the keyboard mapped to one letter, or a series of letters! It seems inefficient to design this way, but it actually follows a well established efficiency principle of redundancy in engineering. 

## Redundancy

Adding an extra 'e' to the keyboard increases the possible ways of typing 'under', which is a relatively common 5-gram word, without compromising the existing layout. That is to say, you can choose to type the word differently, (and any other word which uses the 'de', 'ed', 'ec', 'ce' bigrams for that matter), without requiring a full reprogramming of your muscle memory for all words using 'e'. For layout designers, I suggest experimenting with duplicate keys of common letters in strategic locations on top of Qwerty layouts for this reason.

## Combinations

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/keys.jpg) |
|:---------------------------:|
| *Figure 6: 'a picture of my personal keyboard'* |

The reason I choose to use an ortholinear keyboard with the keys as close together as possible is because this arrangement gives me 44 or so extra positions to press with my fingers. That is to say, when I type I'm often pressing two keys side by side with the same finger, which produces the most common combination n-grams like 'the' or 'and' or 'ver'. This speeds up my typing significantly without changing the underlying Qwerty layout, my fingers don't move as much since the 'in-between' keys are closer together than the centers of the individual keys themsevles. 

With duplicate keys and combination keys, the layout analyzer types on my Qwerty keyboard at over 100wpm. 



