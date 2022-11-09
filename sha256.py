import sqlite3
a = 0x6a09e667
b = 0xbb67ae85
c = 0x3c6ef372
d = 0xa54ff53a
e = 0x510e527f
f = 0x9b05688c
g = 0x1f83d9ab
h = 0x5be0cd19
zeros32 = ""
for x in range (32):
    zeros32.append("0")
chunk48 = []
for y in range(48):
    chunk48.append (zeros32)

constants = """0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5 0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
0xd807aa98 0x12835b01 0x243185be 0x550c7dc3 0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc 0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7 0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13 0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3 0xd192e819 0xd6990624 0xf40e3585 0x106aa070
0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5 0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208 0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2"""
constants = constants.split(" ")
#print(h7)
def tobx(x):    
    res = ""
    #find multiple of 2
    while True:
        x = int(x)
        res+=str(x%2)
        x/=2
        if x == 0.5:
            res = res[::-1]
            r = 8- ((len(res)+8) % 8)
            a = ""
            for i in range(r):
                a+="0"
            res = a+res
            f=[]
            for a in range(int(len(res)/8)):
                f.append("")
                for b in range(8):
                    f[a]+=res[b+8*a]
            return(f)
                    


            
def tob(d):
    liste=[128,64,32,16,8,4,2,1]
     #convert decimal number ex. 2 to binary ex. 00000010 (8 bit only)
    o = "" 
    for i in liste:
        if d>=i:
            o+=str(1)
            d-=i
        else:
            o+=str(0)
    return o
def convertChar(x):
    asci = ord(x)
    binary = tobx(asci)
    return(binary)
def count(x):
    #return total len of list
    o = 0
    for i in x:
        for e in i:
            o+=1
    return(o)
def calc(n):
    #return 512b/8
    #x+y+64 = 512b
    x=0
    for i in n:
        c = convertChar(i)
        x+=len(c)
    orgy = x*8
    x = orgy
    while((x+64)%512!=0):
        x+=8
    print("x orgy",x,orgy)
    xbytes = x/8
    return int(xbytes-orgy/8-1)
    #des len 384
    #wo 64 376
    #orgy 362
    
def sha256(n):
    n = str(n)
    binarylist = []
    for e in n:
        c = convertChar((e))
        for i in c:
            binarylist.append(i)
    binarylist.append(10000000)
    b512 = calc(n)
    print(b512)
    for i in range(b512):
        binarylist.append("00000000")
    binarylist+=(endianness(len(n)))
    array = []
    step = 0
    o = ""
    blocks = []
    for i in range(int(len(binarylist)/64)):
        blocks.append([])
        for j in range(64):
            print(len(binarylist))
            blocks[i].append(binarylist[0])
            binarylist.pop(0)
    ###########

    #count=-1
    for blockid in range(len(blocks)):
        #count+=1
        array.append([])
        for i in blocks[blockid]:
            step+=1
            o+=str(i)
            if step!=0 and step%4==0:
                array[blockid].append(o)
                o=""
    for w in array:
        w+=chunk48
        for i in range(16,64):
            s0 = xor(xor(rightrotate(w[i-15] , 7) , rightrotate(w[i-15] , 18)) , rightshift(w[i-15] , 3))
            s1 = xor(xor(rightrotate(w[i- 2] , 17) , rightrotate(w[i- 2] , 19)) , rightshift(w[i- 2] , 10))
            w[i] = w[i-16] + s0 + w[i-7] + s1

            

    ############################
        


def endianness(length):
    length*= 8
    binary = tobx(length)
    print("bin",binary,len(binary))
    rem = 8 - len(binary)
    o = []
    for i in range(rem):
        o.append("00000000")
    for i in binary:
        o.append((i))
    return(o)

def rightrotate(num,times):
    #at each time delete leftmost and add the deleted to the leftmost
    for i in range(times):
        #tmp = num
        #print(len(num[0:7]))
        num = num[7]+num[0:7]
    return(num)
def rightshift(num,times):
    #at each time delete leftmost and add zero to the leftmost
    for i in range(times):
        #tmp = num
        #print(len(num[0:7]))
        num = "0"+num[0:7]
    return(num)
def xor(x,y):
    o= ""
    for i in range(8):
        if x[i] != y[i] and y[i] == 1 or x[i] == 1:
            o+="1"
        else:
            o+="0"
    return o
def AND(x,y):
    o= ""
    for i in range(8):
        o+= str(int(x[i])*int(y[i]))
    return o



def main():
    sha256("132412343546456345638947568937465987649857623984765982374659827346598273645982736598273645982736459827364598726349587263498576239845762398475629384756298374569283746592837465928376459823746")






main()
         