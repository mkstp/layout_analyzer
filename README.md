# Ergonomic Physical Model-based Keyboard Layout Analyzer
It's en exciting time to be a keyboard layout enthusiast, because the technologies to reconfigure and test new layout ideas are fast, easy, and accessible. New alternative layouts to Qwerty are made in good fun, and it's interesting (at least for me) to study new rationales for letter placements. As en enthusiast myself, this project represents the culmination of many years spent playing with layouts and keyboards.

My goal was to create a layout that’s both easy to learn and efficient to type on — two qualities often seen as tradeoffs. Many optimized layouts significantly deviate from QWERTY, requiring years to master. Lacking the patience for that, I approached the problem differently.

This tool models finger kinematics and uses a job shop scheduling algorithm to simulate typing on an ortholinear keyboard. By keeping the model’s typing speed constant, I can objectively assess the efficiency of different layouts and iterate quickly.

## Background

To type, your fingers must move to a key and press it. An ergonomic model quantifies the difficulty of these actions, inspired by the Colemak Mod-DH methodology, which uses finger strength, resting position, and angle of approach to assign penalty scores for key positions.

![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/iso_angle_approach.png)

Colemak Mod-DH's key insight is the "angle-of-approach" argument: with a standard keyboard centered at your midline, your hands approach the home row at a radial angle, not vertically. This makes keys like ‘C’ and ‘M’ easier to reach for the index fingers, which naturally curl inward. The model adjusts resting points based on this angle and calculates penalties for movement, with lateral motions penalized more than vertical ones.

![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/aoa.png)

However, this model doesn’t fully account for kinematic finger motion types — abduction/adduction (ABD) and flexion/extension (FLEX). Since fingers flex/extend faster than they spread, by extension of Mod-DH's angle-of-approach argument, I propose calculating movement penalties relative to each finger's angle of approach, not the keyboard's orientation. Keys requiring more movement in slower, less flexible muscle groups will naturally take longer to press.

![alt text](https://github.com/mkstp/layout_analyzer/blob/main/Images/finger_movements.png)