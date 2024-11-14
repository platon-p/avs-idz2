.text
j enddef_io
.macro read_x()
        jal read_x
.end_macro

read_x:
        li a7 4
        la a0 enter_x
        ecall
        
        li a7 7
        ecall
        ret
enddef_io: