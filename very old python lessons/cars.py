cars = 100
space_in_a_car = 4.0
drivers = 30
passengers = 90
cars_not_driven = cars - drivers
carpool_capacity = drivers * (space_in_a_car - 1)

print("There are", cars, "cars available")
print("We can transport", carpool_capacity, "people")
