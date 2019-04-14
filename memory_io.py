
ir = 'latch_3_ir_out'
not_ir = 'not_opcode_latch_3'

for i in range(9):
    out = 'and andaddr'+str(i)+'('
    for j in range(16): 
        if i == 0: 
            out = out + (not_ir+'['+str(j)+'],')  
        if i == 1: 
            if j == 0: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],')
        if i == 2: 
            if j == 1: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],')
        if i == 3: 
            if j == 1 or j == 0: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],')
        if i == 4: 
            if j == 2: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],')  
        if i == 5: 
            if j == 2 or j == 0: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],')  
        if i == 6: 
            if j == 2 or  j == 1: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],') 
        if i == 7: 
            if j == 2 or j == 1 or j == 0: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],')  
        if i == 8: 
            if j == 3: 
                out = out + (ir+'['+str(j)+'],')
            else:
                out = out + (not_ir+'['+str(j)+'],') 
    out = out+');'
    print(out)
        