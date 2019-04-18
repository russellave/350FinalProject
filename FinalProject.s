main:
  #how to use all of the fixed registers
	#lw $r1, 0($r0) #r1 = sensor input [0:20]-->sensors in.
  #lw $r3, 2($r0) #r3 = controller input 0 is none, 1 is left, 2 is mid left, 4 is mid-right, 8 is right
  #addi $r2, $r0, 0 #r2 = sensor output [0:2]-->sensors out.
  #addi $r4, $r0, 0 #r4 = screen out 0 is splash, 1 is dummy, 2 is save/load, 4 is game, 8 is leaderboard
  #addi $r5, $r0, 0 #r5 = score out
  #addi $r6, $r0, 0 #r6 = mistake out

  addi $r7, $r0, 1 #dummy screen code

  and $r10, $r7, $r4  #is dummy code
	and $r11, $r0, $r4  #is splash code

	bne $r10, $r7, check_dummy_input
	bne $r11, $r8, check_splash_input

check_splash_input:
	lw $r3, 2($r0) #check controller input
	bne $r0, $r3, splash_transition
  j check_splash_input #stay on screen until value is inputted

splash_transition:
  addi $r4, $r0, 1 #update screen to dummy screen
  sw $r4, 3($r0) #output new screen to verilog
	j main #main will process the new screen

check_dummy_input:
  #verilog will display the hit (color the box) based on the accuracy/force
  #check_dummy input will check controller input

	lw $r3, 0($r0) controller input  	#Find controller input

  addi $r7, $r0, 1 #back mode code for controller
  addi $r8, $r0, 2 #save mode code for controller
  addi $r9, $r0, 4 #load mode code for controller
  addi $r10 $r0, 8 #play mode code for controller

	bne $r7, $r3, splash_transition // just go back to dummy screen (should do nothing)
  bne $r8, $r3, save_pattern_screen
  bne $r9, $r3, load_pattern_screen
  bne $r10, $r3, play_game


save_pattern_screen: 
#update screen
  addi $r4, $r0, 2 #update screen in processor
  sw $r4, 3($r0) #output new screen to verilog
  addi $r3, $r0, 0 #remove previous controller input so that user can select save location
  j save_pattern

load_pattern_screen: 
#update screen
  addi $r4, $r0, 2 #update screen in processor
  sw $r4, 3($r0) #output new screen to verilog
  addi $r3, $r0, 0 #remove previous controller input so that user can select save location
  j load_pattern

save_pattern:
  
  #controller to select where to save pattern (4 buttons)

  lw $r1, 0($r0)
  lw $r3, 2($r0)
  addi $r19, $r0, 0 #counter for save pattern

  #values to compare controller input to
  addi $r15, $r0, 1 #back button/end saving
  addi $r17, $r0, 2 #save first location
  addi $r18, $r0, 4 #save second location
  addi $r19, $r0, 8 #save third location

  bne $r15, $r3, splash_transition #back button hit, go to dummy screen
  and $r16, $r1, $r3 #save location chosen and there is a sensor input
  bne $r16, $r0, save_hit

  j save_pattern

save_hit:

  and $r20, $r3, $r17 #check if controller is first save location
  and $r21, $r3, $r18
  and $r22, $r3, $r19
  bne $r0, $r20, save_first_location
  bne $r0, $r21, save_second_location
  bne $r0, $r22, save_third_location

save_first_location:
  sw $r1, 500($19)
  addi $r19, $r19, 1 #incrememnt counter
  j save_pattern

save_second_location:
  sw $r1, 1000($19)
  addi $r19, $r19, 1 #incrememnt counter
  j save_pattern

save_third_location:
  sw $r1, 1500($19)
  addi $r19, $r19, 1 #incrememnt counter
  j save_pattern


load_pattern:
  
  #controller to select which pattern to load(4 buttons)

  lw $r1, 0($r0)
  lw $r3, 2($r0)
  addi $r19, $r0, 0 #counter for load pattern

  #values to compare controller input to
  addi $r15, $r0, 1 #back button/end saving
  addi $r17, $r0, 2 #save first location
  addi $r18, $r0, 4 #save second location
  addi $r19, $r0, 8 #save third location

  bne $r15, $r3, splash_transition #back button hit, go to dummy screen
  and $r16, $r1, $r3 #save location chosen and there is a sensor input
  bne $r16, $r0, load_hit

  j load_pattern

load_hit:

  and $r20, $r3, $r17 #check if controller is first load location
  and $r21, $r3, $r18
  and $r22, $r3, $r19
  bne $r0, $r20, load_first_location
  bne $r0, $r21, load_second_location
  bne $r0, $r22, load_third_location

load_first_location:
  lw $r23, 500($19)
  addi $r19, $r19, 1 #incrememnt counter
  j check_pattern

load_second_location:
  lw $r23, 1000($19)
  addi $r19, $r19, 1 #incrememnt counter
  j check_pattern

load_third_location:
  lw $r23, 1500($19)
  addi $r19, $r19, 1 #incrememnt counter
  j check_pattern

check_pattern: 
  #check first pad
  #check second pad
  #check third pad
  j load_pattern



play_game:
