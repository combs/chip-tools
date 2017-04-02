import CHIP_IO.GPIO as GPIO

def switches_setup():
	ports=["U14_13","U14_14","U14_15","U14_16"]
	for port in ports:
		try:
			GPIO.setup(port, GPIO.IN)
		except RuntimeError:
			print("Couldn't set up port",port)
			pass

def switches_read():
	value = 0
	if GPIO.input("U14_13"):
		value = value + 1
	if GPIO.input("U14_14"):
		value = value + 2
	if GPIO.input("U14_15"):
		value = value + 4
	if GPIO.input("U14_16"):
		value = value + 8
	return value

if __name__ == '__main__':
	# test code
	switches_setup()
	print(switches_read())
