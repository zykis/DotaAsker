# -*- coding: utf-8 -*-


escape_characters = [':', '?', ' '] # characters to divide attribute_names from template string

class Hero:
    name = ""
    str = 0
    str_per_lvl = 0.0
    agi = 0
    agi_per_lvl = 0.0
    int = 0
    int_per_lvl = 0.0
    
    armor = 0.0
    movement_speed = 0
    melee = True
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

def main(self):
    templates = self.getTemplates()
    # for t in templates:
        # self.generateQuestionsFromTemplate(

def getHeroes(jsonFile=None):
    if jsonFile is None:
        print("No input file with heroes")
        return
    heroes = []
    with open(jsonFile) as data_file:    
        data = json.load(data_file)
        for d in data:
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
            h.movement_speed = d.get("movement_speed", None)
            h.melee = d.get("melee", None)
            h.attack_range = d.get("attack_range", None)
            
            heroes.append(h)
    return heroes

def getTemplates(templatesFile="./templates.txt"):
    lines = []
    questions = []
    with open(templatesFile, 'r') as file:
        lines = file.readlines()
        lines = [l for l in lines if not (l.strip().startswith('#') or l.strip() == "")] # ignore comments
        
    for l in lines:
        if l.startswith('EN: '):
            q = Question()
            q.text_en = l[len('EN: '):]
        elif l.startswith('RU: '):
            text_ru = l[len('RU: '):]
            if q is None:
                print ("English variation for question: {} IS MISSING".format(text_ru))
                return None
            else:
                q.text_ru = text_ru
                questions.append(q)
        
    print('templates count: %d' % len(lines))
    print(lines)
    return questions

def generateQuestionsFromTemplate(templateStringEN=None, templateStringRU=None, jsonFile=None, outputJson="./output.json"):
    # [1] getting heroes from json
    heroes = getHeroes(jsonFile)
    
    # [2.1] getting attribute_names
    templateWhatever = ""
    if templateStringEN is None:
        if templateStringRU is None:
            print("No template provided")
            return
        else:
            templateWhatever = templateStringRU
    else:
        templateWhatever = templateStringEN
    
    attribute_names = []
    attr_count = templateWhatever.count("$$")
    last_pos = 0 # last $$ position
    for i in range(0, attr_count):
        pos = templateWhatever.find("$$", last_pos)
        # finding first occuarence of escape character
        min_ch_pos = len(templateWhatever) - 1
        print(templateWhatever)
        print(len(templateWhatever))
        for ch in escape_characters:
            ch_pos = templateWhatever.find(ch, pos)
            if ch_pos != -1:
                print('character {} found at position: {}'.format(ch, ch_pos))
                min_ch_pos = min(ch_pos, min_ch_pos)
            
        length = min_ch_pos - pos - len('$$')
        attr_name = templateWhatever[pos + 2: pos + 2 + length]
        print ('pos:{} len:{} attr_name:{}'.format(pos, length, attr_name))
        attribute_names.append(attr_name)
        
    # [2.2] dividing attribute_names by classes
    hero_attribute_names = []
    item_attribute_names_names = []
    tournament_attribute_names = []
    
    for a in attribute_names:
        first = a.split('.')[0]
        second = a.split('.')[1]
        if first == 'hero':
            hero_attribute_names.append(second)
        elif first == 'item':
            item_attribute_names.append(second)
        elif first == 'tournament':
            tournament_attribute_names.append(second)
    
    # [3] creating questions instances
    # [3.1] heroes
    questions = []
    print (hero_attribute_names)
    
    if len(hero_attribute_names) > 0:
        for h in heroes:          
            # creating ENGLISH template string
            if templateStringEN is not None:
                template_string_en = templateStringEN
                for i in range(0, len(hero_attribute_names)):
                    template_string_en = template_string_en.replace("$$" + "hero." + hero_attribute_names[i], "{}")
                    print (template_string_en)
                
                for i in range(0, len(hero_attribute_names)):
                    variable = getattr(h, hero_attribute_names[i]) # getting attribute by key
                    template_string_en = template_string_en.format(variable) # replacing each {} with actual value
                    print (template_string_en)
                
            # creating RUSSIAN template string
            if templateStringRU is not None:
                template_string_ru = templateStringRU
                for i in range(0, len(hero_attribute_names)):
                    template_string_ru = template_string_ru.replace("$$" + "hero." + hero_attribute_names[i], "{}")
                
                for i in range(0, len(hero_attribute_names)):
                    variable = getattr(h, hero_attribute_names[i]) # getting attribute by key
                    template_string_ru = template_string_ru.format(variable) # replacing each {} with actual value
            
            # create question
            q = Question()
            q.text_en = template_string_en
            q.text_ru = template_string_ru
            
            print("English: %s" % template_string_en)
            print("Russian: %s" % template_string_ru.decode('utf8'))
            
            questions.append(q)
    
    # [4] serialize questions to json
    # [5] save to file
    print('questions count: %d' % len(questions))
    return questions
        
if (__name__ == "__main__"):
    import sys
    sys.path.append('/home/zykis/DotaAsker/server/')
    sys.path.append('/home/zykis/DotaAsker/server/flask/lib/python2.7/site-packages/')
    
    sys.path.append('/home/artem/projects/DotaAsker/server/')
    sys.path.append('/home/artem/projects/DotaAsker/server/flask/lib/python2.7/site-packages/')
    
    from application.models import Question
    import json
    
    # generateQuestionsFromTemplate(templateStringEN="What is the base strength of the $$hero.name?", templateStringRU="Чему равна базовая сила $$hero.name?", jsonFile="./heroes.json")
    getTemplates()
    
    
    