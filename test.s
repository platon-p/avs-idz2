.data
    case1: .double 0
    case2: .double 1
    case3: .double 2
    case4: .double -1
    case5: .double -0.01
    case6: .double 7
    
    nl: .string "\n"
    accuracy: .double 0.001
.text
.include "math.s"
.macro run(%case)
    fld fa0 %case t0
    fld fa1 accuracy t0
    cos(fa0, fa1)
    li a7 3
    ecall
    li a7 4
    la a0 nl
    ecall
.end_macro
run(case1)
run(case2)
run(case3)
run(case4)
run(case5)
run(case6)