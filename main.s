.data
accuracy: .double 0.001
.text
.include "math.s"
.include "io.s"
        read_x() # res = fa0
        fld fa1 accuracy t0
        cos_norm(fa0, fa1)
        
        li a7 3
        ecall
        
        li a7 10
        ecall
