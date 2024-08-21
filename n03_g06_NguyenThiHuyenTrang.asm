.eqv SEVENSEG_LEFT 0xFFFF0011 		# Dia chi cua den led 7 doan trai
.eqv SEVENSEG_RIGHT 0xFFFF0010 		# Dia chi cua den led 7 doan phai
.eqv MASK_CAUSE_COUNTER 0x00000400 	# Bit 10: Counter interrupt
.eqv COUNTER 0xFFFF0013 		# Time Counter
.eqv KEY_CODE   0xFFFF0004         	# ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        	# =1 if has a new keycode?  

.data
array: .byte 	63, 6,  91, 79, 102, 109 ,125, 7, 127, 111	# tu 0 den 9
string: .asciiz "bo mon ky thuat may tinh" 
message1: .asciiz "Thoi gian hoan thanh: "
message2: .asciiz " (giay)\nToc do go trung binh: "
message3: .asciiz " (tu/phut)\n"
message4: .asciiz "Chon Yes de tiep tuc kiem tra"

.text	# bien toan cuc : k0, k1, s0, s1, s2, s3, s4

main:
	li	$k0, KEY_CODE              
	li  	$k1, KEY_READY  
	la	$s0, string	 	# s0 = dia chi cua xau string
	addi	$s1, $0, 0		# s1 = so ki tu dung
	addi	$s2, $0, 0		# s2 = so tu
	addi	$s3, $0, 0		# s3 = so lan xay ra counter interrupt
	addi	$s4, $0, 0		# s4 = ki tu truoc 
	addi	$s5, $0, 0		# s5 = dem thoi gian

	
WaitForKey: 
	lw 	$t1, 0($k1) 		# $t1 = [$k1] = KEY_READY
	nop
	beq 	$t1, $zero, WaitForKey # if $t1 == 0 then Polling
	nop

	# Enable the interrupt of TimeCounter of Digital Lab Sim
	li 	$t1, COUNTER
	sb 	$t1, 0($t1)
	
#------ vong lap doi keyboard interrupt ------------
loop: 
	lw   	$t1, 0($k1)                 	# $t1 = [$k1] = KEY_READY              
	bne  	$t1, $zero, keyboard_interrupt	# Tao keyboard interrupt khi nhan duoc ky tu tu ban phim
	addi	$v0, $0, 32			# Neu khong nhap ky tu nao => sleep 
	li	$a0, 5 				# sleep 5 ms 
	syscall
	b 	loop				# So lenh trong 1 vong lap = 6 => cu lap 5 lan thi tao 1 counter interrupt => dem 25 ms 1 counter interrupt
	nop
	
#------- keyboard interrupt khi nhan duoc ky tu tu ban phim ----------
keyboard_interrupt:
	teqi	$t1, 1				# kiem tra neu t1 = 1 (co ky tu nhap vao tu ban phim) thi ngat (thuc hien cau lenh o .ktext)
	b	loop				# Quay lai vong lap de cho doi su kien interrupt tiep theo
	nop

.ktext 0x80000180

#------ tam thoi vo hieu hoa ngat ------------
dis_int:
	li 	$t1, COUNTER 			# BUG: must disable with Time Counter
	sb 	$zero, 0($t1)

#------ kiem tra loai interrupt o thanh ghi $13 -----------
get_cause:
	mfc0 	$t1, $13 			# $t1 = Coproc0.cause
is_counter:
	li 	$t2, MASK_CAUSE_COUNTER		# if Cause value confirm Counter..
	and 	$at, $t1, $t2
	bne 	$at, $t2, keyboard_intr

#------ Counter interrupt -------------
counter_intr:
	blt	$s3, 40, continue		# Neu so lan ngat do counter = 40 => du 1s -> khoi tao lai $s3, tang bien dem thoi gian len 1s
	addi	$s3, $0, 0			# Khoi tao lai $s3 = 0
	addi	$s5, $s5, 1			# Tang bien dem thoi gian len 1s
	j	end_intr
	nop
continue:
	addi	$s3, $s3, 1			#Neu chua du 1s thi tang bien dem so lan ngat
	j 	end_intr
	nop
	
#----- xu ly keyboard interrupt -----------	
keyboard_intr:

process:					# Kiem tra ky tu nhap vao
	lb	$t0, 0($s0)			# t0 = string[i] 
	lb	$t1, 0($k0)			# t1 = ki tu nhap vao tu ban phim
	beq 	$t1, 10, end_program		# Ki tu la '\n' => in
	bne	$t0, $t1, check_space		# Neu ki tu nhap vao # string[i] -> khong tang so ki tu dung
	nop
	addi	$s1, $s1, 1			# Tang so ky tu dung
	
check_space:					# Kiem tra ki tu nhap vao co phai la ' ' khong (de xac dinh tu)
	bne	$t1, ' ', end_process		# Neu ky tu nhap vao != ' ' => khong them tu moi
	nop
	beq	$s4, ' ', end_process		# Neu co 2 dau cach lien tiep => khong them tu moi
	nop
	addi	$s2, $s2, 1			# Tang bien dem so tu da nhap
end_process:
	beq	$t0, $0, update
	addi	$s0, $s0, 1 			# Tang dia chi xau len 1
update:
	addi	$s4, $t1, 0			# Cap nhat lai ky tu truoc do
	j 	end_intr
	
# ----------------------- Ket thuc xu ly ngat --------------------------------------	
end_intr: 
	# Enable the interrupt of TimeCounter of Digital Lab Sim
	li 	$t1, COUNTER
	sb 	$t1, 0($t1)
	mtc0 	$zero, $13 			# Must clear cause register
next_pc: 
	mfc0 	$at, $14 			# $at <= Coproc0.$14 = Coproc0.epc
	addi 	$at, $at, 4 			# $at = $at + 4 (next instruction)
	mtc0 	$at, $14 			# Coproc0.$14 = Coproc0.epc <= $at
return: 
	eret					# Return from exception

#------ Ket thuc chuong trinh khi nhan ky tu Enter ------------------------
				
end_program:
	beq	$s4, ' ', print_digi_lab_sim	# neu ki tu cuoi cung khong la dau cach => them 1 tu
	beq	$s4, $0, print_digi_lab_sim	# neu khong nhap ki tu nao => s2 = 0 => in ket qua
	addi	$s2, $s2, 1
	
print_digi_lab_sim:				# in so ky tu dung ra digital lab sim
	li	$t1, 10
	div	$s1, $t1			
	mfhi	$t1 				# t1 = chữ số bên phải
	mflo	$t2				# t2 = chữ số bên trái
	
	la	$t0, array
	add	$t1, $t0, $t1			# t1 = dia chi gia tri cho sevenseg_right
	add	$t2, $t0, $t2			# t2 = dia chi gia tri cho sevenseg_left
	
	lb	$t1, 0($t1)			# t1 = gia tri cho sevenseg_right
	jal	show_7seg_right			# hien thi led ben phai
	nop
	
	lb	$t2, 0($t2)			# t2 = gia tri cho sevenseg_left
	jal	show_7seg_left			# hien thi led ben trai
	nop
	
	j	print_rate
show_7seg_right: 				# in ket qua led ben phai
	li 	$t0, SEVENSEG_RIGHT		# assign right port's address
	sb 	$t1, 0($t0) 			# assign new value for right led
	nop
	jr 	$ra
	nop	
show_7seg_left: 				# in ket qua led ben trai
	li 	$t0, SEVENSEG_LEFT 		# assign left port's address
	sb 	$t2, 0($t0) 			# assign new value for left led
	nop
	jr 	$ra
	nop	

print_rate:					# in ra thoi gian va toc do go
	li	$v0, 4
	la	$a0, message1
	syscall					# in ra dong "Thoi gian hoan thanh: "
	
	li	$v0, 1
	addi	$a0, $s5, 0
	syscall					# in ra thoi gian
	
	li	$v0, 4
	la	$a0, message2
	syscall					# in ra dong " (giay)\nToc do go trung binh: "
	
	li	$v0, 1
	li	$a0, 60
	mult	$s2, $a0
	mflo	$s2
	div	$s2, $s5
	mflo	$a0				# toc do go 1 phut = so tu * 60 / thoi gian
	syscall					# in ra toc do go
	
	li	$v0, 4
	la	$a0, message3
	syscall					# in ra dong " (tu/phut)"
	
#----- Kiem tra xem co muon tiep tuc chuong trinh khong ------	
check_back:
	li	$v0, 50
	la	$a0, message4
	syscall
	
	beq	$a0, 0, main
	beq	$a0, 1, end
end:	
