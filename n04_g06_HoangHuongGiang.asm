.eqv  HEADING    0xffff8010   
.eqv  MOVING     0xffff8050    
.eqv  LEAVETRACK 0xffff8020    
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv  MASK_CAUSE_KEYMATRIX 0x00000800     # Bit 11: Key matrix interrupt 
.data
	script0: .asciiz "161,1,3120,19,1,3120,90,0,1000,180,1,3000,90,0,1000,0,1,3000,90,1,1000,180,0,1500,270,1,1000,180,0,1500,90,1,1000,90,0,1500,0,1,3000,270,0,1000,90,1,2000,180,0,3000,90,0,1800,0,1,3000,147,1,3580,0,1,3000,90,0,2000,199,1,3150,90,0,2000,341,1,3150,199,0,2100,90,1,1330,161,0,1050,90,0,1200,0,1,3000,153,1,3200,27,1,3200,180,1,3000"
	script4: .asciiz "71,1,1700,37,1,1700,17,1,1700,0,1,1700,341,1,1700,320,1,1700,295,1,1700,180,1,8820,90,0,7000,270,1,2300,345,1,4520,15,1,4000,75,1,2500,90,0,2000,180,1,8820,90,1,2666,0,0,4410,270,1,2666,0,0,4410,90,1,2666"
	script8: .asciiz "180,1,4800,0,0,2400,90,1,2500,180,0,2400,0,1,4800,90,0,1200,180, 1, 3600, 157, 1,750,135,1,750,90,1,1000,45,1,750,23,1,750,0,1,3600,90,0,3600,180,0,700,315,1,1000,270,1,1000,225,1,1000,180,1,1000,135,1,1000,90,1,1000,135,1,1000,180,1,1000,225,1,1000,270,1,1000,315,1,1000,180,0,700,90,0,4700,0,1,4800,270,0,1500,90,1,3000"
	String0wrong: .asciiz "Postscript so 0 sai do "
	String4wrong: .asciiz "Postscript so 4 sai do "
	String8wrong: .asciiz "Postscript so 8 sai do "
	StringAllwrong: .asciiz "Tat ca Postscript deu sai"
	Reasonwrong1:	.asciiz "loi cu phap"
	Reasonwrong2:	.asciiz "thieu bo so"
	EndofProgram: .asciiz "Chuong trinh ket thuc!"
	ChooseAnotherScript: .asciiz "Vui long chon postscipt khac"
	NotCheck: .asciiz "Chua check xong. Xin hay doi mot lat"
	Done:	.asciiz "Da cat xong!"
	Choose:	.asciiz "----------------------MENU-----------------------\nVui long chon phim tren Digital Lab Sim\n0: VIETNAM\n4: DCE\n8: HUST\nc: Thoat chuong trinh"
	NotNormal: .asciiz "Xay ra loi bat thuong!"
	Array: .word
	
.text
main:		li $v0, 55
		la $a0, Choose
		li $a1, 1
		syscall
		li $t1, IN_ADDRESS_HEXA_KEYBOARD
		li $t2, OUT_ADDRESS_HEXA_KEYBOARD
		li $t3, 0x80 # bit 7 of = 1 to enable interrupt
		sb $t3, 0($t1)
		la $k0, Array
		li $s0, 4
		div $k0, $s0 #lay dia chi mang/4
		mfhi $s1 #gan s1 = dia chi mang mod 4
		beqz $s1, First_Ck #Neu s1 = 0=> dia chi mang chia het cho 4 => check
		sub $s0, $s0, $s1 #s0 = 4 - dia chi mang mod 4
		add $k0, $k0, $s0 #k0 = dia chi + (4 - dia chi mod4) => Dia chi o nho tiep theo
First_Ck:	jal StringCheck
Loop: 	nop
	addi $v0, $zero, 32
	li $a0, 200
	syscall
	nop
	nop
	b Loop # Wait for interrupt
	nop
	b Loop
end_of_main:	li $v0, 55
		la $a0, EndofProgram
		li $a1, 1
		syscall
		li $v0, 10
		syscall
#------------------------------
#StringCheck: Kiem tra du lieu dau vao
#a0: dia chi cac chuoi
#t7, t8, t9: giu gia tri 1 neu chuoi 0, 4, 8 sai
#a1: bit gia tri dung sai
#s0: dem so chuoi sai
#k0: dia chi mang
#------------------------------
StringCheck:	li $s0, 0
SC_InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $ra,0($sp)  
mainSC:		la $a0, script0
        	jal Check
        	addi $t7, $a0, 0 #t7 = gia tri dung/sai cua chuoi 0
        	la $a0, String0wrong #Gan a0 = message khi chuoi 0 sai
        	jal WrongMessage
        	nop
Check_script4: 	la $a0, script4
        	jal Check
        	addi $t8, $a0, 0 #t8 = gia tri dung/sai cua chuoi 4
        	la $a0, String4wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
       		nop
Check_script8:	la $a0, script8
        	jal Check
        	addi $t9, $a0, 0 #t9 = gia tri dung/sai cua chuoi 8
        	la $a0, String8wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
       		nop
       		blt $s0, 3, SC_ResSR
       		li $a1, 3
       		la $a0, StringAllwrong
       		jal WrongMessage
       		j end_of_main
SC_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_StringCheck: 	addi $t6, $zero, 1 #luu t6 = 1 => da hoan thanh check
			jr $ra    
#------------------
WrongMessage:	li $v0, 59
		beq $a1, 0, end_of_WN
		beq $a1, 2, Reason2
		beq $a1, 3, Reason3
		la $a1, Reasonwrong1 #sai do ly do 1
		j call
Reason2:	la $a1,Reasonwrong2 #sai do ly do 2
		j call
Reason3:	li $v0, 55
		li $a1, 0
call:		addi $s0, $s0, 1
		syscall
end_of_WN:	jr $ra  

#---------------
#Check: Kiem tra 1 chuoi co vi pham hay khong
#a0: dia chi ban dau cua script
#a1: Gia tri dung sai
#a2: byte duoc load
#a3: dem so dau phay
#v0: byte truoc byte hien tai
#Loi sai : Co chu hoac ky hieu ( 1), Khong du bo so(2)
#---------------
Check:		li $a3, 0 #gan a3 = 0
		lb $a2, 0($a0) 
		beq $a2, 0x2C, wrong1 #khi ky tu dau tien la ',' thi sai
loop_Check:	lb $a2, 0($a0)
		beq $a2, 0x2C, is_comma #Neu a2 = ',' thi thuc hien cong so dau phay
		beq $a2, 0x00, end_string #Neu a2 = /0 thi thuc hien ket thuc string
		beq $a2, 0x20, next_loop #neu a2 = dau cach thi bo qua
		blt $a2, 0x30, wrong1 #neu a2 < 30 => a2 la ky tu khac chu so => loi
		bgt $a2, 0x39, wrong1 #neu a2 > 39 => a2 la ky tu khac chu so => loi
		j next_loop
		nop
is_comma:	beq $v0, 0x2C, wrong1
		nop
		addi $a3, $a3, 1 #so dau phay cong 1
next_loop:	addi $a0, $a0, 1 #Tang a0 + 1 => chi den byte tiep theo
		addi $v0, $a2, 0 #v0 giu byte truoc 
		j loop_Check
		nop
wrong1:		li $a1, 1 #gan a1 = 1, day sai do xuat hien chu hoac ky hieu
		li $a0, 1
		jr $ra #Quay ve ctr con goc
wrong2: 	li $a1, 2 #a1= 2, day sai do thieu bo so
		li $a0, 2
		jr $ra
end_string:	beq $v0, 0x2C, wrong1 #Neu ky tu cuoi cung cua chuoi la , => sai
		li $a2, 3 #gan a2 = 3
		div $a3, $a2 #a3/3 
		mfhi $a2 #a2 = a3 mod 3 = so dau phay mod 3
		bne $a2,2, wrong2 #neu a2 != a1 != 2 => so dau phay khong chia 3 du 2 => khong du bo so
		addi $a0, $k0, 0 #a1 = k0 => Chuoi dung va a0 chua dia chi mang cua chuoi dang xet
		addi $a3, $a3, 3 #a3= a3 + 1 + 2( A3 + 1 = so cac so co trong chuoi, 
		#+1 de chua 1 o luu gia tri 0/1(da chuyen thanh mang/chua chuyen thanh mang)
		#+1 de chua 1 o luu gia tri ket thuc mang
		sll $a3, $a3, 2 #a3= a3*4
		add $k0, $k0, $a3 #k0 chi den dia chi moi de nhan vao chuoi tiep theo neu chuoi dung
		li $a2, -1
		sw $a2, -4($k0)
		li $a1, 0
		jr $ra 
#-------------------------
.ktext 0x80000180
Check_Cause:	mfc0  $t4, $13
		li    $t3, MASK_CAUSE_KEYMATRIX # if Cause value confirm Key.. 
        	and   $at, $t4,$t3 
        	beq   $at,$t3, is_Check_ready #Neu ngat do ban phim thi tiep tuc check
ReasonNotNormal: 	li $v0, 55
        		la $a0, NotNormal #thong bao loi bat thuong
        		li $a1, 0
        		syscall
       			li $v0, 10
       			syscall
is_Check_ready:	   	beq $t6, 1, IntSR
			addi $sp, $sp, 4
			sw $v0, 0($sp)
			addi $sp, $sp, 4
			sw $a0, 0($sp)
			addi $sp, $sp, 4
			sw $a1, 0($sp)
			li $v0, 55
			la $a0, NotCheck #Chua check xong
			li $a1, 1 
			syscall
			j ResValueforcheck
IntSR: 			
	li $t3, 0x81 # check hang 1: 0,1,2,3
	sb $t3, 0($t1) # Luu vao $t1
	lb $a0, 0($t2) # Doc phim
	beq $a0, 0x11, Found_script0 #Neu chon 0 thi chay den Found_Script0
	bne $a0, 0x00, PleaseAnother #Neu nhan duoc so khac 0 thi can doi postscript khac
	li $t3, 0x82 # check hang 2: 4, 5, 6, 7
	sb $t3, 0($t1) 
	lb $a0, 0($t2) # Doc
	beq $a0, 0x12, Found_script4 #Neu chon 4 thi nhay den Found_script4
	bne $a0, 0x00, PleaseAnother #Neu so khac 4 => Doi
	li $t3, 0x84 # check hang 3: 8, 9, A, B
	sb $t3, 0($t1) 
	lb $a0, 0($t2) # Doc phim
	beq $a0, 0x14, Found_script8 #Neu chon 8 thi nhay den Found_script8
	bne $a0, 0x00, PleaseAnother #Neu so khac 8 => Doi 
	li $t3, 0x88 # check hang 4: C, D, E, F
	sb $t3, 0($t1) 
	lb $a0, 0($t2) # Doc phim
	beq $a0, 0x18, end_of_main #neu chon c thi ket thuc ctr
	bne $a0, 0x00, PleaseAnother
	beq $a0, 0x00, ReasonNotNormal #Khong nhan duoc gia tri nao => loi bat thuong
#----------------------------
#a1: Luu dia chi mang neu chuoi dung, 1/2 neu chuoi sai => Lay du lieu tu $t7, $t8,$t9
#a0: Gan dia chi scriptXwrong(duoc goi neu chuoi sai)
#s3: Gan dia chi chuoi
#----------------------------
Found_script0: add $a1, $zero, $t7 #luu dia chi mang 0(neu dung ) tu t7 vao a1
		la $a0, String0wrong #gan a0 dia chi thong bao neu chuoi 0 sai
		la $s3, script0 #Gan s3 dia chi cua chuoi
		j Found #Nhay den ham xu ly
Found_script4: add $a1, $zero, $t8 
		la $a0, String4wrong
		la $s3, script4
		j Found
Found_script8: add $a1, $zero, $t9 
		la $a0, String8wrong
		la $s3, script8
Found:	beq $a1, 1, WrongScript
	beq $a1, 2, WrongScript #Neu a1 = 1 hoac 2 thi chuoi sai => Nhay den WrongScript
	addi $a0, $s3, 0 #nap dia chi stringX vao $a0
	lw $s1, 0($a1)
	addi $a2, $a1, 0 #luu dia chi lai vao a2 do thanh ghi a1 bi thay doi khi goi den StringSolve
	bne $s1, 0, StringRun #Nếu chuỗi chưa chuyển thành số thì nhảy đến hàm chuyển #Nếu không thì chạy SCRIPT
	jal StringSolve	
StringRun:	addi $s0, $a2, 4 #Chay mang bat dau tu phan tu t2
		jal MarsbotControl #Trinh dieu khien Marsbot
		j next_pc
WrongScript: 	li $v0, 59
		beq $a1, 2, WS_Reason2
		la $a1, Reasonwrong1 #sai do ly do 1
		j WS_call
WS_Reason2:	la $a1,Reasonwrong2 #sai do ly do 2
WS_call:	syscall #voi a0 da duoc gan la thong bao chuoi sai tu truoc
#------------------------------------
PleaseAnother:		li $v0, 55
			la $a0, ChooseAnotherScript
			li $a1, 1
			syscall #In thong bao xin chon vi tri khac
			j return
next_pc: 	mfc0    $at, $14        # $at <=  Coproc0.$14 = Coproc0.epc 
		addi    $at, $at, 4     # $at = $at + 4   (next instruction) 
		mtc0    $at, $14        # Coproc0.$14 = Coproc0.epc <= $at   
		beq $t6, 0, ResValueforcheck
		j return
ResValueforcheck:	lw $a1, 0($sp)
			addi $sp, $sp, -4
			lw $a0, 0($sp)
			addi $sp, $sp, -4
			lw $v0, 0($sp)
			addi $sp, $sp, -4
return: 	eret # Return from exception

#-----------------
#StringSolve: Xu ly bien doi chuoi thanh so
#a0: dia chi chuoi(Tham so truyen vao)
#a1: dia chi mang (Tham so truyen vao)
#s0: byte duoc load
#s1: dem so truoc ','
#s2: So da duoc xu ly
#s3: 10
#s4: Dem tu 1 - s1 khi chuyen so
#s5: 10^i
#------------------
StringSolve:	
		li $s0, 1 #Gan gia tri s0 khac 0 de bat dau ctr 
		li $s3, 1
		sw $s3, 0($a1)	#Luu bit 1 vao pt dau tien mang de xac dinh chuoi da duoc chuyen
		addi $a1, $a1, 4 #Luu gia tri tu pt thu 2
mainSS:		li $s3, 10
		li $s2, 0
		li $s1, 1 #Bien dem bat dau tu 1
		li $s5, 1 #luu s5 = 10^0
SS_loop:	lb $s0, 0($a0) #s0 = byte duoc xet
		beq $s0, 0x20, SS_nextbyte #Neu gap dau ' ' thì bỏ qua
		beq $s0, 0x2C, Into_Array	#Neu gap dau ',' thi chuyen thanh so
		beq $s0, 0x00, Into_Array	#Neu gap ket thuc chuoi thì thuc hien chuyen thanh so lan cuoi
		addi $sp, $sp, 1
		sb $s0, 0($sp) #luu byte vao stack
		addi $s1, $s1, 1 #dem so chu so cua so do
SS_nextbyte:	addi $a0, $a0, 1
		j SS_loop
Into_Array:	li $s4, 1
		addi $v0, $s0, 0 #luu byte dau hieu dan toi chuyen sang so (0x2C, 0x00). Voi 0x00 thi de ket thuc ctr
Into_loop:	beq $s4, $s1, SaveArray #Neu da du so cac chu so thi luu vao mang
		lb $s0, 0($sp)
		addi $sp, $sp, -1
		addi $s0, $s0, -48 #Doi gia tri $s0 sang so
		mult $s0, $s5
		mflo $s0 #s0 = s0*10^i								
		add $s2, $s0, $s2 #s2 + s0
		#Next
		mult $s5, $s3 #s5 nhan 10 sau moi lan chuyen
		mflo $s5 #s5 = 10^(i+1)
		addi $s4, $s4, 1
		j Into_loop
SaveArray:	sw $s2, 0($a1)
		add $a1, $a1, 4	
		addi $a0, $a0, 1
		beq $v0, 0x00, end_of_StringSolve #neu v0 = 0x00 => ket thuc cau
		j mainSS
#______________
end_of_StringSolve: 	jr $ra  
#----------------------------
#MarsbotControl	: Trinh dieu khien Marsbot
#s0: dia chi mang ( luu truoc khi vao ctrinh con)
#a1: rotate - goc xoay
#a0: tg chay
#a2: bit track - untrack
#-------------------------
MarsbotControl:
MB_InSR:	addi  $sp,$sp,4    # Save $ra because we may change it later 
        	sw    $ra,0($sp) 
FirstRun:	li $a1, 165
		li $a0, 10000
		jal ROTATE
		nop
		jal GO
		nop
		addi    $v0,$zero,32    # Dua Marsbot ra giua man hinh de de nhin hon       
        	syscall 
TakeData:	lw $a1, 0($s0) #Load goc xoay
		addi $s0, $s0, 4
		beq $a1, -1, MB_EndScript #Neu gia tri load duoc = -1 => ket thuc
		lw $a2, 0($s0) #load bit track/untrack
		addi $s0, $s0, 4
		lw $a0, 0($s0) # Load tg chay
		addi $s0, $s0, 4
MB_Run:		jal ROTATE
		nop
		beq $a2, 0, Leave 	#Neu a2 = 0 => Khong luu lai vet => thuc hien di chuyen luon
		jal     TRACK           # and draw new track line 
        	nop  
Leave:		addi    $v0,$zero,32        
        	syscall 	#a0 la tham so thoi gian
       		jal     UNTRACK         # keep old track 
        	nop 
MB_nextData:  	j TakeData  #Tiep tuc lay du lieu tu mang
MB_EndScript:	jal STOP #Dung
MB_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
        	li $v0, 55
		la $a0, Done
		li $a1, 1
		syscall #Thong bao da ve xong
end_of_MarsbotControl:	jr $ra		

#----------------------------------------------------------- 
# GO procedure, to start running 
# param[in]    none 
#----------------------------------------------------------- 
GO:     li    $at, MOVING     # change MOVING port 
        addi  $k0, $zero,1    # to  logic 1, 
        sb    $k0, 0($at)     # to start running 
        nop         
        jr    $ra 
        nop 
#----------------------------------------------------------- 
# STOP procedure, to stop running 
# param[in]    none 
#----------------------------------------------------------- 
STOP:   li    $at, MOVING     # change MOVING port to 0 
        sb    $zero, 0($at)   # to stop 
        nop 
        jr    $ra 
        nop 
#----------------------------------------------------------- 
# TRACK procedure, to start drawing line  
# param[in]    none 
#-----------------------------------------------------------              
TRACK:  li    $at, LEAVETRACK # change LEAVETRACK port 
        addi  $k0, $zero,1    # to  logic 1, 
        sb    $k0, 0($at)     # to start tracking 
        nop 
        jr    $ra 
        nop         
#----------------------------------------------------------- 
# UNTRACK procedure, to stop drawing line 
# param[in]    none 
#-----------------------------------------------------------         
UNTRACK:li    $at, LEAVETRACK # change LEAVETRACK port to 0 
        sb    $zero, 0($at)   # to stop drawing tail 
        nop 
        jr    $ra 
        nop 
#----------------------------------------------------------- 
# ROTATE procedure, to rotate the robot 
# param[in]    $a1, An angle between 0 and 359 
#                   0 : North (up) 
#                   90: East  (right) 
#                  180: South (down) 
#                  270: West  (left) 
#-----------------------------------------------------------  
ROTATE: li    $at, HEADING    # change HEADING port 
        sw    $a1, 0($at)     # to rotate robot 
        nop 
        jr    $ra 
        nop 
