.data
pi: .double 3.141592653589793
pi2: .double 6.283185307179586
one: .double 1.0
enter_x: .string "Enter x: "
.text
j enddef_math
.macro taylor_term(%x, %n)
        fmv.d fa0 %x
        mv    a0  %n
        jal   taylor_term
        # res = fa0
.end_macro 

.macro pow(%x, %n)
        fmv.d fa0 %x
        mv    a0 %n
        jal   pow
.end_macro
.macro fact(%n) # I did not use it
        mv  a0 %n
        jal fact
.end_macro 
.macro cos(%x, %accuracy)
        fmv.d fa0 %x
        fmv.d fa1 %accuracy
        jal cos
.end_macro

.macro cos_norm(%x, %accuracy)
        fmv.d fa0 %x
        fmv.d fa1 %accuracy
        jal   normalize
        jal   cos
.end_macro

# ----------------------------

# x = fa0; res = fa0
normalize:
        # normailze = make |fa0| < 2pi
        fcvt.d.w ft0 zero
        fld      ft1 pi2 t2 # what to sub
        
        fge.d    t0  fa0 ft0
        bnez     t0  nonega
        fneg.d   ft1 ft1
        nonega:

        norm:
        fabs.d ft2 fa0
        flt.d  t0  ft2 ft1
        bnez   t0  end_norm
        fsub.d fa0 fa0 ft1
        j norm
        end_norm:
        ret

cos:    # x = fa0, accuracy = fa1; res = fa0 = cos(x)
        addi sp sp -24
        sw   ra 20(sp)
        sw   s0 16 (sp)
        fsd  fs0 8(sp)
        fsd  fs1 (sp)
        
        # fs0 = x, fs1 = temp_res, s0 = n (0,1,2,...)
        
        fmv.d    fs0 fa0
        fcvt.d.w fs1 zero
        li       s0 0
        
        loop_taylor:
        taylor_term(fs0, s0)
        fabs.d ft0 fa0
        flt.d  t0  ft0 fa1
        bnez   t0  taylor_end
        
        fadd.d fs1 fs1 fa0
        addi   s0 s0 1
        j loop_taylor
        taylor_end:
        fmv.d fa0 fs1 # res
        
        lw ra 20(sp)
        lw s0 16 (sp)
        fld fs0 8(sp)
        fld fs1 (sp)
        addi sp sp 16
        ret

taylor_term:
        # res = (-1)^n * x^(2n) / (2n)!
        # res = fa0, x = fa0, n = a0
        addi sp  sp -16
        sw   ra  12(sp)
        sw   s0  8(sp)
        fsd  fs0 (sp)
        
        mv    s0  a0  # s0 = n
        fmv.d fs0 fa0 # fs0 = x
        
        li  t1 1 
        sll t1 s0 t1 # = n << 1 = 2n
        pow(fa0, t1)
        # fa0 = x^2n
        
        # previously I calculated 2n!, but
        # if n = 7, overflow happens. so if we
        # want to calculate term for n >= 7,
        # we need to divide in loop
        # unsigned would not help :( 
        li t0 1
        sll t0 s0 t0 # t0 = 2n
        fcvt.d.w ft0 t0 # = 2n
        fcvt.d.w ft1 zero # = 0 = const
        fld ft2 one t0 # ft2 = 1 = const
        div_fact:
        feq.d t0 ft0 ft1
        bnez t0 end_div
        fdiv.d fa0 fa0 ft0
        fsub.d ft0 ft0 ft2
        j div_fact
        end_div:
        
        andi t0 s0 1
        beqz t0 noneg
        fneg.d fa0 fa0
        noneg:
        
        fld fs0 (sp)
        lw s0 8(sp)
        lw ra 12(sp)
        addi sp sp 16
        
        ret

fact:   # a0 = a0! (res = n!)
        li t0 1
        loop_fact:
        beqz a0 end_fact
        mul  t0 t0 a0
        addi a0 a0 -1
        j loop_fact
        end_fact:
        mv a0 t0
        ret

pow:    # fa0 = fa0 ^ a0 (res = x ^ n)
        fld    ft0 one t0 # t0 is temporary (check command docs)
        loop_pow:
        beqz   a0  end_pow
        fmul.d ft0 fa0 ft0
        addi   a0  a0 -1
        j      loop_pow
        end_pow:
        fmv.d  fa0 ft0
        ret

enddef_math: