# Basically success. can process through leaves chain.
# Need to do:
#   Cycle reference check
#   Type check
#   Exception
#   Multiple return values called by key value

class leaf:
	def __init__(self):
		self.isChanged = False
		pass

	def solver(self):
		self.isChanged = False

	def eval(self, arg):
		if isinstance(arg, leaf):
			print("argument is leaf")
			return arg.solver()
		elif isinstance(arg, int):
			print("argument is int")
			return arg
		elif isinstance(arg, float):
			print("argument is float")
			return arg
		else:
			print("invalid type argument")
	
	def returnType(self):
		return None　## return type of value which is returned by solver()

	def setArg(self, value):
		self.checkRefCycle()
		self.isChanged = True
		## Type chech, rise exception if new argument is unacceptable type. 

	def removeArg(self):
		pass ## delete the argument & re-initialize value

	def checkRefCycle(self):
		pass ## Cycle reference check.

class plus(leaf):
	def __init__(self):
		self.argx = 0
		self.argy = 0

	def solver(self):
		return self.eval(self.argx) + self.eval(self.argy)



class minus(leaf):
	def __init__(self):
		self.argx = 1
		self.argy = 1

	def solver(self):
		return self.eval(self.argx) - self.eval(self.argy)


class multiply(leaf):
	def __init__(self):
		self.argx = 0
		self.argy = 0

	def solver(self):
		return self.eval(self.argx) * self.eval(self.argy)

class divide(leaf):
	def __init__(self):
		self.argx = 0
		self.argy = 0

	def solver(self):
		if self.argy == 0:
			print("cannot divide by 0")
		else:
			return self.eval(self.argx) / self.eval(self.argy)



