from app.db import Question
import json

escape_characters = [':', '?', ' '] # characters to divide attributes from template string

class Hero:
    name = ""
    str = 0
    str_per_lvl = 0.0
    agi = 0
    agi_per_lvl = 0.0
    int = 0
    int_per_lvl = 0.0
    
    armor = 0.0
    movementspeed = 0
    melee = true
    attack_range = 0

# Generate questions, based on input data in json-file
# Example: "What is the base strength of the $$hero.name?"
# will generate appropriative question for all heroes, that contains in jsonFile

# Variables: 
# All values are prepended with $$ sign

# hero.name
# hero.str
# hero.str_lvl
# hero.agi
# hero.agi_lvl
# hero.int
# hero.int_lvl

# hero.armor
# hero.movementspeed
# hero.melee
# hero.attack_range

def getHeroes(jsonFile=None):
    if jsonFile is None:
        print("No input file with heroes")
        return
    heroes = []
    with open(jsonFile) as data_file:    
        data = json.load(data_file)
        for d in data['heroes']:
            # d is a hero dictionary now
            h = Hero()
            
            # basic stats
            h.name = d.get("name", None)
            h.str = d.get("str", None)
            h.str_per_lvl = d.get("str_per_lvl", None)
            h.agi = d.get("agi", None)
            h.agi_per_lvl = d.get("agi_per_lvl", None)
            h.int = d.get("int", None)
            h.int_per_lvl = d.get("int_per_lvl", None)
            
            # stats
            h.armor = d.get("armor", None)
            h.movementspeed = d.get("movementspeed", None)
            h.melee = d.get("melee", None)
            h.attack_range = d.get("attack_range", None)
            
            heroes.append(h)
    return heroes

def generateQuestionFromTemplate(self, templateStringEN=None, templateStringRU=None, jsonFile="./heroes.json", outputJson="./output.json"):
    
    # [1] getting heroes from json
    heroes = self.getHeroes(jsonFile)
    
    # [2] creating questions instances
    questions = []
    for h in heroes:
        # getting attributes keys from template string
        
        templateWhatever = ""
        if templateStringEN is None:
            if templateStringRU is None:
                print("No template provided")
                return
            else:
                templateWhatever = templateStringRU
        else:
            templateWhatever = templateStringEN
        
        attributes = []
        attr_count = templateWhatever.count("$$")
        last_pos = 0 # last $$ position
        for i in range(0, attr_count):
            pos = templateWhatever.find("$$", last_pos)
            # finding first occuarence of escape character
            min_ch_pos = len(templateWhatever) - 1
            for ch in escape_characters:
                ch_pos = templateWhatever.find(ch, pos)
                min_ch_pos = min(ch_pos, min_ch_pos)
                
            length = min_ch_pos - pos
            attr_name = templateWhatever[pos + 2: length - 2]
            attributes.append(attr_name)
        
        # creating ENGLISH template string
        if templateStringEN is not None:
            template_string_en = templateStringEN
            for i in range(0, attr_count):
                template_string_en = template_string_en.replace("$$" + attributes[i], "{}")
            
            for i in range(0, attr_count):
                variable = h.value(attributes[i]) # getting attribute by key
                template_string_en = template_string_en.format(variable) # replacing each {} with actual value
            
        # creatomg RUSSIAN template string
        if templateStringRU is not None:
            template_string_ru = templateStringRU
            for i in range(0, attr_count):
                template_string_ru = template_string_ru.replace("$$" + attributes[i], "{}")
            
            for i in range(0, attr_count):
                variable = h.value(attributes[i]) # getting attribute by key
                template_string_ru = template_string_ru.format(variable) # replacing each {} with actual value
        
        # create question
        q = Question()
        q.text_en = template_string_en
        q.text_ru = template_string_ru
        
        print("English: " % template_string_en)
        print("Russian: " % template_string_ru.encode('utf8'))
        
        questions.append(q)
    
    # [3] serialize questions to json
    # [4] save to file
    return questions
        
if (self == "__main__"):
    sys.path.append('/home/zykis/DotaAsker/server/')
    sys.path.append('/home/zykis/DotaAsker/server/flask/lib/python2.7/site-packages/')
    
    sys.path.append('/home/artem/projects/DotaAsker/server/')
    sys.path.append('/home/artem/projects/DotaAsker/server/flask/lib/python2.7/site-packages/')
    
    generateQuestionFromTemplate(templateStringEN="What is the base strength of the $$hero.name?", templateStringRU="Чему равна базовая сила $$hero.name?")