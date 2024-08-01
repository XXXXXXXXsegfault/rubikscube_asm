.entry
push %rbp
mov %rsp,%rbp
call @prog_init
sub $112,%rsp
xor %ecx,%ecx
movq $80,32+0(%rsp)
movq $@WndProc,32+8(%rsp)
mov %rcx,32+16(%rsp)
movq $0x400000,32+24(%rsp)
mov %rcx,32+32(%rsp)
movq $8,32+48(%rsp)
mov %rcx,32+56(%rsp)
movq $@WName,32+64(%rsp)
mov %rcx,32+72(%rsp)
mov $0x7f00,%edx
.dllcall "user32.dll" "LoadCursorA"
mov %rax,32+40(%rsp)
lea 32(%rsp),%rcx
.dllcall "user32.dll" "RegisterClassExA"
test %rax,%rax
je @Err_Exit

xor %ecx,%ecx
mov $0x80000000,%edx
push %rcx
pushq $0x400000
push %rcx
push %rcx
pushq $600
pushq $600
push %rdx
push %rdx
mov $0x100,%ecx
mov $@WName,%rdx
mov %rdx,%r8
mov $0x10c80000,%r9d
sub $32,%rsp
.dllcall "user32.dll" "CreateWindowExA"
test %rax,%rax
je @Err_Exit

mov %rax,%rcx
mov $1,%edx
mov $12,%r8d
xor %r9d,%r9d
.dllcall "user32.dll" "SetTimer"

@MsgLoop
lea 32(%rsp),%rcx
xor %edx,%edx
mov %edx,%r8d
mov %edx,%r9d
.dllcall "user32.dll" "GetMessageA"
cmp $0,%rax
jle @Err_Exit
lea 32(%rsp),%rcx
.dllcall "user32.dll" "TranslateMessage"
lea 32(%rsp),%rcx
.dllcall "user32.dll" "DispatchMessageA"
jmp @MsgLoop

@Err_Exit
xor %eax,%eax
mov %rbp,%rsp
pop %rbp
ret

@prog_init
sub $40,%rsp
.dllcall "user32.dll" "SetProcessDPIAware"

mov $0x3f800000,%eax
mov %eax,@_$DATA+0
mov %eax,@_$DATA+20
mov %eax,@_$DATA+40

mov $0x0101010101010101,%rcx
mov %rcx,%rax
mov %rax,@_$DATA+256+16
mov %rax,@_$DATA+256+24
add %rcx,%rax
mov %rax,@_$DATA+256+32
mov %rax,@_$DATA+256+40
add %rcx,%rax
mov %rax,@_$DATA+256+48
mov %rax,@_$DATA+256+56
add %rcx,%rax
mov %rax,@_$DATA+256+64
mov %rax,@_$DATA+256+72
add %rcx,%rax
mov %rax,@_$DATA+256+80
mov %rax,@_$DATA+256+88

add $40,%rsp

ret

@paint_triangle_2d_subproc
mov 32(%rbp),%esi
sub 16(%rbp),%esi
mov 56(%rbp),%edi
sub 40(%rbp),%edi
mov %ecx,%eax
sub 40(%rbp),%eax
imul %esi
idiv %edi
add 16(%rbp),%eax
mov %eax,24(%rsp)
# paint_line
# 16(%rbp) -- y
# 24(%rbp) -- x1
# 32(%rbp) -- x2
# 40(%rbp) -- color
push %rbp
mov %rsp,%rbp
push %rcx
push %rdx
push %rsi
mov 24(%rbp),%eax
mov 32(%rbp),%ecx
cmp %eax,%ecx
jg @paint_line_swap
mov %eax,32(%rbp)
mov %ecx,24(%rbp)
sub %ecx,%eax
je @paint_line_end
@paint_line_swap

mov 16(%rbp),%eax
neg %eax
add $300,%eax
mov $600,%edx
imul %edx
mov 32(%rbp),%ecx
mov 24(%rbp),%edx
sub %edx,%ecx
add %edx,%eax
shl $2,%eax
add $@_$DATA+4096+1200,%eax
mov 40(%rbp),%edx
mov @_$DATA+112,%esi
@paint_line_loop
mov %edx,(%rax)
mov %esi,1440000(%rax)
add $4,%eax
dec %ecx
jne @paint_line_loop

@paint_line_end
pop %rsi
pop %rdx
pop %rcx
mov %rbp,%rsp
pop %rbp
ret

@swap_points
# %eax -- p1
# %ecx -- p2
mov (%rax),%rdx
xchg %rdx,(%rcx)
mov %rdx,(%rax)
mov -24(%rax),%rdx
xchg %rdx,-24(%rcx)
mov %rdx,-24(%rax)
ret

@paint_triangle_2d
# 16(%rbp) -- x1
# 24(%rbp) -- x2
# 32(%rbp) -- x3
# 40(%rbp) -- y1
# 48(%rbp) -- y2
# 56(%rbp) -- y3
# 88(%rbp) -- color
push %rbp
mov %rsp,%rbp
push %rax
push %rcx
push %rdx
push %rsi
push %rdi

mov 40(%rbp),%eax
lea 48(%rbp),%rcx
cmp (%rcx),%eax
jle @paint_triangle_2d_sort1
lea 40(%rbp),%rax
call @swap_points
@paint_triangle_2d_sort1

mov 40(%rbp),%eax
lea 56(%rbp),%rcx
cmp (%rcx),%eax
jle @paint_triangle_2d_sort2
lea 40(%rbp),%rax
call @swap_points
@paint_triangle_2d_sort2

mov 48(%rbp),%eax
lea 56(%rbp),%rcx
cmp (%rcx),%eax
jle @paint_triangle_2d_sort3
lea 48(%rbp),%rax
call @swap_points
@paint_triangle_2d_sort3

sub $48,%rsp
mov 88(%rbp),%eax
mov %eax,24(%rsp)

mov 40(%rbp),%ecx
@paint_triangle_2d_loop1
cmp 48(%rbp),%ecx
jge @paint_triangle_2d_loop1_end
mov %ecx,(%rsp)
mov 24(%rbp),%esi
sub 16(%rbp),%esi
mov 48(%rbp),%edi
sub 40(%rbp),%edi
mov %ecx,%eax
sub 40(%rbp),%eax
imul %esi
idiv %edi
add 16(%rbp),%eax
mov %eax,8(%rsp)

call @paint_triangle_2d_subproc

inc %ecx
jmp @paint_triangle_2d_loop1
@paint_triangle_2d_loop1_end

@paint_triangle_2d_loop2
cmp 56(%rbp),%ecx
jge @paint_triangle_2d_loop2_end
mov %ecx,(%rsp)
mov 32(%rbp),%esi
sub 24(%rbp),%esi
mov 56(%rbp),%edi
sub 48(%rbp),%edi
mov %ecx,%eax
sub 48(%rbp),%eax
imul %esi
idiv %edi
add 24(%rbp),%eax
mov %eax,8(%rsp)

call @paint_triangle_2d_subproc

inc %ecx
jmp @paint_triangle_2d_loop2
@paint_triangle_2d_loop2_end

add $48,%rsp

pop %rdi
pop %rsi
pop %rdx
pop %rcx
pop %rax
mov %rbp,%rsp
pop %rbp
ret

@vector_transform
# %rax -- ptr
push %rcx
movss 4(%rax),%xmm5
movss 8(%rax),%xmm3
mov $20,%ecx
cvtsi2ss %ecx,%xmm0
addss %xmm0,%xmm5
divss %xmm5,%xmm3
movss %xmm3,4(%rax)
movss (%rax),%xmm0
divss %xmm5,%xmm0
movss %xmm0,(%rax)
pop %rcx
ret

@paint_triangle_3d
# 16(%rbp) -- p1
# 32(%rbp) -- p2
# 48(%rbp) -- p3
# 64(%rbp) -- color
push %rbp
mov %rsp,%rbp
push %rax
push %rcx
push %rdx
sub $80,%rsp

mov 64(%rbp),%eax
mov %eax,72(%rsp)

lea 16(%rsp),%rax
mov $48,%ecx
@paint_triangle_3d_loop
push %rax
lea (%rcx,%rbp,1),%rax
call @vector_transform
pop %rax

mov $1400,%edx
cvtsi2ss %edx,%xmm1

movss (%rcx,%rbp,1),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%edx
mov %edx,(%rax)
movss 4(%rcx,%rbp,1),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%edx
mov %edx,24(%rax)
sub $8,%rax
sub $16,%ecx
jne @paint_triangle_3d_loop

call @paint_triangle_2d

add $80,%rsp
pop %rdx
pop %rcx
pop %rax
mov %rbp,%rsp
pop %rbp
ret

@paint_square
# 16(%rbp) -- start
# 32(%rbp) -- x_vec
# 48(%rbp) -- y_vec
# 64(%rbp) -- z_vec
# 80(%rbp) -- red
# 84(%rbp) -- green
# 88(%rbp) -- blue
# 92(%rbp) -- width
push %rbp
mov %rsp,%rbp
push %rax
push %rcx
sub $112,%rsp
movups 16(%rbp),%xmm0
mov $0x41a00000,%eax
movq %rax,%xmm1
shufps $0x51,%xmm1,%xmm1
addps %xmm1,%xmm0
mulps 64(%rbp),%xmm0
movups %xmm0,%xmm1
movups %xmm0,%xmm2
shufps $0x1,%xmm1,%xmm1
shufps $0x2,%xmm2,%xmm2
addss %xmm1,%xmm0
addss %xmm2,%xmm0
xor %eax,%eax
movd %eax,%xmm1
comiss %xmm1,%xmm0
ja @paint_square_end

movss 68(%rbp),%xmm2
mov $125,%eax
cvtsi2ss %eax,%xmm1
mulss %xmm1,%xmm2
mov $128,%eax
cvtsi2ss %eax,%xmm1
subss %xmm2,%xmm1

movss 80(%rbp),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%eax
mov %ax,50(%rsp)
movss 84(%rbp),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%eax
mov %al,49(%rsp)
movss 88(%rbp),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%eax
mov %al,48(%rsp)


movss 92(%rbp),%xmm0
shufps $0x00,%xmm0,%xmm0
movups 16(%rbp),%xmm1
movups %xmm1,(%rsp)
movups %xmm1,80(%rsp)
movups 32(%rbp),%xmm2
movups 48(%rbp),%xmm3
mulps %xmm0,%xmm2
mulps %xmm0,%xmm3
addps %xmm2,%xmm1
movups %xmm1,16(%rsp)
addps %xmm3,%xmm1
movups %xmm1,32(%rsp)
movups %xmm1,96(%rsp)
subps %xmm2,%xmm1
movups %xmm1,64(%rsp)
call @paint_triangle_3d
movups 96(%rsp),%xmm1
movups %xmm1,(%rsp)
movups 64(%rsp),%xmm1
movups %xmm1,16(%rsp)
movups 80(%rsp),%xmm1
movups %xmm1,32(%rsp)
call @paint_triangle_3d

@paint_square_end
add $112,%rsp
pop %rcx
pop %rax
pop %rbp
ret

@paint_full_square
# 16(%rbp) -- start
# 32(%rbp) -- x_vec
# 48(%rbp) -- y_vec
# 64(%rbp) -- z_vec
# 80(%rbp) -- red
# 84(%rbp) -- green
# 88(%rbp) -- blue
push %rbp
mov %rsp,%rbp
push %rax
sub $104,%rsp
movups 16(%rbp),%xmm0
movups %xmm0,(%rsp)
movups 32(%rbp),%xmm0
movups %xmm0,16(%rsp)
movups 48(%rbp),%xmm0
movups %xmm0,32(%rsp)
movups 64(%rbp),%xmm0
movups %xmm0,48(%rsp)
movl $0x3f000000,64(%rsp)
movl $0x3f000000,68(%rsp)
movl $0x3f000000,72(%rsp)
movl $0x3f800000,76(%rsp)
call @paint_square
movups (%rsp),%xmm0
movups 16(%rsp),%xmm1
movups 32(%rsp),%xmm2
mov $0x3e000000,%eax
movd %eax,%xmm3
shufps $0x00,%xmm3,%xmm3
mulps %xmm3,%xmm1
mulps %xmm3,%xmm2
addps %xmm1,%xmm0
addps %xmm2,%xmm0
movups %xmm0,(%rsp)
movups 80(%rbp),%xmm0
movups %xmm0,64(%rsp)
movl $0x3f400000,76(%rsp)
call @paint_square
add $104,%rsp
pop %rax
pop %rbp
ret

@get_xyz
# %rax -- ptr
# %rcx -- num
push %rdx
cmp $2,%cl
jae @get_xyz_X1
movups @_$DATA+0,%xmm0
movups %xmm0,(%rax)
movups @_$DATA+16,%xmm0
movups %xmm0,16(%rax)
movups @_$DATA+32,%xmm0
movups %xmm0,32(%rax)
jmp @get_xyz_end
@get_xyz_X1

cmp $4,%cl
jae @get_xyz_X2
movups @_$DATA+16,%xmm0
movups %xmm0,0(%rax)
movups @_$DATA+32,%xmm0
movups %xmm0,16(%rax)
movups @_$DATA+0,%xmm0
movups %xmm0,32(%rax)
jmp @get_xyz_end
@get_xyz_X2

movups @_$DATA+32,%xmm0
movups %xmm0,0(%rax)
movups @_$DATA+0,%xmm0
movups %xmm0,16(%rax)
movups @_$DATA+16,%xmm0
movups %xmm0,32(%rax)
@get_xyz_end

test $1,%cl
je @get_xyz_noneg
movups (%rax),%xmm0
movups 16(%rax),%xmm1
movups %xmm1,(%rax)
movups %xmm0,16(%rax)
movups 32(%rax),%xmm0
mov $0xbf800000,%edx
movd %edx,%xmm1
shufps $0x00,%xmm1,%xmm1
mulps %xmm1,%xmm0
movups %xmm0,32(%rax)
@get_xyz_noneg

pop %rdx
ret

@get_xyz_r
# %rax -- ptr
# %rcx -- num
push %rdx
cmp $2,%cl
jae @get_xyz_r_X1
movups @_$DATA+48,%xmm0
movups %xmm0,(%rax)
movups @_$DATA+64,%xmm0
movups %xmm0,16(%rax)
movups @_$DATA+80,%xmm0
movups %xmm0,32(%rax)
jmp @get_xyz_r_end
@get_xyz_r_X1

cmp $4,%cl
jae @get_xyz_r_X2
movups @_$DATA+64,%xmm0
movups %xmm0,0(%rax)
movups @_$DATA+80,%xmm0
movups %xmm0,16(%rax)
movups @_$DATA+48,%xmm0
movups %xmm0,32(%rax)
jmp @get_xyz_r_end
@get_xyz_r_X2

movups @_$DATA+80,%xmm0
movups %xmm0,0(%rax)
movups @_$DATA+48,%xmm0
movups %xmm0,16(%rax)
movups @_$DATA+64,%xmm0
movups %xmm0,32(%rax)
@get_xyz_r_end

test $1,%cl
je @get_xyz_r_noneg
movups (%rax),%xmm0
movups 16(%rax),%xmm1
movups %xmm1,(%rax)
movups %xmm0,16(%rax)
movups 32(%rax),%xmm0
mov $0xbf800000,%edx
movd %edx,%xmm1
shufps $0x00,%xmm1,%xmm1
mulps %xmm1,%xmm0
movups %xmm0,32(%rax)
@get_xyz_r_noneg

pop %rdx
ret

@is_square_rotating
# %rcx -- num
# return -- 0: no, 1: yes, 2: invalid
push %rcx
cmp $96,%cl
jae @is_square_rotating_invalid
mov %cl,%al
and $15,%al
cmp $11,%al
jae @is_square_rotating_invalid
and $3,%al
cmp $3,%al
je @is_square_rotating_invalid

mov @_$DATA+96,%al
cmp $0,%al
je @is_square_rotating_no

dec %al
lea (%rax,%rax,2),%eax
shl $1,%al
mov %cl,%ch
shr $4,%ch
add %ch,%al
movzbl %al,%eax
shl $1,%eax
mov @rotating_list(%rax),%ax
and $0xf,%cl
shr %cl,%ax
test $1,%al
jne @is_square_rotating_yes
@is_square_rotating_no
xor %eax,%eax
pop %rcx
ret

@is_square_rotating_invalid
mov $2,%eax
pop %rcx
ret
@is_square_rotating_yes
mov $1,%eax
pop %rcx
ret

@paint_squares_not_rotating
push %rax
push %rcx
push %rdx
sub $128,%rsp
movl $96,112(%rsp)
@paint_squares_not_rotating_loop
mov 112(%rsp),%ecx
dec %ecx
call @is_square_rotating
test %eax,%eax
jne @paint_squares_not_rotating_loop_continue
lea 16(%rsp),%rax
shr $4,%ecx
call @get_xyz

mov $0x3fc00000,%edx
movd %edx,%xmm0
mov 112(%rsp),%ecx
dec %ecx
and $0x3,%ecx
cvtsi2ss %ecx,%xmm1
mov 112(%rsp),%ecx
dec %ecx
shr $2,%ecx
and $0x3,%ecx
cvtsi2ss %ecx,%xmm2
shufps $0x00,%xmm0,%xmm0
shufps $0x00,%xmm1,%xmm1
shufps $0x00,%xmm2,%xmm2
subps %xmm0,%xmm1
subps %xmm0,%xmm2
movups 48(%rsp),%xmm3
mulps %xmm0,%xmm3
movups 16(%rsp),%xmm4
mulps %xmm1,%xmm4
addps %xmm4,%xmm3
movups 32(%rsp),%xmm4
mulps %xmm2,%xmm4
addps %xmm4,%xmm3
movups %xmm3,(%rsp)
mov 112(%rsp),%ecx
dec %ecx
mov %ecx,@_$DATA+112
movzbl @_$DATA+256(%rcx),%ecx
shl $4,%ecx
movups @square_colors(%rcx),%xmm0
movups %xmm0,64(%rsp)
call @paint_full_square


@paint_squares_not_rotating_loop_continue
decl 112(%rsp)
jne @paint_squares_not_rotating_loop

cmpb $0,@_$DATA+96
je @paint_squares_not_rotating_end
mov @_$DATA+96,%cl
dec %cl

lea 16(%rsp),%rax
call @get_xyz
mov $0x3f000000,%eax
movd %eax,%xmm0
mov $0x3fc00000,%eax
movd %eax,%xmm1
shufps $0x00,%xmm0,%xmm0
shufps $0x00,%xmm1,%xmm1
movups 48(%rsp),%xmm2
mulps %xmm0,%xmm2
movups 16(%rsp),%xmm3
mulps %xmm1,%xmm3
subps %xmm3,%xmm2
movups 32(%rsp),%xmm3
mulps %xmm1,%xmm3
subps %xmm3,%xmm2
movups %xmm2,(%rsp)
mov $0x3f000000,%eax
mov %eax,64(%rsp)
mov %eax,68(%rsp)
mov %eax,72(%rsp)
movl $0x40400000,76(%rsp)
call @paint_square
@paint_squares_not_rotating_end

add $128,%rsp
pop %rdx
pop %rcx
pop %rax
ret


@paint_squares_rotating
push %rax
push %rcx
push %rdx
sub $128,%rsp
movl $96,112(%rsp)
@paint_squares_rotating_loop
mov 112(%rsp),%ecx
dec %ecx
call @is_square_rotating
cmp $1,%eax
jne @paint_squares_rotating_loop_continue
lea 16(%rsp),%rax
shr $4,%ecx
call @get_xyz_r

mov $0x3fc00000,%edx
movd %edx,%xmm0
mov 112(%rsp),%ecx
dec %ecx
and $0x3,%ecx
cvtsi2ss %ecx,%xmm1
mov 112(%rsp),%ecx
dec %ecx
shr $2,%ecx
and $0x3,%ecx
cvtsi2ss %ecx,%xmm2
shufps $0x00,%xmm0,%xmm0
shufps $0x00,%xmm1,%xmm1
shufps $0x00,%xmm2,%xmm2
subps %xmm0,%xmm1
subps %xmm0,%xmm2
movups 48(%rsp),%xmm3
mulps %xmm0,%xmm3
movups 16(%rsp),%xmm4
mulps %xmm1,%xmm4
addps %xmm4,%xmm3
movups 32(%rsp),%xmm4
mulps %xmm2,%xmm4
addps %xmm4,%xmm3
movups %xmm3,(%rsp)
mov 112(%rsp),%ecx
dec %ecx
movzbl @_$DATA+256(%rcx),%ecx
shl $4,%ecx
movups @square_colors(%rcx),%xmm0
movups %xmm0,64(%rsp)
call @paint_full_square


@paint_squares_rotating_loop_continue
decl 112(%rsp)
jne @paint_squares_rotating_loop

cmpb $0,@_$DATA+96
je @paint_squares_rotating_end
mov @_$DATA+96,%cl
dec %cl
xor $1,%cl
lea 16(%rsp),%rax
call @get_xyz_r
mov $0xbf000000,%eax
movd %eax,%xmm0
mov $0x3fc00000,%eax
movd %eax,%xmm1
shufps $0x00,%xmm0,%xmm0
shufps $0x00,%xmm1,%xmm1
movups 48(%rsp),%xmm2
mulps %xmm0,%xmm2
movups 16(%rsp),%xmm3
mulps %xmm1,%xmm3
subps %xmm3,%xmm2
movups 32(%rsp),%xmm3
mulps %xmm1,%xmm3
subps %xmm3,%xmm2
movups %xmm2,(%rsp)
mov $0x3f000000,%eax
mov %eax,64(%rsp)
mov %eax,68(%rsp)
mov %eax,72(%rsp)
movl $0x40400000,76(%rsp)
call @paint_square
@paint_squares_rotating_end

add $128,%rsp
pop %rdx
pop %rcx
pop %rax
ret

@rotate_around
# 16(%rbp) -- pointer to axis
# 24(%rbp) -- pointer to vector
# 32(%rbp) -- angle
push %rbp
mov %rsp,%rbp
push %rax
push %rcx
sub $96,%rsp
mov 16(%rbp),%rax
mov 24(%rbp),%rcx
mov %rcx,56(%rsp)
movups (%rax),%xmm0
movups (%rcx),%xmm1
movups %xmm0,%xmm2
mulps %xmm1,%xmm2
movups %xmm2,%xmm3
movups %xmm2,%xmm4
shufps $0x01,%xmm3,%xmm3
shufps $0x02,%xmm4,%xmm4
addss %xmm3,%xmm2
addss %xmm4,%xmm2
shufps $0x00,%xmm2,%xmm2
movups %xmm0,%xmm3
mulps %xmm3,%xmm2
movups %xmm1,%xmm3
subps %xmm2,%xmm3
movups %xmm2,64(%rsp)
movups %xmm3,80(%rsp)

movups %xmm0,%xmm2
movups %xmm3,%xmm1
shufps $0x09,%xmm0,%xmm0
shufps $0x12,%xmm1,%xmm1
shufps $0x12,%xmm2,%xmm2
shufps $0x09,%xmm3,%xmm3
mulps %xmm1,%xmm0
mulps %xmm3,%xmm2
subps %xmm2,%xmm0
movups %xmm0,32(%rsp)
movss 32(%rbp),%xmm0
cvtss2sd %xmm0,%xmm0
.dllcall "msvcrt.dll" "sin"
cvtsd2ss %xmm0,%xmm0
movss %xmm0,48(%rsp)
movss 32(%rbp),%xmm0
cvtss2sd %xmm0,%xmm0
.dllcall "msvcrt.dll" "cos"
cvtsd2ss %xmm0,%xmm0
shufps $0x00,%xmm0,%xmm0
movss 48(%rsp),%xmm1
shufps $0x00,%xmm1,%xmm1
movups 80(%rsp),%xmm2
movups 32(%rsp),%xmm3
mulps %xmm0,%xmm2
mulps %xmm1,%xmm3
addps %xmm3,%xmm2
addps 64(%rsp),%xmm2
mov 56(%rsp),%rcx
movups %xmm2,(%rcx)


add $96,%rsp
pop %rcx
pop %rax
pop %rbp
ret


@paint_all
push %rdx
sub $128,%rsp
mov $@_$DATA+4096,%rdx

@paint_all_clear_loop
movq $0,(%rdx)
movq $-1,1440000(%rdx)
add $8,%rdx
cmp $@_$DATA+1444096,%rdx
jne @paint_all_clear_loop

mov @_$DATA+96,%cl
cmp $0,%cl
je @paint_all_norotate
dec %cl

lea 32(%rsp),%rax
call @get_xyz

mov @_$DATA+116,%eax
mov %eax,16(%rsp)
movups @_$DATA+0,%xmm0
movups %xmm0,@_$DATA+48
movups @_$DATA+16,%xmm0
movups %xmm0,@_$DATA+64
movups @_$DATA+32,%xmm0
movups %xmm0,@_$DATA+80

lea 64(%rsp),%rax
mov %rax,(%rsp)
movq $@_$DATA+48,8(%rsp)
call @rotate_around
addq $16,8(%rsp)
call @rotate_around
addq $16,8(%rsp)
call @rotate_around

mov %rsp,%rax
call @get_xyz

mov $0x3f000000,%eax
movd %eax,%xmm0
shufps $0x00,%xmm0,%xmm0
movups 32(%rsp),%xmm1
movups %xmm1,%xmm2
mulss %xmm0,%xmm1
mov $0x41a00000,%eax
movq %rax,%xmm0
shufps $0x51,%xmm0,%xmm0
addps %xmm0,%xmm1
mulps %xmm1,%xmm2
movups %xmm2,%xmm0
movups %xmm2,%xmm1
shufps $0x01,%xmm1,%xmm1
shufps $0x02,%xmm2,%xmm2
addss %xmm1,%xmm0
addss %xmm2,%xmm0
movss %xmm0,(%rsp)

testl $0x80000000,(%rsp)
jne @paint_all_X1
call @paint_squares_rotating

@paint_all_X1
call @paint_squares_not_rotating
testl $0x80000000,(%rsp)
je @paint_all_X2
call @paint_squares_rotating
@paint_all_X2
jmp @paint_all_end
@paint_all_norotate
call @paint_squares_not_rotating
@paint_all_end

add $128,%rsp
pop %rdx
ret

@transform_cw
# %al -- surface
push %rax
push %rcx
push %rdx
push %rbx
sub $128,%rsp
movzbl %al,%eax
shl $4,%eax
xor %ecx,%ecx
@transform_cw_X11
mov @_$DATA+256(%rax,%rcx,1),%bl
mov %bl,(%rsp,%rcx,1)
inc %ecx
cmp $11,%ecx
jne @transform_cw_X11
xor %ecx,%ecx
@transform_cw_X12
movzbl @cube_transform2(%rcx),%edx
cmp $10,%edx
ja @transform_cw_X13
mov (%rsp,%rcx,1),%bl
mov %bl,@_$DATA+256(%rax,%rdx,1)
@transform_cw_X13
inc %ecx
cmp $11,%ecx
jne @transform_cw_X12

shr $2,%eax
lea (%rax,%rax,2),%eax

xor %ecx,%ecx
@transform_cw_X2
movzbl @cube_transform3(%rax,%rcx,1),%edx
mov @_$DATA+256(%rdx),%bl
mov %bl,3(%rsp,%rcx,1)
inc %ecx
cmp $12,%ecx
jne @transform_cw_X2
mov 12(%rsp),%bx
mov %bx,(%rsp)
mov 14(%rsp),%bl
mov %bl,2(%rsp)

xor %ecx,%ecx
@transform_cw_X3
movzbl @cube_transform3(%rax,%rcx,1),%edx
mov (%rsp,%rcx,1),%bl
mov %bl,@_$DATA+256(%rdx)
inc %ecx
cmp $12,%ecx
jne @transform_cw_X3

add $128,%rsp
pop %rbx
pop %rdx
pop %rcx
pop %rax
ret

@transform_ccw
# %al -- surface
push %rax
push %rcx
push %rdx
push %rbx
sub $128,%rsp
movzbl %al,%eax
shl $4,%eax
xor %ecx,%ecx
@transform_ccw_X11
mov @_$DATA+256(%rax,%rcx,1),%bl
mov %bl,(%rsp,%rcx,1)
inc %ecx
cmp $11,%ecx
jne @transform_ccw_X11
xor %ecx,%ecx
@transform_ccw_X12
movzbl @cube_transform1(%rcx),%edx
cmp $10,%edx
ja @transform_ccw_X13
mov (%rsp,%rcx,1),%bl
mov %bl,@_$DATA+256(%rax,%rdx,1)
@transform_ccw_X13
inc %ecx
cmp $11,%ecx
jne @transform_ccw_X12
shr $2,%eax
lea (%rax,%rax,2),%eax

xor %ecx,%ecx
@transform_ccw_X2
movzbl @cube_transform3(%rax,%rcx,1),%edx
mov @_$DATA+256(%rdx),%bl
mov %bl,(%rsp,%rcx,1)
inc %ecx
cmp $12,%ecx
jne @transform_ccw_X2
mov (%rsp),%bx
mov %bx,12(%rsp)
mov 2(%rsp),%bl
mov %bl,14(%rsp)

xor %ecx,%ecx
@transform_ccw_X3
movzbl @cube_transform3(%rax,%rcx,1),%edx
mov 3(%rsp,%rcx,1),%bl
mov %bl,@_$DATA+256(%rdx)
inc %ecx
cmp $12,%ecx
jne @transform_ccw_X3

add $128,%rsp
pop %rbx
pop %rdx
pop %rcx
pop %rax
ret


@WndProc
sub $8,%rsp
push %r9
push %r8
push %rdx
push %rcx

cmp $2,%edx
jne @WndProc_DESTROY
xor %ecx,%ecx
.dllcall "user32.dll" "PostQuitMessage"

@WndProc_DESTROY

cmp $15,%edx
jne @WndProc_PAINT
sub $128,%rsp
lea 32(%rsp),%rdx
.dllcall "user32.dll" "BeginPaint"

call @paint_all

mov 32(%rsp),%rcx
.dllcall "gdi32.dll" "CreateCompatibleDC"
mov %rax,112(%rsp)
mov 32(%rsp),%rcx
mov $600,%edx
mov %edx,%r8d
.dllcall "gdi32.dll" "CreateCompatibleBitmap"
mov %rax,120(%rsp)
mov %rax,%rdx
mov 112(%rsp),%rcx
.dllcall "gdi32.dll" "SelectObject"
mov 120(%rsp),%rcx
mov $1440000,%edx
mov $@_$DATA+4096,%r8
.dllcall "gdi32.dll" "SetBitmapBits"
mov 32(%rsp),%rcx
xor %edx,%edx
mov %edx,%r8d
mov $600,%r9d
sub $8,%rsp
pushq $0xcc0020
push %rdx
push %rdx
pushq 112+32(%rsp)
push %r9
sub $32,%rsp
.dllcall "gdi32.dll" "BitBlt"
add $80,%rsp
mov 120(%rsp),%rcx
.dllcall "gdi32.dll" "DeleteObject"
mov 112(%rsp),%rcx
.dllcall "gdi32.dll" "DeleteDC"

mov 128(%rsp),%rcx
lea 32(%rsp),%rdx
.dllcall "user32.dll" "EndPaint"

add $128,%rsp
jmp @WndProc_End
@WndProc_PAINT

cmp $275,%edx
jne @WndProc_TIMER

mov $0x3d9a6a62,%eax
movd %eax,%xmm0
movss @_$DATA+116,%xmm1
comiss %xmm0,%xmm1
ja @TIMER_X1

mov $0xbd9a6a62,%eax
movd %eax,%xmm0
comiss %xmm0,%xmm1
jb @TIMER_X1
movb $0,@_$DATA+96
movb $1,@_$DATA+99
jmp @TIMER_XE
@TIMER_X1
subss %xmm0,%xmm1
movss %xmm1,@_$DATA+116
movb $1,@_$DATA+99
@TIMER_XE

mov $0,%al
xchg %al,@_$DATA+99
test %al,%al
je @WndProc_End
sub $32,%rsp
mov 32(%rsp),%rcx
xor %edx,%edx
mov %edx,%r8d
.dllcall "user32.dll" "InvalidateRect"

add $32,%rsp
jmp @WndProc_End
@WndProc_TIMER

cmp $513,%edx
jne @WndProc_LBUTTONDOWN
movl $0,@_$DATA+100
movb $1,@_$DATA+97
mov %r9d,@_$DATA+108
jmp @WndProc_End
@WndProc_LBUTTONDOWN

cmp $514,%edx
jne @WndProc_LBUTTONUP
movb $0,@_$DATA+97
cmpb $0,@_$DATA+96
jne @WndProc_End
cmpl $10,@_$DATA+100
ja @WndProc_End
mov %r9d,%edx
movswl %dx,%ecx
sar $16,%edx
cmp $600,%edx
jae @WndProc_End
cmp $600,%ecx
jae @WndProc_End
mov $600,%eax
mul %edx
add %eax,%ecx
shl $2,%ecx
mov @_$DATA+1444096(%rcx),%eax
cmp $-1,%eax
je @WndProc_End
movl $0x3fc90fdb,@_$DATA+116
shr $4,%al
call @transform_ccw
inc %al
mov %al,@_$DATA+96
movb $1,@_$DATA+99
jmp @WndProc_End
@WndProc_LBUTTONUP

cmp $516,%edx
jne @WndProc_RBUTTONDOWN
movl $0,@_$DATA+104
movb $1,@_$DATA+98
mov %r9d,@_$DATA+108
jmp @WndProc_End
@WndProc_RBUTTONDOWN

cmp $517,%edx
jne @WndProc_RBUTTONUP
movb $0,@_$DATA+98
cmpb $0,@_$DATA+96
jne @WndProc_End
cmpl $10,@_$DATA+104
ja @WndProc_End
mov %r9d,%edx
movswl %dx,%ecx
sar $16,%edx
cmp $600,%edx
jae @WndProc_End
cmp $600,%ecx
jae @WndProc_End
mov $600,%eax
mul %edx
add %eax,%ecx
shl $2,%ecx
mov @_$DATA+1444096(%rcx),%eax
cmp $-1,%eax
je @WndProc_End
movl $0xbfc90fdb,@_$DATA+116
shr $4,%al
call @transform_cw
inc %al
mov %al,@_$DATA+96
movb $1,@_$DATA+99
jmp @WndProc_End
jmp @WndProc_End
@WndProc_RBUTTONUP

cmp $512,%edx
jne @WndProc_End
# WM_MOUSEMOVE
cmp @_$DATA+108,%r9d
je @WndProc_End

test $1,%r8d
je @MOUSEMOVE_NOLEFT
movswl %r9w,%eax
movswl @_$DATA+108,%ecx
sub %ecx,%eax
cmp $0,%eax
jg @MOUSEMOVE_LEFT_NEG1
neg %eax
@MOUSEMOVE_LEFT_NEG1
add %eax,@_$DATA+100
mov %r9d,%eax
sar $16,%eax
movswl @_$DATA+110,%ecx
sub %ecx,%eax
cmp $0,%eax
jg @MOUSEMOVE_LEFT_NEG2
neg %eax
@MOUSEMOVE_LEFT_NEG2
add %eax,@_$DATA+100

movswl %r9w,%eax
movswl @_$DATA+108,%edx
sub %edx,%eax
mul %eax
mov %eax,%ecx
mov %r9d,%eax
sar $16,%eax
movswl @_$DATA+110,%edx
sub %edx,%eax
mul %eax
add %eax,%ecx
cvtsi2ss %ecx,%xmm0
sub $128,%rsp
cvtss2sd %xmm0,%xmm0
.dllcall "msvcrt.dll" "sqrt"
cvtsd2ss %xmm0,%xmm0

movswq %r9w,%rax
movswq @_$DATA+108,%rdx
sub %rdx,%rax
cvtsi2ss %rax,%xmm1
movslq %r9d,%rax
sar $16,%rax
movswq @_$DATA+110,%rdx
sub %rdx,%rax
cvtsi2ss %rax,%xmm2
divss %xmm0,%xmm1
divss %xmm0,%xmm2
movss %xmm1,40(%rsp)
movss %xmm2,32(%rsp)
movl $0,36(%rsp)
lea 32(%rsp),%rax

mov %rax,(%rsp)
mov $60,%eax
cvtsi2ss %eax,%xmm1
divss %xmm1,%xmm0
movss %xmm0,16(%rsp)
movq $@_$DATA+0,8(%rsp)
call @rotate_around
addq $16,8(%rsp)
call @rotate_around
addq $16,8(%rsp)
call @rotate_around

movb $1,@_$DATA+99

add $128,%rsp

@MOUSEMOVE_NOLEFT

test $2,%r8d
je @MOUSEMOVE_NORIGHT
movswl %r9w,%eax
movswl @_$DATA+108,%ecx
sub %ecx,%eax
cmp $0,%eax
jg @MOUSEMOVE_RIGHT_NEG1
neg %eax
@MOUSEMOVE_RIGHT_NEG1
add %eax,@_$DATA+104
mov %r9d,%eax
sar $16,%eax
movswl @_$DATA+110,%ecx
sub %ecx,%eax
cmp $0,%eax
jg @MOUSEMOVE_RIGHT_NEG2
neg %eax
@MOUSEMOVE_RIGHT_NEG2
add %eax,@_$DATA+104
@MOUSEMOVE_NORIGHT
mov %r9d,@_$DATA+108

@WndProc_End
mov (%rsp),%rcx
mov 8(%rsp),%rdx
mov 16(%rsp),%r8
mov 24(%rsp),%r9
.dllcall "user32.dll" "DefWindowProcA"
add $40,%rsp
ret



@WName
.string "Rubik\'s Cube"
@cube_transform1
.byte 8,4,0,16,9,5,1,16,10,6,2
@cube_transform2
.byte 2,6,10,16,1,5,9,16,0,4,8
@cube_transform3
.byte 58,54,50,88,89,90,40,41,42,74,70,66
.byte 64,68,72,34,33,32,82,81,80,48,52,56
.byte 90,86,82,24,25,26,72,73,74,10,6,2
.byte 80,84,88,0,4,8,66,65,64,18,17,16
.byte 42,38,34,26,22,18,56,57,58,8,9,10
.byte 0,1,2,48,49,50,24,20,16,40,36,32

.align 1
@rotating_list
.word 0x777,0x000,0x700,0x444,0x444,0x700
.word 0x000,0x777,0x007,0x111,0x111,0x007
.word 0x444,0x700,0x777,0x000,0x700,0x444
.word 0x111,0x007,0x000,0x777,0x007,0x111
.word 0x700,0x444,0x444,0x700,0x777,0x000
.word 0x007,0x111,0x111,0x007,0x000,0x777
.align 2
@square_colors
.long 0x3f800000,0x3f800000,0,0
.long 0x3f800000,0x3f800000,0x3f800000,0
.long 0x3f800000,0,0,0
.long 0x3f800000,0x3f000000,0,0
.long 0,0x3f800000,0,0
.long 0,0,0x3f800000,0

# 0 -- x
# 16 -- y
# 32 -- z
# 48 -- rx
# 64 -- ry
# 80 -- rz
# 96 -- rotation state
# 97 -- lbutton_pressed
# 98 -- rbutton_pressed
# 99 -- paint
# 100 -- l_total
# 104 -- r_total
# 108 -- cursor_pos
# 112 -- current_color
# 116 -- rotation_angle
# 256 -- colors
# 4096 -- pbuf
# 1444096 -- surface_buf
.datasize 2884096