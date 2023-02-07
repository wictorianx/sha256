#  step 1:
#  convert string to binary
#  append a single 1
#  Pad with 0’s until data is a multiple of 512, less 64 bits // 64 8
#  Append 64 bits to the end, where the 64 bits are a big-endian integer representing the length of the original input in binary
toInt = ord
def toBinary(number):
    if number>255:
        print("Number is larger than scope")
    output = ""
    for i in range(8):
        if number == 0:
            return (output[::-1])
        if number%2==0:
            output+="0"
        else:
            output+="1"
        number=int(number/2)
def completeBinary(inp):
    length = len(inp)
    if length>=8:
        print("Can't complete number to 8 bits, it is larger than 7 bits")
    appendage = 8-length
    zeros = ""
    for i in range(appendage):
        zeros+="0"
    return zeros+inp
def bin8(inp):
    return completeBinary(toBinary(inp))
def strToBinary(inp):
    output=""
    for i in range(len(inp)):
        output+=(bin8(toInt(inp[i])))+" "
    output+=(bin8(toInt(inp[i])))
    return output
def step01(input_string):
    output = strToBinary(input_string)+" 10000000"
    return strToBinary(input_string)+" 10000000"
def oLen(i):
    l = len(i.split(" "))
    return l
def padnum(inp):
    l = oLen(inp)
    c = l
    while True:
        if ((c+8)%64==0):
            return c-l
        c+=1
def pad(inp, num):
    for i in range(num):
        inp+=" 00000000"
    return(inp)#, len(inp.split(" "))
def l2bigEndian(inp):
    #input is always 64 bits long
    l = len(inp)
    f = format(l,"064b")
    o=""
    for i in range(8):
        for j in range(8):
            o+=f[i*8+j]
        o+=" "
    return (o[:len(o)-1])

def step1(inp):
    inp = "hello world"     
    output = step01(inp)    
    length = padnum(output)  
    v0 = pad(output, length)
    plus = l2bigEndian(inp) 
    print(f"{v0} {plus}")   

