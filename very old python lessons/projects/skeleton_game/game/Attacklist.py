import engine
from textwrap import dedent

class FacePunch(Attack):
	self.base_damage = 1.0
	def attempt(self):
		print(dedent("""Reeling back, you gather as much strength
				as you can and launch into a punch, right
				into his very weird face."""))
		super(FacePunch, self).attempt()

class ScarfKick(Attack):
	self.base_damage = 1.5
	def attempt(self):
		print(dedent("""Quickly, you grab both ends of his overly
				large scarf. You jump up, anchoring yourself
				on his scarf and kick him with all your
				weight."""))
		super(ScarfKick, self).attempt()

class SetFire(Attack):
	self.base_damage = 2.0
	def attempt(self):
		print(dedent("""A lighter sits in his pocket which he uses
				to smoke. You swipe it, and duck under his
				attempts to grab you. You manage to light
				his pant leg on fire. As you run to let the
				fire spread, you smell burning clothes.
				You don't smell burning heir though, he's
				way to bald for that."""))
		super(SetFire, self).attempt()

class CallCavalry(Attack):
	self.base_damage = 1.6
	def attempt(self):
		print(dedent("""Caro the horse lady comes by and sees you
				fighting the marktler. She's weird but
				ultimately a good person, so she helps you
				by running him over."""))
		super(CallCavalry, self).attempt()

class CallLawyer(Attack):
	self.base_damage = 3.0
	def attempt(self):
		print(dedent("""In a swift movement, you whip out your phone
				and call your lawyer. It's super effective!
				He quivers in fear because he knows how
				shady he has been. Your lawyer pulls out a
				mysterious document. You don't entirely know
				what was on the paper, but the look in his
				eyes tells you all you need to know."""))
		super(CallLawyer, self).attempt()
