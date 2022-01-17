import unittest
import sys
sys.path.append('/mnt/c/Users/april/Documents/python/projects/skeleton_game/game/')
from circle_area import area
from math import pi

class TestCircleArea(unittest.TestCase):

	def test_area(self):
		self.assertAlmostEqual(area(1), pi)
		self.assertAlmostEqual(area(0), 0)
		self.assertRaises(ValueError, area, -2)
		self.assertRaises(ValueError, area, 3+5j)
		self.assertRaises(ValueError, area, True)
		self.assertRaises(ValueError, area, 'pickles')
