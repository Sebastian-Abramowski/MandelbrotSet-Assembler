	.data
base_address: .word 0x10010000	# base address of the Bitmap Display
pixel_size:   .word 3      	# pixel size (in bytes)
width:        .word 512   	# width of the Bitmap Display (in pixels)
height:       .word 512
magic_number:	.word 2048
fin:	.asciz "black.bmp"
fout:	.asciz "output.bmp"
sth_went_wrong:	.asciz "Something went wrong with opneing your file"
BitMapFileHeader:	.space 14
BitMapInfoHeader:	.space 40
addr:	.space 786432		# IT WAS JUST FOR TESTING and you can't do it that way, in the main program
# it is dynamically allocated


	
	.text
	.global main
main:	
	li a0, 10
	li a1, 500
	li a2, 0
	li a3, 255
	li a4, 0
	jal ra, draw_pixel_on_bmp
	

	b open_source_file
	b terminate

testing_fixed_point_rep:
	li t4, 15
	li t0, 100              	# some number to multiply
	li a3, 0x00006000     		# multiply by 0.75
	mul t0, t0, a3          
	srl t0, t0, t4
	
	li a7, 1
	mv a0, t0
	ecall

	ret

draw_pixel_on_bmp:
	# a0 - x_coridnate, a1 - y_cordinate, a2 - red component, a3 - green component, a4 - blue component
	
	li t4, 512
	mv t0, a0
	sub t1, t4, a1 # Mapping to the bitmap's coordinate system
	
	# Calculate the memory address of the pixel
	li t2, 512   		 	# width of bitmap
	mul t1, t1, t2	 		# y * width
	add t1, t1, t0 	 		# y * width + x
	li t2, 3      	 		# pixel size in bytes
	mul t1, t1, t2	 		# (y * width + x) * pixel size
	la t3, addr
	add t0, t1, t3 	 		# Add base address of buffer to byte offset
	
	# Set pixel color to red (255, 0, 0)
	sb a4, (t0)    			# Write blue component to byte 3 
	sb a3, 1(t0)  	 		# Write green component to byte 2
	sb a2, 2(t0)   			# Write red component to byte 1
	
	ret

open_source_file:
	li a7, 1024
	la a0, fin
	mv a1, zero
	ecall
	
	li t0, -1
	beq a0, t0, open_error
	mv s0, a0
read_headers:
	li a7, 63
	mv a0, s0
	la a1, BitMapFileHeader
	li a2, 14
	ecall
	
	li a7, 63
	mv a0, s0
	la a1, BitMapInfoHeader
	li a2, 40
	ecall

close_source_file:
	li a7, 57
	mv a0, s0
	ecall
	
	
	
open_dest_file:
	li a7, 1024
	la a0, fout
	li a1, 1
	ecall
	
	mv s0, a0
	
write_headers:
	li a7, 64
	mv a0, s0
	la a1, BitMapFileHeader
	li a2, 14
	ecall
	
	li a7, 64
	mv a0, s0
	la a1, BitMapInfoHeader
	li a2, 40
	ecall

write_table:
	li a7, 64
	mv a0, s0
	la a1, addr
	li a2, 786432
	ecall

close_dest_file:
	li a7, 57
	mv a0, s0
	ecall

terminate:
	li a7, 10
	ecall
	

open_error:
	li a7, 4
	la a0, sth_went_wrong
	ecall
	
	b terminate

# This function was made for testing purposes of function for drawing and generating colours, it can come in handy in the future
just_testing:
	mv s6, ra
	li t5, 257
loop_x:
	li t6, 1
loop_y2:
	la t2, height
	lw t2, (t2)
	sub t2, t2, t5
	mv a0, t2
	#jal ra, generate_colour
	mv a2, a0
	mv a0, t5
	mv a1, t6	
	
	#jal ra, draw_pixel
	
	addi t6, t6, 1
	
	la t2, height
	lw t2, (t2)
	blt t6, t2, loop_y2
	
	addi t5, t5, 1	
	bgt t5, t2, end_loop2
	b loop_x
end_loop2:
	jr s6
	
