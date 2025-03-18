from random import randint

class base:
    def __init__(self,name,a1,a2,a3,a4):
        self.name = name
        self.sweet = a1
        self.salty = a2
        self.sour = a3
        self.bitter = a4
    def overdone(self):
        if self.sweet > 10 or self.salty > 10 or self.sour > 10 or self.bitter > 10:
            return True
    def match(self, target):
        if (target["sweet"] - 1 <= self.sweet <= target["sweet"] + 1)\
            and (target["salty"] - 1 <= self.salty <= target["salty"] + 1)\
            and (target["sour"] - 1 <= self.sour <= target["sour"] + 1)\
            and (target["bitter"] - 1 <= self.bitter <= target["bitter"] + 1):
            return True
        else:
            return False


#Target Drink
targ = base("target",randint(0,10),randint(0,10),randint(0,10),randint(0,10))
target = targ.__dict__
#Descriptions
for i in ["sweet", "salty","sour","bitter"]:
    if target[i] <= 1:
        print("not", end = " ")
    elif target[i] <= 5:
        print("slightly", end = " ")
    elif target[i] <= 8:
        print("moderately", end = " ")
    elif target[i] < 11:
        print("Extremely",  end = " ")
    print(i)

#Additions
"""
sugar = base("sugar",2,0,0,0)
salt = base("salt",0,2,0,0)
coffee = base("coffee",0,0,0,3)
lemon = base("lemon",0,0,2,0)
citrus = base("citrus",0,0,4,1)
"""
#Start Mixing!!!
starter = base("mix",0,0,0,0)
#Setting marks
choice = input("Enter Choice of base (L/D/S)    :")
if choice == 'D':
    starter.bitter += 4
    starter.sweet += 1
elif choice == 'L':
    starter.bitter += 6
elif choice == 'S':
    starter.bitter += 1
while True:
    #ingredient adding
    ing = int(input("Choose ingredient to add (Sugar, Salt, Coffee, Lemon, Citrus):     "))
    if ing == 0:
        starter.sweet += 2
    elif ing == 1:
        starter.salty += 2
    elif ing == 2:
        starter.bitter += 3
    elif ing == 3:
        starter.sour += 2
    elif ing == 4:
        starter.sour += 4
        starter.bitter += 1
    print(starter.__dict__.values())
    if starter.overdone():
        print("EWWWWW")
        break
    if starter.match(target):
        print("CONGRATULATIONS")
        break