class parent(object):

	def override(self):
		print("PARENT override()")

	def implicit(self):
		print("PARENT implicit()")

	def altered(self):
		print("PARENT altered()")

class child(parent):

	def override(self):
		print("CHILD override()")

	def altered(self):
		print("CHILD, BEFORE PARENT altered()")
		super(child, self).altered()
		print("CHILD, AFTER PARENT altered()")

dad = parent()
son = child()

dad.implicit()
son.implicit()
print('-' * 10)

dad.altered()
son.altered()
print('-' * 10)

dad.override()
son.override()
print('-' * 10)


class other(object):

	def override(self):
		print("OTHER override")

	def implicit(self):
		print("OTHER implicit")

	def altered(self):
		print("OTHER altered")

class child1(object):

	def __init__(self):
		self.other = other()

	def implicit(self):
		self.other.implicit()

	def altered(self):
		print("CHILD, BEFORE OTHER altered()")
		self.other.altered()
		print("CHILD, AFTER OTHER altered()")

	def override(self):
		print("CHILD override")

daughter = child1()
daughter.implicit()
daughter.altered()
daughter.override()
