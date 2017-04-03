class Translation:
    ruDict = dict()
    
    def __init__(self):
        ruDict = read_translation('ru')

    def read_translation(self, locale)
        with open('translation_' + locale + '.txt') as translationFile:
            d = dict()
            for l in translationFile:
                (key, val) = line.split('::')
                d[key] = val
            
        

    def tr(self, text, locale = 'en'):
        if locale == 'ru':
            return ruDict.get(text, text)
        else:
            return text