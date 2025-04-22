from random import randint

class base:
    def __init__(self,name,a1,a2,a3,a4):
        self.name = name
        self.sweet = a1
        self.salty = a2
        self.sour = a3
        self.bitter = a4
    """def overdone(self):
        if self.sweet > 10 or self.salty > 10 or self.sour > 10 or self.bitter > 10:
            return True"""
    def match(self, target):
        if (target["sweet"] == self.sweet)\
            and (target["salty"] == self.salty)\
            and (target["sour"] == self.sour)\
            and (target["bitter"] == self.bitter):
            return True
        else:
            return False
    def score_calc(self, mix):
        score = 100
        parameters = ["sweet","salty","sour","bitter"]
        for i in range(4):
            score -= (abs(mix[parameters[i]] - self.__dict__[parameters[i]]))*25
        return score


"""
#Additions
sugar = base("sugar",2,0,0,0)
salt = base("salt",0,2,0,0)
coffee = base("coffee",0,0,0,3)
lemon = base("lemon",0,0,2,0)
citrus = base("citrus",0,0,4,1)
"""
#Setting marks
"""choice = input("Enter Choice of base (L/D/S)    :")
if choice == 'D':
    starter.bitter += 1
    starter.sweet += 1
elif choice == 'L':
    starter.bitter += 6
elif choice == 'S':
    starter.bitter += 1"""


#Target Drink
def definetarg():
    targ = base("target",randint(0,2),randint(0,2),randint(0,2),randint(0,2))
    target = targ.__dict__
    print(target)
    return target

target = definetarg()
stage, multiplier = 1, 1
i = 0
while True:

    print("Stage", stage, "Round", i+1)
    score = 0

    #Min score for each round
    min_score = 50*stage
    print("Minimum Score for this round is", min_score)

    #Start Mixing
    starter = base("mix",0,0,0,0)
    choice = list(map(int,input("Select Tier of each ingredient (0/1/2)    :").split()))
    starter.sweet += choice[0]
    starter.salty += choice[1]
    starter.sour += choice[2]
    starter.bitter += choice[3]

    score += starter.score_calc(target)
    score *= multiplier
    print("Your score is", score, " was multiplied by", multiplier)
    
    if starter.match(target):
        score = multiplier*100
        multiplier += 4-i
        print("Guessed Correctly")
        target = definetarg()
        i, stage = 0, stage+1
    
    if score >= min_score:
        multiplier -= 1
        target = definetarg()
        i , stage = 0, stage+1
        print("Close one that")
    elif i == 3:
        print("Game Over, made it to", stage)
        break
    else:
        print("Try again")
        i+=1
