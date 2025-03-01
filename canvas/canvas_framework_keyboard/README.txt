# 🃏 Poker Card Generator 🎮

A graphical poker hand evaluator written in Assembly language. This program generates random poker hands and automatically determines the best possible poker combination.

## 📋 Overview

This project demonstrates low-level programming concepts using x86 Assembly to create a visual poker application. The program:

1. Randomly generates 5 unique playing cards
2. Displays them graphically in a window
3. Automatically determines and displays the best poker hand combination

## 🎯 Features

- **Card Generation**: Uses randomization to produce unique poker hands
- **Graphical Interface**: Renders detailed card images with proper suits and values
- **Hand Evaluation**: Detects all standard poker combinations:
  - Royal Flush
  - Straight Flush
  - Four of a Kind
  - Full House
  - Flush
  - Straight
  - Three of a Kind
  - Two Pair
  - Pair
  - High Card

## 🔧 Technical Implementation

This assembly program uses:

- **Canvas Library**: For window and graphical drawing operations
- **MSVCRT Library**: For memory allocation and standard operations
- **Custom Macros**: For streamlined drawing and evaluation procedures
- **Embedded Image Data**: Card images stored as embedded pixel data

## 🖼️ Visual Components

- Each card is rendered with appropriate suit symbols:
  - ♥️ Hearts (inima rosie)
  - ♠️ Spades (inima neagra)  
  - ♣️ Clubs (trefla)
  - ♦️ Diamonds (romb)

## 🧮 Algorithm Details

The program follows these steps:
1. Generate random cards (ensuring uniqueness)
2. Display cards graphically in the window
3. Identify card attributes (suit and rank)
4. Evaluate for all possible combinations, prioritizing from highest to lowest rank
5. Display the resulting combination name

## 💻 Running the Program

The program requires:
- x86 Assembly environment
- MASM/TASM compatible assembler
- The referenced libraries (canvas.lib and msvcrt.lib)
- All included image files in the project directory

## 🔍 Educational Value

This project demonstrates:
- Low-level bit manipulation
- Random number generation
- Memory management
- Algorithm implementation in Assembly
- Graphical programming fundamentals

## 📝 Code Structure

- **Data Section**: Contains card image data, variables and structures
- **Procedures**: Functions for rendering and evaluating poker hands
- **Macros**: Helper code for repetitive operations
- **Main Logic**: Card generation and game initialization

---

*This project was created as a demonstration of Assembly programming techniques for graphical applications and game logic.*
