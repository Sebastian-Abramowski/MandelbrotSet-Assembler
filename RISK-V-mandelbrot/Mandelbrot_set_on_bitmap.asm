
	.data
base_address: .word 0x10010000	# base address of the Bitmap Display
width:        .word 512   	# width in pixels
height:       .word 512		# height in pixels



	.text
	.global main
main:

	jal ra, generate

	b terminate_program

	
draw_pixel: 
	# a0 - x_coridnate, a1 - y_cordinate, a2 - hex_colour (e.g. 0x0000FF)    
  
   	# Calculate the memory address of the pixel
   	la  t0, base_address	# load base address
	lw  t1, width        	# load width
	
	mul t3, a1, t1       	# calculate y * width
	add t3, t3, a0       	# calculate y * width + x
	slli t3, t3, 2       	# multiply by 4 (each pixel takes 4 bytes)
	add t0, t0, t3       	# add the offset to the base address
	
	sw a2, (t0)         	# store the color in memory
	ret


from_xy_to_complex:
	# a0 - x_cordinate_of_pixel, a1 - y_cordinate_of_pixel
	# Function takes (x, y) of the pixel and calculates the (a, b) of the corresponding complex number
	# the center of the complex coordinate system is at the center of the bitmap (256, 256)
		
	# Changing to -256, 256 (Mapping values)
	la t0, width
	lw t0, (t0)
	srli t0, t0, 1		# 256
	li t1, -256
	
	blt a0, t0, minus_x
	beq a0, t0, minus_x
	
	add a0, a0, t1
	b after_changing_x
minus_x:
	sub a0, a0, t0 		# -256 + number from 0 to 255
after_changing_x:
	blt a1, t0, plus_y
	beq a1, t0, plus_y
	
	sub a1, t0, a1
	b after_changing_y
plus_y:
	sub a1, t0, a1
after_changing_y:
	
	slli a0, a0, 3  	# 22b, 10b
	slli a1, a1, 3
	
skip_to_ret:	
	ret



mandel_iter_test_number:
	# a0 - a, a1 - b, a2 - max iterations, a3 - radius ( RADIUS IN IN OUR FORMAT 22b, 10b )
	
	# the reuslt is returned in a0 - which indicates the number of iterations (it either -1 or some value lesser than max_iterations)
	mv t0, a0		# t0 = a
	mv t1, a1		# t1 = b
	
	li t4, 0		# iteration counter is set to 0
	
	#calc r^2
	mv t2, a3
	mul t2, t2, t2		# t3 = radius^2
	srai t2, t2, 10
	
loop:
	# calc z^2 (at first z = c), note that in t0, t1 you have updated values of (a, b) of copmlex number z
	
	mul t5, t0, t0		# t5 = a^2
	srai t5, t5, 10
	mul t6, t1, t1		# t6 = b^2
	srai t6, t6, 10
	sub t6, t5, t6		# t6 = a^2 - b^2 it hold a value that will be assigned to a new real part of z
	mul t5, t0, t1		# t5 = a*b
	srai t5, t5, 10
	slli t5, t5, 1		# t5 = 2a*b
	
	add t6, t6, a0		# adding the real part of c to a new real part
	add t5, t5, a1		# adding the imaginary part of to a new imaginary part
	
	mv t0, t6		# updating the real part of z and the imaginary part
	mv t1, t5
	# at this point z(n+1) = z(n)^2 + c
	
	# check if |z^2 + c| >= radius^2
	
	# new a^2 in t3
	mv t3, t0
	mul t3, t3, t3
	srai t3, t3, 10
	
	# new b^2 in t5
	mv t5, t1
	mul t5, t5, t5
	srai t5, t5, 10
	
	add t5, t5, t3		# t5 = new a^2+b^2 which is equal to the distance from the center^2
	
	bgt t5, t2, out_of_radius
	
	# update the iteratoin counter
	addi t4, t4, 1
	blt t4, a2, loop
	
	# when we are here, the number is within the radius after max interation
	li a0, -1 		# a0 equal to -1 means that our original c doesn't leave the circle - > it will have the black colour in the future
	ret
out_of_radius:
	mv a0, t4		# returns in a0 then umber of iteratons after which the complex number left the circle
	ret

	
generate_colour:
	# a0 - number of iterations
	
	# calculates the green part of the colour based on the nmber of iteratons (max number for iterations in this is set to 255)
	li t1, 0
	blt a0, t1, black
	
	# returns the hexadecimal colour in a0
	li t0, 255
	sub t0, t0, a0		# t0 = 255 - number of iteratins
	slli t0, t0, 8
	
	li t1, 255
	sub t1, t1, a0
	slli t1, t1, 4
	add t0, t0, t1

	mv a0, t0
	ret
black:
	li a0, 0
	ret
	

generate:
	mv s6, ra
	li t5, 0	# x
loop_x2:	
	li t6, 1	# y
loop_y:
	mv a0, t5
	mv a1, t6
	
	jal ra, from_xy_to_complex
	li a2, 255
	li a3, 2048 # This is 100000000000, which is 2 in our 22b, 10b fixed-point representation

	mv s1, t5
	mv s2, t6
	jal ra, mandel_iter_test_number
	mv t5, s1
	mv t6, s2
	
	jal ra, generate_colour
	mv a2, a0
	mv a0, t5 
	mv a1, t6
	
	jal ra, draw_pixel
	
	addi t6, t6, 1
	
	la t2, height
	lw t2, (t2)
	blt t6, t2, loop_y
	
	addi t5, t5, 1	
	blt t5, t2, loop_x2
end_loop:
	jr s6


terminate_program: 
    li a7, 10
    ecall	 
