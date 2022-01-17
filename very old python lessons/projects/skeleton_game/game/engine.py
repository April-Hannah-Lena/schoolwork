from random import randint
from sys import exit

player_health = 100.0
marktler_health = 100.0

class Scene(object):

	def enter(self):
		print("scene not yet configured")
		exit(1)

class Attack(object):

	def attempt(self):
		self.damage = self.base_damage * randint(0, 20)
		print(f"You dealt {self.damage}pts damage")
		marktler_health = marktler_health - self.damage

class Engine(object):

	def __init__(self):
		self.map = map
		player_health = 100.0
		marktler_health = 100.0

	def play(self):
		current_scene = self.map.opening_scene()
#		last_scene = self.map.next_scene('finished')
#
#		while current_scene != last_scene:
#			next_scene_name = current_scene.enter()
#			current_scene = self.map.next_scene(next_scene_name)
#
#	current_scene.enter()
		while (player_health > 0 and marktler_health > 0):
			print('-'*10)
			print("What will you do?")

			self.options = list(attacks.keys())
			self.choices = []
			while len(self.choices) < 3:
				self.choices.append(self.options[randint(0, len(self.choices)-1)])

			print(self.choices)
			self.choice = input('> ')
			self.choices.remove(self.choice)
			attacks.get(self.choice).attempt()

		if marktler_health <= 0:
			print("You win! He's destroyed.")
			exit(1)
		if player_health <= 0:
			print("You died, and you lost your apartment.")
			exit(1)
