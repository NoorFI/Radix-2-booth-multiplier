# **SYSTEMVERILOG FOR DIGITAL DESIGN**
## *MEDS Training Programme*
### **Module 4 Assesment**
### *8-bit Signed Radix-2 Booth Multiplier*

**Project Description:**</br>
Multiplication is one of the most fundamental arithmetic operations in digital systems and is extensively used in processors, digital signal processing (DSP), communication systems, image processing, and embedded applications. Conventional binary multiplication methods require a large number of partial products, increasing hardware complexity, delay, and power consumption.

To improve efficiency, optimized multiplication algorithms such as Booth multiplication are commonly used. The Radix-2 Booth algorithm reduces unnecessary arithmetic operations by examining the multiplier bits and identifying consecutive sequences of ones. This minimizes the number of addition and subtraction operations while naturally supporting signed two's complement multiplication.

This project focuses on the design and implementation of an 8-bit signed sequential multiplier using the Radix-2 Booth algorithm in SystemVerilog. The design follows a modular architecture consisting of a datapath, a finite state machine (FSM) controller and a Booth encoder. The design is verified using self-checking SystemVerilog testbenches with both directed and randomized test cases.

**Objectives:**</br>
The main objectives of this project are:
- Design an 8-bit signed Radix-2 Booth multiplier in SystemVerilog.
- Implement the multiplier using a sequential hardware architecture.
- Design separate datapath and control units.
- Implement an FSM-based controller for managing multiplication operations.
- Perform one Booth iteration per clock cycle.
- Verify the design using self-checking SystemVerilog testbenches.
- Validate the design using directed, corner-case and randomized verification.

**Motivation:**</br>
Hardware multipliers play a very important role in modern computing systems. The Radix-2 Booth algorithm is a widely used signed multiplication technique because it:
- Naturally supports two's complement signed multiplication without requiring additional correction circuitry.
- Reduces unnecessary arithmetic operations by encoding consecutive runs of ones.
- Provides an efficient sequential implementation requiring minimal hardware resources.
- Produces a fully synthesizable hardware design suitable for FPGA and ASIC implementation.

**Methodology:**</br>
The proposed system uses a sequential Booth multiplication architecture divided into three major sections:
- Datapath
- Controller FSM
- Booth Encoder

**Booth Algorithm:**</br>
The Radix-2 Booth algorithm examines the multiplier bits in overlapping groups of two:
~~~
(Q0, Q-1)
~~~

The arithmetic operation is selected according to the following encoding:

| Booth Bits |       Operation       |
|:----------:|:---------------------:|
|     00     |      No Operation     |
|     01     |    Add Multiplicand   |
|     10     | Subtract Multiplicand |
|     11     |      No Operation     |

After the selected arithmetic operation, the combined register undergoes an arithmetic right shift by one bit.
~~~
{A, Q, Q-1} >>> 1
~~~

Since one multiplier bit is processed during each iteration, the multiplication completes after N clock cycles.

**Booth Algorithm Flowchart:**</br>
## Booth Multiplication Algorithm

```mermaid
flowchart TD
    A([Start])
    B[Load Multiplicand and Multiplier]
    C[Initialize A = 0<br/>Q-1 = 0<br/>Count = N]
    D[Read Booth Bits<br/>Q0,Q-1]
    E{Booth Bits}
    F[Add Multiplicand]
    G[Subtract Multiplicand]
    H[No Operation]
    I[Arithmetic Right Shift]
    J[Count = Count - 1]
    K{Count == 0?}
    L[Output Product]
    M([Done])
    A --> B
    B --> C
    C --> D
    D --> E
    E -->|01| F
    E -->|10| G
    E -->|00 or 11| H
    F --> I
    G --> I
    H --> I
    I --> J
    J --> K
    K -->|No| D
    K -->|Yes| L
    L --> M
```

**FSM State Diagram:**</br>
```mermaid
stateDiagram-v2
    [*] --> IDLE
    IDLE --> LOAD : start_signal
    LOAD --> RUN
    RUN --> RUN : count > 0
    RUN --> DONE : count == 0
    DONE --> IDLE : !start_signal
```

**Schematic:**

![Schematic](docs/schematic.png)

**RTL Modules:**</br>
The project consists of the following RTL modules:
- controller_fsm.sv
- datapath.sv
- booth_encoder.sv
- radix2_booth_multiplier.sv

**Verification Strategy:**</br>
The design is verified using self-checking SystemVerilog testbenches.
The verification process includes:
- Directed test cases
- Corner-case testing
- Randomized testing
- Automatic PASS/FAIL checking using the built-in signed multiplication operator as the reference model

The expected product is calculated using:
~~~
expected = $signed(a) * $signed(b); //where a = multiplicand & b = multiplier
~~~

**Installation:**

Follow these instructions inside bash:

1. Clone the repository:
    ~~~
    git clone https://github.com/<your-username>/Radix-2-booth-multiplier.git
    cd Radix-2-booth-multiplier
    ~~~

**Project Structure:**</br>
~~~
project/
│
├── rtl/
│   ├── controller_fsm.sv
│   ├── datapath.sv
│   ├── booth_encoder.sv
│   └── radix2_booth_multiplier.sv
│
├── tb/
│   ├── tb_controller_fsm.sv
│   └── tb_radix2_booth_multiplier.sv
│
└── README.md
~~~

**Functional Coverage:**</br>
The verification environment includes functional coverage to ensure that all major operating scenarios of the Booth multiplier are exercised.

Coverage includes:
- Positive × Positive multiplication
- Positive × Negative multiplication
- Negative × Negative multiplication
- Zero multiplication
- Boundary values (127 and -128)
- Randomized signed operand combinations
- All Booth encoding combinations (00, 01, 10, 11)

Coverage Results
|    Coverage Item   | Status |
|:------------------:|:------:|
|    Booth Encoder   |  100%  |
|   Directed Tests   |  PASS  |
|    Corner Cases    |  PASS  |
| Random Tests (500) |  PASS  |

**Waveforms:**

![Waveform](docs/waveform_top.png)
>Top module

![Waveform](docs/waveform_fsm.png)
>Controller FSM

**Terminal:**

![Terminal](docs/terminal_top.png)
>Top module

![Terminal](docs/terminal_fsm.png)
>Controller FSM

Author:</br>
***Noor Fatima***