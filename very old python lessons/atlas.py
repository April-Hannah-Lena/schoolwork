states = {
	"Oregon": "OR",
	"Florida": "FL",
	'California': 'CA',
	'New York': 'NY',
	'Michigan': 'MI'
}

cities = {
	'CA': 'San Francisco',
	'MI': 'Detroit',
	'FL': 'Jacksonville'
}

cities['NY'] = 'New York City'
cities['OR'] = 'Portland'

print('-' * 10)
for state, abbrev in list(states.items()):
	print(f"{state} is abbreviated {abbrev} and has {cities[abbrev]} in it")

print('-' * 10)
state = states.get('Texas')

if not state:
	print("Sorry, no Texas")
