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

### Theory of Motion Penalty Scores

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/aoa.png) |
|:---------------------------:|
| *Figure 3: individual angles of approach* |

This is what I'm using to calculate the individual angles of approach for all my fingers (based on a birds-eye image taken of my outstretched fingers over a grid-style keyboard). Resting coordinates for my fingers are the red dots, the black lines are the angles of approach, the black dots are the key center coordinates on an ortholinear keyboard.

| ![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/abstract_angle_of_approach.png) |
|:---------------------------:|
| *Figure 4: differing movement ratios on the aoa* |

The black dots represent key centers on a simplified keyboard, while the red dot marks the index finger's adjusted resting position based on Colemak Mod-DH. The black line shows the index finger's angle of approach, the red line indicates abduction/adduction movement, and the blue line represents flexion/extension. Comparing line lengths from the resting point under 'J' highlights the differing ratios of these movements.

To derive a penalty score for abduction/adduction (ABD) and flexion/extension (FLEX) based on each finger's angle of approach (AOA), we calculate the distance to a key from the AOA. Movement parallel to the AOA measures FLEX, while movement perpendicular to it measures ABD.

Instead of arbitrarily scaling lateral movement by a difficulty factor (as in Colemak Mod-DH), a more precise approach uses angular velocity data from Baker et al.’s study on finger kinematics. This provides measurable difficulty factors for scoring these motions:

| Finger          | Mean PIP FLEX angular velocity V<sub>flex</sub> (deg/sec) | Mean PIP FLEX angular acceleration A<sub>flex</sub> (deg/sec²) | Mean MCP ABD angular velocity V<sub>abd</sub> (deg/sec) | Mean MCP ABD angular acceleration A<sub>abd</sub> (deg/sec²) |
|------------------|-----------------------------------------|-----------------------------------------------|----------------------------------------|-----------------------------------------------|
| Pinky           | [34, 31]                                | [370, 300]                                    | [20, 19]                               | [620, 580]                                    |
| Ring            | [32, 38]                                | [210, 270]                                    | [12, 14]                               | [590, 640]                                    |
| Middle          | [35, 36]                                | [250, 250]                                    | [14, 18]                               | [590, 590]                                    |
| Index           | [33, 34]                                | [350, 400]                                    | [21, 25]                               | [570, 600]                                    |
| Thumb           | [19, 32]                                | [300, 610]                                    | [20, 36]                               | [210, 610]                                    |

Your fingers travel at different speeds when they flex or extend vs when they abduct or adduct. I'm predicting this will have an effect on typing speed for bigrams that are either placed in parallel or perpendicular to each finger's AOA. To find the amount of angular displacement as each finger moves from an initial to a target position along the FLEX and ABD axes we can use the law of cosines. For simplicity, I'm going to use a radius of 50mm on both the FLEX and ABD axes for all fingers which is roughly the measurement of both my middle + distal and my proximal phalanx (finger segments).

![Equation](https://latex.codecogs.com/png.latex?\theta_{abd}=\cos^{-1}\left(\frac{5000-D_{abd}^2}{10000}\right))
